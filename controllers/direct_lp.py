from bottle import request, template, response
import json
import os
from datetime import datetime
import csv
from io import StringIO

# ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ====================

def parse_csv_data(file_content, file_type='csv'):
    """Парсинг данных из CSV или Excel файла"""
    try:
        lines = file_content.strip().split('\n')
        # Пропускаем пустые строки
        lines = [line.strip() for line in lines if line.strip()]
        
        if len(lines) < 2:
            return None, "Файл должен содержать хотя бы 2 строки"
        
        # Первая строка - коэффициенты целевой функции
        c_str = lines[0]
        c = []
        for x in c_str.split(','):
            try:
                c.append(float(x.strip()))
            except:
                pass
        
        if not c:
            return None, "Не удалось прочитать коэффициенты целевой функции"
        
        # Остальные строки - матрица A и вектор b
        A = []
        b = []
        constraints = []
        
        for i, line in enumerate(lines[1:], start=1):
            parts = line.split(',')
            if len(parts) < 2:
                continue
            
            # Определяем тип ограничения
            rel = '<='
            if '<=' in line:
                rel = '<='
            elif '>=' in line:
                rel = '>='
            elif '=' in line:
                rel = '='
            
            # Извлекаем числа
            nums = []
            for p in parts:
                p = p.strip().replace('<=', '').replace('>=', '').replace('=', '')
                try:
                    nums.append(float(p))
                except:
                    pass
            
            if len(nums) >= 2:
                A.append(nums[:-1])
                b.append(nums[-1])
                constraints.append(rel)
        
        if not A:
            return None, "Не удалось извлечь матрицу ограничений"
        
        return {
            'c': c,
            'A': A,
            'b': b,
            'constraints': constraints
        }, None
        
    except Exception as e:
        return None, f"Ошибка при разборе файла: {str(e)}"

def validate_input_data(c, A, b):
    """Проверка корректности входных данных"""
    if not c:
        return False, "Целевая функция не задана"
    if not A:
        return False, "Матрица ограничений пуста"
    
    m = len(A)
    n = len(c)
    
    for i, row in enumerate(A):
        if len(row) != n:
            return False, f"Ошибка в строке {i+1}: ожидалось {n} элементов, получено {len(row)}"
    
    if len(b) != m:
        return False, f"Размер вектора b ({len(b)}) не соответствует числу строк ({m})"
    
    return True, "OK"

def to_canonical_form(c, A, b, constraints_types):
    """Приведение к канонической форме"""
    m = len(A)
    n = len(c)
    
    new_A = []
    new_b = []
    new_c = list(c)
    
    slack_count = 0
    artificial_count = 0
    artificial_rows = []
    
    steps = []
    
    steps.append({
        'title': 'Исходные данные',
        'c': c[:],
        'A': [row[:] for row in A],
        'b': b[:],
        'constraints': constraints_types[:]
    })
    
    for i in range(m):
        row = list(A[i])
        rel = constraints_types[i]
        
        if rel == '<=':
            slack_count += 1
            for j in range(len(new_A)):
                new_A[j].append(0)
            row.append(1)
            new_c.append(0)
            new_A.append(row)
            new_b.append(b[i])
            steps.append({
                'title': f'Ограничение {i+1}: добавляем slack-переменную s{slack_count}',
                'action': f'{i+1}-е ограничение типа "≤" → добавляем s{slack_count} с коэффициентом +1'
            })
            
        elif rel == '>=':
            artificial_count += 1
            artificial_rows.append(i)
            for j in range(len(new_A)):
                new_A[j].append(0)  # surplus
                new_A[j].append(0)  # artificial
            row.append(-1)  # surplus
            row.append(1)   # artificial
            new_c.append(0)
            new_c.append(0)
            new_A.append(row)
            new_b.append(b[i])
            steps.append({
                'title': f'Ограничение {i+1}: добавляем surplus и искусственную переменные',
                'action': f'{i+1}-е ограничение типа "≥" → вычитаем s и добавляем y{artificial_count}'
            })
            
        elif rel == '=':
            artificial_count += 1
            artificial_rows.append(i)
            for j in range(len(new_A)):
                new_A[j].append(0)
            row.append(1)
            new_c.append(0)
            new_A.append(row)
            new_b.append(b[i])
            steps.append({
                'title': f'Ограничение {i+1}: добавляем искусственную переменную',
                'action': f'{i+1}-е ограничение типа "=" → добавляем y{artificial_count}'
            })
    
    # Нормализация b
    for i in range(m):
        if new_b[i] < 0:
            new_A[i] = [-x for x in new_A[i]]
            new_b[i] = -new_b[i]
            steps.append({
                'title': f'Нормализация правой части {i+1}',
                'action': f'b[{i+1}] < 0 → умножаем уравнение на -1'
            })
    
    steps.append({
        'title': 'Каноническая форма',
        'c': new_c[:],
        'A': [row[:] for row in new_A],
        'b': new_b[:]
    })
    
    return {
        'A': new_A,
        'b': new_b,
        'c': new_c,
        'slack_count': slack_count,
        'artificial_count': artificial_count,
        'artificial_rows': artificial_rows,
        'original_n': n,
        'original_m': m,
        'steps': steps
    }

def simplex_solver(c, A, b, maximize=True, constraints_types=None):
    """
    Симплекс-метод с подробным пошаговым выводом
    """
    if constraints_types is None:
        constraints_types = ['<='] * len(A)
    
    # Логи
    all_steps = []
    iterations = []
    
    def add_step(title, data=None, action=None):
        all_steps.append({
            'title': title,
            'data': data,
            'action': action
        })
    
    add_step('НАЧАЛО РЕШЕНИЯ', {
        'c': c[:],
        'A': [row[:] for row in A],
        'b': b[:],
        'maximize': maximize,
        'constraints': constraints_types
    })
    
    # Шаг 1: Приведение к канонической форме
    add_step('ШАГ 1: Приведение к канонической форме')
    canon = to_canonical_form(c, A, b, constraints_types)
    
    for step in canon['steps']:
        add_step(step['title'], step.get('data'), step.get('action'))
    
    new_A = canon['A']
    new_b = canon['b']
    new_c = list(canon['c'])
    m = len(new_A)
    n = len(new_A[0])
    
    # Если максимизация - преобразуем
    if maximize:
        new_c = [-x for x in new_c]
        add_step('Преобразование в задачу минимизации', {
            'action': 'max F → min F\', F\' = -F',
            'c_new': new_c
        })
    
    # Определяем, нужен ли двухфазный метод
    need_two_phase = canon['artificial_count'] > 0
    
    if need_two_phase:
        add_step('Требуется двухфазный метод', {
            'reason': f'Есть {canon["artificial_count"]} искусственных переменных'
        })
        
        # ========== ФАЗА 1 ==========
        add_step('=== ФАЗА 1: Минимизация суммы искусственных переменных ===')
        
        # Целевая функция фазы 1
        c1 = [0] * n
        artificial_start = n - canon['artificial_count']
        for j in range(artificial_start, n):
            c1[j] = 1
        
        add_step('Целевая функция Фазы 1', {
            'description': 'min Σyᵢ',
            'c1': c1
        })
        
        # Начальный базис
        basis = []
        for i in range(canon['slack_count']):
            basis.append(canon['original_n'] + i)
        for i in range(canon['artificial_count']):
            basis.append(artificial_start + i)
        
        add_step('Начальный базис', {
            'basis': basis,
            'basis_names': [get_var_name(j, canon) for j in basis]
        })
        
        # Строим таблицу
        tableau = build_tableau(new_A, new_b, c1)
        
        # Вычисляем индексную строку
        tableau = update_objective_row(tableau, basis, c1)
        
        add_step('Начальная симплекс-таблица Фазы 1', {
            'tableau': format_tableau(tableau, basis, canon)
        })
        
        # Итерации фазы 1
        result1 = run_iterations(tableau, basis, c1, canon, 1, add_step, iterations)
        
        if not result1['success']:
            return {
                'success': False,
                'error': result1['error'],
                'steps': all_steps,
                'iterations': iterations
            }
        
        tableau = result1['tableau']
        basis = result1['basis']
        
        # Проверка min Σyᵢ = 0
        opt_val = tableau[-1][-1]
        if abs(opt_val) > 1e-8:
            add_step('Система несовместна', {
                'min_sum_y': opt_val,
                'conclusion': 'min Σyᵢ > 0 → нет допустимых решений'
            })
            return {
                'success': False,
                'error': f'Система ограничений несовместна (min Σyᵢ = {opt_val:.4f} > 0)',
                'steps': all_steps,
                'iterations': iterations
            }
        
        add_step('Фаза 1 завершена успешно', {
            'min_sum_y': opt_val,
            'conclusion': 'min Σyᵢ = 0 → допустимое решение найдено'
        })
        
        # Удаляем искусственные переменные из базиса
        tableau, basis = remove_artificial_from_basis(tableau, basis, canon, add_step)
        
        # Удаляем столбцы искусственных переменных
        new_tableau = []
        for row in tableau:
            new_row = row[:artificial_start] + [row[-1]]
            new_tableau.append(new_row)
        tableau = new_tableau
        
        add_step('Столбцы искусственных переменных удалены', {
            'new_size': f'{len(tableau)} × {len(tableau[0])}'
        })
        
        # ========== ФАЗА 2 ==========
        add_step('=== ФАЗА 2: Решение исходной задачи ===')
        
        # Восстанавливаем целевую функцию
        c2 = list(canon['c'])
        if maximize:
            c2 = [-x for x in c2]
        
        add_step('Целевая функция Фазы 2', {
            'c2': c2[:canon['original_n']],
            'description': 'Исходная целевая функция'
        })
        
        # Обновляем индексную строку
        tableau = update_objective_row(tableau, basis, c2[:len(tableau[0])-1])
        
        add_step('Симплекс-таблица Фазы 2', {
            'tableau': format_tableau_short(tableau, basis, canon)
        })
        
        # Итерации фазы 2
        result2 = run_iterations(tableau, basis, c2[:len(tableau[0])-1], canon, 2, add_step, iterations)
        
        if not result2['success']:
            return {
                'success': False,
                'error': result2['error'],
                'steps': all_steps,
                'iterations': iterations
            }
        
        tableau = result2['tableau']
        basis = result2['basis']
        
    else:
        # ========== ОДНОФАЗНЫЙ МЕТОД ==========
        add_step('Однофазный метод (искусственных переменных нет)')
        
        basis = list(range(canon['original_n'], n))
        
        add_step('Начальный базис', {
            'basis': basis,
            'basis_names': [f's{i+1}' for i in range(len(basis))]
        })
        
        tableau = build_tableau(new_A, new_b, new_c)
        tableau = update_objective_row(tableau, basis, new_c)
        
        add_step('Начальная симплекс-таблица', {
            'tableau': format_tableau(tableau, basis, canon)
        })
        
        result = run_iterations(tableau, basis, new_c, canon, 1, add_step, iterations)
        
        if not result['success']:
            return {
                'success': False,
                'error': result['error'],
                'steps': all_steps,
                'iterations': iterations
            }
        
        tableau = result['tableau']
        basis = result['basis']
    
    # Извлекаем решение
    solution = [0] * canon['original_n']
    for i, bv in enumerate(basis):
        if bv < canon['original_n']:
            solution[bv] = tableau[i][-1]
    
    value = tableau[-1][-1]
    if maximize:
        value = -value
    
    add_step('=== РЕШЕНИЕ НАЙДЕНО ===', {
        'solution': solution,
        'value': value,
        'total_iterations': len([it for it in iterations if it.get('phase') in [1, 2]])
    })
    
    return {
        'success': True,
        'solution': [round(x, 6) for x in solution],
        'value': round(value, 6),
        'steps': all_steps,
        'iterations': iterations,
        'total_iterations': len(iterations)
    }

def build_tableau(A, b, c):
    """Построение симплекс-таблицы"""
    m = len(A)
    n = len(A[0])
    
    tableau = []
    for i in range(m):
        row = list(A[i]) + [b[i]]
        tableau.append(row)
    
    obj_row = [0] * (n + 1)
    tableau.append(obj_row)
    
    return tableau

def update_objective_row(tableau, basis, c):
    """Обновление индексной строки"""
    m = len(tableau) - 1
    n = len(tableau[0]) - 1
    
    for j in range(n + 1):
        tableau[-1][j] = 0
    
    for j in range(n):
        z_j = 0
        for i in range(m):
            if basis[i] < len(c):
                z_j += c[basis[i]] * tableau[i][j]
        tableau[-1][j] = z_j - (c[j] if j < len(c) else 0)
    
    z_0 = 0
    for i in range(m):
        if basis[i] < len(c):
            z_0 += c[basis[i]] * tableau[i][-1]
    tableau[-1][-1] = z_0
    
    return tableau

def run_iterations(tableau, basis, c, canon, phase, add_step, iterations):
    """Выполнение итераций симплекс-метода"""
    m = len(tableau) - 1
    n = len(tableau[0]) - 1
    iteration = 0
    max_iter = 50
    
    while iteration < max_iter:
        # Проверка оптимальности
        last_row = tableau[-1][:-1]
        negative = []
        for j, val in enumerate(last_row):
            if val < -1e-8:
                negative.append((j, val))
        
        if not negative:
            add_step(f'Итерация {iteration}: достигнут оптимум', {
                'reason': 'Все Δⱼ ≥ 0'
            })
            break
        
        iteration += 1
        
        # Выбор разрешающего столбца
        pivot_col, pivot_delta = min(negative, key=lambda x: x[1])
        
        # Вычисление симплекс-отношений
        ratios = []
        for i in range(m):
            if tableau[i][pivot_col] > 1e-8:
                ratio = tableau[i][-1] / tableau[i][pivot_col]
                ratios.append((ratio, i))
        
        if not ratios:
            add_step(f'Итерация {iteration}: задача не ограничена', {
                'reason': 'Все Θᵢ = ∞'
            })
            return {
                'success': False,
                'error': 'Целевая функция не ограничена'
            }
        
        # Выбор разрешающей строки
        min_ratio, pivot_row = min(ratios, key=lambda x: x[0])
        pivot_val = tableau[pivot_row][pivot_col]
        
        # Сохраняем данные итерации
        entering_var = get_var_name(pivot_col, canon)
        leaving_var = get_var_name(basis[pivot_row], canon) if basis[pivot_row] < len(c) else f"x{basis[pivot_row]+1}"
        
        iter_data = {
            'phase': phase,
            'iteration': iteration,
            'pivot_col': pivot_col,
            'pivot_row': pivot_row,
            'pivot_val': pivot_val,
            'delta': pivot_delta,
            'ratios': [{'value': r[0], 'row': r[1]} for r in ratios],
            'entering_var': entering_var,
            'leaving_var': leaving_var,
            'tableau_before': [row[:] for row in tableau],
            'basis_before': basis[:]
        }
        
        add_step(f'=== Фаза {phase}, Итерация {iteration} ===', {
            'entering': f'Вводим {entering_var} (Δ = {pivot_delta:.4f})',
            'leaving': f'Выводим {leaving_var} (Θ = {min_ratio:.4f})',
            'pivot_element': f'a_{pivot_row},{pivot_col} = {pivot_val:.4f}',
            'ratios': [f'Θ{i} = {r:.4f}' for i, r in enumerate([t[-1]/t[pivot_col] if t[pivot_col] > 1e-8 else float("inf") for t in tableau[:m]])]
        })
        
        # Жорданово исключение
        for j in range(n + 1):
            tableau[pivot_row][j] /= pivot_val
        
        for i in range(m + 1):
            if i != pivot_row:
                factor = tableau[i][pivot_col]
                for j in range(n + 1):
                    tableau[i][j] -= factor * tableau[pivot_row][j]
        
        basis[pivot_row] = pivot_col
        
        iter_data['tableau_after'] = [row[:] for row in tableau]
        iter_data['basis_after'] = basis[:]
        iterations.append(iter_data)
        
        add_step(f'Таблица после итерации {iteration}', {
            'tableau': format_tableau_short(tableau, basis, canon)
        })
    
    if iteration >= max_iter:
        return {
            'success': False,
            'error': 'Превышено максимальное число итераций'
        }
    
    return {
        'success': True,
        'tableau': tableau,
        'basis': basis
    }

def remove_artificial_from_basis(tableau, basis, canon, add_step):
    """Удаление искусственных переменных из базиса"""
    m = len(tableau) - 1
    n = len(tableau[0]) - 1
    artificial_start = len(canon['c']) - canon['artificial_count']
    
    for i in range(m):
        if basis[i] >= artificial_start:
            # Ищем неискусственную переменную с ненулевым коэффициентом
            found = False
            for j in range(artificial_start):
                if abs(tableau[i][j]) > 1e-8:
                    # Делаем замену
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
                    
                    add_step(f'Замена в базисе', {
                        'action': f'Искусственная переменная y{old_basis - artificial_start + 1} заменена на {get_var_name(j, canon)}'
                    })
                    found = True
                    break
            
            if not found:
                # Строка нулевая - можно удалить
                add_step(f'Удаление нулевой строки', {
                    'action': f'Строка {i} соответствует нулевому ограничению, удаляется'
                })
    
    return tableau, basis

def get_var_name(idx, canon):
    """Получение имени переменной"""
    if idx < canon['original_n']:
        return f'x{idx + 1}'
    elif idx < canon['original_n'] + canon['slack_count']:
        return f's{idx - canon["original_n"] + 1}'
    else:
        return f'y{idx - canon["original_n"] - canon["slack_count"] + 1}'

def format_tableau(tableau, basis, canon):
    """Форматирование таблицы для вывода"""
    m = len(tableau) - 1
    n = len(tableau[0]) - 1
    
    result = {
        'headers': ['Базис', 'b'] + [get_var_name(j, canon) for j in range(n)],
        'rows': []
    }
    
    for i in range(m):
        basis_name = get_var_name(basis[i], canon) if basis[i] < len(canon['c']) else f'x{basis[i]+1}'
        row = {
            'basis': basis_name,
            'b': round(tableau[i][-1], 4),
            'coeffs': [round(tableau[i][j], 4) for j in range(n)]
        }
        result['rows'].append(row)
    
    result['obj_row'] = {
        'basis': 'Δ',
        'b': round(tableau[-1][-1], 4),
        'coeffs': [round(tableau[-1][j], 4) for j in range(n)]
    }
    
    return result

def format_tableau_short(tableau, basis, canon):
    """Краткое форматирование таблицы"""
    return format_tableau(tableau, basis, canon)

def load_theory():
    """Загрузка теоретических данных"""
    try:
        json_path = os.path.join('static', 'data', 'theory_direct.json')
        if os.path.exists(json_path):
            with open(json_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}
    except:
        return {}

def solve_direct_lp():
    theory = load_theory()
    
    default_c = "3,5"
    default_rows = 2
    default_cols = 2
    default_sense = "max"
    
    saved_A = [[1, 0], [0, 2]]
    saved_b = [4, 12]
    saved_constraints = ['<=', '<=']
    saved_c = default_c
    saved_rows = default_rows
    saved_cols = default_cols
    saved_sense = default_sense
    
    saved_data = request.get_cookie('direct_lp_data')
    if saved_data:
        try:
            saved = json.loads(saved_data)
            saved_c = saved.get('c', default_c)
            saved_rows = saved.get('rows', default_rows)
            saved_cols = saved.get('cols', default_cols)
            saved_sense = saved.get('sense', default_sense)
            if saved.get('A'):
                saved_A = saved['A']
            if saved.get('b'):
                saved_b = saved['b']
            if saved.get('constraints'):
                saved_constraints = saved['constraints']
        except:
            pass
    
    result = None
    error = None
    file_error = None
    
    if request.method == 'POST':
        try:
            # Проверяем, был ли загружен файл
            file_upload = request.files.get('data_file')
            
            if file_upload and file_upload.filename:
                file_content = file_upload.file.read().decode('utf-8')
                parsed, file_error = parse_csv_data(file_content)
                
                if parsed:
                    c_list = parsed['c']
                    A_list = parsed['A']
                    b_list = parsed['b']
                    constraints_list = parsed.get('constraints', ['<='] * len(A_list))
                    
                    saved_c = ','.join(str(x) for x in c_list)
                    saved_rows = len(A_list)
                    saved_cols = len(c_list)
                    saved_A = A_list
                    saved_b = b_list
                    saved_constraints = constraints_list
                    
                    c = c_list
                    A = A_list
                    b = b_list
                    constraints_types = constraints_list
                    sense = saved_sense == 'max'
                else:
                    error = file_error
                    c = [0, 0]
                    A = saved_A
                    b = saved_b
                    constraints_types = saved_constraints
                    sense = saved_sense == 'max'
            else:
                # Данные из формы
                c_str = request.forms.get('c', saved_c)
                c = []
                for x in c_str.split(','):
                    try:
                        c.append(float(x.strip()))
                    except:
                        pass
                if not c:
                    c = [0, 0]
                
                rows = int(request.forms.get('rows', saved_rows))
                cols = int(request.forms.get('cols', saved_cols))
                
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
                constraints_types = []
                for i in range(rows):
                    try:
                        val = float(request.forms.get(f'b_{i}', '0'))
                    except:
                        val = 0.0
                    b.append(val)
                    rel = request.forms.get(f'rel_{i}', '<=')
                    constraints_types.append(rel)
                
                sense = request.forms.get('sense', 'max') == 'max'
                
                saved_c = c_str
                saved_rows = rows
                saved_cols = cols
                saved_sense = 'max' if sense else 'min'
                saved_A = A
                saved_b = b
                saved_constraints = constraints_types
            
            # Проверка данных
            is_valid, msg = validate_input_data(c, A, b)
            if not is_valid:
                error = msg
            else:
                result = simplex_solver(c, A, b, maximize=sense, constraints_types=constraints_types)
            
            # Сохраняем в cookie
            save_data = {
                'c': saved_c,
                'rows': saved_rows,
                'cols': saved_cols,
                'sense': saved_sense,
                'A': saved_A,
                'b': saved_b,
                'constraints': saved_constraints
            }
            response.set_cookie('direct_lp_data', json.dumps(save_data), path='/')
            
            # История
            if result and result.get('success'):
                os.makedirs('data', exist_ok=True)
                with open('data/history_direct.txt', 'a', encoding='utf-8') as f:
                    f.write(f"\n{'='*60}\n")
                    f.write(f"Дата: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                    f.write(f"c: {c}\n")
                    f.write(f"A: {A}\n")
                    f.write(f"b: {b}\n")
                    f.write(f"Решение: x = {result['solution']}\n")
                    f.write(f"F = {result['value']}\n")
                    f.write(f"Итераций: {result['total_iterations']}\n")
                    f.write(f"{'='*60}\n")
            
        except Exception as e:
            error = f"Ошибка: {str(e)}"
            result = None
    
    return template('direct_lp',
                   theory=theory,
                   c=saved_c,
                   rows=saved_rows,
                   cols=saved_cols,
                   sense=saved_sense,
                   result=result,
                   error=error,
                   file_error=file_error,
                   constraints_types=saved_constraints,
                   A=saved_A,
                   b=saved_b)