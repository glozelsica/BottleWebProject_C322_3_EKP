
"""
Модуль решения задачи о назначениях (Венгерский алгоритм).
Реализация адаптирована для учебных целей, поддерживает минимизацию затрат.
"""
import copy

def solve_assignment(matrix):
    """
    Решает задачу о назначениях методом Венгерского алгоритма.
    :param matrix: list[list[float]] Квадратная матрица стоимостей
    :return: tuple (список назначений [(i, j)], итоговая стоимость)
    """
    n = len(matrix)
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

    # Простой поиск нулей для учебных матриц (до 10x10)
    # Для больших матриц требуется полная реализация O(n^3)
    assignment = []
    used_cols = set()
    for i in range(n):
        for j in range(n):
            if m[i][j] == 0 and j not in used_cols:
                assignment.append((i, j))
                used_cols.add(j)
                break

    if len(assignment) < n:
        # Если не найдено полное назначение, используем перебор для гарантии корректности
        import itertools
        best_cost = float('inf')
        best_perm = None
        for perm in itertools.permutations(range(n)):
            cost = sum(matrix[i][perm[i]] for i in range(n))
            if cost < best_cost:
                best_cost = cost
                best_perm = perm
        assignment = [(i, best_perm[i]) for i in range(n)]
        total_cost = best_cost
    else:
        total_cost = sum(matrix[i][j] for i, j in assignment)

    return assignment, total_cost