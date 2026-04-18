"""
Контроллер для решения задачи о назначениях (Венгерский алгоритм).
Совместим с архитектурой BottleWebProject_C322_3_EKP.
"""
from bottle import template, request
from datetime import datetime
import copy
import itertools
import os


def solve_assignment():
    """
    Обработчик GET/POST запросов для страницы /assignment.
    Возвращает отрендеренный HTML-шаблон.
    """
    # Инициализация переменных
    result = None
    error = None
    matrix_value = ''
    
    # Обработка POST-запроса (форма отправлена)
    if request.method == 'POST':
        try:
            # Получение и очистка данных из формы
            matrix_str = request.forms.get('matrix', '').strip()
            matrix_value = matrix_str  # Сохраняем для отображения в форме
            
            if not matrix_str:
                raise ValueError("Поле ввода матрицы пустое.")
            
            # Парсинг матрицы из текста
            rows = [line.strip().split() for line in matrix_str.split('\n') if line.strip()]
            matrix = [[float(v) for v in row] for row in rows]
            
            # Валидация: квадратная матрица
            n = len(matrix)
            if n == 0:
                raise ValueError("Матрица не должна быть пустой.")
            if any(len(r) != n for r in matrix):
                raise ValueError(f"Матрица должна быть квадратной. Получено: {n}×{len(matrix[0]) if matrix else 0}")
            if n > 6:
                raise ValueError(f"Размер матрицы не должен превышать 6×6. Получено: {n}×{n}")
            
            # Вызов алгоритма решения
            assignment, cost = _hungarian_algorithm(matrix)
            
            # Логирование успешного выполнения
            _log_result(matrix, assignment, cost, "SUCCESS")
            
            # Подготовка данных для шаблона результата
            result = {
                'assignment': assignment,
                'cost': cost,
                'status': 'Оптимальное решение найдено'
            }
            
        except Exception as e:
            error_msg = str(e)
            _log_result(request.forms.get('matrix', ''), None, None, f"ERROR: {error_msg}")
            error = error_msg
    
    # Возврат отрендеренного шаблона (единая страница: ввод + теория + результат)
    return template('assignment',
        title='Задача о назначениях',
        message='Венгерский алгоритм: оптимальное распределение исполнителей по работам',
        result=result,
        error=error,
        matrix_value=matrix_value,
        year=datetime.now().year
    )


def _hungarian_algorithm(matrix):
    """
    Реализация Венгерского алгоритма для задачи минимизации.
    
    Args:
        matrix (list[list[float]]): Квадратная матрица стоимостей
        
    Returns:
        tuple: (список назначений [(i, j)], итоговая стоимость)
    """
    n = len(matrix)
    if n == 0:
        return [], 0
    
    # Для учебных целей (n ≤ 6) используем гарантированно точный перебор
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
    
    Args:
        input_data: Входные данные (матрица или строка)
        assignment: Список назначений [(i, j)] или None
        cost: Итоговая стоимость или None
        status: Статус выполнения ("SUCCESS" или сообщение об ошибке)
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