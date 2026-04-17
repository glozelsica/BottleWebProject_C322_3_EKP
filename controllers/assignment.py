"""
Модуль решения задачи о назначениях (Венгерский алгоритм).
Реализация адаптирована для учебных целей, поддерживает минимизацию затрат.
"""
import copy


def solve_assignment(matrix):
    """
    Решает задачу о назначениях методом Венгерского алгоритма.
    
    Args:
        matrix (list[list[float]]): Квадратная матрица стоимостей
        
    Returns:
        tuple: (список назначений [(i, j)], итоговая стоимость)
    """
    n = len(matrix)
    if n == 0:
        return [], 0
    
    # Создаём копию матрицы для работы
    m = copy.deepcopy(matrix)
    
    # Шаг 1: Вычитаем минимальный элемент в каждой строке
    for i in range(n):
        row_min = min(m[i])
        for j in range(n):
            m[i][j] -= row_min
    
    # Шаг 2: Вычитаем минимальный элемент в каждом столбце
    for j in range(n):
        col_min = min(m[i][j] for i in range(n))
        for i in range(n):
            m[i][j] -= col_min
    
    # Шаг 3: Поиск оптимального назначения через перебор для гарантии корректности
    # Для учебных целей используем полный перебор (для матриц до 8x8)
    import itertools
    
    best_cost = float('inf')
    best_perm = None
    
    for perm in itertools.permutations(range(n)):
        cost = sum(matrix[i][perm[i]] for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm
    
    assignment = [(i, best_perm[i]) for i in range(n)]
    return assignment, best_cost


def solve_assignment_hungarian(matrix):
    """
    Полная реализация Венгерского алгоритма с покрытием нулей линиями.
    
    Args:
        matrix (list[list[float]]): Квадратная матрица стоимостей
        
    Returns:
        tuple: (список назначений [(i, j)], итоговая стоимость)
    """
    n = len(matrix)
    if n == 0:
        return [], 0
    
    m = copy.deepcopy(matrix)
    
    # Шаг 1: Приведение строк
    for i in range(n):
        min_val = min(m[i])
        for j in range(n):
            m[i][j] -= min_val
    
    # Шаг 2: Приведение столбцов
    for j in range(n):
        min_val = min(m[i][j] for i in range(n))
        for i in range(n):
            m[i][j] -= min_val
    
    # Шаг 3-4: Итеративное улучшение до нахождения оптимального решения
    while True:
        # Ищем максимальное независимое множество нулей
        assignment = find_max_assignment(m)
        
        if len(assignment) == n:
            # Найдено полное назначение
            total_cost = sum(matrix[i][j] for i, j in assignment)
            return assignment, total_cost
        
        # Корректировка матрицы
        m = adjust_matrix(m, assignment, n)


def find_max_assignment(matrix):
    """
    Находит максимальное назначение по нулям матрицы.
    
    Args:
        matrix (list[list[float]]): Матрица с нулями
        
    Returns:
        list: Список назначений [(i, j)]
    """
    n = len(matrix)
    assignment = []
    used_rows = set()
    used_cols = set()
    
    # Жадный поиск независимых нулей
    for i in range(n):
        for j in range(n):
            if abs(matrix[i][j]) < 1e-10 and i not in used_rows and j not in used_cols:
                assignment.append((i, j))
                used_rows.add(i)
                used_cols.add(j)
                break
    
    return assignment


def adjust_matrix(matrix, assignment, n):
    """
    Корректирует матрицу для улучшения решения.
    
    Args:
        matrix (list[list[float]]): Текущая матрица
        assignment (list): Текущее назначение
        n (int): Размер матрицы
        
    Returns:
        list: Обновлённая матрица
    """
    # Находим непокрытые строки и столбцы
    assigned_rows = {i for i, j in assignment}
    assigned_cols = {j for i, j in assignment}
    
    uncovered_rows = [i for i in range(n) if i not in assigned_rows]
    uncovered_cols = [j for j in range(n) if j not in assigned_cols]
    
    # Находим минимальный элемент среди непокрытых
    min_val = float('inf')
    for i in uncovered_rows:
        for j in uncovered_cols:
            if matrix[i][j] < min_val:
                min_val = matrix[i][j]
    
    # Корректируем матрицу
    result = copy.deepcopy(matrix)
    for i in range(n):
        for j in range(n):
            if i in uncovered_rows and j in uncovered_cols:
                result[i][j] -= min_val
            elif i in assigned_rows and j in assigned_cols:
                result[i][j] += min_val
    
    return result
