from bottle import request, template, response
from datetime import datetime
import json
import os
import math

EPS = 1e-10  # Точность для сравнения float

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
    data = {
        'suppliers': suppliers,
        'consumers': consumers,
        'supply': supply,
        'demand': demand,
        'costs': costs
    }
    response.set_cookie('transport_data', json.dumps(data), path='/', secret=None)

def load_form_data_from_cookie():
    saved_data = request.get_cookie('transport_data')
    if saved_data:
        try:
            saved = json.loads(saved_data)
            return saved
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
            
            plan_nw, cost_nw, steps_nw, nw_info = northwest_corner_full(supply_corr[:], demand_corr[:], costs_corr)
            plan_me, cost_me, steps_me, me_info = min_element_full(supply_corr[:], demand_corr[:], costs_corr)
            
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


def find_cycle_correct(basis, start_i, start_j, n, m):
    """
    ПРАВИЛЬНЫЙ поиск цикла пересчёта.
    Возвращает список клеток цикла с чередующимися знаками + и -
    """
    temp_basis = basis.copy()
    temp_basis.append((start_i, start_j))
    
    row_cells = {}
    col_cells = {}
    
    for (i, j) in temp_basis:
        if i not in row_cells:
            row_cells[i] = []
        row_cells[i].append(j)
        if j not in col_cells:
            col_cells[j] = []
        col_cells[j].append(i)
    
    for i in row_cells:
        row_cells[i].sort()
    for j in col_cells:
        col_cells[j].sort()
    
    visited = set()
    path = []
    
    def dfs(i, j, last_dir):
        if (i, j) in visited:
            return False
        visited.add((i, j))
        path.append((i, j))
        
        if len(path) >= 4 and (i, j) == (start_i, start_j):
            return True
        
        if last_dir != 'H':
            for nj in row_cells.get(i, []):
                if nj != j:
                    if dfs(i, nj, 'H'):
                        return True
        
        if last_dir != 'V':
            for ni in col_cells.get(j, []):
                if ni != i:
                    if dfs(ni, j, 'V'):
                        return True
        
        path.pop()
        visited.remove((i, j))
        return False
    
    if dfs(start_i, start_j, ''):
        if len(path) > 1 and path[-1] == (start_i, start_j):
            path = path[:-1]
        
        # Проверяем чередование знаков
        cycle = []
        for idx, (i, j) in enumerate(path):
            sign = 1 if idx % 2 == 0 else -1
            cycle.append((i, j, sign))
        
        # Дополнительная проверка: первая и последняя клетки должны быть с разными знаками
        if len(cycle) >= 2 and cycle[0][2] == cycle[-1][2]:
            # Если знаки одинаковые, корректируем
            for idx in range(len(cycle)):
                cycle[idx] = (cycle[idx][0], cycle[idx][1], cycle[idx][2] * (-1) ** idx)
        
        return cycle
    
    return None


def build_cycle_table_with_cycle(plan, cycle, n, m, enter_i, enter_j, costs):
    """Строит таблицу с визуализацией цикла - упрощённая версия для скорости"""
    import json as json_module
    
    cycle_data = []
    for (i, j, sign) in cycle:
        cycle_data.append({'i': i, 'j': j, 'sign': sign, 'value': round(plan[i][j], 2) if plan[i][j] > EPS else 0})
    
    # Простая таблица без лишних украшений
    table_html = '<div style="overflow-x: auto;">'
    table_html += '<table class="result-table" style="margin: 15px auto; border-collapse: collapse;">'
    table_html += '<thead><tr style="background: #EDE7F6;">'
    table_html += '<th style="padding: 8px; border: 1px solid #9B2226;">&nbsp;</th>'
    for j in range(m):
        table_html += f'<th style="padding: 8px; border: 1px solid #9B2226;">B{j+1}</th>'
    table_html += '</tr></thead><tbody>'
    
    for i in range(n):
        table_html += f'<tr><th style="padding: 8px; border: 1px solid #9B2226;">A{i+1}</th>'
        for j in range(m):
            value = round(plan[i][j], 2) if plan[i][j] > EPS else '—'
            is_enter = (i == enter_i and j == enter_j)
            in_cycle = any(ci == i and cj == j for (ci, cj, _) in cycle)
            
            if is_enter:
                bg = '#fff3cd'
                border = '2px solid #ff9800'
                sign_symbol = '★'
            elif in_cycle:
                sign_val = next((s for (ci, cj, s) in cycle if ci == i and cj == j), None)
                if sign_val == 1:
                    bg = '#e8f5e9'
                    border = '2px solid #4caf50'
                    sign_symbol = '+'
                elif sign_val == -1:
                    bg = '#ffebee'
                    border = '2px solid #f44336'
                    sign_symbol = '-'
                else:
                    bg = 'white'
                    border = '1px solid #ddd'
                    sign_symbol = ''
            else:
                bg = 'white'
                border = '1px solid #ddd'
                sign_symbol = ''
            
            table_html += f'<td style="padding: 8px; text-align: center; min-width: 60px; background-color: {bg}; border: {border};">'
            table_html += f'<strong>{value}</strong>'
            if sign_symbol:
                table_html += f'<span style="margin-left: 5px; font-weight: bold;">{sign_symbol}</span>'
            table_html += f'<br><small>c={costs[i][j]}</small>'
            table_html += '</td>'
        table_html += '</tr>'
    table_html += '</tbody></table></div>'
    
    # Canvas только для линий (упрощённый)
    canvas_id = f"cycleCanvas_{enter_i}_{enter_j}"
    canvas_html = f'''
    <div style="position: relative; margin: 15px 0; text-align: center;">
        <canvas id="{canvas_id}" width="500" height="300" style="border: 1px solid #9B2226; border-radius: 8px; background: white; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"></canvas>
    </div>
    <script>
    (function() {{
        const canvas = document.getElementById('{canvas_id}');
        if(!canvas) return;
        const ctx = canvas.getContext('2d');
        const n = {n};
        const m = {m};
        const cycleData = {json_module.dumps(cycle_data)};
        const enterCell = {{i: {enter_i}, j: {enter_j}}};
        
        const cellWidth = canvas.width / (m + 1);
        const cellHeight = canvas.height / (n + 1);
        
        function getCellCenter(i, j) {{
            return {{ x: (j + 1.5) * cellWidth, y: (i + 1.5) * cellHeight }};
        }}
        
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        // Сетка
        ctx.beginPath();
        ctx.strokeStyle = '#ccc';
        ctx.lineWidth = 1;
        for(let row = 0; row <= n; row++) {{
            ctx.moveTo(cellWidth, row * cellHeight);
            ctx.lineTo(canvas.width - cellWidth/2, row * cellHeight);
            ctx.stroke();
        }}
        for(let col = 0; col <= m; col++) {{
            ctx.moveTo((col + 0.5) * cellWidth, 0);
            ctx.lineTo((col + 0.5) * cellWidth, canvas.height);
            ctx.stroke();
        }}
        
        // Жирная точка
        const start = getCellCenter(enterCell.i, enterCell.j);
        ctx.beginPath();
        ctx.arc(start.x, start.y, 12, 0, 2 * Math.PI);
        ctx.fillStyle = '#ff9800';
        ctx.fill();
        ctx.beginPath();
        ctx.arc(start.x, start.y, 5, 0, 2 * Math.PI);
        ctx.fillStyle = '#fff';
        ctx.fill();
        
        // Линии цикла
        if(cycleData.length > 1) {{
            const points = cycleData.map(cell => getCellCenter(cell.i, cell.j));
            ctx.beginPath();
            ctx.strokeStyle = '#2196f3';
            ctx.lineWidth = 3;
            ctx.moveTo(points[0].x, points[0].y);
            for(let i = 1; i < points.length; i++) ctx.lineTo(points[i].x, points[i].y);
            ctx.lineTo(points[0].x, points[0].y);
            ctx.stroke();
        }}
        
        // Знаки
        cycleData.forEach(cell => {{
            const center = getCellCenter(cell.i, cell.j);
            ctx.font = 'bold 22px Arial';
            ctx.fillStyle = cell.sign === 1 ? '#4caf50' : '#f44336';
            ctx.fillText(cell.sign === 1 ? '+' : '-', center.x - 10, center.y - 12);
        }});
        
        // Подписи
        ctx.font = 'bold 14px Arial';
        ctx.fillStyle = '#9B2226';
        for(let i = 0; i < n; i++) ctx.fillText(`A${i+1}`, 10, (i + 1.5) * cellHeight);
        for(let j = 0; j < m; j++) ctx.fillText(`B${j+1}`, (j + 1.5) * cellWidth, 20);
    }})();
    </script>
    '''
    
    return table_html + canvas_html


def build_new_matrix_visual(plan, costs, n, m):
    """Визуализация новой матрицы - упрощённая"""
    table_html = '<div style="overflow-x: auto;">'
    table_html += '<table class="result-table" style="margin: 15px auto; border-collapse: collapse;">'
    table_html += '<thead><tr style="background: #EDE7F6;">'
    table_html += '<th style="padding: 8px; border: 1px solid #9B2226;">&nbsp;</th>'
    for j in range(m):
        table_html += f'<th style="padding: 8px; border: 1px solid #9B2226;">B{j+1}</th>'
    table_html += '</tr></thead><tbody>'
    
    for i in range(n):
        table_html += f'<tr><th style="padding: 8px; border: 1px solid #9B2226;">A{i+1}</th>'
        for j in range(m):
            value = round(plan[i][j], 2) if plan[i][j] > EPS else '—'
            table_html += f'<td style="padding: 8px; text-align: center; min-width: 60px; border: 1px solid #ddd;">'
            table_html += f'<strong>{value}</strong><br><small>c={costs[i][j]}</small>'
            table_html += '</td>'
        table_html += '</tr>'
    table_html += '</tbody></table></div>'
    return table_html


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
            <h3 style="margin: 0 0 15px 0;">📊 Сравнение начальных планов</h3>
            <p style="margin: 8px 0;">🔹 Метод северо-западного угла: стоимость = <strong>{cost_nw}</strong> ден. ед.</p>
            <p style="margin: 8px 0;">🔹 Метод минимального элемента: стоимость = <strong>{cost_me}</strong> ден. ед.</p>
            <div style="margin-top: 15px; padding: 10px; background: rgba(255,255,255,0.2); border-radius: 8px;">
                ✅ <strong>Выбран опорный план метода "{initial_method_name}"</strong><br>
                📌 Стоимость: <strong>{initial_cost} ден. ед.</strong>
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
            <strong>📝 Система уравнений:</strong><br>{sys_eq}{'<br>...' if len(basis) > 8 else ''}<br>
            <span style="color: #9B2226;">🔹 Принимаем u₁ = 0</span>
        </div>
        <div style="background: #e3f2fd; padding: 12px; border-radius: 8px; margin: 10px 0;">
            <strong>✨ Потенциалы:</strong><br>uᵢ = {[round(x,2) for x in u]}<br>vⱼ = {[round(x,2) for x in v]}
        </div>
        '''
        
        # Оценки
        deltas = []
        enter_i, enter_j = -1, -1
        max_delta = -float('inf')
        
        for i in range(n):
            for j in range(m):
                if plan[i][j] < EPS:
                    delta = u[i] + v[j] - costs[i][j]
                    # Округляем для избежания погрешностей
                    delta = round(delta, 6)
                    deltas.append({
                        'cell': f"({i+1},{j+1})",
                        'delta': delta,
                        'formula': f"{round(u[i],2)} + {round(v[j],2)} - {costs[i][j]} = {delta}",
                        'is_positive': delta > EPS
                    })
                    if delta > max_delta + EPS:
                        max_delta = delta
                        enter_i, enter_j = i, j
        
        current_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
        
        # Таблица оценок
        deltas_table = '<table class="result-table" style="margin: 10px 0;"><thead>'
        deltas_table += '<tr><th>Клетка</th><th>Формула</th><th>Оценка Δ</th></tr></thead><tbody>'
        for d in deltas:
            bg = '#ffeb3b' if d['is_positive'] else 'white'
            deltas_table += f'<tr style="background-color: {bg};">'
            deltas_table += f'<td style="padding: 6px;">{d["cell"]}</td>'
            deltas_table += f'<td style="padding: 6px;">{d["formula"]}</td>'
            deltas_table += f'<td style="padding: 6px; color: {"#28a745" if d["is_positive"] else "#333"};">{d["delta"]}</td>'
            deltas_table += '</tr>'
        deltas_table += '</tbody></table>'
        
        # Проверка оптимальности
        if max_delta <= EPS:
            iterations.append({
                'type': 'optimal',
                'iteration': iteration_num,
                'html': system_html + deltas_table + f'''
                <div style="background: #d4edda; padding: 15px; border-radius: 12px; margin: 15px 0; border: 2px solid #28a745;">
                    <h4 style="margin: 0;">🎉 ПЛАН ОПТИМАЛЕН!</h4>
                    <p>Все оценки Δᵢⱼ ≤ 0, дальнейшее улучшение невозможно.</p>
                    <p style="font-size: 1.2rem;">📌 Стоимость: <strong>{round(current_cost, 2)} ден. ед.</strong></p>
                </div>
                '''
            })
            break
        
        # Есть положительные оценки
        positive_html = f'''
        <div style="background: #fff3cd; padding: 12px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #ffc107;">
            <strong>⚠️ Найдена положительная оценка!</strong><br>
            📌 Δ = <strong>{round(max_delta, 6)}</strong> в клетке <strong>({enter_i+1}, {enter_j+1})</strong>
        </div>
        '''
        
        # Построение цикла
        temp_basis = basis + [(enter_i, enter_j)]
        cycle = find_cycle_correct(temp_basis, enter_i, enter_j, n, m)
        
        if not cycle:
            iterations.append({
                'type': 'error',
                'iteration': iteration_num,
                'html': system_html + deltas_table + positive_html + '<div style="background: #f8d7da; padding: 15px; border-radius: 12px;"><strong>❌ Ошибка:</strong> Не удалось построить цикл</div>'
            })
            break
        
        # Находим theta с проверкой на вырожденность
        theta = float('inf')
        for (i, j, sign) in cycle:
            if sign == -1:
                if plan[i][j] < theta - EPS:
                    theta = plan[i][j]
        
        # Проверка на theta == 0 (вырожденная задача)
        if theta <= EPS:
            iterations.append({
                'type': 'warning',
                'iteration': iteration_num,
                'html': system_html + deltas_table + positive_html + '''
                <div style="background: #fff3cd; padding: 15px; border-radius: 12px; margin: 10px 0;">
                    <strong>⚠️ ВНИМАНИЕ:</strong> Вырожденная задача! θ = 0, план уже оптимален.
                </div>
                '''
            })
            break
        
        # Визуализация цикла
        cycle_visual = build_cycle_table_with_cycle(plan, cycle, n, m, enter_i, enter_j, costs)
        
        # Перераспределение с корректным округлением
        new_plan = [row[:] for row in plan]
        for (i, j, sign) in cycle:
            new_plan[i][j] += sign * theta
            if abs(new_plan[i][j]) < EPS:
                new_plan[i][j] = 0.0
        
        new_cost = sum(new_plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
        new_matrix = build_new_matrix_visual(new_plan, costs, n, m)
        
        iterations.append({
            'type': 'iteration',
            'iteration': iteration_num,
            'html': system_html + deltas_table + positive_html + cycle_visual + f'''
            <div style="background: #e8f5e9; padding: 15px; border-radius: 12px; margin: 15px 0;">
                <h4 style="margin: 0 0 10px 0;">📊 Перераспределение</h4>
                <p>θ = <strong>{round(theta, 2)}</strong> (минимальная перевозка в клетках со знаком «-»)</p>
                <p><strong>Новая матрица:</strong></p>
                {new_matrix}
                <div style="font-size: 1.1rem; font-weight: bold; color: #28a745; margin-top: 10px;">
                    💰 Новая стоимость: <strong>{round(new_cost, 2)}</strong> ден. ед.<br>
                    📉 Уменьшение: <strong>{round(current_cost - new_cost, 2)}</strong> ден. ед.
                </div>
            </div>
            '''
        })
        
        plan = new_plan
        iteration_num += 1
    
    total_cost = sum(plan[i][j] * costs[i][j] for i in range(n) for j in range(m))
    return plan, total_cost, iterations