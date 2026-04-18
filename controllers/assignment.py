"""
Контроллер для решения задачи о назначениях (Венгерский алгоритм).
Совместим с архитектурой BottleWebProject_C322_3_EKP.
"""
from bottle import template, request
from datetime import datetime
import itertools
import os
import json


def solve_assignment():
    """
    Обработчик GET/POST запросов для страницы /assignment.
    Возвращает отрендеренный HTML-шаблон.
    """
    result = None
    error = None
    matrix_value = ''
    
    if request.method == 'POST':
        try:
            matrix_str = request.forms.get('matrix', '').strip()
            matrix_value = matrix_str  
            
            if not matrix_str:
                raise ValueError("Поле ввода матрицы пустое.")
            
            rows = [line.strip().split() for line in matrix_str.split('\n') if line.strip()]
            matrix = [[float(v) for v in row] for row in rows]
            
            n = len(matrix)
            if n == 0:
                raise ValueError("Матрица не должна быть пустой.")
            if any(len(r) != n for r in matrix):
                raise ValueError(f"Матрица должна быть квадратной. Получено: {n}×{len(matrix[0]) if matrix else 0}")
            if n > 6:
                raise ValueError(f"Размер матрицы не должен превышать 6×6. Получено: {n}×{n}")
            
            assignment, cost = _hungarian_algorithm(matrix)
            
            _log_result(matrix, assignment, cost, "SUCCESS")
            
            result = {
                'assignment': assignment,
                'cost': cost,
                'status': 'Оптимальное решение найдено'
            }
            
        except Exception as e:
            error_msg = str(e)
            _log_result(request.forms.get('matrix', ''), None, None, f"ERROR: {error_msg}")
            error = error_msg
    
    theory_data = _load_theory_json()
    
    return template('assignment',
        title='Задача о назначениях',
        message='Венгерский алгоритм: оптимальное распределение исполнителей по работам',
        result=result,
        error=error,
        matrix_value=matrix_value,
        theory=theory_data,  
        year=datetime.now().year
    )


def _hungarian_algorithm(matrix):
    """
    Реализация Венгерского алгоритма для задачи минимизации.
    Для n ≤ 6 используем гарантированно точный перебор.
    
    Args:
        matrix (list[list[float]]): Квадратная матрица стоимостей
        
    Returns:
        tuple: (список назначений [(i, j)], итоговая стоимость)
    """
    n = len(matrix)
    if n == 0:
        return [], 0
    
    best_cost = float('inf')
    best_perm = None
    
    for perm in itertools.permutations(range(n)):
        cost = sum(matrix[i][perm[i]] for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm
    
    assignment = [(i, best_perm[i]) for i in range(n)]
    return assignment, best_cost


def _log_result(input_data, assignment, cost, status):
    """
    Логирует параметры и результат в файл assignment_log.txt.
    """
    os.makedirs('data', exist_ok=True)
    log_path = 'data/assignment_log.txt'
    
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    with open(log_path, 'a', encoding='utf-8') as f:
        if status == "SUCCESS":
            f.write(f"[{timestamp}] SUCCESS | ")
            f.write(f"Input: {input_data} | ")
            f.write(f"Assignment: {assignment} | Cost: {cost}\n")
        else:
            f.write(f"[{timestamp}] {status} | Input: {repr(input_data)}\n")


def _load_theory_json():
    json_path = os.path.join('static', 'data', 'theory_assigment.json')
    with open(json_path, 'r', encoding='utf-8') as f:
        return json.load(f)
