from bottle import request, template
from datetime import datetime
import json
import os

def load_theory():
    """Загрузка теоретических данных из JSON файла"""
    try:
        # Сначала пробуем новый файл
        json_path = os.path.join('data', 'theory_transport_new.json')
        if os.path.exists(json_path):
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                print(f"✅ Теория загружена из: {json_path}")
                return data
        
        # Если нет, пробуем старый
        json_path = os.path.join('data', 'theory_transport.json')
        if os.path.exists(json_path):
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                print(f"✅ Теория загружена из: {json_path}")
                # Удаляем images если они есть (чтобы не было ошибок)
                if 'example' in data and 'images' in data['example']:
                    del data['example']['images']
                return data
        
        # Если файлов нет, возвращаем встроенную теорию
        print("❌ Файлы с теорией не найдены, использую встроенную теорию")
        return get_builtin_theory()
        
    except Exception as e:
        print(f"❌ Ошибка загрузки теории: {e}")
        return get_builtin_theory()

def get_builtin_theory():
    """Встроенная теория на случай отсутствия JSON файла"""
    return {
        "title": "Транспортная задача линейного программирования",
        "sections": [
            {
                "id": "section1",
                "title": "1. Постановка транспортной задачи. Закрытая модель",
                "content": "Транспортная задача является одним из наиболее важных частных случаев общей задачи линейного программирования.\n\nПусть в пунктах А₁, А₂, ..., Аₘ производится некоторый продукт, причем объем производства в п. Аᵢ составляет aᵢ единиц. Произведенный продукт должен быть доставлен в пункты потребления В₁, В₂, ..., Вₙ, причем объем потребления в п. Вⱼ составляет bⱼ единиц.\n\nЦелевая функция: F = ΣᵢΣⱼ cᵢⱼ · xᵢⱼ → min\n\nОграничения по запасам: Σⱼ xᵢⱼ = aᵢ\nОграничения по потребностям: Σᵢ xᵢⱼ = bⱼ\n\nОПРЕДЕЛЕНИЕ: Если общая потребность равна общему запасу, т.е. Σaᵢ = Σbⱼ, то модель называется закрытой.",
                "formulas_text": [
                    "F = ΣᵢΣⱼ cᵢⱼ · xᵢⱼ → min",
                    "Σⱼ xᵢⱼ = aᵢ",
                    "Σᵢ xᵢⱼ = bⱼ",
                    "Σaᵢ = Σbⱼ",
                    "N = m + n - 1"
                ]
            },
            {
                "id": "section2",
                "title": "2. Метод потенциалов",
                "content": "Метод потенциалов используется для проверки оптимальности опорного плана и его улучшения.\n\nАлгоритм:\n1. Строят опорный план (северо-западным углом или минимальным элементом)\n2. Находят потенциалы uᵢ и vⱼ из системы uᵢ + vⱼ = cᵢⱼ для базисных клеток\n3. Вычисляют оценки Δᵢⱼ = uᵢ + vⱼ - cᵢⱼ\n4. Если все Δᵢⱼ ≤ 0, план оптимален\n5. Если есть Δᵢⱼ > 0, строят цикл пересчёта и улучшают план",
                "formulas_text": [
                    "uᵢ + vⱼ = cᵢⱼ (для базисных клеток)",
                    "Δᵢⱼ = uᵢ + vⱼ - cᵢⱼ",
                    "θ = min{xᵢⱼ} по клеткам со знаком «-»"
                ]
            },
            {
                "id": "section3",
                "title": "3. Дополнительные ограничения",
                "content": "1. Запрещенные маршруты: тариф = M\n2. Обязательные поставки: корректируют запасы и потребности\n3. Открытая модель: вводят фиктивного поставщика или потребителя"
            }
        ],
        "example": {
            "title": "Пример решения",
            "description": "Задача с 3 поставщиками и 3 потребителями",
            "supply": [70, 100, 110],
            "demand": [80, 50, 150],
            "total_supply": 280,
            "total_demand": 280,
            "explanation": "Сначала проверяем баланс: сумма запасов = сумме потребностей = 280. Затем строим опорный план методом минимального элемента, после чего применяем метод потенциалов."
        },
        "literature": [
            "Ваулин А.Е. Методы цифровой обработки данных. — СПб.: ВИККИ, 1993.",
            "Таха Х.А. Введение в исследование операций. — М.: Вильямс, 2005."
        ]
    }


def solve_transport():
    result = None
    error = None
    theory = load_theory()
    
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
            plan_nw, cost_nw, steps_nw, nw_degenerate = northwest_corner_full(supply[:], demand[:], costs)
            
            # Минимальный элемент
            plan_me, cost_me, steps_me, me_degenerate = min_element_full(supply[:], demand[:], costs)
            
            # Метод потенциалов для обоих планов
            plan_opt_nw, cost_opt_nw, iterations_nw = potential_method_full(costs, plan_nw)
            plan_opt_me, cost_opt_me, iterations_me = potential_method_full(costs, plan_me)
            
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
            
            result = {
                'northwest_plan': plan_nw,
                'northwest_cost': round(cost_nw, 2),
                'northwest_steps': steps_nw,
                'northwest_degenerate': nw_degenerate,
                'mincost_plan': plan_me,
                'mincost_cost': round(cost_me, 2),
                'mincost_steps': steps_me,
                'mincost_degenerate': me_degenerate,
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
    
    degenerate_info = {
        'is_degenerate': is_degenerate,
        'basic_cells': basic_cells,
        'expected_basic': expected_basic,
        'message': f"⚠️ План вырожденный! Базисных клеток {basic_cells} вместо {expected_basic}" if is_degenerate else f"✅ План невырожденный (базисных клеток: {basic_cells} из {expected_basic})"
    }
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost, steps, degenerate_info


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
    
    degenerate_info = {
        'is_degenerate': is_degenerate,
        'basic_cells': basic_cells,
        'expected_basic': expected_basic,
        'message': f"⚠️ План вырожденный! Базисных клеток {basic_cells} вместо {expected_basic}" if is_degenerate else f"✅ План невырожденный (базисных клеток: {basic_cells} из {expected_basic})"
    }
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost, steps, degenerate_info


def find_cycle(basis, start_i, start_j, n, m):
    """Поиск цикла пересчёта с помощью DFS"""
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


def potential_method_full(costs, initial_plan):
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
        
        deltas = []
        enter_i, enter_j = -1, -1
        max_delta = 0
        
        for i in range(n):
            for j in range(m):
                if plan[i][j] == 0:
                    delta = u[i] + v[j] - costs[i][j]
                    deltas.append({
                        'cell': f"({i+1}, {j+1})",
                        'ui': round(u[i], 2),
                        'vj': round(v[j], 2),
                        'cij': costs[i][j],
                        'delta': round(delta, 2),
                        'formula': f"{round(u[i],2)} + {round(v[j],2)} - {costs[i][j]} = {round(delta,2)}"
                    })
                    if delta > max_delta:
                        max_delta = delta
                        enter_i, enter_j = i, j
        
        iteration = {
            'iteration': iteration_num,
            'potentials_u': [round(x, 2) for x in u],
            'potentials_v': [round(x, 2) for x in v],
            'potentials_explanation': "Потенциалы найдены из системы uᵢ + vⱼ = cᵢⱼ для базисных клеток. Приняли u₁ = 0.",
            'deltas': deltas,
            'max_delta': round(max_delta, 2),
            'enter_cell': f"({enter_i+1}, {enter_j+1})" if enter_i != -1 else "нет",
            'enter_explanation': f"Выбрана клетка ({enter_i+1}, {enter_j+1}) с Δ = {round(max_delta,2)}",
            'check_optimal': "✅ План оптимален!" if max_delta <= 0 else "⚠️ Требуется улучшение."
        }
        
        if max_delta <= 0:
            iteration['status'] = 'optimal'
            iterations.append(iteration)
            break
        
        cycle = find_cycle(basis, enter_i, enter_j, n, m)
        
        if cycle:
            cycle_description = "Цикл строится из свободной клетки по базисным."
            
            min_val = float('inf')
            for (i, j, sign) in cycle:
                if sign == -1:
                    if plan[i][j] < min_val:
                        min_val = plan[i][j]
            
            if min_val != float('inf') and min_val > 0:
                for (i, j, sign) in cycle:
                    if sign == 1:
                        plan[i][j] += min_val
                    elif sign == -1:
                        plan[i][j] -= min_val
                        if plan[i][j] < 0:
                            plan[i][j] = 0
                
                cycle_visual = []
                for idx, (i, j, sign) in enumerate(cycle):
                    cycle_visual.append({
                        'cell': f"({i+1},{j+1})",
                        'sign': '+' if sign == 1 else '-'
                    })
                
                iteration['cycle'] = {
                    'cells': cycle_visual,
                    'theta': min_val,
                    'theta_explanation': f"θ = {min_val}",
                    'description': cycle_description,
                    'redistribution': f"Перераспределено {min_val} единиц"
                }
        
        iterations.append(iteration)
    
    total_cost = 0
    for i in range(n):
        for j in range(m):
            total_cost += plan[i][j] * costs[i][j]
    
    return plan, total_cost, iterations