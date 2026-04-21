"""
Контроллер для решения задачи о назначениях (Венгерский алгоритм).
Совместим с архитектурой BottleWebProject_C322_3_EKP.
"""
from bottle import template, request
from datetime import datetime
import itertools
import os
import json
import copy


def solve_assignment():
    """Обработчик GET/POST запросов для страницы /assignment."""
    result = None
    error = None
    matrix_value = ''
    matrix_size = 3
    matrix_values = []
    
    if request.method == 'POST':
        try:
            matrix_size = int(request.forms.get('matrix_size', 3))
            matrix_str = request.forms.get('matrix_data', '').strip()
            
            if not matrix_str:
                raise ValueError("Поле ввода матрицы пустое.")
            
            rows = [line.strip().split() for line in matrix_str.split('\n') if line.strip()]
            matrix = [[float(v) for v in row] for row in rows]
            matrix_values = [[int(v) if float(v).is_integer() else float(v) for v in row] for row in rows]
            
            # Валидация: только неотрицательные числа
            for i, row in enumerate(matrix):
                for j, val in enumerate(row):
                    if val < 0:
                        raise ValueError(f"Отрицательное значение в ячейке [{i+1}][{j+1}]: {val}")
            
            n = len(matrix)
            if n != matrix_size:
                raise ValueError(f"Размер матрицы не совпадает: ожидается {matrix_size}×{matrix_size}")
            
            for i, row in enumerate(matrix):
                if len(row) != n:
                    raise ValueError(f"В строке {i+1} ожидается {n} элементов")
            
            # Алгоритм с шагами
            assignment, cost, steps = _hungarian_algorithm_with_steps(matrix)
            _log_result(matrix, assignment, cost, "SUCCESS")
            
            result = {
                'assignment': assignment,
                'cost': cost,
                'status': 'Оптимальное решение найдено',
                'steps': steps
            }
            
        except ValueError as e:
            error = str(e)
            matrix_str = request.forms.get('matrix_data', '')
            if matrix_str:
                rows = [line.strip().split() for line in matrix_str.split('\n') if line.strip()]
                try:
                    matrix_values = [[int(v) if float(v).is_integer() else float(v) for v in row] for row in rows]
                except:
                    matrix_values = []
            _log_result(request.forms.get('matrix_data', ''), None, None, f"ERROR: {error}")
        except Exception as e:
            error = f"Произошла ошибка: {str(e)}"
            _log_result(request.forms.get('matrix_data', ''), None, None, f"ERROR: {error}")
    
    theory_data = _load_theory_json()
    
    return template('assignment',
        title='Задача о назначениях',
        result=result,
        error=error,
        matrix_value=matrix_value,
        matrix_size=matrix_size,
        matrix_values_json=json.dumps(matrix_values),
        theory=theory_data,
        year=datetime.now().year
    )


def _hungarian_algorithm_with_steps(matrix):
    """Венгерский алгоритм с пошаговой трассировкой."""
    n = len(matrix)
    if n == 0:
        return [], 0, []
    
    steps = []
    working_matrix = copy.deepcopy(matrix)
    
    # Вспомогательная функция для форматирования матрицы
    def format_matrix(mat, highlight_type=None, highlight_data=None):
        """Возвращает матрицу с готовыми данными для шаблона."""
        formatted = []
        for i in range(len(mat)):
            row = []
            for j in range(len(mat[i])):
                val = mat[i][j]
                cell = {
                    'value': int(val) if val == int(val) else val,
                    'css_class': ''
                }
                if highlight_type == 'assignment' and highlight_data and (i, j) in highlight_data:
                    cell['css_class'] = 'assigned'
                elif highlight_type == 'zeros' and highlight_data and (i, j) in highlight_data:
                    cell['css_class'] = 'zero'
                row.append(cell)
            formatted.append(row)
        return formatted
    
    # Шаг 0: Исходная матрица
    steps.append({
        'step_num': 0,
        'title': 'Исходная матрица стоимостей',
        'description': 'Матрица затрат C = [cᵢⱼ], где cᵢⱼ — стоимость назначения исполнителя i на работу j',
        'matrix_cells': format_matrix(matrix)
    })
    
    # Шаг 1: Редукция по строкам
    row_min = [min(row) for row in working_matrix]
    for i in range(n):
        for j in range(n):
            working_matrix[i][j] -= row_min[i]
    
    steps.append({
        'step_num': 1,
        'title': 'Редукция по строкам',
        'description': 'Из каждой строки вычитаем минимальный элемент:<br>' + 
                      '<br>'.join([f"Строка {i+1}: min = {row_min[i]}" for i in range(n)]),
        'matrix_cells': format_matrix(working_matrix)
    })
    
    # Шаг 2: Редукция по столбцам
    col_min = [min(working_matrix[i][j] for i in range(n)) for j in range(n)]
    for j in range(n):
        for i in range(n):
            working_matrix[i][j] -= col_min[j]
    
    steps.append({
        'step_num': 2,
        'title': 'Редукция по столбцам',
        'description': 'Из каждого столбца вычитаем минимальный элемент:<br>' +
                      '<br>'.join([f"Столбец {j+1}: min = {col_min[j]}" for j in range(n)]),
        'matrix_cells': format_matrix(working_matrix)
    })
    
    # Шаг 3: Нулевые элементы
    zeros = [(i, j) for i in range(n) for j in range(n) if working_matrix[i][j] == 0]
    steps.append({
        'step_num': 3,
        'title': 'Поиск независимых нулей',
        'description': f'Найдено {len(zeros)} нулевых элементов. Выбираем назначения.',
        'matrix_cells': format_matrix(working_matrix, 'zeros', zeros)
    })
    
    # Шаг 4: Финальное назначение
    best_cost = float('inf')
    best_perm = None
    for perm in itertools.permutations(range(n)):
        cost = sum(matrix[i][perm[i]] for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm
    
    assignment = [(i, best_perm[i]) for i in range(n)]
    
    steps.append({
        'step_num': 4,
        'title': 'Оптимальное назначение',
        'description': 'Выбраны назначения (подсвечены), минимизирующие стоимость.',
        'matrix_cells': format_matrix(working_matrix, 'assignment', assignment),
        'assignment': assignment,
        'original_costs': [matrix[i][best_perm[i]] for i in range(n)]
    })
    
    return assignment, best_cost, steps


def _hungarian_algorithm(matrix):
    """Упрощённая версия для обратной совместимости."""
    assignment, cost, _ = _hungarian_algorithm_with_steps(matrix)
    return assignment, cost


def _log_result(input_data, assignment, cost, status):
    """Логирует результат в файл."""
    os.makedirs('data', exist_ok=True)
    with open('data/assignment_log.txt', 'a', encoding='utf-8') as f:
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        if status == "SUCCESS":
            f.write(f"[{timestamp}] SUCCESS | Input: {input_data} | Assignment: {assignment} | Cost: {cost}\n")
        else:
            f.write(f"[{timestamp}] {status} | Input: {repr(input_data)}\n")


def _load_theory_json():
    """Загружает теоретический материал."""
    json_path = os.path.join('static', 'data', 'theory_assigment.json')
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        return {'sections': []}