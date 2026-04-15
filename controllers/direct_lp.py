from bottle import request, template, response, HTTPResponse
import numpy as np
import json
import os
from datetime import datetime
from utils.json_loader import load_theory
from utils.excel_exporter import export_to_excel, export_to_csv

def simplex_method_numpy(c, A, b, maximize=True):
    """
    Реализация симплекс-метода с использованием numpy
    
    Параметры:
    c - список коэффициентов целевой функции
    A - список списков (матрица ограничений)
    b - список правых частей
    maximize - True для максимизации, False для минимизации
    
    Возвращает:
    словарь с результатом решения
    """
    
    m = len(A)  # количество ограничений
    n = len(c)  # количество переменных
    
    if not maximize:
        c = [-x for x in c]
    
    A = np.array(A, dtype=float)
    b = np.array(b, dtype=float).reshape(-1, 1)
    c = np.array(c, dtype=float)
    
    # добавляем дополнительные переменные
    slack = np.eye(m)
    tableau = np.hstack([A, slack, b])
    
    # последняя строка (целевая функция)
    obj_row = np.hstack([-c, np.zeros(m), 0])
    tableau = np.vstack([tableau, obj_row])
    
    iteration = 0
    max_iterations = 100
    
    while iteration < max_iterations:
        iteration += 1
        
        # последняя строка без последнего элемента
        last_row = tableau[-1, :-1]
        
        # ищем отрицательные элементы в последней строке
        negative_indices = np.where(last_row < -1e-10)[0]
        
        if len(negative_indices) == 0:
            break
        
        # выбираем разрешающий столбец (наиболее отрицательный)
        pivot_col = negative_indices[np.argmin(last_row[negative_indices])]
        
        # ищем разрешающую строку
        ratios = []
        for i in range(m):
            if tableau[i, pivot_col] > 1e-10:
                ratio = tableau[i, -1] / tableau[i, pivot_col]
                ratios.append((ratio, i))
        
        if len(ratios) == 0:
            return {
                'success': False,
                'error': 'Задача не ограничена. Решение не существует.'
            }
        
        # выбираем строку с минимальным положительным отношением
        pivot_row = min(ratios, key=lambda x: x[0])[1]
        
        # делим разрешающую строку на разрешающий элемент
        pivot_val = tableau[pivot_row, pivot_col]
        tableau[pivot_row, :] = tableau[pivot_row, :] / pivot_val
        
        # обнуляем остальные строки
        for i in range(m + 1):
            if i != pivot_row:
                factor = tableau[i, pivot_col]
                tableau[i, :] = tableau[i, :] - factor * tableau[pivot_row, :]
    
    if iteration >= max_iterations:
        return {
            'success': False,
            'error': 'Превышено максимальное число итераций. Возможна вырожденность задачи.'
        }
    
    # извлекаем решение
    solution = np.zeros(n)
    for j in range(n):
        col = tableau[:m, j]
        if np.sum(np.abs(col - 1) < 1e-10) == 1 and np.sum(np.abs(col) < 1e-10) == m - 1:
            row = np.where(np.abs(col - 1) < 1e-10)[0][0]
            solution[j] = tableau[row, -1]
    
    optimal_value = tableau[-1, -1]
    if not maximize:
        optimal_value = -optimal_value
    
    return {
        'success': True,
        'solution': solution.tolist(),
        'value': float(optimal_value),
        'iterations': iteration
    }

def solve_direct_lp():
    theory = load_theory('direct')
    
    # значения по умолчанию
    default_c = "3,5"
    default_rows = 2
    default_cols = 2
    default_A = [[1, 0], [0, 2]]
    default_b = [4, 12]
    default_sense = "max"
    
    # загружаем сохранённые значения из cookie
    saved_data = request.get_cookie('direct_lp_data')
    if saved_data:
        try:
            import json
            saved = json.loads(saved_data)
            saved_c = saved.get('c', default_c)
            saved_rows = saved.get('rows', default_rows)
            saved_cols = saved.get('cols', default_cols)
            saved_A = saved.get('A', default_A)
            saved_b = saved.get('b', default_b)
            saved_sense = saved.get('sense', default_sense)
        except:
            saved_c = default_c
            saved_rows = default_rows
            saved_cols = default_cols
            saved_A = default_A
            saved_b = default_b
            saved_sense = default_sense
    else:
        saved_c = default_c
        saved_rows = default_rows
        saved_cols = default_cols
        saved_A = default_A
        saved_b = default_b
        saved_sense = default_sense
    
    result = None
    error = None
    
    if request.method == 'POST':
        try:
            # получаем данные из формы
            c_str = request.forms.get('c', '')
            c = [float(x.strip()) for x in c_str.split(',') if x.strip()]
            
            rows = int(request.forms.get('rows', saved_rows))
            cols = int(request.forms.get('cols', saved_cols))
            
            # матрица A
            A = []
            for i in range(rows):
                row = []
                for j in range(cols):
                    val = request.forms.get(f'A_{i}_{j}', '0')
                    row.append(float(val))
                A.append(row)
            
            # правые части b
            b = []
            for i in range(rows):
                val = request.forms.get(f'b_{i}', '0')
                b.append(float(val))
            
            sense = request.forms.get('sense', 'max') == 'max'
            
            # решаем задачу
            result = simplex_method_numpy(c, A, b, maximize=sense)
            
            # сохраняем в историю
            save_to_history(c, A, b, result, sense)
            
            # сохраняем в cookie
            import json
            save_data = {
                'c': c_str,
                'rows': rows,
                'cols': cols,
                'A': A,
                'b': b,
                'sense': 'max' if sense else 'min'
            }
            response.set_cookie('direct_lp_data', json.dumps(save_data), path='/', max_age=2592000)
            
            # если результат успешный, готовим данные для экспорта
            if result.get('success'):
                export_ready = True
            else:
                export_ready = False
                error = result.get('error')
            
        except Exception as e:
            error = f"Ошибка при обработке данных: {str(e)}"
            result = None
            # сохраняем введённые данные даже при ошибке
            try:
                import json
                save_data = {
                    'c': request.forms.get('c', ''),
                    'rows': int(request.forms.get('rows', 2)),
                    'cols': int(request.forms.get('cols', 2)),
                    'A': [[float(request.forms.get(f'A_{i}_{j}', '0')) for j in range(int(request.forms.get('cols', 2)))] for i in range(int(request.forms.get('rows', 2)))],
                    'b': [float(request.forms.get(f'b_{i}', '0')) for i in range(int(request.forms.get('rows', 2)))],
                    'sense': request.forms.get('sense', 'max')
                }
                response.set_cookie('direct_lp_data', json.dumps(save_data), path='/')
            except:
                pass
    
    return template('direct_lp',
                   theory=theory,
                   c=saved_c,
                   rows=saved_rows,
                   cols=saved_cols,
                   A=saved_A,
                   b=saved_b,
                   sense=saved_sense,
                   result=result,
                   error=error)

def save_to_history(c, A, b, result, sense):
    os.makedirs('data', exist_ok=True)
    with open('data/history_direct.txt', 'a', encoding='utf-8') as f:
        f.write(f"\n{'='*60}\n")
        f.write(f"Дата и время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Целевая функция: {c}\n")
        f.write(f"Матрица ограничений: {A}\n")
        f.write(f"Правые части: {b}\n")
        f.write(f"Направление оптимизации: {'максимизация' if sense else 'минимизация'}\n")
        if result.get('success'):
            f.write(f"Решение: x = {result['solution']}\n")
            f.write(f"Значение целевой функции: {result['value']}\n")
            f.write(f"Количество итераций: {result['iterations']}\n")
        else:
            f.write(f"Ошибка: {result.get('error', 'Неизвестная ошибка')}\n")
        f.write(f"{'='*60}\n")