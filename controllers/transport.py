from bottle import request, template
from datetime import datetime
import json
import os
from copy import deepcopy

def load_theory():
    """Загрузка теоретических данных из JSON файла"""
    try:
        json_path = os.path.join('data', 'theory_transport.json')
        if os.path.exists(json_path):
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                print(f"✅ Теория загружена из: {json_path}")
                return data
        print("❌ Файл theory_transport.json не найден")
        return {}
    except Exception as e:
        print(f"❌ Ошибка загрузки теории: {e}")
        return {}

def solve_transport():
    result = None
    error = None
    theory = load_theory()
    
    if request.method == 'POST':
        try:
            suppliers = int(request.forms.get('suppliers', 3))
            consumers = int(request.forms.get('consumers', 3))
            
            supply = []
            for i in range(suppliers):
                val = request.forms.get(f'supply_{i}')
                supply.append(float(val) if val else 0)
            
            demand = []
            for j in range(consumers):
                val = request.forms.get(f'demand_{j}')
                demand.append(float(val) if val else 0)
            
            costs = []
            for i in range(suppliers):
                row = []
                for j in range(consumers):
                    val = request.forms.get(f'cost_{i}_{j}')
                    row.append(float(val) if val else 0)
                costs.append(row)
            
            total_supply = sum(supply)
            total_demand = sum(demand)
            balanced = abs(total_supply - total_demand) < 0.0001
            
            # Приведение к сбалансированному виду
            supply_corr = supply[:]
            demand_corr = demand[:]
            costs_corr = [row[:] for row in costs]
            orig_suppliers = suppliers
            orig_consumers = consumers
            
            if not balanced:
                if total_supply > total_demand:
                    demand_corr.append(total_supply - total_demand)
                    for i in range(suppliers):
                        costs_corr[i].append(0)
                    consumers += 1
                else:
                    supply_corr.append(total_demand - total_supply)
                    costs_corr.append([0] * consumers)
                    suppliers += 1
            
            # 1. Метод северо-западного угла
            plan_nw, cost_nw, steps_nw, nw_info = northwest_corner_full(supply_corr[:], demand_corr[:], costs_corr)
            
            # 2. Метод минимального элемента
            plan_me, cost_me, steps_me, me_info = min_element_full(supply_corr[:], demand_corr[:], costs_corr)
            
            # 3. Метод потенциалов для обоих планов
            plan_opt_nw, cost_opt_nw, iterations_nw = potential_method_full(costs_corr, plan_nw)
            plan_opt_me, cost_opt_me, iterations_me = potential_method_full(costs_corr, plan_me)
            
            # Выбор лучшего
            if cost_opt_me <= cost_opt_nw:
                best_plan = plan_opt_me
                best_cost = cost_opt_me
                best_iterations = iterations_me
                best_method = "минимального элемента"
            else:
                best_plan = plan_opt_nw
                best_cost = cost_opt_nw
                best_iterations = iterations_nw
                best_method = "северо-западного угла"
            
            # Обрезаем планы до исходной размерности
            if not balanced:
                if total_supply > total_demand:
                    best_plan = [row[:-1] for row in best_plan]
                else:
                    best_plan = best_plan[:-1]
            
            result = {
                'northwest_plan': plan_nw,
                'northwest_cost': round(cost_nw, 2),
                'northwest_steps': steps_nw,
                'northwest_degenerate': nw_info,
                'mincost_plan': plan_me,
                'mincost_cost': round(cost_me, 2),
                'mincost_steps': steps_me,
                'mincost_degenerate': me_info,
                'best_plan': best_plan,
                'best_cost': round(best_cost, 2),
                'best_method': best_method,
                'best_iterations': best_iterations,
                'suppliers': orig_suppliers,
                'consumers': orig_consumers,
                'supply': supply,
                'demand': demand,
                'costs': costs,
                'balanced': balanced,
                'total_supply': total_supply,
                'total_demand': total_demand
            }
            
        except Exception as e:
            error = str(e)
            import traceback
            traceback.print_exc()
    return template('transport', result=result, error=error, year=datetime.now().year)


def northwest_corner_full(supply, demand, costs):
    n = len(supply)
    m = len(demand)
    plan = [[0] * m for _ in range(n)]
    steps = []
    i, j = 0, 0
    step_num = 1
    
    supply_copy = supply[:]
    demand_copy = demand[:]
    
    while i < n and j < m:
        amount = min(supply_copy[i], demand_copy[j])
        plan[i][j] = amount
        steps.append({
            'step': step_num,
            'cell': f"({i+1}, {j+1})",
            'amount': amount,
            'formula': f"min({supply_copy[i]}, {demand_copy[j]}) = {amount}"
        })
        supply_copy[i] -= amount
        demand_copy[j] -= amount
        if abs(supply_copy[i]) < 0.0001:
            i += 1
        else:
            j += 1
        step_num += 1
    
    basic_cells = sum(1 for i in range(n) for j in range(m) if plan[i][j] > 0)
    expected_basic = n + m - 1
    is_degenerate = basic_cells < expected_basic
    
    info = {
        'is_degenerate': is_degenerate,
        'basic_cells': basic_cells,
        'expected_basic': expected_basic,
        'message': f"⚠️ План вырожденный! Базисных клеток {basic_cells} вместо {expected_basic}" if is_degenerate else f"✅ План невырожденный (базисных клеток: {basic_cells} из {expected_basic})"
    }
    
    total_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
    return plan, total_cost, steps, info


def min_element_full(supply, demand, costs):
    n = len(supply)
    m = len(demand)
    plan = [[0] * m for _ in range(n)]
    supply_copy = supply[:]
    demand_copy = demand[:]
    steps = []
    
    cells = [(i, j, costs[i][j]) for i in range(n) for j in range(m)]
    cells.sort(key=lambda x: x[2])
    
    step_num = 1
    for i, j, cost in cells:
        if supply_copy[i] > 0 and demand_copy[j] > 0:
            amount = min(supply_copy[i], demand_copy[j])
            plan[i][j] = amount
            steps.append({
                'step': step_num,
                'cell': f"({i+1}, {j+1})",
                'cost': cost,
                'amount': amount,
                'formula': f"min({supply_copy[i]}, {demand_copy[j]}) = {amount}"
            })
            supply_copy[i] -= amount
            demand_copy[j] -= amount
            step_num += 1
    
    basic_cells = sum(1 for i in range(n) for j in range(m) if plan[i][j] > 0)
    expected_basic = n + m - 1
    is_degenerate = basic_cells < expected_basic
    
    info = {
        'is_degenerate': is_degenerate,
        'basic_cells': basic_cells,
        'expected_basic': expected_basic,
        'message': f"⚠️ План вырожденный! Базисных клеток {basic_cells} вместо {expected_basic}" if is_degenerate else f"✅ План невырожденный (базисных клеток: {basic_cells} из {expected_basic})"
    }
    
    total_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
    return plan, total_cost, steps, info


def find_full_cycle(basis, start_i, start_j, n, m):
    """
    Поиск цикла пересчёта методом обхода в глубину (DFS)
    Возвращает список клеток цикла с чередующимися знаками + и -
    """
    temp_basis = basis.copy()
    temp_basis.append((start_i, start_j))
    
    # Строим граф соседей по строкам и столбцам
    row_neighbors = {}
    col_neighbors = {}
    
    for (i, j) in temp_basis:
        if i not in row_neighbors:
            row_neighbors[i] = []
        row_neighbors[i].append(j)
        if j not in col_neighbors:
            col_neighbors[j] = []
        col_neighbors[j].append(i)
    
    # Сортируем для детерминированности
    for i in row_neighbors:
        row_neighbors[i].sort()
    for j in col_neighbors:
        col_neighbors[j].sort()
    
    visited = set()
    path = []
    
    def dfs(i, j, direction):
        if (i, j) in visited:
            return False
        
        visited.add((i, j))
        path.append((i, j))
        
        if (i, j) == (start_i, start_j) and len(path) >= 4:
            return True
        
        # Движение по строке (горизонтально)
        if direction != 'col':
            for nj in row_neighbors.get(i, []):
                if nj != j:
                    if dfs(i, nj, 'row'):
                        return True
        
        # Движение по столбцу (вертикально)
        if direction != 'row':
            for ni in col_neighbors.get(j, []):
                if ni != i:
                    if dfs(ni, j, 'col'):
                        return True
        
        path.pop()
        visited.remove((i, j))
        return False
    
    if dfs(start_i, start_j, ''):
        if len(path) > 1 and path[-1] == (start_i, start_j):
            path = path[:-1]
        
        cycle = []
        for idx, (i, j) in enumerate(path):
            sign = 1 if idx % 2 == 0 else -1
            cycle.append((i, j, sign))
        return cycle
    
    return None


def potential_method_full(costs, initial_plan):
    """Полноценный метод потенциалов с визуализацией каждой итерации"""
    n = len(costs)
    m = len(costs[0])
    plan = [row[:] for row in initial_plan]
    iterations = []
    iteration_num = 1
    max_iterations = 30
    
    while iteration_num <= max_iterations:
        # Собираем базисные клетки
        basis = []
        for i in range(n):
            for j in range(m):
                if plan[i][j] > 0:
                    basis.append((i, j))
        
        # Добавляем фиктивные базисные клетки при вырожденности
        expected_basic = n + m - 1
        if len(basis) < expected_basic:
            for i in range(n):
                for j in range(m):
                    if plan[i][j] == 0 and (i, j) not in basis:
                        if len(basis) < expected_basic:
                            basis.append((i, j))
        
        # Расчёт потенциалов u и v
        u = [None] * n
        v = [None] * m
        u[0] = 0
        
        changed = True
        while changed:
            changed = False
            for (i, j) in basis:
                if u[i] is not None and v[j] is None:
                    v[j] = costs[i][j] - u[i]
                    changed = True
                elif v[j] is not None and u[i] is None:
                    u[i] = costs[i][j] - v[j]
                    changed = True
        
        for i in range(n):
            if u[i] is None:
                u[i] = 0
        for j in range(m):
            if v[j] is None:
                v[j] = 0
        
        # Вычисляем оценки Δ для свободных клеток
        deltas = []
        enter_i, enter_j = -1, -1
        max_delta = -float('inf')
        
        for i in range(n):
            for j in range(m):
                if plan[i][j] == 0:
                    delta = u[i] + v[j] - costs[i][j]
                    deltas.append({
                        'cell': f"({i+1}, {j+1})",
                        'delta': round(delta, 2),
                        'formula': f"{round(u[i],2)} + {round(v[j],2)} - {costs[i][j]} = {round(delta,2)}",
                        'is_positive': delta > 0
                    })
                    if delta > max_delta:
                        max_delta = delta
                        enter_i, enter_j = i, j
        
        iteration = {
            'iteration': iteration_num,
            'potentials_u': [round(x, 2) for x in u],
            'potentials_v': [round(x, 2) for x in v],
            'deltas': deltas,
            'max_delta': round(max_delta, 2) if max_delta > -float('inf') else 0,
            'enter_cell': f"({enter_i+1}, {enter_j+1})" if enter_i != -1 else "нет",
            'enter_explanation': f"Выбрана клетка ({enter_i+1}, {enter_j+1}) с Δ = {round(max_delta,2)}" if enter_i != -1 else "",
            'check_optimal': "✅ План оптимален! Дальнейшее улучшение невозможно." if max_delta <= 0 else "⚠️ Найдена положительная оценка, требуется улучшение плана.",
            'cycle': None  # По умолчанию цикла нет
        }
        
        # Если все оценки ≤ 0, план оптимален
        if max_delta <= 0:
            iteration['status'] = 'optimal'
            iterations.append(iteration)
            break
        
        # Строим цикл пересчёта
        if enter_i != -1 and enter_j != -1:
            cycle = find_full_cycle(basis, enter_i, enter_j, n, m)
            
            if cycle:
                # Визуализация цикла
                cycle_cells = []
                min_val = float('inf')
                
                for (i, j, sign) in cycle:
                    cycle_cells.append({
                        'cell': f"({i+1},{j+1})",
                        'sign': '+' if sign == 1 else '-',
                        'i': i,
                        'j': j
                    })
                    if sign == -1:
                        if plan[i][j] < min_val:
                            min_val = plan[i][j]
                
                theta = min_val if min_val != float('inf') else 0
                
                # Рассчитываем новую стоимость
                new_plan = [row[:] for row in plan]
                for (i, j, sign) in cycle:
                    new_plan[i][j] += sign * theta
                    if new_plan[i][j] < 0:
                        new_plan[i][j] = 0
                new_cost = sum(new_plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
                
                iteration['cycle'] = {
                    'cells': cycle_cells,
                    'theta': theta,
                    'theta_explanation': f"θ = {theta} (минимальная перевозка в клетках со знаком '-')",
                    'description': "Цикл пересчёта — замкнутая ломаная линия по базисным клеткам. Вершины цикла отмечены знаками «+» и «-».",
                    'redistribution': f"Перераспределено {theta} единиц груза по циклу"
                }
                iteration['new_cost'] = round(new_cost, 2)
                
                # Применяем перераспределение к плану
                for (i, j, sign) in cycle:
                    plan[i][j] += sign * theta
                    if plan[i][j] < 0:
                        plan[i][j] = 0
            else:
                iteration['cycle'] = None
                iteration['cycle_error'] = "Не удалось построить цикл пересчёта"
                # Принудительно завершаем, чтобы избежать бесконечного цикла
                break
        
        iterations.append(iteration)
        iteration_num += 1
    
    total_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
    return plan, total_cost, iterations