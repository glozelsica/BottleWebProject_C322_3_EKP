# -*- coding: utf-8 -*-
from bottle import request, template, response
import json
import os
from datetime import datetime
import traceback

# ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ====================

def validate_input_data(c, A, b):
    if not c:
        return False, "Целевая функция не задана"
    if not A:
        return False, "Матрица ограничений пуста"
    m = len(A)
    n = len(c)
    for i, row in enumerate(A):
        if len(row) != n:
            return False, f"Строка {i+1}: ожидалось {n} элементов, получено {len(row)}"
    if len(b) != m:
        return False, f"Размер вектора b ({len(b)}) не соответствует числу строк ({m})"
    return True, "OK"

def to_canonical_form(c, A, b, constraints_types):
    """Приведение к канонической форме с гарантией одинаковой длины строк"""
    m = len(A)
    n = len(c)

    rows_info = []  # (row_coeffs, b_i, has_slack, has_surplus, has_art)
    slack_count = 0
    surplus_count = 0
    artificial_count = 0
    steps = [{'title': 'Приведение к каноническому виду', 'data': {'типы_ограничений': constraints_types}}]

    for i in range(m):
        row = list(A[i])
        rel = constraints_types[i]

        # Нормализация правой части (b_i >= 0)
        if b[i] < 0:
            row = [-x for x in row]
            b_i = -b[i]
            steps.append({'title': f'Ограничение {i+1}: правая часть < 0 → умножено на -1',
                          'data': {'старая_b': b[i], 'новая_b': b_i}})
        else:
            b_i = b[i]

        if rel == '<=':
            slack_count += 1
            rows_info.append((row, b_i, True, False, False))
            steps.append({'title': f'Ограничение {i+1} (≤): добавлена дополнительная переменная s{slack_count}'})
        elif rel == '>=':
            surplus_count += 1
            artificial_count += 1
            rows_info.append((row, b_i, False, True, True))
            steps.append({'title': f'Ограничение {i+1} (≥): добавлены избыточная переменная и искусственная y{artificial_count}'})
        elif rel == '=':
            artificial_count += 1
            rows_info.append((row, b_i, False, False, True))
            steps.append({'title': f'Ограничение {i+1} (=): добавлена искусственная переменная y{artificial_count}'})

    total_vars = n + slack_count + surplus_count + artificial_count
    new_A = []
    new_b = []
    new_c = list(c) + [0.0] * (slack_count + surplus_count + artificial_count)

    # Индексы для добавления специальных переменных
    slack_idx = n
    surplus_idx = n + slack_count
    art_idx = n + slack_count + surplus_count

    for (row, b_i, has_slack, has_surplus, has_art) in rows_info:
        new_row = [0.0] * total_vars
        # Копируем исходные коэффициенты
        for j in range(n):
            new_row[j] = row[j]
        # Добавляем соответствующие переменные
        if has_slack:
            new_row[slack_idx] = 1.0
            slack_idx += 1
        if has_surplus:
            new_row[surplus_idx] = -1.0
            surplus_idx += 1
        if has_art:
            new_row[art_idx] = 1.0
            art_idx += 1
        new_A.append(new_row)
        new_b.append(b_i)

    return {
        'A': new_A, 'b': new_b, 'c': new_c,
        'slack_count': slack_count, 'surplus_count': surplus_count,
        'artificial_count': artificial_count, 'original_n': n,
        'original_m': m, 'steps': steps
    }

def build_tableau(A, b, c):
    m = len(A)
    n = len(A[0])
    tableau = [list(row) + [b[i]] for i, row in enumerate(A)]
    tableau.append([0.0] * (n + 1))
    return tableau

def update_objective_row(tableau, basis, c):
    m = len(tableau) - 1
    n = len(tableau[0]) - 1
    for j in range(n + 1):
        tableau[-1][j] = 0.0

    for j in range(n):
        z_j = 0.0
        for i in range(m):
            bv = basis[i]
            if 0 <= bv < len(c):
                z_j += c[bv] * tableau[i][j]
        c_j = c[j] if j < len(c) else 0.0
        tableau[-1][j] = c_j - z_j

    z_0 = 0.0
    for i in range(m):
        bv = basis[i]
        if 0 <= bv < len(c):
            z_0 += c[bv] * tableau[i][-1]
    tableau[-1][-1] = z_0
    return tableau

def format_tableau(tableau, basis, var_names):
    m = len(tableau) - 1
    n = len(tableau[0]) - 1
    headers = ['Базис', 'b'] + var_names
    rows = []
    for i in range(m):
        b_idx = basis[i]
        basis_name = var_names[b_idx] if 0 <= b_idx < len(var_names) else f'?{b_idx}'
        rows.append({
            'basis': basis_name,
            'b': round(tableau[i][-1], 4),
            'coeffs': [round(tableau[i][j], 4) for j in range(n)]
        })
    obj_row = {
        'basis': 'Δ',
        'b': round(tableau[-1][-1], 4),
        'coeffs': [round(tableau[-1][j], 4) for j in range(n)]
    }
    return {'headers': headers, 'rows': rows, 'obj_row': obj_row}

def format_number(x, precision=6):
    rounded = round(x, precision)
    if abs(rounded) < 1e-9:
        return "0"
    if abs(rounded - round(rounded)) < 1e-9:
        return str(int(round(rounded)))
    return f"{rounded:.{precision}f}".rstrip('0').rstrip('.') if '.' in f"{rounded:.{precision}f}" else f"{rounded:.{precision}f}"

def run_simplex_iterations(tableau, basis, c, var_names, phase, steps, iterations, max_iter=100):
    m = len(tableau) - 1
    n = len(tableau[0]) - 1
    iteration = 0

    while iteration < max_iter:
        last_row = tableau[-1][:-1]
        negative = [(j, val) for j, val in enumerate(last_row) if val < -1e-8]

        if not negative:
            steps.append({'title': f'Фаза {phase}, итерация {iteration}: оптимум достигнут',
                          'data': {'причина': 'Все Δⱼ ≥ 0'}})
            break

        iteration += 1
        pivot_col, pivot_delta = min(negative, key=lambda x: x[1])

        if pivot_col < 0 or pivot_col >= n:
            steps.append({'title': f'Ошибка: некорректный разрешающий столбец {pivot_col}'})
            return {'success': False, 'error': f'Некорректный столбец {pivot_col}'}

        ratios = []
        for i in range(m):
            if tableau[i][pivot_col] > 1e-8:
                ratio = tableau[i][-1] / tableau[i][pivot_col]
                ratios.append((ratio, i))

        if not ratios:
            steps.append({'title': f'Фаза {phase}, итерация {iteration}: задача не ограничена',
                          'data': {'причина': 'Нет положительных элементов в разрешающем столбце'}})
            return {'success': False, 'error': 'Целевая функция не ограничена'}

        min_ratio, pivot_row = min(ratios, key=lambda x: x[0])

        if pivot_row < 0 or pivot_row >= m:
            steps.append({'title': f'Ошибка: некорректный разрешающий строка {pivot_row}'})
            return {'success': False, 'error': f'Некорректная строка {pivot_row}'}

        pivot_val = tableau[pivot_row][pivot_col]
        if abs(pivot_val) < 1e-10:
            steps.append({'title': f'Ошибка: разрешающий элемент близок к нулю'})
            return {'success': False, 'error': 'Разрешающий элемент равен нулю'}

        entering = var_names[pivot_col] if pivot_col < len(var_names) else f'col{pivot_col}'
        leaving = var_names[basis[pivot_row]] if basis[pivot_row] < len(var_names) else f'basis{basis[pivot_row]}'

        steps.append({'title': f'=== Фаза {phase}, Итерация {iteration} ===',
                      'data': {'вводим': f'{entering} (Δ = {pivot_delta:.4f})',
                               'выводим': f'{leaving}',
                               'разрешающий_элемент': f'a[{pivot_row+1},{pivot_col+1}] = {pivot_val:.4f}'}})

        iter_data = {
            'phase': phase, 'iteration': iteration,
            'pivot_col': pivot_col, 'pivot_row': pivot_row, 'pivot_val': pivot_val,
            'entering': entering, 'leaving': leaving,
            'tableau_before': format_tableau(tableau, basis, var_names)
        }

        # Жорданово исключение с проверкой индексов
        try:
            # Нормировка разрешающей строки
            for j in range(n + 1):
                if j >= len(tableau[pivot_row]):
                    raise IndexError(f"Столбец {j} вне строки {pivot_row} длиной {len(tableau[pivot_row])}")
                tableau[pivot_row][j] /= pivot_val

            # Обнуление остальных строк
            for i in range(m + 1):
                if i != pivot_row:
                    factor = tableau[i][pivot_col]
                    for j in range(n + 1):
                        if j >= len(tableau[i]):
                            raise IndexError(f"Столбец {j} вне строки {i} длиной {len(tableau[i])}")
                        tableau[i][j] -= factor * tableau[pivot_row][j]
        except IndexError as e:
            steps.append({'title': f'Ошибка индекса при преобразовании: {str(e)}'})
            return {'success': False, 'error': f'Ошибка индекса: {str(e)}'}

        basis[pivot_row] = pivot_col
        iter_data['tableau_after'] = format_tableau(tableau, basis, var_names)
        iterations.append(iter_data)
        steps.append({'title': f'Таблица после итерации {iteration}',
                      'data': {'tableau': format_tableau(tableau, basis, var_names)}})

    if iteration >= max_iter:
        return {'success': False, 'error': 'Превышено максимальное число итераций'}
    return {'success': True, 'tableau': tableau, 'basis': basis, 'iterations': iteration}

def remove_artificial_vars(tableau, basis, var_names, artificial_start, steps):
    """Удаление искусственных переменных из базиса и столбцов"""
    m = len(tableau) - 1
    n = len(tableau[0]) - 1

    for i in range(m):
        if basis[i] >= artificial_start:
            found = False
            for j in range(artificial_start):
                if abs(tableau[i][j]) > 1e-8:
                    pivot_val = tableau[i][j]
                    for k in range(n + 1):
                        tableau[i][k] /= pivot_val
                    for r in range(m + 1):
                        if r != i:
                            factor = tableau[r][j]
                            for k in range(n + 1):
                                tableau[r][k] -= factor * tableau[i][k]
                    old_basis = basis[i]
                    basis[i] = j
                    steps.append({'title': f'Замена в базисе: {var_names[old_basis]} → {var_names[j]}'})
                    found = True
                    break
            if not found:
                steps.append({'title': f'Строка {i+1} соответствует нулевому ограничению, удаляется'})

    # Удаление столбцов искусственных переменных
    new_tableau = []
    for row in tableau:
        new_row = row[:artificial_start] + [row[-1]]
        new_tableau.append(new_row)
    new_var_names = var_names[:artificial_start]
    # Корректируем базисные индексы, если они ссылались на удалённые столбцы
    for i in range(m):
        if basis[i] >= artificial_start:
            basis[i] = 0  # фиктивный индекс, в реальной задаче такой ситуации быть не должно после замены
    return new_tableau, basis, new_var_names

def simplex_method_full(c, A, b, maximize=True, constraints_types=None):
    if constraints_types is None:
        constraints_types = ['<='] * len(A)

    steps = []
    iterations = []
    def add_step(title, data=None):
        steps.append({'title': title, 'data': data})

    add_step('НАЧАЛО РЕШЕНИЯ', {'c': c, 'A': A, 'b': b,
                               'направление': 'максимизация' if maximize else 'минимизация',
                               'типы_ограничений': constraints_types})

    canon = to_canonical_form(c, A, b, constraints_types)
    for step in canon['steps']:
        add_step(step['title'], step.get('data'))

    new_A = canon['A']
    new_b = canon['b']
    new_c = list(canon['c'])
    m = len(new_A)
    n_total = len(new_A[0])

    var_names = [f'x{i+1}' for i in range(canon['original_n'])]
    var_names += [f's{i+1}' for i in range(canon['slack_count'])]
    var_names += [f'e{i+1}' for i in range(canon['surplus_count'])]
    artificial_start = n_total - canon['artificial_count']
    var_names += [f'y{i+1}' for i in range(canon['artificial_count'])]

    if maximize:
        new_c = [-x for x in new_c]
        add_step('Преобразование в задачу минимизации',
                 {'действие': 'max F → min F\', F\' = -F', 'c_новый': new_c})

    need_two_phase = canon['artificial_count'] > 0

    if need_two_phase:
        add_step('=== ФАЗА 1: Минимизация суммы искусственных переменных ===')
        c1 = [0.0] * n_total
        for j in range(artificial_start, n_total):
            c1[j] = 1.0
        add_step('Целевая функция Фазы 1', {'c': c1})

        basis = []
        for i in range(canon['slack_count']):
            basis.append(canon['original_n'] + i)
        for i in range(canon['artificial_count']):
            basis.append(artificial_start + i)
        add_step('Начальный базис', {'базис': [var_names[b] for b in basis]})

        tableau = build_tableau(new_A, new_b, c1)
        tableau = update_objective_row(tableau, basis, c1)
        add_step('Начальная симплекс-таблица Фазы 1',
                 {'таблица': format_tableau(tableau, basis, var_names)})

        res1 = run_simplex_iterations(tableau, basis, c1, var_names, 1, steps, iterations)
        if not res1['success']:
            return {'success': False, 'error': res1['error'], 'steps': steps, 'iterations': iterations}

        # Пересчитываем строку Δ для точного значения Σy
        tableau = update_objective_row(tableau, basis, c1)

        opt_val = tableau[-1][-1]
        if abs(opt_val) > 1e-6:
            add_step('Система несовместна', {'min_сумма_y': opt_val,
                                            'вывод': 'min Σy > 0 → допустимых решений нет'})
            return {'success': False, 'error': f'Система ограничений несовместна (min Σy = {opt_val:.4f})',
                    'steps': steps, 'iterations': iterations}

        add_step('Фаза 1 завершена успешно', {'min_сумма_y': opt_val,
                                             'вывод': 'min Σy = 0 → допустимое решение найдено'})

        tableau, basis, var_names = remove_artificial_vars(tableau, basis, var_names,
                                                           artificial_start, steps)
        add_step('Столбцы искусственных переменных удалены')

        add_step('=== ФАЗА 2: Решение исходной задачи ===')
        c2 = new_c[:len(var_names)]
        add_step('Целевая функция Фазы 2', {'c': c2})

        tableau = update_objective_row(tableau, basis, c2)
        add_step('Симплекс-таблица Фазы 2',
                 {'таблица': format_tableau(tableau, basis, var_names)})

        res2 = run_simplex_iterations(tableau, basis, c2, var_names, 2, steps, iterations)
        if not res2['success']:
            return {'success': False, 'error': res2['error'], 'steps': steps, 'iterations': iterations}

        # Пересчитываем строку Δ для точного значения F
        tableau = update_objective_row(tableau, basis, c2)

        # Общее количество итераций = сумма итераций обеих фаз
        total_iterations = res1.get('iterations', 0) + res2.get('iterations', 0)

    else:
        add_step('=== ОДНОФАЗНЫЙ МЕТОД ===')
        basis = list(range(canon['original_n'], n_total))
        add_step('Начальный базис', {'базис': [var_names[b] for b in basis]})

        tableau = build_tableau(new_A, new_b, new_c)
        tableau = update_objective_row(tableau, basis, new_c)
        add_step('Начальная симплекс-таблица',
                 {'таблица': format_tableau(tableau, basis, var_names)})

        res = run_simplex_iterations(tableau, basis, new_c, var_names, 1, steps, iterations)
        if not res['success']:
            return {'success': False, 'error': res['error'], 'steps': steps, 'iterations': iterations}
        
        # ✅ ВАЖНО: пересчёт строки Δ для точного значения F
        tableau = update_objective_row(tableau, basis, new_c)
        
        total_iterations = res.get('iterations', 0)

    # Извлечение решения
    solution = [0.0] * canon['original_n']
    for i, bv in enumerate(basis):
        if 0 <= bv < canon['original_n']:
            solution[bv] = tableau[i][-1]

    # Правильное извлечение значения целевой функции
    # Извлечение значения целевой функции
    if maximize:
        # При максимизации мы решали минимизацию с -c, в углу -F
        value = -tableau[-1][-1]
    else:
        # При минимизации в углу F
        value = tableau[-1][-1]
    add_step('=== РЕШЕНИЕ НАЙДЕНО ===', {
        'оптимальный_план': [format_number(x) for x in solution],
        'значение_ЦФ': format_number(value),
        'всего_итераций': total_iterations
    })

    return {
        'success': True,
        'solution': [format_number(x) for x in solution],
        'value': format_number(value),
        'steps': steps,
        'iterations': iterations,
        'total_iterations': total_iterations
    }

def load_theory():
    try:
        json_path = os.path.join('static', 'data', 'theory_direct.json')
        if os.path.exists(json_path):
            with open(json_path, 'r', encoding='utf-8') as f:
                return json.load(f)
    except:
        pass
    return {}

def solve_direct_lp():
    theory = load_theory()
    default_c = "3,5"
    default_rows = 2
    default_cols = 2
    default_sense = "max"
    saved_c = default_c
    saved_rows = default_rows
    saved_cols = default_cols
    saved_sense = default_sense
    saved_A = [[1, 0], [0, 2]]
    saved_b = [4, 12]
    saved_constraints = ['<=', '<=']

    saved_data = request.get_cookie('direct_lp_data')
    if saved_data:
        try:
            saved = json.loads(saved_data)
            saved_c = saved.get('c', default_c)
            saved_rows = saved.get('rows', default_rows)
            saved_cols = saved.get('cols', default_cols)
            saved_sense = saved.get('sense', default_sense)
            if saved.get('A'): saved_A = saved['A']
            if saved.get('b'): saved_b = saved['b']
            if saved.get('constraints'): saved_constraints = saved['constraints']
        except:
            pass

    result = None
    error = None

    if request.method == 'POST':
        try:
            c_str = request.forms.get('c', saved_c)
            c = []
            for x in c_str.split(','):
                try:
                    c.append(float(x.strip()))
                except:
                    pass
            if not c:
                c = [0, 0]
                saved_c = '0,0'
            else:
                saved_c = c_str

            rows = int(request.forms.get('rows', saved_rows))
            cols = int(request.forms.get('cols', saved_cols))
            saved_rows = rows
            saved_cols = cols

            A = []
            for i in range(rows):
                row = []
                for j in range(cols):
                    try:
                        val = float(request.forms.get(f'A_{i}_{j}', '0'))
                    except:
                        val = 0.0
                    row.append(val)
                A.append(row)

            b = []
            constraints = []
            for i in range(rows):
                try:
                    b_val = float(request.forms.get(f'b_{i}', '0'))
                except:
                    b_val = 0.0
                b.append(b_val)
                rel = request.forms.get(f'rel_{i}', '<=')
                constraints.append(rel)

            sense = request.forms.get('sense', 'max') == 'max'
            saved_sense = 'max' if sense else 'min'
            saved_A = A
            saved_b = b
            saved_constraints = constraints

            is_valid, msg = validate_input_data(c, A, b)
            if not is_valid:
                error = msg
            else:
                result = simplex_method_full(c, A, b, sense, constraints)

            save_data = {
                'c': saved_c, 'rows': saved_rows, 'cols': saved_cols,
                'sense': saved_sense, 'A': saved_A, 'b': saved_b,
                'constraints': saved_constraints
            }
            response.set_cookie('direct_lp_data', json.dumps(save_data), path='/')

            if result and result.get('success'):
                os.makedirs('data', exist_ok=True)
                with open('data/history_direct.txt', 'a', encoding='utf-8') as f:
                    f.write(f"\n{'='*60}\n")
                    f.write(f"Дата: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                    f.write(f"c: {c}\nA: {A}\nb: {b}\n")
                    f.write(f"Решение: x = {result['solution']}\nF = {result['value']}\n")
                    f.write(f"Итераций: {result['total_iterations']}\n{'='*60}\n")

        except Exception as e:
            error = f"Ошибка: {str(e)}\n{traceback.format_exc()}"
            result = None

    return template('direct_lp',
                   theory=theory, c=saved_c, rows=saved_rows, cols=saved_cols,
                   sense=saved_sense, result=result, error=error,
                   constraints_types=saved_constraints, A=saved_A, b=saved_b)