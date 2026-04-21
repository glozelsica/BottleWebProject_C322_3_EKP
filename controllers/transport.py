from bottle import request, template, response
from datetime import datetime
import json
import os

EPS = 1e-10

def load_theory():
    try:
        json_path = os.path.join('data', 'theory_transport.json')
        if os.path.exists(json_path):
            with open(json_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}
    except Exception as e:
        print(f"Ошибка загрузки теории: {e}")
        return {}

def save_form_data_to_cookie(suppliers, consumers, supply, demand, costs):
    data = {'suppliers': suppliers, 'consumers': consumers, 'supply': supply, 'demand': demand, 'costs': costs}
    response.set_cookie('transport_data', json.dumps(data), path='/', secret=None)

def load_form_data_from_cookie():
    saved_data = request.get_cookie('transport_data')
    if saved_data:
        try:
            return json.loads(saved_data)
        except:
            pass
    return None

def solve_transport():
    theory = load_theory()
    result = None
    error = None
    
    saved = load_form_data_from_cookie()
    if saved:
        default_suppliers = saved.get('suppliers', 3)
        default_consumers = saved.get('consumers', 3)
        default_supply = saved.get('supply', [70, 100, 110])
        default_demand = saved.get('demand', [80, 50, 150])
        default_costs = saved.get('costs', [[1,4,5],[3,5,2],[2,6,4]])
    else:
        default_suppliers = 3
        default_consumers = 3
        default_supply = [70, 100, 110]
        default_demand = [80, 50, 150]
        default_costs = [[1,4,5],[3,5,2],[2,6,4]]
    
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
            
            save_form_data_to_cookie(suppliers, consumers, supply, demand, costs)
            
            total_supply = sum(supply)
            total_demand = sum(demand)
            balanced = abs(total_supply - total_demand) < EPS
            
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
            
            plan_nw, cost_nw, steps_nw, nw_info = northwest_corner_full(supply_corr, demand_corr, costs_corr)
            plan_me, cost_me, steps_me, me_info = min_element_full(supply_corr, demand_corr, costs_corr)
            
            if cost_me <= cost_nw:
                best_initial_plan = plan_me
                best_initial_cost = cost_me
                best_initial_name = "минимального элемента"
            else:
                best_initial_plan = plan_nw
                best_initial_cost = cost_nw
                best_initial_name = "северо-западного угла"
            
            plan_opt, cost_opt, iterations_opt = potential_method_full(
                costs_corr, best_initial_plan, best_initial_name, 
                best_initial_cost, cost_nw, cost_me
            )
            
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
                'cost_nw': round(cost_nw, 2),
                'cost_me': round(cost_me, 2)
            }
            
        except Exception as e:
            error = str(e)
            import traceback
            traceback.print_exc()
    
    form_data = {
        'suppliers': default_suppliers,
        'consumers': default_consumers,
        'supply': default_supply,
        'demand': default_demand,
        'costs': default_costs
    }
    
    return template('transport', result=result, error=error, theory=theory, form_data=form_data, year=datetime.now().year)


def northwest_corner_full(supply, demand, costs):
    n, m = len(supply), len(demand)
    plan = [[0]*m for _ in range(n)]
    steps = []
    i, j = 0, 0
    step_num = 1
    s, d = supply[:], demand[:]
    
    while i < n and j < m:
        amount = min(s[i], d[j])
        plan[i][j] = amount
        steps.append({'step': step_num, 'cell': f"({i+1},{j+1})", 'amount': amount, 'formula': f"min({s[i]}, {d[j]}) = {amount}"})
        s[i] -= amount
        d[j] -= amount
        if abs(s[i]) < EPS:
            i += 1
        else:
            j += 1
        step_num += 1
    
    basic_cells = sum(1 for i in range(n) for j in range(m) if plan[i][j] > EPS)
    expected = n + m - 1
    info = {'is_degenerate': basic_cells < expected, 'basic_cells': basic_cells, 'expected_basic': expected,
            'message': f"⚠️ План вырожденный! Базисных клеток {basic_cells} вместо {expected}" if basic_cells < expected else f"✅ План невырожденный (базисных клеток: {basic_cells} из {expected})"}
    total_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
    return plan, total_cost, steps, info


def min_element_full(supply, demand, costs):
    n, m = len(supply), len(demand)
    plan = [[0]*m for _ in range(n)]
    s, d = supply[:], demand[:]
    steps = []
    cells = [(i, j, costs[i][j]) for i in range(n) for j in range(m)]
    cells.sort(key=lambda x: x[2])
    step_num = 1
    
    for i, j, cost in cells:
        if s[i] > EPS and d[j] > EPS:
            amount = min(s[i], d[j])
            plan[i][j] = amount
            steps.append({'step': step_num, 'cell': f"({i+1},{j+1})", 'cost': cost, 'amount': amount, 'formula': f"min({s[i]}, {d[j]}) = {amount}"})
            s[i] -= amount
            d[j] -= amount
            step_num += 1
    
    basic_cells = sum(1 for i in range(n) for j in range(m) if plan[i][j] > EPS)
    expected = n + m - 1
    info = {'is_degenerate': basic_cells < expected, 'basic_cells': basic_cells, 'expected_basic': expected,
            'message': f"⚠️ План вырожденный! Базисных клеток {basic_cells} вместо {expected}" if basic_cells < expected else f"✅ План невырожденный (базисных клеток: {basic_cells} из {expected})"}
    total_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
    return plan, total_cost, steps, info


def find_cycle_simple(plan, enter_i, enter_j, n, m):
    """Упрощённый поиск цикла пересчёта"""
    # Ищем первую базисную клетку в той же строке
    j2 = None
    for j in range(m):
        if plan[enter_i][j] > EPS and j != enter_j:
            j2 = j
            break
    
    # Ищем базисную клетку в том же столбце
    i2 = None
    for i in range(n):
        if plan[i][enter_j] > EPS and i != enter_i:
            i2 = i
            break
    
    if j2 is not None and i2 is not None:
        # Проверяем, есть ли базисная клетка на пересечении
        if plan[i2][j2] > EPS:
            return [
                (enter_i, enter_j, 1),   # +
                (enter_i, j2, -1),       # -
                (i2, j2, 1),             # +
                (i2, enter_j, -1)        # -
            ]
    
    return None


def build_cycle_table(plan, cycle, costs, n, m, enter_i, enter_j):
    """Построение таблицы с визуализацией цикла"""
    html = '<div style="overflow-x: auto; margin: 15px 0;"><table class="result-table" style="border-collapse: collapse; margin: 0 auto;">'
    html += '<thead><tr style="background: #EDE7F6;"><th></th>'
    for j in range(m):
        html += f'<th style="padding: 8px; border: 1px solid #9B2226;">B{j+1}</th>'
    html += '<th>Запасы</th></tr></thead><tbody>'
    
    for i in range(n):
        html += f'<tr><th style="padding: 8px; border: 1px solid #9B2226;">A{i+1}</th>'
        for j in range(m):
            val = round(plan[i][j], 2) if plan[i][j] > EPS else '—'
            cell_class = ''
            if i == enter_i and j == enter_j:
                cell_class = 'cycle-cell-enter'
            else:
                for (ci, cj, sign) in cycle:
                    if ci == i and cj == j:
                        cell_class = 'cycle-cell-plus' if sign == 1 else 'cycle-cell-minus'
                        break
            html += f'<td class="{cell_class}" style="padding: 8px; text-align: center; min-width: 60px; border: 1px solid #ddd;'
            if cell_class == 'cycle-cell-plus':
                html += ' background-color: #d4edda;'
            elif cell_class == 'cycle-cell-minus':
                html += ' background-color: #f8d7da;'
            elif cell_class == 'cycle-cell-enter':
                html += ' background-color: #fff3cd;'
            html += f'"><strong>{val}</strong><br><small>c={costs[i][j]}</small>'
            if cell_class == 'cycle-cell-plus':
                html += '<span style="margin-left: 5px; color: green;">(+)</span>'
            elif cell_class == 'cycle-cell-minus':
                html += '<span style="margin-left: 5px; color: red;">(-)</span>'
            elif cell_class == 'cycle-cell-enter':
                html += '<span style="margin-left: 5px; color: orange;">★</span>'
            html += '</td>'
        html += f'<td style="background:#e9ecef">{sum(plan[i])}</td>'
        html += '</tr>'
    
    html += '<tr><th>Потребности</th>'
    for j in range(m):
        html += f'<td style="background:#e9ecef">{sum(plan[i][j] for i in range(n))}</td>'
    html += '<td style="background:#e9ecef">—</td>'
    html += '</tr>'
    html += '</tbody></table></div>'
    return html


def potential_method_full(costs, initial_plan, initial_method_name, initial_cost, cost_nw, cost_me):
    n, m = len(costs), len(costs[0])
    plan = [row[:] for row in initial_plan]
    iterations = []
    iteration_num = 1
    max_iterations = 30
    
    # Сравнение начальных планов
    iterations.append({
        'type': 'comparison',
        'html': f'''
        <div style="background: linear-gradient(135deg, #9b59b6, #8e44ad); color: white; padding: 20px; border-radius: 12px; margin-bottom: 20px;">
            <h3 style="margin: 0 0 15px 0;">Сравнение начальных планов</h3>
            <p style="margin: 8px 0;">Метод северо-западного угла: стоимость = <strong>{round(cost_nw, 2)}</strong> ден. ед.</p>
            <p style="margin: 8px 0;">Метод минимального элемента: стоимость = <strong>{round(cost_me, 2)}</strong> ден. ед.</p>
            <div style="margin-top: 15px; padding: 10px; background: rgba(255,255,255,0.2); border-radius: 8px;">
                <strong>Выбран опорный план метода "{initial_method_name}"</strong><br>
                Стоимость: <strong>{round(initial_cost, 2)} ден. ед.</strong>
            </div>
        </div>
        '''
    })
    
    while iteration_num <= max_iterations:
        basis = [(i, j) for i in range(n) for j in range(m) if plan[i][j] > EPS]
        
        # Расчёт потенциалов
        u, v = [None]*n, [None]*m
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
        u = [x if x is not None else 0 for x in u]
        v = [x if x is not None else 0 for x in v]
        
        # Система уравнений
        sys_eq = '<br>'.join([f"u{i+1} + v{j+1} = {costs[i][j]}" for (i, j) in basis[:8]])
        system_html = f'''
        <div style="background: #f0f0f0; padding: 12px; border-radius: 8px; margin: 10px 0;">
            <strong>Система уравнений:</strong><br>{sys_eq}{'<br>...' if len(basis) > 8 else ''}<br>
            <span style="color: #9B2226;">Принимаем u₁ = 0</span>
        </div>
        <div style="background: #e3f2fd; padding: 12px; border-radius: 8px; margin: 10px 0;">
            <strong>Найденные потенциалы:</strong><br>uᵢ = {[round(x,2) for x in u]}<br>vⱼ = {[round(x,2) for x in v]}
        </div>
        '''
        
        # Вычисление оценок
        deltas = []
        enter_i, enter_j = -1, -1
        max_delta = -float('inf')
        for i in range(n):
            for j in range(m):
                if plan[i][j] < EPS:
                    delta = round(u[i] + v[j] - costs[i][j], 6)
                    deltas.append({'cell': f"({i+1},{j+1})", 'delta': delta, 
                                   'formula': f"{round(u[i],2)} + {round(v[j],2)} - {costs[i][j]} = {delta}", 
                                   'is_positive': delta > EPS})
                    if delta > max_delta + EPS:
                        max_delta = delta
                        enter_i, enter_j = i, j
        
        current_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
        
        # Таблица оценок
        deltas_table = '<table class="result-table" style="margin: 10px 0;"><thead>'
        deltas_table += '<tr><th>Клетка</th><th>Формула</th><th>Оценка Δ</th></tr></thead><tbody>'
        for d in deltas:
            bg = '#ffeb3b' if d['is_positive'] else 'white'
            deltas_table += f'<tr style="background-color: {bg};"><td style="padding: 6px;">{d["cell"]}</td>'
            deltas_table += f'<td style="padding: 6px;">{d["formula"]}</td>'
            deltas_table += f'<td style="padding: 6px;">{d["delta"]}</td></tr>'
        deltas_table += '</tbody></table>'
        
        # Проверка оптимальности
        if max_delta <= EPS:
            iterations.append({
                'type': 'optimal',
                'iteration': iteration_num,
                'html': system_html + deltas_table + f'''
                <div style="background: #d4edda; padding: 15px; border-radius: 12px; margin: 15px 0; border: 2px solid #28a745;">
                    <h4 style="margin: 0;">ПЛАН ОПТИМАЛЕН!</h4>
                    <p>Все оценки Δᵢⱼ ≤ 0, дальнейшее улучшение невозможно.</p>
                    <p style="font-size: 1.2rem;">Стоимость: <strong>{round(current_cost, 2)} ден. ед.</strong></p>
                </div>
                '''
            })
            break
        
        # Есть положительная оценка
        positive_html = f'''
        <div style="background: #fff3cd; padding: 12px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #ffc107;">
            <strong>Найдена положительная оценка!</strong><br>
            Δ = <strong>{round(max_delta, 6)}</strong> в клетке <strong>({enter_i+1}, {enter_j+1})</strong><br>
            Это означает, что включение этой клетки в план позволит уменьшить общую стоимость перевозок.
        </div>
        '''
        
        # Построение цикла
        cycle = find_cycle_simple(plan, enter_i, enter_j, n, m)
        
        if not cycle:
            iterations.append({
                'type': 'error', 
                'iteration': iteration_num, 
                'html': system_html + deltas_table + positive_html + 
                '<div style="background: #f8d7da; padding: 15px; border-radius: 12px;"><strong>Ошибка:</strong> Не удалось построить цикл</div>'
            })
            break
        
        # Находим theta
        theta = float('inf')
        for (i, j, sign) in cycle:
            if sign == -1 and plan[i][j] < theta - EPS:
                theta = plan[i][j]
        if theta <= EPS:
            theta = 1
        
        # Визуализация цикла
        cycle_table = build_cycle_table(plan, cycle, costs, n, m, enter_i, enter_j)
        
        # Таблица изменений
        changes_table = '<table class="result-table" style="margin: 10px 0;"><thead>'
        changes_table += '<tr><th>Клетка</th><th>Знак</th><th>Было</th><th>Стало</th></tr></thead><tbody>'
        for (i, j, sign) in cycle:
            new_val = plan[i][j] + sign * theta
            changes_table += f'<tr><td style="text-align: center;">({i+1},{j+1})</td>'
            changes_table += f'<td style="text-align: center; font-weight: bold; color: {"green" if sign==1 else "red"};">{"+" if sign==1 else "-"}</td>'
            changes_table += f'<td style="text-align: center;">{round(plan[i][j], 2)}</td>'
            changes_table += f'<td style="text-align: center;">{round(new_val, 2)}</td></tr>'
        changes_table += '</tbody></table>'
        
        # Перераспределение
        new_plan = [row[:] for row in plan]
        for (i, j, sign) in cycle:
            new_plan[i][j] += sign * theta
            if abs(new_plan[i][j]) < EPS:
                new_plan[i][j] = 0.0
        
        new_cost = sum(new_plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
        
        # Новая матрица
        new_matrix = '<div style="overflow-x: auto; margin: 15px 0;"><table class="result-table" style="border-collapse: collapse; margin: 0 auto;">'
        new_matrix += '<thead><tr style="background: #EDE7F6;"><th></th>'
        for j in range(m):
            new_matrix += f'<th style="padding: 8px;">B{j+1}</th>'
        new_matrix += '<th>Запасы</th></tr></thead><tbody>'
        for i in range(n):
            new_matrix += f'<tr><th>A{i+1}</th>'
            for j in range(m):
                val = round(new_plan[i][j], 2) if new_plan[i][j] > EPS else '—'
                new_matrix += f'<td style="padding: 8px; text-align: center;"><strong>{val}</strong><br><small>c={costs[i][j]}</small></td>'
            new_matrix += f'<td style="background:#e9ecef">{sum(new_plan[i])}</td>'
            new_matrix += '</tr>'
        new_matrix += '</tbody></table></div>'
        
        iterations.append({
            'type': 'iteration',
            'iteration': iteration_num,
            'html': system_html + deltas_table + positive_html + f'''
            <div style="margin: 15px 0; padding: 10px; background: #e8e8e8; border-radius: 8px;">
                <p><strong>Построение цикла пересчёта:</strong></p>
                <p><em>Цикл пересчёта — это замкнутая ломаная линия, вершины которой расположены в занятых клетках. Знаки чередуются, начиная с «+» в вводимой клетке (отмечена ★).</em></p>
                {cycle_table}
                <p><strong>Цикл:</strong> {" → ".join([f"({i+1},{j+1})<sup>{'+' if s==1 else '-'}</sup>" for (i,j,s) in cycle])}</p>
                <p><strong>θ = {theta}</strong> — минимальная перевозка в клетках со знаком «-».</p>
                {changes_table}
                <p><strong>Новая матрица после перераспределения:</strong></p>
                {new_matrix}
                <div style="font-size: 1.1rem; font-weight: bold; color: #28a745; margin-top: 10px;">
                    Новая стоимость: <strong>{round(new_cost, 2)}</strong> ден. ед.<br>
                    Уменьшение: <strong>{round(current_cost - new_cost, 2)}</strong> ден. ед.
                </div>
            </div>
            '''
        })
        
        plan = new_plan
        iteration_num += 1
    
    total_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
    return plan, total_cost, iterations