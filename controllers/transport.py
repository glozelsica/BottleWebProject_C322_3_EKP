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
    return {"title": "Транспортная задача", "theory": {}, "solution_example": {}}

def solve_transport():
    """Главная функция-обработчик для страницы транспортной задачи"""
    theory = load_theory()
    result = None
    error = None
    
    if request.method == 'POST':
        try:
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
            
            # Проверка сбалансированности
            total_supply = sum(supply)
            total_demand = sum(demand)
            
            if abs(total_supply - total_demand) > 0.0001:
                # Добавляем фиктивного поставщика или потребителя
                if total_supply > total_demand:
                    # Добавляем фиктивного потребителя
                    demand.append(total_supply - total_demand)
                    for i in range(suppliers):
                        costs[i].append(0)
                    consumers += 1
                else:
                    # Добавляем фиктивного поставщика
                    supply.append(total_demand - total_supply)
                    costs.append([0] * consumers)
                    suppliers += 1
            
            # 1. Метод северо-западного угла
            northwest_plan, northwest_cost = northwest_corner(supply.copy(), demand.copy(), costs)
            
            # 2. Метод минимального элемента
            mincost_plan, mincost_cost = min_element_method(supply.copy(), demand.copy(), costs)
            
            # 3. Выбираем лучший начальный план
            if northwest_cost <= mincost_cost:
                best_plan = northwest_plan
            else:
                best_plan = mincost_plan
            
            # 4. Оптимизация методом потенциалов
            optimal_plan, optimal_cost = potential_method(supply, demand, costs, best_plan)
            
            # Приводим планы к исходной размерности (если добавляли фиктивных)
            if len(optimal_plan) > len(supply) - (1 if total_supply < total_demand else 0):
                # Убираем фиктивного поставщика
                optimal_plan = optimal_plan[:-1] if total_supply < total_demand else optimal_plan
                for i in range(len(optimal_plan)):
                    if len(optimal_plan[i]) > len(demand) - (1 if total_supply > total_demand else 0):
                        optimal_plan[i] = optimal_plan[i][:-1] if total_supply > total_demand else optimal_plan[i]
            
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
                'costs': costs,
                'balanced': total_supply == total_demand
            }
            
            save_to_history(request.forms, result)
            
        except Exception as e:
            error = str(e)
    
    return template('transport', 
        theory=theory, 
        result=result, 
        error=error,
        year=datetime.now().year)


def northwest_corner(supply, demand, costs):
    """Метод северо-западного угла"""
    n = len(supply)
    m = len(demand)
    plan = [[0] * m for _ in range(n)]
    supply_copy = supply[:]
    demand_copy = demand[:]
    i, j = 0, 0
    
    while i < n and j < m:
        amount = min(supply_copy[i], demand_copy[j])
        plan[i][j] = amount
        supply_copy[i] -= amount
        demand_copy[j] -= amount
        
        if supply_copy[i] == 0:
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
    supply_copy = supply[:]
    demand_copy = demand[:]
    
    cells = [(i, j, costs[i][j]) for i in range(n) for j in range(m)]
    cells.sort(key=lambda x: x[2])
    
    for i, j, _ in cells:
        if supply_copy[i] > 0 and demand_copy[j] > 0:
            amount = min(supply_copy[i], demand_copy[j])
            plan[i][j] = amount
            supply_copy[i] -= amount
            demand_copy[j] -= amount
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost


def potential_method(supply, demand, costs, initial_plan):
    """Метод потенциалов — полная оптимизация"""
    n = len(supply)
    m = len(demand)
    plan = [row[:] for row in initial_plan]
    
    max_iterations = 100
    
    for _ in range(max_iterations):
        # Шаг 1: Расчёт потенциалов
        u = [None] * n
        v = [None] * m
        u[0] = 0
        
        # Итеративно вычисляем потенциалы
        changed = True
        while changed:
            changed = False
            for i in range(n):
                for j in range(m):
                    if plan[i][j] > 0:
                        if u[i] is not None and v[j] is None:
                            v[j] = costs[i][j] - u[i]
                            changed = True
                        elif v[j] is not None and u[i] is None:
                            u[i] = costs[i][j] - v[j]
                            changed = True
        
        # Заполняем None значениями
        for i in range(n):
            if u[i] is None:
                u[i] = 0
        for j in range(m):
            if v[j] is None:
                v[j] = 0
        
        # Шаг 2: Поиск клетки с положительной оценкой
        enter_i, enter_j = -1, -1
        max_delta = 0
        
        for i in range(n):
            for j in range(m):
                if plan[i][j] == 0:
                    delta = u[i] + v[j] - costs[i][j]
                    if delta > max_delta + 0.0001:
                        max_delta = delta
                        enter_i, enter_j = i, j
        
        # Если все оценки ≤ 0 — план оптимален
        if max_delta <= 0:
            break
        
        # Шаг 3: Построение цикла пересчёта
        cycle = find_cycle(plan, enter_i, enter_j, n, m)
        
        if not cycle:
            break
        
        # Шаг 4: Находим минимальное значение в клетках со знаком '-'
        theta = float('inf')
        for i, j, sign in cycle:
            if sign == -1:
                theta = min(theta, plan[i][j])
        
        if theta == float('inf'):
            break
        
        # Шаг 5: Перераспределение по циклу
        for i, j, sign in cycle:
            plan[i][j] += sign * theta
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost


def find_cycle(plan, enter_i, enter_j, n, m):
    """Поиск цикла пересчёта для клетки (enter_i, enter_j)"""
    # Находим все базисные клетки
    basic = [(i, j) for i in range(n) for j in range(m) if plan[i][j] > 0]
    basic.append((enter_i, enter_j))
    
    # Строим граф по строкам и столбцам
    rows = {}
    cols = {}
    
    for i, j in basic:
        if i not in rows:
            rows[i] = []
        rows[i].append(j)
        if j not in cols:
            cols[j] = []
        cols[j].append(i)
    
    # DFS для поиска цикла
    def dfs(current_i, current_j, target_i, target_j, visited, path):
        path.append((current_i, current_j))
        
        if current_i == target_i and current_j == target_j and len(path) > 1:
            return True
        
        visited.add((current_i, current_j))
        
        # Идём по строке
        if current_i in rows:
            for nj in rows[current_i]:
                if (current_i, nj) not in visited and not (current_i == target_i and nj == target_j and len(path) == 1):
                    if dfs(current_i, nj, target_i, target_j, visited, path):
                        return True
        
        # Идём по столбцу
        if current_j in cols:
            for ni in cols[current_j]:
                if (ni, current_j) not in visited and not (ni == target_i and current_j == target_j and len(path) == 1):
                    if dfs(ni, current_j, target_i, target_j, visited, path):
                        return True
        
        path.pop()
        visited.remove((current_i, current_j))
        return False
    
    visited = set()
    path = []
    
    if dfs(enter_i, enter_j, enter_i, enter_j, visited, path):
        # Убираем последнюю точку (она повторяет первую)
        path = path[:-1]
        
        # Расставляем знаки (+ и -), начиная с + в исходной клетке
        cycle = []
        sign = 1
        for idx, (i, j) in enumerate(path):
            if i == enter_i and j == enter_j and idx == 0:
                cycle.append((i, j, 1))
            else:
                cycle.append((i, j, sign))
                sign *= -1
        return cycle
    
    return []


def save_to_history(data, result):
    """Сохранение результата в историю"""
    os.makedirs('data', exist_ok=True)
    with open('data/history_transport.txt', 'a', encoding='utf-8') as f:
        f.write(f"[{datetime.now()}]\n")
        f.write(f"Размерность: {result['suppliers']}x{result['consumers']}\n")
        f.write(f"Оптимальная стоимость: {result['optimal_cost']}\n")
        f.write("-" * 50 + "\n")