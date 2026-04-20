from bottle import request, template
from datetime import datetime
import json
import os

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
            has_fictive = False
            
            if not balanced:
                if total_supply > total_demand:
                    demand_corr.append(total_supply - total_demand)
                    for i in range(suppliers):
                        costs_corr[i].append(0)
                    consumers += 1
                    has_fictive = True
                else:
                    supply_corr.append(total_demand - total_supply)
                    costs_corr.append([0] * consumers)
                    suppliers += 1
                    has_fictive = True
            
            # 1. Метод северо-западного угла
            plan_nw, cost_nw, steps_nw, nw_info = northwest_corner_full(supply_corr[:], demand_corr[:], costs_corr)
            
            # 2. Метод минимального элемента
            plan_me, cost_me, steps_me, me_info = min_element_full(supply_corr[:], demand_corr[:], costs_corr)
            
            # Сравниваем результаты и выбираем лучший начальный план
            if cost_me <= cost_nw:
                best_initial_plan = plan_me
                best_initial_cost = cost_me
                best_initial_name = "минимального элемента"
                best_initial_steps = steps_me
                best_initial_degenerate = me_info
            else:
                best_initial_plan = plan_nw
                best_initial_cost = cost_nw
                best_initial_name = "северо-западного угла"
                best_initial_steps = steps_nw
                best_initial_degenerate = nw_info
            
            # 3. Метод потенциалов для лучшего начального плана
            plan_opt, cost_opt, iterations_opt = potential_method_full(costs_corr, best_initial_plan, best_initial_name, best_initial_cost)
            
            # Обрезаем планы до исходной размерности если были фиктивные участники
            if has_fictive:
                if total_supply > total_demand:
                    plan_opt = [row[:-1] for row in plan_opt]
                else:
                    plan_opt = plan_opt[:-1]
            
            result = {
                'northwest_plan': plan_nw,
                'northwest_cost': round(cost_nw, 2),
                'northwest_steps': steps_nw,
                'northwest_degenerate': nw_info,
                'mincost_plan': plan_me,
                'mincost_cost': round(cost_me, 2),
                'mincost_steps': steps_me,
                'mincost_degenerate': me_info,
                'best_initial_plan': best_initial_plan,
                'best_initial_cost': round(best_initial_cost, 2),
                'best_initial_name': best_initial_name,
                'best_initial_steps': best_initial_steps,
                'best_initial_degenerate': best_initial_degenerate,
                'best_plan': plan_opt,
                'best_cost': round(cost_opt, 2),
                'best_iterations': iterations_opt,
                'suppliers': orig_suppliers,
                'consumers': orig_consumers,
                'supply': supply,
                'demand': demand,
                'costs': costs,
                'balanced': balanced,
                'total_supply': total_supply,
                'total_demand': total_demand,
                'has_fictive': has_fictive
            }
            
        except Exception as e:
            error = str(e)
            import traceback
            traceback.print_exc()
    
    return template('transport', result=result, error=error, theory=theory, year=datetime.now().year)


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
    
    row_neighbors = {}
    col_neighbors = {}
    
    for (i, j) in temp_basis:
        if i not in row_neighbors:
            row_neighbors[i] = []
        row_neighbors[i].append(j)
        if j not in col_neighbors:
            col_neighbors[j] = []
        col_neighbors[j].append(i)
    
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
        
        if direction != 'col':
            for nj in row_neighbors.get(i, []):
                if nj != j:
                    if dfs(i, nj, 'row'):
                        return True
        
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


def build_cycle_visual_matrix(plan, cycle, n, m, enter_i, enter_j):
    """
    Строит визуальное представление матрицы с циклом
    Возвращает HTML таблицу с отображением цикла
    """
    html = '<table class="cycle-visual-table" style="border-collapse: collapse; margin: 15px auto;">'
    html += '<thead><tr><th></th>'
    for j in range(m):
        html += f'<th style="padding: 8px; border: 1px solid #ddd;">B{j+1}</th>'
    html += '</tr></thead><tbody>'
    
    for i in range(n):
        html += f'<tr><th style="padding: 8px; border: 1px solid #ddd;">A{i+1}</th>'
        for j in range(m):
            cell_class = ""
            cell_style = "padding: 12px; border: 2px solid #9B2226; text-align: center; min-width: 70px;"
            
            # Проверяем, входит ли клетка в цикл
            cycle_cell = None
            for (ci, cj, sign) in cycle:
                if ci == i and cj == j:
                    cycle_cell = (sign, ci, cj)
                    break
            
            if cycle_cell:
                sign = cycle_cell[0]
                if i == enter_i and j == enter_j:
                    cell_class = "cycle-cell-enter"
                    cell_style += " background-color: #fff3cd; position: relative;"
                elif sign == 1:
                    cell_class = "cycle-cell-plus"
                    cell_style += " background-color: #d4edda; position: relative;"
                elif sign == -1:
                    cell_class = "cycle-cell-minus"
                    cell_style += " background-color: #f8d7da; position: relative;"
                
                value = plan[i][j] if plan[i][j] > 0 else '-'
                html += f'<td class="{cell_class}" style="{cell_style}">'
                html += f'<strong>{value}</strong>'
                if sign == 1:
                    html += '<span style="position: absolute; top: 2px; right: 5px; color: #28a745; font-weight: bold;">+</span>'
                elif sign == -1:
                    html += '<span style="position: absolute; top: 2px; right: 5px; color: #dc3545; font-weight: bold;">-</span>'
                if i == enter_i and j == enter_j:
                    html += '<span style="position: absolute; top: 2px; left: 5px; color: #ffc107; font-weight: bold;">★</span>'
                html += f'<br><small>(c={costs[i][j] if i < len(costs) and j < len(costs[0]) else 0})</small>'
                html += '</td>'
            else:
                value = plan[i][j] if plan[i][j] > 0 else '-'
                html += f'<td style="padding: 12px; border: 1px solid #ddd; text-align: center;">'
                html += f'<strong>{value}</strong><br><small>(c={costs[i][j] if i < len(costs) and j < len(costs[0]) else 0})</small>'
                html += '</td>'
        html += '</tr>'
    html += '</tbody></table>'
    return html


def potential_method_full(costs, initial_plan, initial_method_name, initial_cost):
    """
    Полноценный метод потенциалов с подробной визуализацией каждого шага
    """
    n = len(costs)
    m = len(costs[0])
    plan = [row[:] for row in initial_plan]
    iterations = []
    iteration_num = 1
    max_iterations = 30
    
    # Шаг 1: Сравнение начальных планов и выбор лучшего
    comparison_html = f'''
    <div style="background: linear-gradient(135deg, #9b59b6, #8e44ad); color: white; padding: 15px; border-radius: 12px; margin-bottom: 20px;">
        <h4 style="margin: 0 0 10px 0;">📊 Сравнение начальных планов</h4>
        <p style="margin: 5px 0;">Метод северо-западного угла: стоимость = {initial_cost} ден. ед.</p>
        <p style="margin: 5px 0;">Метод минимального элемента: стоимость = {initial_cost} ден. ед.</p>
        <p style="margin: 10px 0 0 0; font-weight: bold;">✅ Выбран опорный план метода "{initial_method_name}" (стоимость = {initial_cost} ден. ед.)</p>
    </div>
    '''
    iterations.append({'type': 'comparison', 'html': comparison_html})
    
    while iteration_num <= max_iterations:
        # Собираем базисные клетки
        basis = []
        for i in range(n):
            for j in range(m):
                if plan[i][j] > 0:
                    basis.append((i, j))
        
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
        
        # Формула для потенциалов
        potential_formula = '''
        <div style="background: #e8f5e9; padding: 12px; border-radius: 10px; margin: 10px 0; border-left: 4px solid #28a745;">
            <strong>📐 Формула для расчёта потенциалов:</strong><br>
            Для каждой базисной клетки выполняется равенство: <strong style="font-size: 1.1rem;">uᵢ + vⱼ = cᵢⱼ</strong>
        </div>
        '''
        
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
        
        # Построение системы уравнений
        system_eq = []
        for (i, j) in basis:
            if i == 0 and j == 0:
                system_eq.append(f"u₁ + v₁ = {costs[i][j]}")
            else:
                system_eq.append(f"u{i+1} + v{j+1} = {costs[i][j]}")
        
        system_html = f'''
        <div style="background: #f0f0f0; padding: 12px; border-radius: 10px; margin: 10px 0;">
            <strong>📝 Система уравнений для базисных клеток:</strong><br>
            {'<br>'.join(system_eq)}<br>
            <span style="color: #9B2226;">🔹 Принимаем u₁ = 0, затем последовательно находим остальные потенциалы.</span>
        </div>
        <div style="background: #e3f2fd; padding: 12px; border-radius: 10px; margin: 10px 0;">
            <strong>✨ Найденные потенциалы:</strong><br>
            Потенциалы поставщиков uᵢ = {[round(x, 2) for x in u]}<br>
            Потенциалы потребителей vⱼ = {[round(x, 2) for x in v]}
        </div>
        '''
        
        # Формула для оценок
        delta_formula = '''
        <div style="background: #fff3e0; padding: 12px; border-radius: 10px; margin: 10px 0; border-left: 4px solid #ff9800;">
            <strong>📐 Формула для расчёта оценок свободных клеток:</strong><br>
            <strong style="font-size: 1.1rem;">Δᵢⱼ = uᵢ + vⱼ - cᵢⱼ</strong>
        </div>
        '''
        
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
        
        # Условие оптимальности
        optimality_condition = '''
        <div style="background: #e8f5e9; padding: 12px; border-radius: 10px; margin: 10px 0; border-left: 4px solid #28a745;">
            <strong>✅ Критерий оптимальности:</strong><br>
            План является оптимальным, если все оценки Δᵢⱼ ≤ 0.
        </div>
        '''
        
        # Проверка на оптимальность
        is_optimal = max_delta <= 0
        current_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
        
        if is_optimal:
            optimal_html = f'''
            <div style="background: #d4edda; padding: 15px; border-radius: 12px; margin: 10px 0; border: 2px solid #28a745;">
                <strong>🎉 ПЛАН ОПТИМАЛЕН!</strong><br>
                Все оценки Δᵢⱼ ≤ 0, дальнейшее улучшение невозможно.<br>
                Текущая стоимость перевозок: <strong>{round(current_cost, 2)} ден. ед.</strong>
            </div>
            '''
            iterations.append({
                'type': 'optimal',
                'iteration': iteration_num,
                'html': potential_formula + system_html + delta_formula + optimality_condition + optimal_html,
                'is_optimal': True
            })
            break
        
        # Если есть положительная оценка
        positive_deltas = [d for d in deltas if d['is_positive']]
        positive_html = f'''
        <div style="background: #fff3cd; padding: 12px; border-radius: 10px; margin: 10px 0; border-left: 4px solid #ffc107;">
            <strong>⚠️ Обнаружены положительные оценки!</strong><br>
            Наибольшая положительная оценка Δ = {round(max_delta, 2)} в клетке ({enter_i+1}, {enter_j+1}).<br>
            Это означает, что включение этой клетки в план позволит уменьшить общую стоимость перевозок.
        </div>
        '''
        
        # Строим цикл пересчёта
        cycle = find_full_cycle(basis, enter_i, enter_j, n, m)
        
        if cycle:
            # Находим минимальное значение в клетках со знаком минус
            min_val = float('inf')
            for (i, j, sign) in cycle:
                if sign == -1:
                    if plan[i][j] < min_val:
                        min_val = plan[i][j]
            
            theta = min_val if min_val != float('inf') else 0
            
            # Строим визуализацию цикла
            cycle_visual = build_cycle_visual_matrix(plan, cycle, n, m, enter_i, enter_j)
            
            cycle_description = f'''
            <div style="background: #e8e8e8; padding: 15px; border-radius: 12px; margin: 15px 0;">
                <h4 style="margin: 0 0 10px 0;">🔄 Построение цикла пересчёта</h4>
                <p><strong>Цикл пересчёта</strong> — замкнутая ломаная линия по базисным клеткам. Вершины цикла отмечены знаками «+» и «-».</p>
                <p><strong>Построенный цикл:</strong></p>
                {cycle_visual}
                <p><strong>Вершины цикла:</strong> 
                { ' → '.join([f"({i+1},{j+1})<sup>{'+' if sign == 1 else '-'}</sup>" for (i, j, sign) in cycle]) }
                </p>
                <p><strong>🔢 θ (минимальная перевозка в клетках со знаком «-»):</strong> {theta}</p>
            </div>
            '''
            
            # Создаём новую матрицу после перераспределения
            new_plan = [row[:] for row in plan]
            for (i, j, sign) in cycle:
                new_plan[i][j] += sign * theta
                if new_plan[i][j] < 0:
                    new_plan[i][j] = 0
            
            new_cost = sum(new_plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
            
            # Визуализация новой матрицы
            new_plan_html = '<table class="result-table" style="margin: 15px auto;">'
            new_plan_html += '<thead><tr><th></th>'
            for j in range(m):
                new_plan_html += f'<th>B{j+1}</th>'
            new_plan_html += '<th>Запасы</th></tr></thead><tbody>'
            for i in range(n):
                new_plan_html += f'<tr><th>A{i+1}</th>'
                for j in range(m):
                    val = new_plan[i][j] if new_plan[i][j] > 0 else '-'
                    new_plan_html += f'<td><strong>{val}</strong><br><small>(c={costs[i][j]})</small></td>'
                new_plan_html += f'<td>{sum(plan[i][j] for j in range(m))}</td></tr>'
            new_plan_html += '</tbody></table>'
            
            redistribution_html = f'''
            <div style="background: #e8f5e9; padding: 15px; border-radius: 12px; margin: 15px 0;">
                <h4 style="margin: 0 0 10px 0;">📊 Перераспределение перевозок</h4>
                <p><strong>Правило перераспределения:</strong> к клеткам со знаком «+» прибавляем θ = {theta}, из клеток со знаком «-» вычитаем θ = {theta}.</p>
                <p><strong>Новая матрица перевозок:</strong></p>
                {new_plan_html}
                <p class="cost-decrease" style="font-size: 1.1rem; font-weight: bold; color: #28a745;">💰 Новая стоимость: {round(new_cost, 2)} ден. ед. (было: {round(current_cost, 2)} ден. ед., уменьшение на {round(current_cost - new_cost, 2)})</p>
            </div>
            '''
            
            iterations.append({
                'type': 'iteration',
                'iteration': iteration_num,
                'html': potential_formula + system_html + delta_formula + optimality_condition + positive_html + cycle_description + redistribution_html,
                'current_cost': round(current_cost, 2),
                'new_cost': round(new_cost, 2),
                'enter_cell': f"({enter_i+1}, {enter_j+1})",
                'max_delta': round(max_delta, 2),
                'theta': theta,
                'is_optimal': False
            })
            
            # Обновляем план для следующей итерации
            plan = new_plan
            
        else:
            error_html = '<div style="background: #f8d7da; padding: 15px; border-radius: 12px;"><strong>❌ Ошибка:</strong> Не удалось построить цикл пересчёта</div>'
            iterations.append({
                'type': 'error',
                'iteration': iteration_num,
                'html': error_html
            })
            break
        
        iteration_num += 1
    
    total_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
    return plan, total_cost, iterations