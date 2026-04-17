from bottle import request, template, redirect
import json
import os
from datetime import datetime

def load_theory():
    path = os.path.join('data', 'theory_transport.json')
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def solve_transport():
    theory = load_theory()
    result = None
    error = None
    northwest_plan = None
    mincost_plan = None
    optimal_plan = None
    
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
            
            # 3. Оптимизация методом потенциалов (берём лучший начальный план)
            if northwest_cost <= mincost_cost:
                best_plan = northwest_plan
                best_cost = northwest_cost
            else:
                best_plan = mincost_plan
                best_cost = mincost_cost
            
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
            
            # Сохраняем в историю
            save_to_history(request.forms, result)
            
        except Exception as e:
            error = str(e)
    
    return template('transport', theory=theory, result=result, error=error)

def northwest_corner(supply, demand, costs):
    """Метод северо-западного угла"""
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
    """Метод минимального элемента"""
    n = len(supply)
    m = len(demand)
    plan = [[0] * m for _ in range(n)]
    
    # Создаём список всех клеток с их координатами и тарифами
    cells = []
    for i in range(n):
        for j in range(m):
            cells.append((i, j, costs[i][j]))
    
    # Сортируем по тарифу
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
    """Метод потенциалов (оптимизация)"""
    n = len(supply)
    m = len(demand)
    plan = [row[:] for row in initial_plan]
    
    max_iterations = 100
    for _ in range(max_iterations):
        # Расчёт потенциалов
        u = [None] * n
        v = [None] * m
        u[0] = 0
        
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
        
        # Заполняем оставшиеся потенциалы
        for i in range(n):
            if u[i] is None:
                u[i] = 0
        for j in range(m):
            if v[j] is None:
                v[j] = 0
        
        # Поиск клетки с положительной оценкой
        enter_i, enter_j = -1, -1
        max_delta = 0
        
        for i in range(n):
            for j in range(m):
                if plan[i][j] == 0:
                    delta = u[i] + v[j] - costs[i][j]
                    if delta > max_delta:
                        max_delta = delta
                        enter_i, enter_j = i, j
        
        if max_delta <= 0:
            break
        
        # Построение цикла
        cycle = find_cycle(plan, enter_i, enter_j, n, m)
        
        if cycle:
            # Находим минимальное значение в клетках со знаком минус
            min_val = float('inf')
            for idx, (i, j, sign) in enumerate(cycle):
                if sign == -1:
                    min_val = min(min_val, plan[i][j])
            
            # Перераспределение
            for i, j, sign in cycle:
                plan[i][j] += sign * min_val
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost

def is_basic_cell(plan, i, j, n, m):
    """Проверка, является ли клетка базисной (входит в опорный план)"""
    if plan[i][j] > 0:
        return True
    # Проверка на вырожденность
    row_sum = sum(1 for x in range(m) if plan[i][x] > 0)
    col_sum = sum(1 for x in range(n) if plan[x][j] > 0)
    return row_sum == 1 and col_sum == 1

def find_cycle(plan, enter_i, enter_j, n, m):
    """Поиск цикла перераспределения"""
    # Упрощённая версия — возвращаем простой цикл
    # В полной версии здесь должен быть алгоритм поиска цикла
    cycle = []
    
    # Ищем первую базисную клетку в строке
    for j in range(m):
        if plan[enter_i][j] > 0 and j != enter_j:
            # Ищем базисную клетку в столбце
            for i in range(n):
                if plan[i][enter_j] > 0 and i != enter_i:
                    cycle = [
                        (enter_i, enter_j, 1),
                        (enter_i, j, -1),
                        (i, j, 1),
                        (i, enter_j, -1)
                    ]
                    return cycle
    return cycle

def save_to_history(data, result):
    """Сохранение в историю"""
    os.makedirs('data', exist_ok=True)
    with open('data/history_transport.txt', 'a', encoding='utf-8') as f:
        f.write(f"[{datetime.now()}]\n")
        f.write(f"Входные данные: {dict(data)}\n")
        f.write(f"Результат: {result}\n")
        f.write("-" * 50 + "\n")