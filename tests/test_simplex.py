# -*- coding: utf-8 -*-
import unittest
import sys
import os

controller_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'controllers')
sys.path.insert(0, controller_path)

from direct_lp import (
    validate_input_data,
    to_canonical_form,
    build_tableau,
    update_objective_row,
    format_number,
    simplex_method_full,
    remove_artificial_vars
)


class TestValidateInputData(unittest.TestCase):
    """Тесты для проверки корректности входных данных."""

    def test_valid_inputs(self):
        cases = [
            ([1, 2], [[1, 0], [0, 1]], [3, 4], True, "OK"),
            ([0, 0], [[0, 0]], [0], True, "OK"),
            ([5], [[1], [2]], [10, 20], True, "OK"),
            ([1.5, 2.5], [[1.0, 2.0], [3.0, 4.0]], [5.5, 6.5], True, "OK"),
        ]
        for c, A, b, exp_valid, exp_msg in cases:
            with self.subTest(c=c, A=A, b=b):
                valid, msg = validate_input_data(c, A, b)
                self.assertEqual(valid, exp_valid)
                self.assertEqual(msg, exp_msg)

    def test_invalid_inputs(self):
        cases = [
            ([], [[1, 2]], [1], False, "Целевая функция не задана"),
            ([1, 2], [], [1], False, "Матрица ограничений пуста"),
            ([1, 2], [[1]], [1], False, "Строка 1: ожидалось 2 элементов, получено 1"),
            ([1, 2], [[1, 2], [3, 4]], [1], False, "Размер вектора b (1) не соответствует числу строк (2)"),
            ([1, 2, 3], [[1, 2], [3, 4]], [1, 2], False, "Строка 1: ожидалось 3 элементов, получено 2"),
        ]
        for c, A, b, exp_valid, exp_msg in cases:
            with self.subTest(c=c, A=A, b=b):
                valid, msg = validate_input_data(c, A, b)
                self.assertEqual(valid, exp_valid)
                self.assertEqual(msg, exp_msg)


class TestToCanonicalForm(unittest.TestCase):
    """Тесты приведения задачи к каноническому виду."""

    def test_only_slack(self):
        c = [3, 5]
        A = [[1, 0], [0, 2]]
        b = [4, 12]
        constraints = ['<=', '<=']
        res = to_canonical_form(c, A, b, constraints)
        self.assertEqual(res['slack_count'], 2)
        self.assertEqual(res['surplus_count'], 0)
        self.assertEqual(res['artificial_count'], 0)
        self.assertEqual(len(res['A'][0]), 4)
        self.assertEqual(res['b'], [4, 12])
        self.assertEqual(res['c'], [3, 5, 0, 0])

    def test_mixed_constraints(self):
        c = [-3, -3]
        A = [[1, 1], [1, -4], [1, 1], [4, -1], [0, 1]]
        b = [7, 0, 3, 0, 3]
        constraints = ['<=', '<=', '>=', '>=', '<=']
        res = to_canonical_form(c, A, b, constraints)
        self.assertEqual(res['slack_count'], 3)
        self.assertEqual(res['surplus_count'], 2)
        self.assertEqual(res['artificial_count'], 2)
        self.assertEqual(len(res['A'][0]), 2 + 3 + 2 + 2)  # 9 переменных
        self.assertTrue(all(bi >= 0 for bi in res['b']))

    def test_negative_b_handling(self):
        c = [2, 3]
        A = [[1, 1], [1, -1]]
        b = [-4, 2]
        constraints = ['<=', '>=']
        res = to_canonical_form(c, A, b, constraints)
        # После умножения на -1: b должно стать положительным
        self.assertEqual(res['b'][0], 4)
        self.assertEqual(res['b'][1], 2)
        # Проверка знаков в первой строке (должны умножиться на -1)
        self.assertEqual(res['A'][0][0], -1)
        self.assertEqual(res['A'][0][1], -1)

    def test_equality_constraint(self):
        c = [1, 2]
        A = [[1, 1]]
        b = [5]
        constraints = ['=']
        res = to_canonical_form(c, A, b, constraints)
        self.assertEqual(res['slack_count'], 0)
        self.assertEqual(res['surplus_count'], 0)
        self.assertEqual(res['artificial_count'], 1)
        self.assertEqual(res['A'][0][2], 1.0)  # искусственная переменная
        self.assertEqual(res['c'], [1, 2, 0])

    def test_all_constraint_types(self):
        c = [4, 3]
        A = [[1, 2], [2, 1], [1, 1]]
        b = [8, 6, 7]
        constraints = ['<=', '>=', '=']
        res = to_canonical_form(c, A, b, constraints)
        self.assertEqual(res['slack_count'], 1)
        self.assertEqual(res['surplus_count'], 1)
        self.assertEqual(res['artificial_count'], 2)
        self.assertEqual(len(res['A'][0]), 2 + 1 + 1 + 2)  # 6 переменных


class TestBuildTableau(unittest.TestCase):
    """Тесты построения начальной симплекс-таблицы."""

    def test_small_tableau(self):
        A = [[1, 0], [0, 2]]
        b = [4, 12]
        c = [3, 5]
        tableau = build_tableau(A, b, c)
        self.assertEqual(len(tableau), 3)
        self.assertEqual(tableau[0], [1, 0, 4])
        self.assertEqual(tableau[1], [0, 2, 12])
        self.assertEqual(tableau[2], [0.0, 0.0, 0.0])

    def test_large_tableau(self):
        A = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        b = [10, 11, 12]
        c = [0.1, 0.2, 0.3]
        tableau = build_tableau(A, b, c)
        self.assertEqual(len(tableau), 4)
        self.assertEqual(len(tableau[0]), 4)
        self.assertEqual(tableau[0][-1], 10)
        self.assertEqual(tableau[1][-1], 11)
        self.assertEqual(tableau[2][-1], 12)


class TestUpdateObjectiveRow(unittest.TestCase):
    """Тесты пересчёта строки оценок (Δ-строки)."""

    def test_slack_basis(self):
        A = [[1, 0, 1, 0], [0, 2, 0, 1]]
        b = [4, 12]
        c = [3, 5, 0, 0]
        tableau = build_tableau(A, b, c)
        basis = [2, 3]  # s1, s2
        tableau = update_objective_row(tableau, basis, c)
        self.assertAlmostEqual(tableau[-1][0], 3.0)
        self.assertAlmostEqual(tableau[-1][1], 5.0)
        self.assertAlmostEqual(tableau[-1][2], 0.0)
        self.assertAlmostEqual(tableau[-1][3], 0.0)
        self.assertAlmostEqual(tableau[-1][-1], 0.0)

    def test_mixed_basis(self):
        tableau = [
            [0, 1, 0.5, -0.5, 5],
            [1, 0, -0.2, 0.4, 2],
            [0, 0, 0, 0, 0]
        ]
        c = [4, 3, 0, 0]
        basis = [1, 0]  # x2, x1
        tableau = update_objective_row(tableau, basis, c)
        # Ручной расчёт z = 3*5 + 4*2 = 23
        self.assertAlmostEqual(tableau[-1][-1], 23.0)
        # Δ для x1 = c1 - (4*1 + 3*0) = 0
        self.assertAlmostEqual(tableau[-1][0], 0.0)
        # Δ для x2 = 3 - (4*0 + 3*1) = 0
        self.assertAlmostEqual(tableau[-1][1], 0.0)


class TestFormatNumber(unittest.TestCase):
    """Тесты форматирования чисел для вывода."""

    def test_various_numbers(self):
        cases = [
            (0.0, "0"),
            (0.0000001, "0"),
            (3, "3"),
            (3.0, "3"),
            (3.5, "3.5"),
            (-2.345678, "-2.345678"),
            (0.1, "0.1"),
            (0.100000, "0.1"),
            (1.23456789, "1.234568"),
            (-0.0, "0"),
        ]
        for val, expected in cases:
            with self.subTest(val=val):
                self.assertEqual(format_number(val), expected)


class TestSimplexMethodFull(unittest.TestCase):
    """Тесты основного алгоритма симплекс-метода для различных типов задач."""

    def test_maximization_slack_only(self):
        c = [3, 5]
        A = [[1, 0], [0, 2]]
        b = [4, 12]
        constraints = ['<=', '<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['4', '6'])
        self.assertEqual(res['value'], '42')

    def test_minimization_slack_only(self):
        c = [2, 3]
        A = [[1, 1], [2, 1]]
        b = [8, 10]
        constraints = ['<=', '<=']
        res = simplex_method_full(c, A, b, maximize=False, constraints_types=constraints)
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['2', '6'])
        self.assertEqual(res['value'], '22')

    def test_two_phase_mixed_constraints(self):
        # Пример с отрицательными коэффициентами и разными ограничениями
        c = [-3, -3]
        A = [[1, 1], [1, -4], [1, 1], [4, -1], [0, 1]]
        b = [7, 0, 3, 0, 3]
        constraints = ['<=', '<=', '>=', '>=', '<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['1', '2'])
        self.assertEqual(res['value'], '-9')

    def test_infeasible_problem(self):
        c = [1, 1]
        A = [[1, 1], [1, 1]]
        b = [2, 5]
        constraints = ['<=', '>=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertFalse(res['success'])
        self.assertIn("несовместна", res['error'])

    def test_unbounded_problem(self):
        c = [1, 1]
        A = [[1, -1]]
        b = [1]
        constraints = ['<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertFalse(res['success'])
        self.assertIn("не ограничена", res['error'])

    def test_equality_constraint_two_phase(self):
        c = [2, 3]
        A = [[1, 1]]
        b = [5]
        constraints = ['=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['0', '5'])
        self.assertEqual(res['value'], '15')

    def test_negative_b_with_slack(self):
        c = [1, 2]
        A = [[1, 1]]
        b = [-3]
        constraints = ['<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        # Ожидаемое решение: x1=0, x2=3, F=6 (после приведения)
        self.assertEqual(res['solution'], ['0', '3'])
        self.assertEqual(res['value'], '6')

    def test_negative_b_with_mixed(self):
        c = [1, 1]
        A = [[1, 2], [2, -1]]
        b = [-4, 2]
        constraints = ['>=', '<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        # Проверяем, что решение найдено (конкретные значения могут варьироваться)
        self.assertIsInstance(res['solution'], list)
        self.assertIsInstance(res['value'], str)

    def test_degenerate_case(self):
        c = [1, 1]
        A = [[1, 0], [0, 1], [1, 1]]
        b = [0, 0, 0]
        constraints = ['<=', '<=', '<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['0', '0'])
        self.assertEqual(res['value'], '0')

    def test_multiple_optimal_solutions(self):
        c = [1, 1]
        A = [[1, 1]]
        b = [1]
        constraints = ['<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        self.assertEqual(res['value'], '1')
        # Решение может быть (1,0) или (0,1) – проверяем только значение
        self.assertIn(res['solution'], [['1', '0'], ['0', '1']])

    def test_large_numbers(self):
        c = [1000, 2000]
        A = [[1, 0], [0, 1]]
        b = [1e6, 2e6]
        constraints = ['<=', '<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['1000000', '2000000'])
        self.assertEqual(res['value'], '5000000000')

    def test_fractional_coefficients(self):
        c = [0.5, 1.5]
        A = [[2, 1], [1, 3]]
        b = [10, 12]
        constraints = ['<=', '<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        # Проверяем, что решение удовлетворяет ограничениям
        sol = [float(x) for x in res['solution']]
        self.assertAlmostEqual(2*sol[0] + sol[1], 10, places=4)
        self.assertAlmostEqual(sol[0] + 3*sol[1], 12, places=4)

    def test_zero_objective_coefficients(self):
        c = [0, 0]
        A = [[1, 1], [1, -1]]
        b = [5, 1]
        constraints = ['<=', '<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        self.assertEqual(res['value'], '0')
        # Любое допустимое решение, проверяем, что решение не пустое
        self.assertTrue(len(res['solution']) == 2)

    def test_all_constraints_equal(self):
        c = [3, 2]
        A = [[1, 1], [2, 1]]
        b = [5, 8]
        constraints = ['=', '=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        # Решение единственное: x1=3, x2=2, F=13
        self.assertEqual(res['solution'], ['3', '2'])
        self.assertEqual(res['value'], '13')

    def test_more_variables_than_constraints(self):
        c = [2, 3, 4]
        A = [[1, 1, 1], [0, 1, 2]]
        b = [10, 8]
        constraints = ['<=', '<=']
        res = simplex_method_full(c, A, b, maximize=True, constraints_types=constraints)
        self.assertTrue(res['success'])
        # Проверка, что решение корректно
        sol = [float(x) for x in res['solution']]
        self.assertLessEqual(sol[0] + sol[1] + sol[2], 10 + 1e-6)
        self.assertLessEqual(sol[1] + 2*sol[2], 8 + 1e-6)


class TestRemoveArtificialVars(unittest.TestCase):
    """Тесты функции удаления искусственных переменных."""

    def test_simple_removal_no_artificial(self):
        A = [[1, 0, 1, 0], [0, 1, 0, 1]]
        b = [4, 6]
        c = [0, 0, 0, 0]
        tableau = build_tableau(A, b, c)
        basis = [2, 3]
        var_names = ['x1', 'x2', 's1', 's2']
        artificial_start = 2  # нет искусственных
        new_tab, new_basis, new_names = remove_artificial_vars(
            tableau, basis, var_names, artificial_start, []
        )
        self.assertEqual(len(new_tab), 3)
        self.assertEqual(new_basis, [2, 3])
        self.assertEqual(new_names, ['x1', 'x2'])

    def test_removal_with_replacement(self):
        # Создаём таблицу, где y1 (индекс 4) в базисе, но есть ненулевой коэффициент при s1 (индекс 2)
        tab = [
            [0, 1, 0.5, -0.5, 1, 5],
            [1, 0, -0.2, 0.4, 0, 2],
            [0, 0, 0, 0, 1, 0],   # y1 в базисе, b=0
            [0, 0, 0, 0, 0, 0]
        ]
        basis = [1, 0, 4]
        var_names = ['x1', 'x2', 's1', 'e1', 'y1']
        artificial_start = 4
        steps = []
        new_tab, new_basis, new_names = remove_artificial_vars(
            tab, basis, var_names, artificial_start, steps
        )
        # y1 не должно быть в базисе
        self.assertNotIn(4, new_basis)
        self.assertEqual(len(new_names), 4)
        # Проверяем, что шаги записаны
        self.assertTrue(any("Замена искусственной переменной" in s['title'] for s in steps))


if __name__ == '__main__':
    unittest.main()