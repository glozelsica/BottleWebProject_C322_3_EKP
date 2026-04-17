"""
Модуль решения транспортной задачи
Методы: северо-западного угла, минимального элемента, потенциалов
Автор: Потылицына З.С.
"""

from bottle import request, template
import json
import os
from datetime import datetime

def load_theory():
    """Загрузка теории из JSON-файла"""
    path = os.path.join('data', 'theory_transport.json')
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {
        "title": "Транспортная задача",
        "full_theory": "Транспортная задача — классическая задача оптимизации...",
        "steps": []
    }

def solve_transport():
    """
    Главная функция-обработчик для страницы транспортной задачи
    Поддерживает GET (показ формы) и POST (решение)
    """
    theory = load_theory()
    result = None
    error = None
    
    if request.method == 'POST':
        try:
            # Получаем данные из формы
            suppliers = int(request.forms.get('suppliers', 0))
            consumers = int(request.forms.get('consumers', 0))
            
            # Запасы поставщиков
            supply = []
            for i in range(suppliers):
                val = request.forms.get(f'supply_{i}')
                supply.append(float(val) if val else 0)
            
            # Потребности потребителей
            demand = []
            for j in range(consumers):
                val = request.forms.get(f'demand_{j}')
                demand.append(float(val) if val else 0)
            
            # Матрица тарифов
            costs = []
            for i in range(suppliers):
                row = []
                for j in range(consumers):
                    val = request.forms.get(f'cost_{i}_{j}')
                    row.append(float(val) if val else 0)
                costs.append(row)
            
            # 1. Метод северо-западного угла
            northwest_plan, northwest_cost = northwest_corner(supply.copy(), demand.copy(), costs)
            
            # 2. Метод минимального элемента
            mincost_plan, mincost_cost = min_element_method(supply.copy(), demand.copy(), costs)
            
            # 3. Выбираем лучший начальный план для оптимизации
            if northwest_cost <= mincost_cost:
                best_plan = northwest_plan
                best_cost = northwest_cost
            else:
                best_plan = mincost_plan
                best_cost = mincost_cost
            
            # 4. Оптимизация методом потенциалов
            optimal_plan, optimal_cost = potential_method(supply.copy(), demand.copy(), costs, best_plan)
            
            result = {
                'northwest_plan': northwest_plan,
                'northwest_cost': round(northwest_cost, 2),
                'mincost_plan': mincost_plan,
                'mincost_cost': round(mincost_cost, 2),
                'optimal_plan': optimal_plan,
                'optimal_cost': round(optimal_cost, 2),
                'suppliers': suppliers,
                'consumers': consumers,
                'supply': supply,
                'demand': demand,
                'costs': costs
            }
            
            # Сохраняем результат в историю
            save_to_history(request.forms, result)
            
        except Exception as e:
            error = str(e)
    
    return template('transport', 
        theory=theory, 
        result=result, 
        error=error,
        year=datetime.now().year)


def northwest_corner(supply, demand, costs):
    """
    Метод северо-западного угла для построения начального опорного плана
    Заполняет таблицу с левого верхнего угла, не учитывая тарифы
    """
    n = len(supply)
    m = len(demand)
    plan = [[0] * m for _ in range(n)]
    i, j = 0, 0
    
    while i < n and j < m:
        amount = min(supply[i], demand[j])
        plan[i][j] = amount
        supply[i] -= amount
        demand[j] -= amount
        
        if supply[i] == 0:
            i += 1
        else:
            j += 1
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost


def min_element_method(supply, demand, costs):
    """
    Метод минимального элемента для построения начального опорного плана
    Выбирает клетку с наименьшим тарифом на каждом шаге
    """
    n = len(supply)
    m = len(demand)
    plan = [[0] * m for _ in range(n)]
    
    # Создаём список всех клеток с их координатами и тарифами
    cells = []
    for i in range(n):
        for j in range(m):
            cells.append((i, j, costs[i][j]))
    
    # Сортируем по тарифу (возрастание)
    cells.sort(key=lambda x: x[2])
    
    for i, j, cost in cells:
        if supply[i] > 0 and demand[j] > 0:
            amount = min(supply[i], demand[j])
            plan[i][j] = amount
            supply[i] -= amount
            demand[j] -= amount
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost


def potential_method(supply, demand, costs, initial_plan):
    """
    Метод потенциалов для оптимизации плана перевозок
    Итеративно улучшает план до достижения оптимальности
    """
    n = len(supply)
    m = len(demand)
    plan = [row[:] for row in initial_plan]
    
    max_iterations = 100
    for iteration in range(max_iterations):
        # Расчёт потенциалов
        u = [None] * n
        v = [None] * m
        u[0] = 0
        
        # Итеративное вычисление потенциалов
        changed = True
        while changed:
            changed = False
            for i in range(n):
                for j in range(m):
                    if plan[i][j] > 0 or is_basic_cell(plan, i, j, n, m):
                        if u[i] is not None and v[j] is None:
                            v[j] = costs[i][j] - u[i]
                            changed = True
                        elif v[j] is not None and u[i] is None:
                            u[i] = costs[i][j] - v[j]
                            changed = True
        
        # Заполняем оставшиеся потенциалы нулями
        for i in range(n):
            if u[i] is None:
                u[i] = 0
        for j in range(m):
            if v[j] is None:
                v[j] = 0
        
        # Поиск клетки с положительной оценкой (Δ > 0)
        enter_i, enter_j = -1, -1
        max_delta = 0
        
        for i in range(n):
            for j in range(m):
                if plan[i][j] == 0:
                    delta = u[i] + v[j] - costs[i][j]
                    if delta > max_delta:
                        max_delta = delta
                        enter_i, enter_j = i, j
        
        # Если все Δ ≤ 0 — план оптимален
        if max_delta <= 0:
            break
        
        # Построение цикла перераспределения
        cycle = find_cycle(plan, enter_i, enter_j, n, m)
        
        if cycle:
            # Находим минимальное значение в клетках со знаком минус
            min_val = float('inf')
            for i, j, sign in cycle:
                if sign == -1:
                    min_val = min(min_val, plan[i][j])
            
            # Перераспределение перевозок по циклу
            for i, j, sign in cycle:
                plan[i][j] += sign * min_val
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost


def is_basic_cell(plan, i, j, n, m):
    """
    Проверка, является ли клетка базисной (входит в опорный план)
    Учитывает вырожденные случаи
    """
    if plan[i][j] > 0:
        return True
    # Проверка на вырожденность: если в строке и столбце только одна базисная клетка
    row_sum = sum(1 for x in range(m) if plan[i][x] > 0)
    col_sum = sum(1 for x in range(n) if plan[x][j] > 0)
    return row_sum == 1 and col_sum == 1


def find_cycle(plan, enter_i, enter_j, n, m):
    """
    Поиск цикла перераспределения для вводимой свободной клетки
    Возвращает список кортежей (i, j, sign)
    """
    # Ищем первую базисную клетку в строке enter_i
    for j in range(m):
        if plan[enter_i][j] > 0 and j != enter_j:
            # Ищем базисную клетку в столбце enter_j
            for i in range(n):
                if plan[i][enter_j] > 0 and i != enter_i:
                    # Простой прямоугольный цикл
                    return [
                        (enter_i, enter_j, 1),   # + в свободной клетке
                        (enter_i, j, -1),        # - в базисной клетке строки
                        (i, j, 1),               # + в базисной клетке
                        (i, enter_j, -1)         # - в базисной клетке столбца
                    ]
    return []


def save_to_history(data, result):
    """Сохранение входных данных и результата в текстовый файл истории"""
    os.makedirs('data', exist_ok=True)
    with open('data/history_transport.txt', 'a', encoding='utf-8') as f:
        f.write(f"[{datetime.now()}]\n")
        f.write(f"Размерность: {result['suppliers']}x{result['consumers']}\n")
        f.write(f"Оптимальная стоимость: {result['optimal_cost']}\n")
        f.write("-" * 50 + "\n")