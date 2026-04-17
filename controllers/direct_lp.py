# -*- coding: utf-8 -*-
from bottle import request, template, response
import numpy as np
import json
import os
from datetime import datetime
from utils.json_loader import load_theory


# ==================== СИМПЛЕКС-МЕТОД ====================

def simplex_method(c, A, b, maximize=True):
    """
    Реализация симплекс-метода с двухфазным методом и правилом Блэнда.
    """
    
    def to_float_array(arr):
        return np.array(arr, dtype=float)
    
    def find_identity_basis(A_mat, m):
        used_rows = set()
        basis = []
        n_cols = A_mat.shape[1]
        
        for j in range(n_cols):
            col = A_mat[:, j]
            ones = np.sum(np.abs(col - 1) < 1e-10)
            zeros = np.sum(np.abs(col) < 1e-10)
            if ones == 1 and zeros == m - 1:
                row = np.where(np.abs(col - 1) < 1e-10)[0][0]
                if row not in used_rows:
                    used_rows.add(row)
                    basis.append(j)
        return basis if len(basis) == m else None

    def simplex_phase(c_vec, A_mat, b_vec, basis):
        m, n = A_mat.shape
        tableau = np.zeros((m + 1, n + 1))
        
        tableau[:m, :n] = A_mat
        tableau[:m, -1] = b_vec.flatten()
        
        c_B = np.array([c_vec[i] for i in basis])
        for j in range(n):
            tableau[-1, j] = c_B @ A_mat[:, j] - c_vec[j]
        tableau[-1, -1] = c_B @ b_vec.flatten()
        
        iteration = 0
        max_iter = 1000
        
        while iteration < max_iter:
            iteration += 1
            
            delta = tableau[-1, :-1]
            if np.all(delta >= -1e-10):
                break
            
            neg_indices = np.where(delta < -1e-10)[0]
            pivot_col = neg_indices[0]
            
            ratios = []
            for i in range(m):
                if tableau[i, pivot_col] > 1e-10:
                    ratio = tableau[i, -1] / tableau[i, pivot_col]
                    ratios.append((ratio, i))
            
            if not ratios:
                return {'success': False, 'error': 'F → ∞ (неограничена)'}
            
            min_ratio = min(r[0] for r in ratios)
            candidates = [r for r in ratios if abs(r[0] - min_ratio) < 1e-10]
            candidates.sort(key=lambda x: basis[x[1]])
            pivot_row = candidates[0][1]
            
            pivot_val = tableau[pivot_row, pivot_col]
            tableau[pivot_row, :] /= pivot_val
            
            for i in range(m + 1):
                if i != pivot_row:
                    factor = tableau[i, pivot_col]
                    tableau[i, :] -= factor * tableau[pivot_row, :]
            
            basis[pivot_row] = pivot_col
        
        if iteration >= max_iter:
            return {'success': False, 'error': 'Зацикливание'}
        
        return {'success': True, 'tableau': tableau, 'basis': basis, 'iterations': iteration}

    m = len(A)
    n = len(c)
    
    A_mat = to_float_array(A)
    b_vec = to_float_array(b).reshape(-1, 1)
    c_vec = to_float_array(c)
    
    if maximize:
        c_vec = -c_vec
    
    basis = find_identity_basis(A_mat, m)
    
    if basis is None:
        artificial_cols = []
        used_rows = set()
        basis = []
        
        for j in range(n):
            col = A_mat[:, j]
            if np.sum(np.abs(col - 1) < 1e-10) == 1 and np.sum(np.abs(col) < 1e-10) == m - 1:
                row = np.where(np.abs(col - 1) < 1e-10)[0][0]
                if row not in used_rows:
                    used_rows.add(row)
                    basis.append(j)
        
        I_m = np.eye(m)
        for i in range(m):
            if i not in used_rows:
                new_col = I_m[:, i].reshape(-1, 1)
                A_mat = np.hstack([A_mat, new_col])
                artificial_cols.append(A_mat.shape[1] - 1)
                basis.append(A_mat.shape[1] - 1)
                used_rows.add(i)
        
        c_aux = np.zeros(A_mat.shape[1])
        for idx in artificial_cols:
            c_aux[idx] = 1.0
        
        phase1 = simplex_phase(c_aux, A_mat, b_vec, basis)
        
        if not phase1['success']:
            return phase1
        
        opt_val = phase1['tableau'][-1, -1]
        if abs(opt_val) > 1e-8:
            return {'success': False, 'error': 'Система несовместна (∅)'}
        
        basis = phase1['basis']
        for art_idx in artificial_cols:
            if art_idx in basis:
                pos = basis.index(art_idx)
                if abs(phase1['tableau'][pos, -1]) > 1e-8:
                    return {'success': False, 'error': 'Не удалось исключить искусственную переменную'}
        
        A_mat = A_mat[:, :n]
        c_phase2 = c_vec
    else:
        c_phase2 = c_vec
    
    phase2 = simplex_phase(c_phase2, A_mat, b_vec, basis)
    
    if not phase2['success']:
        return phase2
    
    tableau = phase2['tableau']
    basis = phase2['basis']
    
    solution = np.zeros(n)
    for i, b_idx in enumerate(basis):
        if b_idx < n:
            solution[b_idx] = tableau[i, -1]
    
    optimal_value = tableau[-1, -1]
    if maximize:
        optimal_value = -optimal_value
    
    return {
        'success': True,
        'solution': solution.tolist(),
        'value': float(optimal_value),
        'iterations': phase2.get('iterations', 0)
    }


# ==================== ПОШАГОВЫЙ РЕШАТЕЛЬ ====================

class SimplexStepSolver:
    """Пошаговый решатель симплекс-метода"""
    
    def __init__(self, c, A, b, maximize=True):
        self.c_orig = np.array(c, dtype=float)
        self.A_orig = np.array(A, dtype=float)
        self.b_orig = np.array(b, dtype=float).reshape(-1, 1)
        self.maximize = maximize
        
        self.current_step = 1
        self.phase = 1
        self.artificial_cols = []
        self.original_n = len(c)
        self.m = len(A)
        
        self._init_canonical()
        self._init_basis()
        
    def _init_canonical(self):
        self.A_mat = self.A_orig.copy()
        self.b_vec = self.b_orig.copy()
        self.c_vec = self.c_orig.copy()
        if self.maximize:
            self.c_vec = -self.c_vec
            
    def _init_basis(self):
        m = self.m
        n = self.A_mat.shape[1]
        
        used_rows = set()
        self.basis = []
        
        for j in range(n):
            col = self.A_mat[:, j]
            ones = np.sum(np.abs(col - 1) < 1e-10)
            zeros = np.sum(np.abs(col) < 1e-10)
            if ones == 1 and zeros == m - 1:
                row = np.where(np.abs(col - 1) < 1e-10)[0][0]
                if row not in used_rows:
                    used_rows.add(row)
                    self.basis.append(j)
        
        if len(self.basis) == m:
            self.has_artificial = False
            self.phase = 2
        else:
            self.has_artificial = True
            self.phase = 1
            I_m = np.eye(m)
            
            for i in range(m):
                if i not in used_rows:
                    new_col = I_m[:, i].reshape(-1, 1)
                    self.A_mat = np.hstack([self.A_mat, new_col])
                    self.artificial_cols.append(self.A_mat.shape[1] - 1)
                    self.basis.append(self.A_mat.shape[1] - 1)
                    used_rows.add(i)
            
            self.c_aux = np.zeros(self.A_mat.shape[1])
            for idx in self.artificial_cols:
                self.c_aux[idx] = 1.0
            self.c_current = self.c_aux
        self._build_tableau()
        
    def _build_tableau(self):
        m, n = self.A_mat.shape
        self.tableau = np.zeros((m + 1, n + 1))
        self.tableau[:m, :n] = self.A_mat
        self.tableau[:m, -1] = self.b_vec.flatten()
        
        c_B = np.array([self.c_current[i] for i in self.basis])
        for j in range(n):
            self.tableau[-1, j] = c_B @ self.A_mat[:, j] - self.c_current[j]
        self.tableau[-1, -1] = c_B @ self.b_vec.flatten()
        
    def get_current_step_data(self):
        if self.current_step == 1:
            return self._step1_initial()
        elif self.current_step == 2:
            return self._step2_canonical()
        elif self.current_step == 3:
            return self._step3_basis()
        elif self.current_step == 4:
            return self._step4_tableau()
        else:
            return self._step_result()
            
    def _step1_initial(self):
        c_expr = ' + '.join([f'{v}·x{i+1}' for i, v in enumerate(self.c_orig)])
        constraints = []
        for i in range(self.m):
            row = ' + '.join([f'{self.A_orig[i][j]}·x{j+1}' for j in range(len(self.c_orig))])
            constraints.append(f'{row} = {self.b_orig[i][0]}')
        return {
            'step': 1,
            'title': 'Шаг 1: Исходная задача',
            'c_expr': c_expr,
            'constraints': constraints,
            'sense': 'max' if self.maximize else 'min',
            'vars': f'x₁, ..., x{len(self.c_orig)} ≥ 0'
        }
        
    def _step2_canonical(self):
        slack_vars = []
        artificial_vars = []
        if self.has_artificial:
            artificial_vars = [f'y{i+1}' for i in range(len(self.artificial_cols))]
        else:
            slack_vars = [f'x{len(self.c_orig)+i+1}' for i in range(self.m)]
        return {
            'step': 2,
            'title': 'Шаг 2: Приведение к каноническому виду',
            'slack_vars': slack_vars,
            'artificial_vars': artificial_vars,
            'matrix_A': self.A_mat.tolist(),
            'vector_b': self.b_vec.flatten().tolist()
        }
        
    def _step3_basis(self):
        basis_names = []
        for idx in self.basis:
            if idx < self.original_n:
                basis_names.append(f'x{idx+1}')
            else:
                basis_names.append(f'y{idx - self.original_n + 1}')
        free_vars = [f'x{i+1}' for i in range(self.original_n) if i not in self.basis]
        x0 = [0.0] * self.A_mat.shape[1]
        for i, b_idx in enumerate(self.basis):
            x0[b_idx] = self.b_vec[i, 0]
        return {
            'step': 3,
            'title': 'Шаг 3: Начальный допустимый базис',
            'basis_vars': basis_names,
            'free_vars': free_vars,
            'x0': x0[:self.original_n],
            'f0': float(self.tableau[-1, -1]) if self.phase == 2 else None,
            'phase': self.phase
        }
        
    def _step4_tableau(self):
        delta = self.tableau[-1, :-1]
        is_optimal = np.all(delta >= -1e-10)
        
        if is_optimal:
            if self.phase == 1 and self.has_artificial:
                opt_val = self.tableau[-1, -1]
                if abs(opt_val) > 1e-8:
                    return {'step': 'result', 'title': 'Результат', 'status': 'infeasible'}
                else:
                    self._transition_to_phase2()
                    return self._step4_tableau()
            else:
                return self._step_result()
        
        neg_indices = np.where(delta < -1e-10)[0]
        pivot_col = neg_indices[0]
        
        ratios = []
        for i in range(self.m):
            if self.tableau[i, pivot_col] > 1e-10:
                ratio = self.tableau[i, -1] / self.tableau[i, pivot_col]
                ratios.append((ratio, i))
        
        if not ratios:
            return {'step': 'result', 'title': 'Результат', 'status': 'unbounded'}
        
        min_ratio = min(r[0] for r in ratios)
        candidates = [r for r in ratios if abs(r[0] - min_ratio) < 1e-10]
        candidates.sort(key=lambda x: self.basis[x[1]])
        pivot_row = candidates[0][1]
        pivot_val = self.tableau[pivot_row, pivot_col]
        
        col_name = f'x{pivot_col+1}' if pivot_col < self.original_n else f'y{pivot_col - self.original_n + 1}'
        row_name = f'x{self.basis[pivot_row]+1}' if self.basis[pivot_row] < self.original_n else f'y{self.basis[pivot_row] - self.original_n + 1}'
        
        return {
            'step': 4,
            'title': f'Итерация',
            'tableau': self._tableau_to_dict(),
            'basis': [f'x{i+1}' if i < self.original_n else f'y{i-self.original_n+1}' for i in self.basis],
            'delta': delta.tolist(),
            'is_optimal': False,
            'pivot_col': pivot_col,
            'pivot_col_name': col_name,
            'pivot_row': pivot_row,
            'pivot_row_name': row_name,
            'pivot_val': float(pivot_val),
            'ratios': [(float(r[0]), r[1]) for r in ratios]
        }
        
    def _tableau_to_dict(self):
        m, n = self.tableau.shape
        headers = ['Базис', 'b']
        for j in range(n - 1):
            if j < self.original_n:
                headers.append(f'x{j+1}')
            else:
                headers.append(f'y{j - self.original_n + 1}')
        
        rows = []
        for i in range(m - 1):
            row_name = f'x{self.basis[i]+1}' if self.basis[i] < self.original_n else f'y{self.basis[i]-self.original_n+1}'
            row = [row_name] + [round(float(x), 4) for x in self.tableau[i, :]]
            rows.append(row)
        
        idx_row = ['F'] + [round(float(x), 4) for x in self.tableau[-1, :]]
        rows.append(idx_row)
        
        return {'headers': headers, 'rows': rows}
        
    def _transition_to_phase2(self):
        self.phase = 2
        keep_cols = list(range(self.original_n))
        self.A_mat = self.A_mat[:, keep_cols]
        self.c_current = self.c_vec
        new_basis = []
        for b in self.basis:
            if b < self.original_n:
                new_basis.append(b)
        self.basis = new_basis
        self._build_tableau()
        
    def next_step(self):
        data = self.get_current_step_data()
        
        if data.get('step') == 'result':
            return data
            
        if 'pivot_col' in data:
            self._do_iteration(data['pivot_col'], data['pivot_row'])
            self.current_step = 4
        else:
            self.current_step += 1
            
        return self.get_current_step_data()
        
    def _do_iteration(self, pivot_col, pivot_row):
        pivot_val = self.tableau[pivot_row, pivot_col]
        self.tableau[pivot_row, :] /= pivot_val
        
        for i in range(self.tableau.shape[0]):
            if i != pivot_row:
                factor = self.tableau[i, pivot_col]
                self.tableau[i, :] -= factor * self.tableau[pivot_row, :]
        
        self.basis[pivot_row] = pivot_col
        
    def prev_step(self):
        if self.current_step > 1:
            self.current_step -= 1
        return self.get_current_step_data()
        
    def _step_result(self):
        delta = self.tableau[-1, :-1]
        if np.any(delta < -1e-10):
            status = 'not_optimal'
        else:
            status = 'optimal'
            
        solution = np.zeros(self.original_n)
        for i, b_idx in enumerate(self.basis):
            if b_idx < self.original_n:
                solution[b_idx] = self.tableau[i, -1]
        
        opt_val = self.tableau[-1, -1]
        if self.maximize:
            opt_val = -opt_val
            
        return {
            'step': 'result',
            'title': 'Результат решения',
            'status': status,
            'solution': solution.tolist(),
            'optimal_value': float(opt_val),
            'tableau_final': self._tableau_to_dict()
        }


# ==================== ХРАНЕНИЕ СЕССИЙ ====================

_step_solvers = {}

def get_step_solver(session_id):
    return _step_solvers.get(session_id)

def create_step_solver(session_id, c, A, b, maximize):
    _step_solvers[session_id] = SimplexStepSolver(c, A, b, maximize)
    return _step_solvers[session_id]


# ==================== ОСНОВНОЙ ОБРАБОТЧИК ====================

def solve_direct_lp():
    theory = load_theory('direct')
    
    # Значения по умолчанию
    default_c = "3,5"
    default_rows = 2
    default_cols = 2
    default_A = [[1, 0], [0, 2]]
    default_b = [4, 12]
    default_sense = "max"
    
    saved_data = request.get_cookie('direct_lp_data')
    if saved_data:
        try:
            saved = json.loads(saved_data)
            saved_c = saved.get('c', default_c)
            saved_rows = saved.get('rows', default_rows)
            saved_cols = saved.get('cols', default_cols)
            saved_A = saved.get('A', default_A)
            saved_b = saved.get('b', default_b)
            saved_sense = saved.get('sense', default_sense)
        except:
            saved_c, saved_rows, saved_cols = default_c, default_rows, default_cols
            saved_A, saved_b, saved_sense = default_A, default_b, default_sense
    else:
        saved_c, saved_rows, saved_cols = default_c, default_rows, default_cols
        saved_A, saved_b, saved_sense = default_A, default_b, default_sense
    
    result = None
    error = None
    step_data = None
    
    session_id = request.get_cookie('session_id')
    if not session_id:
        import uuid
        session_id = str(uuid.uuid4())
        response.set_cookie('session_id', session_id, path='/', max_age=2592000)
    
    if request.method == 'POST':
        action = request.forms.get('action', 'solve')
        
        try:
            c_str = request.forms.get('c', '')
            c = [float(x.strip()) for x in c_str.split(',') if x.strip()]
            
            rows = int(request.forms.get('rows', saved_rows))
            cols = int(request.forms.get('cols', saved_cols))
            
            A = []
            for i in range(rows):
                row = []
                for j in range(cols):
                    val = request.forms.get(f'A_{i}_{j}', '0')
                    row.append(float(val))
                A.append(row)
            
            b = []
            for i in range(rows):
                val = request.forms.get(f'b_{i}', '0')
                b.append(float(val))
            
            sense = request.forms.get('sense', 'max') == 'max'
            
            if action == 'solve':
                result = simplex_method(c, A, b, maximize=sense)
            elif action == 'step_init':
                solver = create_step_solver(session_id, c, A, b, sense)
                step_data = solver.get_current_step_data()
            elif action == 'step_next':
                solver = get_step_solver(session_id)
                if solver:
                    step_data = solver.next_step()
            elif action == 'step_prev':
                solver = get_step_solver(session_id)
                if solver:
                    step_data = solver.prev_step()
            
            save_data = {
                'c': c_str,
                'rows': rows,
                'cols': cols,
                'A': A,
                'b': b,
                'sense': 'max' if sense else 'min'
            }
            response.set_cookie('direct_lp_data', json.dumps(save_data), path='/', max_age=2592000)
            
            if result and not result.get('success'):
                error = result.get('error')
                
        except Exception as e:
            error = f"Ошибка при обработке данных: {str(e)}"
            result = None
    
    return template('direct_lp',
                   theory=theory,
                   c=saved_c,
                   rows=saved_rows,
                   cols=saved_cols,
                   A=saved_A,
                   b=saved_b,
                   sense=saved_sense,
                   result=result,
                   error=error,
                   step_data=step_data)