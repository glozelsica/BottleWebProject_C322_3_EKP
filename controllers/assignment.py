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
    print("=" * 50)
    print(f"REQUEST METHOD: {request.method}")
    print(f"FORM DATA: {request.forms.get('matrix_data')}")
    print(f"MATRIX SIZE: {request.forms.get('matrix_size')}")
    print("=" * 50)
    result = None
    error = None
    matrix_value = ''
    matrix_size = 3
    matrix_values = []
    
    if request.method == 'POST':
        try:
            # 1. Сначала получаем размер, чтобы знать, чего ожидать
            matrix_size = int(request.forms.get('matrix_size', 3))
            matrix_str = request.forms.get('matrix_data', '').strip()
            
            if not matrix_str:
                raise ValueError("Поле ввода матрицы пустое.")
            
            # Парсинг
            rows = [line.strip().split() for line in matrix_str.split('\n') if line.strip()]
            matrix = [[float(v) for v in row] for row in rows]
            
            # Сохраняем значения для восстановления (округляем для красоты, если нужно)
            matrix_values = [[int(v) if float(v).is_integer() else float(v) for v in row] for row in rows]
            
            # Валидация размеров
            n = len(matrix)
            if n != matrix_size:
                raise ValueError(f"Размер матрицы не совпадает: ожидается {matrix_size}×{matrix_size}")
            
            for i, row in enumerate(matrix):
                if len(row) != n:
                    raise ValueError(f"В строке {i+1} ожидается {n} элементов")
            
            # Алгоритм
            assignment, cost = _hungarian_algorithm(matrix)
            _log_result(matrix, assignment, cost, "SUCCESS")
            
            result = {
                'assignment': assignment,
                'cost': cost,
                'status': 'Оптимальное решение найдено'
            }
            
        except ValueError as e:
            error = str(e)
            # При ошибке тоже сохраняем данные, чтобы пользователь не вводил всё заново
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
    
    # ВАЖНО: Используем json.dumps для корректного JS-формата
    return template('assignment',
        title='Задача о назначениях',
        message='Венгерский алгоритм: оптимальное распределение исполнителей по работам',
        result=result,
        error=error,
        matrix_value=matrix_value,
        matrix_size=matrix_size,
        matrix_values_json=json.dumps(matrix_values),  # <-- Передаём как JSON-строку
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
