from bottle import request, template, response
import json
import os
from datetime import datetime

def simplex_method(c, A, b, maximize=True):
    m = len(A)
    n = len(c)
    
    if not maximize:
        c = [-x for x in c]
    
    tableau = []
    for i in range(m):
        row = A[i][:] + [0]*m + [b[i]]
        row[n + i] = 1
        tableau.append(row)
    
    last_row = [-x for x in c] + [0]*m + [0]
    tableau.append(last_row)
    
    iteration = 0
    max_iterations = 100
    
    while iteration < max_iterations:
        iteration += 1
        
        pivot_col = -1
        for j in range(n + m):
            if tableau[-1][j] < -1e-10:
                pivot_col = j
                break
        
        if pivot_col == -1:
            break
        
        pivot_row = -1
        min_ratio = float('inf')
        for i in range(m):
            if tableau[i][pivot_col] > 1e-10:
                ratio = tableau[i][-1] / tableau[i][pivot_col]
                if ratio < min_ratio:
                    min_ratio = ratio
                    pivot_row = i
        
        if pivot_row == -1:
            return {
                'success': False,
                'error': 'Задача не ограничена. Решение не существует.'
            }
        
        pivot_val = tableau[pivot_row][pivot_col]
        for j in range(n + m + 1):
            tableau[pivot_row][j] /= pivot_val
        
        for i in range(m + 1):
            if i != pivot_row:
                factor = tableau[i][pivot_col]
                for j in range(n + m + 1):
                    tableau[i][j] -= factor * tableau[pivot_row][j]
    
    if iteration >= max_iterations:
        return {
            'success': False,
            'error': 'Превышено максимальное число итераций.'
        }
    
    solution = [0] * n
    for j in range(n):
        for i in range(m):
            if abs(tableau[i][j] - 1) < 1e-10:
                is_basic = True
                for k in range(m):
                    if k != i and abs(tableau[k][j]) > 1e-10:
                        is_basic = False
                        break
                if is_basic:
                    solution[j] = tableau[i][-1]
                    break
    
    optimal_value = tableau[-1][-1]
    if not maximize:
        optimal_value = -optimal_value
    
    return {
        'success': True,
        'solution': [round(float(v), 6) for v in solution],
        'value': round(float(optimal_value), 6),
        'iterations': iteration
    }

def solve_direct_lp():
    default_c = "3,5"
    default_rows = 2
    default_cols = 2
    default_sense = "max"
    
    saved_data = request.get_cookie('direct_lp_data')
    if saved_data:
        try:
            saved = json.loads(saved_data)
            saved_c = saved.get('c', default_c)
            saved_rows = saved.get('rows', default_rows)
            saved_cols = saved.get('cols', default_cols)
            saved_sense = saved.get('sense', default_sense)
        except:
            saved_c = default_c
            saved_rows = default_rows
            saved_cols = default_cols
            saved_sense = default_sense
    else:
        saved_c = default_c
        saved_rows = default_rows
        saved_cols = default_cols
        saved_sense = default_sense
    
    result = None
    error = None
    
    if request.method == 'POST':
        try:
            c_str = request.forms.get('c', '')
            if c_str.strip():
                c = [float(x.strip()) for x in c_str.split(',') if x.strip()]
            else:
                c = [0, 0]
            
            rows = int(request.forms.get('rows', saved_rows))
            cols = int(request.forms.get('cols', saved_cols))
            
            A = []
            for i in range(rows):
                row = []
                for j in range(cols):
                    val = request.forms.get(f'A_{i}_{j}', '0')
                    try:
                        row.append(float(val))
                    except:
                        row.append(0.0)
                A.append(row)
            
            b = []
            for i in range(rows):
                val = request.forms.get(f'b_{i}', '0')
                try:
                    b.append(float(val))
                except:
                    b.append(0.0)
            
            sense = request.forms.get('sense', 'max') == 'max'
            
            result = simplex_method(c, A, b, maximize=sense)
            
            save_data = {
                'c': c_str,
                'rows': rows,
                'cols': cols,
                'sense': 'max' if sense else 'min'
            }
            response.set_cookie('direct_lp_data', json.dumps(save_data), path='/')
            
            if result.get('success'):
                os.makedirs('data', exist_ok=True)
                with open('data/history_direct.txt', 'a', encoding='utf-8') as f:
                    f.write(f"\n{'='*60}\n")
                    f.write(f"Дата: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                    f.write(f"Целевая функция: {c}\n")
                    f.write(f"Решение: x = {result['solution']}\n")
                    f.write(f"F = {result['value']}\n")
                    f.write(f"Итераций: {result['iterations']}\n")
                    f.write(f"{'='*60}\n")
            
        except Exception as e:
            error = f"Ошибка при обработке данных: {str(e)}"
            result = None
    
    return template('direct_lp',
                   c=saved_c,
                   rows=saved_rows,
                   cols=saved_cols,
                   sense=saved_sense,
                   result=result,
                   error=error)