# -*- coding: utf-8 -*-


from bottle import request, template, response
import json
import os
from datetime import datetime
import traceback

# ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ====================

def validate_input_data(c, A, b):
    """
    Проверяет согласованность размерностей входных данных:
    - Вектор коэффициентов целевой функции c должен быть непустым.
    - Матрица ограничений A не должна быть пустой.
    - Каждая строка матрицы A должна иметь столько же элементов, сколько переменных в c.
    - Длина вектора правых частей b должна совпадать с количеством строк A.
    
    Возвращает кортеж (True/False, сообщение).
    """
    if not c:
        return False, "Целевая функция не задана"
    if not A:
        return False, "Матрица ограничений пуста"
    m = len(A)          # количество ограничений (строк)
    n = len(c)          # количество переменных (столбцов)
    
    for i, row in enumerate(A):
        if len(row) != n:
            return False, f"Строка {i+1}: ожидалось {n} элементов, получено {len(row)}"
    
    if len(b) != m:
        return False, f"Размер вектора b ({len(b)}) не соответствует числу строк ({m})"
    
    return True, "OK"


def to_canonical_form(c, A, b, constraints_types):
    """
    Преобразует исходную задачу ЛП в каноническую форму, требуемую для симплекс-метода.
    Каноническая форма подразумевает:
        - Все ограничения – равенства (Ax = b).
        - Все переменные неотрицательны (x ≥ 0).
        - Все правые части b_i ≥ 0.
    
    В зависимости от типа ограничения вводятся дополнительные переменные:
        - ≤ : добавляется дополнительная (slack) переменная s_i с коэффициентом +1.
        - ≥ : добавляется избыточная (surplus) переменная e_i с коэффициентом -1
              и искусственная (artificial) переменная y_i с коэффициентом +1.
        - = : добавляется только искусственная переменная y_i.
    
    Возвращает словарь с расширенными матрицами и счётчиками переменных.
    """
    m = len(A)
    n = len(c)

    rows_info = []          # список для хранения информации о каждом ограничении
    slack_count = 0
    surplus_count = 0
    artificial_count = 0
    steps = [{'title': 'Приведение к каноническому виду', 'data': {'типы_ограничений': constraints_types}}]

    for i in range(m):
        row = list(A[i])
        rel = constraints_types[i]

        # Приведение правой части к неотрицательному виду (умножение на -1 при b_i < 0)
        if b[i] < 0:
            row = [-x for x in row]
            b_i = -b[i]
            steps.append({'title': f'Ограничение {i+1}: правая часть < 0 → умножено на -1',
                          'data': {'старая_b': b[i], 'новая_b': b_i}})
        else:
            b_i = b[i]

        # Обработка по типу ограничения
        if rel == '<=':
            slack_count += 1
            rows_info.append((row, b_i, True, False, False))
            steps.append({'title': f'Ограничение {i+1} (≤): добавлена дополнительная переменная s{slack_count}'})
        elif rel == '>=':
            surplus_count += 1
            artificial_count += 1
            rows_info.append((row, b_i, False, True, True))
            steps.append({'title': f'Ограничение {i+1} (≥): добавлены избыточная переменная e{surplus_count} и искусственная y{artificial_count}'})
        elif rel == '=':
            artificial_count += 1
            rows_info.append((row, b_i, False, False, True))
            steps.append({'title': f'Ограничение {i+1} (=): добавлена искусственная переменная y{artificial_count}'})

    total_vars = n + slack_count + surplus_count + artificial_count
    new_A = []
    new_b = []
    # Расширенный вектор целевой функции: для s_i и e_i коэффициенты = 0,
    # для y_i в фазе 1 будут 1, в фазе 2 – 0.
    new_c = list(c) + [0.0] * (slack_count + surplus_count + artificial_count)

    # Индексы для вставки столбцов новых переменных
    slack_idx = n
    surplus_idx = n + slack_count
    art_idx = n + slack_count + surplus_count

    # Формирование строк расширенной матрицы A
    for (row, b_i, has_slack, has_surplus, has_art) in rows_info:
        new_row = [0.0] * total_vars
        for j in range(n):
            new_row[j] = row[j]
        if has_slack:
            new_row[slack_idx] = 1.0
            slack_idx += 1
        if has_surplus:
            new_row[surplus_idx] = -1.0   # избыточная переменная входит с коэффициентом -1
            surplus_idx += 1
        if has_art:
            new_row[art_idx] = 1.0        # искусственная переменная входит с коэффициентом +1
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
    """
    Строит начальную симплекс-таблицу (матрицу коэффициентов с добавочным столбцом b).
    Формат таблицы:
        Первые m строк: коэффициенты ограничений A и столбец b.
        Последняя (m+1)-я строка: строка оценок Δ (целевая функция).
    """
    m = len(A)
    n = len(A[0])
    tableau = [list(row) + [b[i]] for i, row in enumerate(A)]
    tableau.append([0.0] * (n + 1))   # строка для Δ
    return tableau


def update_objective_row(tableau, basis, c):
    """
    Пересчитывает строку оценок (Δ-строку) симплекс-таблицы.
    Для каждого столбца j вычисляется:
        z_j = Σ_{i=1..m} c[базис_i] * a_ij
        Δ_j = c_j - z_j
    Также вычисляется текущее значение целевой функции:
        Z = Σ_{i=1..m} c[базис_i] * b_i
    и помещается в правый нижний угол таблицы (со знаком, соответствующим минимизации).
    """
    m = len(tableau) - 1
    n = len(tableau[0]) - 1
    
    # Обнуляем строку оценок
    for j in range(n + 1):
        tableau[-1][j] = 0.0

    # Вычисляем Δ_j
    for j in range(n):
        z_j = 0.0
        for i in range(m):
            bv = basis[i]
            if 0 <= bv < len(c):
                z_j += c[bv] * tableau[i][j]
        c_j = c[j] if j < len(c) else 0.0
        tableau[-1][j] = c_j - z_j

    # Вычисляем текущее значение ЦФ
    z_0 = 0.0
    for i in range(m):
        bv = basis[i]
        if 0 <= bv < len(c):
            z_0 += c[bv] * tableau[i][-1]
    tableau[-1][-1] = z_0
    
    return tableau


def format_tableau(tableau, basis, var_names):
    """
    Преобразует числовую симплекс-таблицу в удобный для отображения словарь.
    Округляет значения до 4 знаков после запятой для читаемости.
    """
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
    """
    Форматирует число для вывода в интерфейсе:
    - числа, близкие к нулю (в пределах 1e-9), выводятся как "0";
    - целые числа выводятся без десятичной точки;
    - дробные округляются до указанной точности, удаляются незначащие нули.
    """
    rounded = round(x, precision)
    if abs(rounded) < 1e-9:
        return "0"
    if abs(rounded - round(rounded)) < 1e-9:
        return str(int(round(rounded)))
    return f"{rounded:.{precision}f}".rstrip('0').rstrip('.') if '.' in f"{rounded:.{precision}f}" else f"{rounded:.{precision}f}"


def run_simplex_iterations(tableau, basis, c, var_names, phase, steps, iterations, max_iter=100):
    """
    Выполняет итерации симплекс-метода для текущей фазы (однофазный или вторая фаза двухфазного метода).
    На каждой итерации:
        1. Анализирует строку Δ: ищет отрицательные оценки (для минимизации).
           ВАЖНОЕ ИСПРАВЛЕНИЕ: пропускает столбцы, соответствующие переменным, уже находящимся в базисе.
           Это предотвращает выбор в качестве вводимой переменной той, что уже есть в базисе,
           что могло бы привести к дублированию и нарушению структуры базиса.
        2. Если все Δ_j ≥ 0, текущее базисное решение оптимально – завершение.
        3. Выбирает разрешающий столбец (pivot column) с минимальной (самой отрицательной) оценкой.
        4. Вычисляет симплекс-отношения θ_i = b_i / a_i,pivot для a_i,pivot > 0.
        5. Если нет положительных a_i,pivot, задача не ограничена – ошибка.
        6. Выбирает разрешающую строку с минимальным θ (правило Бленда для предотвращения зацикливания).
        7. Выполняет преобразование Жордана-Гаусса: нормирует разрешающую строку и обнуляет остальные.
        8. Обновляет базис: заменяет выводимую переменную на вводимую.
        9. Сохраняет состояние до и после итерации для отображения.
    """
    m = len(tableau) - 1
    n = len(tableau[0]) - 1
    iteration = 0

    while iteration < max_iter:
        last_row = tableau[-1][:-1]
        
        # --- КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: исключаем базисные переменные из кандидатов на ввод ---
        negative = []
        for j, val in enumerate(last_row):
            if val < -1e-8:      # числовой допуск для отрицательности
                # Пропускаем столбцы, соответствующие переменным, которые уже являются базисными
                if j not in basis:
                    negative.append((j, val))
                else:
                    # Логируем пропуск для прозрачности
                    steps.append({
                        'title': f'Пропуск столбца {var_names[j]} (Δ={val:.4f}) – уже в базисе'
                    })
        # --------------------------------------------------------------------------------

        if not negative:
            steps.append({
                'title': f'Фаза {phase}, итерация {iteration}: оптимум достигнут',
                'data': {'причина': 'Все Δⱼ ≥ 0 для небазисных переменных'}
            })
            break

        iteration += 1
        # Выбор вводимой переменной: столбец с минимальным Δ (наиболее отрицательным)
        pivot_col, pivot_delta = min(negative, key=lambda x: x[1])

        if pivot_col < 0 or pivot_col >= n:
            steps.append({'title': f'Ошибка: некорректный разрешающий столбец {pivot_col}'})
            return {'success': False, 'error': f'Некорректный столбец {pivot_col}'}

        # Вычисление симплекс-отношений
        ratios = []
        for i in range(m):
            if tableau[i][pivot_col] > 1e-8:
                ratio = tableau[i][-1] / tableau[i][pivot_col]
                ratios.append((ratio, i))

        if not ratios:
            steps.append({'title': f'Фаза {phase}, итерация {iteration}: задача не ограничена',
                          'data': {'причина': 'Нет положительных элементов в разрешающем столбце'}})
            return {'success': False, 'error': 'Целевая функция не ограничена'}

        # Выбор выводимой переменной по минимальному отношению
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

        # Преобразование таблицы (шаг Жордана-Гаусса)
        try:
            # Нормируем разрешающую строку
            for j in range(n + 1):
                tableau[pivot_row][j] /= pivot_val

            # Обнуляем остальные строки в разрешающем столбце
            for i in range(m + 1):
                if i != pivot_row:
                    factor = tableau[i][pivot_col]
                    for j in range(n + 1):
                        tableau[i][j] -= factor * tableau[pivot_row][j]
        except IndexError as e:
            steps.append({'title': f'Ошибка индекса при преобразовании: {str(e)}'})
            return {'success': False, 'error': f'Ошибка индекса: {str(e)}'}

        # Обновление базиса
        basis[pivot_row] = pivot_col
        iter_data['tableau_after'] = format_tableau(tableau, basis, var_names)
        iterations.append(iter_data)
        steps.append({'title': f'Таблица после итерации {iteration}',
                      'data': {'tableau': format_tableau(tableau, basis, var_names)}})

    if iteration >= max_iter:
        return {'success': False, 'error': 'Превышено максимальное число итераций'}
    return {'success': True, 'tableau': tableau, 'basis': basis, 'iterations': iteration}


def remove_artificial_vars(tableau, basis, var_names, artificial_start, steps):
    """
    Удаляет искусственные переменные после успешного завершения первой фазы двухфазного метода.
    Эта процедура критически важна для корректного перехода ко второй фазе.

    Шаги:
    1. Замена искусственных переменных, оставшихся в базисе, на натуральные переменные.
       Для каждой строки, где базисная переменная является искусственной (индекс ≥ artificial_start):
           - Ищется натуральная переменная (индекс < artificial_start), имеющая ненулевой коэффициент
             в этой строке и при этом ещё не находящаяся в базисе.
           - Если такая найдена, выполняется шаг Жордана-Гаусса, чтобы ввести её в базис вместо искусственной.
           - Если подходящей переменной нет, строка будет удалена (это возможно, если ограничение было избыточным).
    2. Удаление строк, где всё ещё остались искусственные переменные в базисе (такие строки соответствуют
       ограничениям, которые не повлияли на допустимую область и могут быть исключены).
    3. Удаление столбцов, соответствующих всем искусственным переменным (с индексами ≥ artificial_start).
    4. Удаление возможных дубликатов базисных переменных (ситуация, которая могла возникнуть из-за
       вырожденности, но исправление в run_simplex_iterations практически исключает её).
    """
    m = len(tableau) - 1
    n = len(tableau[0]) - 1

    # Рабочие копии, чтобы не испортить исходные данные
    tab = [row[:] for row in tableau]
    bas = basis[:]

    # 1. Замена искусственных переменных в базисе на натуральные
    for i in range(m):
        if bas[i] >= artificial_start:                     # в базисе искусственная переменная
            pivot_col = -1
            # Ищем натуральную переменную, которой ЕЩЁ НЕТ в базисе
            for j in range(artificial_start):
                if abs(tab[i][j]) > 1e-8 and j not in bas:
                    pivot_col = j
                    break
            if pivot_col == -1:
                steps.append({
                    'title': f'Строка {i+1} (была {var_names[bas[i]]}) удалена – нет подходящей замены'
                })
                continue  # эту строку позже удалим

            # Выполняем замену (pivot) – аналогично итерации симплекс-метода
            pivot_val = tab[i][pivot_col]
            for j in range(n + 1):
                tab[i][j] /= pivot_val
            for r in range(m + 1):
                if r != i:
                    factor = tab[r][pivot_col]
                    for j in range(n + 1):
                        tab[r][j] -= factor * tab[i][j]
            old_basis = bas[i]
            bas[i] = pivot_col
            steps.append({
                'title': f'Замена искусственной переменной {var_names[old_basis]} на натуральную {var_names[pivot_col]}'
            })

    # 2. Удаление строк, где всё ещё остались искусственные переменные в базисе
    rows_to_keep = []
    basis_to_keep = []
    for i in range(m):
        if bas[i] < artificial_start:
            rows_to_keep.append(tab[i])
            basis_to_keep.append(bas[i])
        else:
            steps.append({
                'title': f'Строка {i+1} с искусственной переменной {var_names[bas[i]]} удалена'
            })

    # 3. Удаление столбцов искусственных переменных
    new_tableau = []
    for row in rows_to_keep:
        new_tableau.append(row[:artificial_start] + [row[-1]])
    new_tableau.append(tab[-1][:artificial_start] + [tab[-1][-1]])

    new_var_names = var_names[:artificial_start]

    # 4. Удаление возможных дубликатов в базисе (на всякий случай)
    seen = set()
    final_basis = []
    final_rows = []
    for i, bv in enumerate(basis_to_keep):
        if bv not in seen:
            seen.add(bv)
            final_basis.append(bv)
            final_rows.append(new_tableau[i])
        else:
            steps.append({
                'title': f'Предупреждение: дубликат переменной {new_var_names[bv]} удалён'
            })

    new_tableau = final_rows + [new_tableau[-1]]
    return new_tableau, final_basis, new_var_names


def simplex_method_full(c, A, b, maximize=True, constraints_types=None):
    """
    Главная точка входа для решения задачи ЛП симплекс-методом.

    Алгоритм:
    1. Проверка и приведение входных данных к каноническому виду (to_canonical_form).
    2. Определение, нужен ли двухфазный метод (если есть искусственные переменные).
    3. Фаза 1 (если требуется):
        - Целевая функция: минимизация суммы искусственных переменных (все y_j).
        - Начальный базис: дополнительные переменные s_i и искусственные y_j.
        - Выполнение симплекс-итераций.
        - Проверка: если min Σy > 0, то система несовместна.
        - Удаление искусственных переменных (remove_artificial_vars).
    4. Фаза 2 (или однофазный метод, если искусственных переменных нет):
        - Целевая функция: исходная (с преобразованием знака, если максимизация → минимизация -F).
        - Пересчёт строки Δ для новой ЦФ.
        - Выполнение симплекс-итераций до оптимальности.
    5. Извлечение оптимального плана: переменные x_j берутся из столбца b для тех переменных,
       которые находятся в финальном базисе; остальные равны 0.
    6. Восстановление значения ЦФ с учётом направления оптимизации.

    Возвращает словарь с флагом успеха, решением, значением ЦФ, пошаговыми данными.
    """
    if constraints_types is None:
        constraints_types = ['<='] * len(A)

    steps = []
    iterations = []
    
    def add_step(title, data=None):
        steps.append({'title': title, 'data': data})

    add_step('НАЧАЛО РЕШЕНИЯ', {'c': c, 'A': A, 'b': b,
                               'направление': 'максимизация' if maximize else 'минимизация',
                               'типы_ограничений': constraints_types})

    # Приведение к каноническому виду
    canon = to_canonical_form(c, A, b, constraints_types)
    for step in canon['steps']:
        add_step(step['title'], step.get('data'))

    new_A = canon['A']
    new_b = canon['b']
    new_c = list(canon['c'])
    n_total = len(new_A[0])

    # Генерация читаемых имён для переменных
    var_names = [f'x{i+1}' for i in range(canon['original_n'])]
    var_names += [f's{i+1}' for i in range(canon['slack_count'])]
    var_names += [f'e{i+1}' for i in range(canon['surplus_count'])]
    artificial_start = n_total - canon['artificial_count']
    var_names += [f'y{i+1}' for i in range(canon['artificial_count'])]

    need_two_phase = canon['artificial_count'] > 0

    if need_two_phase:
        # ========== ФАЗА 1 ==========
        add_step('=== ФАЗА 1: Минимизация суммы искусственных переменных ===')
        
        # Целевая функция Фазы 1: c1 = (0 для натуральных, 1 для искусственных)
        c1 = [0.0] * n_total
        for j in range(artificial_start, n_total):
            c1[j] = 1.0
        add_step('Целевая функция Фазы 1', {'c': c1})

        # Начальный базис: сначала все slack-переменные, затем все искусственные
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

        tableau = update_objective_row(tableau, basis, c1)
        opt_val = tableau[-1][-1]
        
        # Проверка совместности: сумма искусственных переменных должна быть 0 (с учётом погрешности)
        if abs(opt_val) > 1e-6:
            add_step('Система несовместна', {'min_сумма_y': opt_val,
                                            'вывод': 'min Σy > 0 → допустимых решений нет'})
            return {'success': False, 'error': f'Система ограничений несовместна (min Σy = {opt_val:.4f})',
                    'steps': steps, 'iterations': iterations}

        add_step('Фаза 1 завершена успешно', {'min_сумма_y': opt_val,
                                             'вывод': 'min Σy = 0 → допустимое решение найдено'})

        # Удаляем искусственные переменные перед фазой 2
        tableau, basis, var_names = remove_artificial_vars(tableau, basis, var_names,
                                                           artificial_start, steps)
        add_step('Столбцы искусственных переменных удалены', 
                 {'базис': [var_names[b] for b in basis] if basis else 'пусто'})

        # ========== ФАЗА 2 ==========
        add_step('=== ФАЗА 2: Решение исходной задачи ===')
        
        # Формируем целевую функцию для Фазы 2
        c2 = [0.0] * len(var_names)
        for j in range(canon['original_n']):
            if maximize:
                c2[j] = -c[j]   # max F  эквивалентно min -F
            else:
                c2[j] = c[j]
        
        add_step('Целевая функция Фазы 2', {'c': c2})

        # Пересчитываем строку Δ для новой ЦФ
        tableau = update_objective_row(tableau, basis, c2)
        add_step('Симплекс-таблица Фазы 2',
                 {'таблица': format_tableau(tableau, basis, var_names)})

        res2 = run_simplex_iterations(tableau, basis, c2, var_names, 2, steps, iterations)
        if not res2['success']:
            return {'success': False, 'error': res2['error'], 'steps': steps, 'iterations': iterations}

        tableau = update_objective_row(tableau, basis, c2)
        final_tableau = tableau
        final_basis = basis
        total_iterations = res1.get('iterations', 0) + res2.get('iterations', 0)

    else:
        # ========== ОДНОФАЗНЫЙ МЕТОД (нет искусственных переменных) ==========
        add_step('=== ОДНОФАЗНЫЙ МЕТОД ===')
        
        if maximize:
            c_modified = [-x for x in new_c]
            add_step('Преобразование в задачу минимизации',
                    {'действие': 'max F → min F\', F\' = -F', 'c_новый': c_modified})
        else:
            c_modified = list(new_c)
        
        # Начальный базис – все дополнительные переменные (slack-переменные)
        basis = list(range(canon['original_n'], n_total))
        add_step('Начальный базис', {'базис': [var_names[b] for b in basis]})

        tableau = build_tableau(new_A, new_b, c_modified)
        tableau = update_objective_row(tableau, basis, c_modified)
        add_step('Начальная симплекс-таблица',
                 {'таблица': format_tableau(tableau, basis, var_names)})

        res = run_simplex_iterations(tableau, basis, c_modified, var_names, 1, steps, iterations)
        if not res['success']:
            return {'success': False, 'error': res['error'], 'steps': steps, 'iterations': iterations}
        
        tableau = update_objective_row(tableau, basis, c_modified)
        final_tableau = tableau
        final_basis = basis
        total_iterations = res.get('iterations', 0)

    # ========== ИЗВЛЕЧЕНИЕ РЕШЕНИЯ ==========
    solution = [0.0] * canon['original_n']
    
    m_final = len(final_tableau) - 1
    for i in range(m_final):
        bv = final_basis[i]
        # Если базисная переменная – одна из исходных x_j
        if 0 <= bv < canon['original_n']:
            solution[bv] = final_tableau[i][-1]
    
    value_in_tableau = final_tableau[-1][-1]
    
    # Восстанавливаем знак ЦФ, если была максимизация
    if maximize:
        value = -value_in_tableau
    else:
        value = value_in_tableau
    
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
    """Загружает теоретический материал из JSON-файла для отображения на странице."""
    try:
        json_path = os.path.join('static', 'data', 'theory_direct.json')
        if os.path.exists(json_path):
            with open(json_path, 'r', encoding='utf-8') as f:
                return json.load(f)
    except:
        pass
    return {}


def solve_direct_lp():
    """
    Обработчик HTTP-запроса для веб-интерфейса.
    - При GET-запросе отображает форму с сохранёнными ранее данными (из cookie).
    - При POST-запросе обрабатывает ввод, вызывает simplex_method_full и возвращает результат.
    - Сохраняет введённые данные в cookie для удобства пользователя.
    - Логирует успешные решения в файл history_direct.txt.
    """
    theory = load_theory()
    
    # Значения по умолчанию
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

    # Восстановление данных из cookies
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
            # Парсинг целевой функции
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

            # Парсинг матрицы A
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

            # Парсинг вектора b и типов ограничений
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

            # Валидация и решение
            is_valid, msg = validate_input_data(c, A, b)
            if not is_valid:
                error = msg
            else:
                result = simplex_method_full(c, A, b, sense, constraints)

            # Сохранение в cookies
            save_data = {
                'c': saved_c, 'rows': saved_rows, 'cols': saved_cols,
                'sense': saved_sense, 'A': saved_A, 'b': saved_b,
                'constraints': saved_constraints
            }
            response.set_cookie('direct_lp_data', json.dumps(save_data), path='/')

            # Логирование успешных решений
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

    # Рендеринг HTML-шаблона с данными
    return template('direct_lp',
                   theory=theory, c=saved_c, rows=saved_rows, cols=saved_cols,
                   sense=saved_sense, result=result, error=error,
                   constraints_types=saved_constraints, A=saved_A, b=saved_b)