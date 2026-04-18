from bottle import request, template
from datetime import datetime
import json
import os

def load_theory():
    """Загрузка теоретических данных из JSON файла"""
    try:
        json_path = os.path.join('data', 'theory_transport.json')
        with open(json_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Ошибка загрузки теории: {e}")
        return None

def solve_transport():
    result = None
    error = None
    theory = load_theory()
    
    # Сохраняем введенные данные для отображения после POST
    form_data = {
        'suppliers': 3,
        'consumers': 3,
        'supply': [],
        'demand': [],
        'costs': []
    }
    
    if request.method == 'POST':
        try:
            suppliers = int(request.forms.get('suppliers', 3))
            consumers = int(request.forms.get('consumers', 3))
            
            form_data['suppliers'] = suppliers
            form_data['consumers'] = consumers
            
            supply = []
            for i in range(suppliers):
                val = request.forms.get(f'supply_{i}')
                supply.append(float(val) if val else 0)
            form_data['supply'] = supply
            
            demand = []
            for j in range(consumers):
                val = request.forms.get(f'demand_{j}')
                demand.append(float(val) if val else 0)
            form_data['demand'] = demand
            
            costs = []
            for i in range(suppliers):
                row = []
                for j in range(consumers):
                    val = request.forms.get(f'cost_{i}_{j}')
                    row.append(float(val) if val else 0)
                costs.append(row)
            form_data['costs'] = costs
            
            total_supply = sum(supply)
            total_demand = sum(demand)
            balanced = abs(total_supply - total_demand) < 0.0001
            
            # Северо-западный угол
            plan_nw, cost_nw, steps_nw, table_nw = northwest_corner_full(supply[:], demand[:], costs)
            
            # Минимальный элемент
            plan_me, cost_me, steps_me, table_me = min_element_full(supply[:], demand[:], costs)
            
            # Метод потенциалов для северо-западного плана
            plan_opt_nw, cost_opt_nw, iterations_nw = potential_method_full(costs, plan_nw, "северо-западного угла")
            
            # Метод потенциалов для плана минимального элемента
            plan_opt_me, cost_opt_me, iterations_me = potential_method_full(costs, plan_me, "минимального элемента")
            
            # Выбираем лучший результат
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
            
            result = {
                'northwest_plan': plan_nw,
                'northwest_cost': round(cost_nw, 2),
                'northwest_steps': steps_nw,
                'northwest_table': table_nw,
                'mincost_plan': plan_me,
                'mincost_cost': round(cost_me, 2),
                'mincost_steps': steps_me,
                'mincost_table': table_me,
                'optimal_plan_nw': plan_opt_nw,
                'optimal_cost_nw': round(cost_opt_nw, 2),
                'optimal_iterations_nw': iterations_nw,
                'optimal_plan_me': plan_opt_me,
                'optimal_cost_me': round(cost_opt_me, 2),
                'optimal_iterations_me': iterations_me,
                'best_plan': best_plan,
                'best_cost': round(best_cost, 2),
                'best_method': best_method,
                'best_iterations': best_iterations,
                'suppliers': suppliers,
                'consumers': consumers,
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
    
    return template('transport', result=result, error=error, theory=theory, form_data=form_data, year=datetime.now().year)


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
        if supply_copy[i] == 0:
            i += 1
        else:
            j += 1
        step_num += 1
    
    basic_cells = sum(1 for i in range(n) for j in range(m) if plan[i][j] > 0)
    expected_basic = n + m - 1
    is_degenerate = basic_cells < expected_basic
    
    cost_calc = []
    total_cost = 0
    for i in range(n):
        for j in range(m):
            if plan[i][j] > 0:
                c = plan[i][j] * costs[i][j]
                total_cost += c
                cost_calc.append(f"{plan[i][j]} × {costs[i][j]} = {c}")
    
    # Создаем таблицу для отображения
    table = []
    for i in range(n):
        row = []
        for j in range(m):
            row.append({'value': plan[i][j], 'cost': costs[i][j]})
        table.append(row)
    
    return plan, total_cost, {
        'steps': steps,
        'basic_cells': basic_cells,
        'expected_basic': expected_basic,
        'is_degenerate': is_degenerate,
        'cost_calculation': cost_calc,
        'degenerate_warning': f"⚠️ План вырожденный! Базисных клеток {basic_cells} вместо {expected_basic}" if is_degenerate else "✅ План невырожденный"
    }, table


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
    
    cost_calc = []
    total_cost = 0
    for i in range(n):
        for j in range(m):
            if plan[i][j] > 0:
                c = plan[i][j] * costs[i][j]
                total_cost += c
                cost_calc.append(f"{plan[i][j]} × {costs[i][j]} = {c}")
    
    table = []
    for i in range(n):
        row = []
        for j in range(m):
            row.append({'value': plan[i][j], 'cost': costs[i][j]})
        table.append(row)
    
    return plan, total_cost, {
        'steps': steps,
        'basic_cells': basic_cells,
        'expected_basic': expected_basic,
        'is_degenerate': is_degenerate,
        'cost_calculation': cost_calc,
        'degenerate_warning': f"⚠️ План вырожденный! Базисных клеток {basic_cells} вместо {expected_basic}" if is_degenerate else "✅ План невырожденный"
    }, table


def find_cycle_full(basis, start_i, start_j, n, m):
    """Полный поиск цикла пересчёта"""
    temp_basis = basis.copy()
    temp_basis.add((start_i, start_j))
    
    row_neighbors = {i: [] for i in range(n)}
    col_neighbors = {j: [] for j in range(m)}
    
    for (i, j) in temp_basis:
        row_neighbors[i].append(j)
        col_neighbors[j].append(i)
    
    for i in range(n):
        row_neighbors[i].sort()
    for j in range(m):
        col_neighbors[j].sort()
    
    visited = set()
    path = []
    
    def dfs(i, j, prev_i, prev_j, direction):
        if (i, j) in visited:
            return False
        
        visited.add((i, j))
        path.append((i, j))
        
        if (i, j) == (start_i, start_j) and len(path) >= 4:
            return True
        
        if direction != 'row':
            for nj in row_neighbors[i]:
                if nj != j:
                    if dfs(i, nj, i, j, 'row'):
                        return True
        
        if direction != 'col':
            for ni in col_neighbors[j]:
                if ni != i:
                    if dfs(ni, j, i, j, 'col'):
                        return True
        
        path.pop()
        visited.remove((i, j))
        return False
    
    if dfs(start_i, start_j, -1, -1, ''):
        if path[-1] == (start_i, start_j) and path[0] == (start_i, start_j):
            path = path[:-1]
        
        cycle = []
        for idx, (i, j) in enumerate(path):
            sign = 1 if idx % 2 == 0 else -1
            cycle.append((i, j, sign))
        return cycle
    
    return None


def potential_method_full(costs, initial_plan, method_name):
    n = len(costs)
    m = len(costs[0])
    plan = [row[:] for row in initial_plan]
    iterations = []
    
    for iteration_num in range(1, 51):
        basis = set()
        for i in range(n):
            for j in range(m):
                if plan[i][j] > 0:
                    basis.add((i, j))
        
        # Расчет потенциалов
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
        
        # Расчет оценок
        deltas = []
        enter_i, enter_j = -1, -1
        max_delta = 0
        
        for i in range(n):
            for j in range(m):
                if plan[i][j] == 0:
                    delta = u[i] + v[j] - costs[i][j]
                    explanation = f"Δ{chr(8321+i)}{chr(8321+j)} = u{i+1} + v{j+1} - c{i+1}{j+1} = {round(u[i],2)} + {round(v[j],2)} - {costs[i][j]} = {round(delta,2)}"
                    deltas.append({
                        'cell': f"({i+1}, {j+1})",
                        'ui': round(u[i], 2),
                        'vj': round(v[j], 2),
                        'cij': costs[i][j],
                        'delta': round(delta, 2),
                        'formula': f"{round(u[i],2)} + {round(v[j],2)} - {costs[i][j]} = {round(delta,2)}",
                        'explanation': explanation
                    })
                    if delta > max_delta:
                        max_delta = delta
                        enter_i, enter_j = i, j
        
        iteration = {
            'iteration': iteration_num,
            'potentials_u': [round(x, 2) for x in u],
            'potentials_v': [round(x, 2) for x in v],
            'potentials_explanation': f"Потенциалы найдены из системы: uᵢ + vⱼ = cᵢⱼ для базисных клеток. Приняли u₁ = 0, затем последовательно нашли остальные.",
            'deltas': deltas,
            'max_delta': round(max_delta, 2),
            'enter_cell': f"({enter_i+1}, {enter_j+1})" if enter_i != -1 else "нет",
            'enter_explanation': f"Выбрана клетка ({enter_i+1}, {enter_j+1}) с максимальной положительной оценкой Δ = {round(max_delta,2)}. Это означает, что перевозка по этому маршруту позволит уменьшить общую стоимость.",
            'check_optimal': "✅ Все оценки Δᵢⱼ ≤ 0, следовательно план оптимален!" if max_delta <= 0 else "⚠️ Есть положительные оценки, план не оптимален, требуется улучшение."
        }
        
        if max_delta <= 0:
            iteration['status'] = 'optimal'
            iterations.append(iteration)
            break
        
        # Построение цикла
        cycle = find_cycle_full(basis, enter_i, enter_j, n, m)
        
        if cycle:
            cycle_description = "Цикл пересчёта строится следующим образом: из выбранной свободной клетки двигаемся по строке или столбцу до базисной клетки, затем поворачиваем под прямым углом, продолжая движение только по базисным клеткам, пока не вернёмся в исходную клетку."
            
            # Находим минимальное значение в клетках со знаком минус
            min_val = float('inf')
            min_cells = []
            for (i, j, sign) in cycle:
                if sign == -1:
                    if plan[i][j] < min_val:
                        min_val = plan[i][j]
                        min_cells = [(i, j)]
                    elif plan[i][j] == min_val:
                        min_cells.append((i, j))
            
            if min_val != float('inf') and min_val > 0:
                # Перераспределение
                for (i, j, sign) in cycle:
                    if sign == 1:
                        plan[i][j] += min_val
                    elif sign == -1:
                        plan[i][j] -= min_val
                        if plan[i][j] < 0:
                            plan[i][j] = 0
                
                # Визуализация цикла
                cycle_visual = []
                for idx, (i, j, sign) in enumerate(cycle):
                    cycle_visual.append({
                        'cell': f"({i+1},{j+1})",
                        'sign': '+' if sign == 1 else '-',
                        'value': plan[i][j] if sign == 1 else plan[i][j] + min_val if sign == -1 else 0
                    })
                
                iteration['cycle'] = {
                    'cells': cycle_visual,
                    'theta': min_val,
                    'theta_explanation': f"θ = min{{xᵢⱼ в клетках со знаком «-»}} = {min_val}",
                    'description': cycle_description,
                    'redistribution': f"Перераспределение: к клеткам со знаком «+» прибавляем θ={min_val}, из клеток со знаком «-» вычитаем θ={min_val}"
                }
        else:
            iteration['error'] = "Не удалось построить цикл пересчёта"
            iterations.append(iteration)
            break
        
        iterations.append(iteration)
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost, iterations