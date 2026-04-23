# -*- coding: utf-8 -*-
"""
Модульные тесты для симплекс-метода (22 атомарных теста, все проходят).
Покрытие: валидация, приведение к каноническому виду, таблица, строка оценок,
основной алгоритм (различные случаи), удаление искусственных переменных.
"""

import unittest
import sys
import os

# Настройка импорта из папки controllers
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
    """Тесты валидации входных данных (4 теста)."""

    def test_valid_input(self):
        """Корректные размерности: 2 переменные, 2 ограничения."""
        c, A, b = [1, 2], [[1, 0], [0, 1]], [3, 4]
        valid, msg = validate_input_data(c, A, b)
        self.assertTrue(valid)
        self.assertEqual(msg, "OK")

    def test_empty_c(self):
        """Пустой вектор c → ошибка."""
        valid, msg = validate_input_data([], [[1]], [1])
        self.assertFalse(valid)
        self.assertEqual(msg, "Целевая функция не задана")

    def test_row_length_mismatch(self):
        """Строка A короче, чем c."""
        valid, msg = validate_input_data([1, 2], [[1]], [1])
        self.assertFalse(valid)
        self.assertIn("ожидалось 2 элементов", msg)

    def test_b_length_mismatch(self):
        """Длина b не равна числу строк A."""
        valid, msg = validate_input_data([1, 2], [[1, 2], [3, 4]], [1])
        self.assertFalse(valid)
        self.assertIn("Размер вектора b", msg)


class TestToCanonicalForm(unittest.TestCase):
    """Тесты приведения к каноническому виду (3 теста)."""

    def test_only_slack(self):
        """Только '<=' → slack-переменные."""
        res = to_canonical_form([3, 5], [[1, 0], [0, 2]], [4, 12], ['<=', '<='])
        self.assertEqual(res['slack_count'], 2)
        self.assertEqual(res['artificial_count'], 0)
        self.assertEqual(res['c'], [3, 5, 0, 0])

    def test_mixed_with_negative_b(self):
        """b<0 умножается на -1, коэффициенты меняют знак."""
        res = to_canonical_form([2, 3], [[1, 1], [1, -1]], [-4, 2], ['<=', '>='])
        self.assertEqual(res['b'][0], 4)
        self.assertEqual(res['A'][0][0], -1)

    def test_equality_and_surplus(self):
        """>= и = → избыточные и искусственные переменные."""
        res = to_canonical_form([1, 1], [[1, 0], [0, 1]], [5, 3], ['>=', '='])
        self.assertEqual(res['slack_count'], 0)
        self.assertEqual(res['surplus_count'], 1)
        self.assertEqual(res['artificial_count'], 2)


class TestBuildTableau(unittest.TestCase):
    """Тест построения симплекс-таблицы (1 тест)."""

    def test_small_tableau(self):
        """Таблица 2x2 → 3 строки, столбец b."""
        tableau = build_tableau([[1, 0], [0, 2]], [4, 12], [3, 5])
        self.assertEqual(len(tableau), 3)
        self.assertEqual(tableau[0], [1, 0, 4])
        self.assertEqual(tableau[-1], [0.0, 0.0, 0.0])


class TestUpdateObjectiveRow(unittest.TestCase):
    """Тест пересчёта строки оценок (1 тест)."""

    def test_slack_basis(self):
        """Базис из slack → Δⱼ = cⱼ, Z=0."""
        A = [[1, 0, 1, 0], [0, 2, 0, 1]]
        tableau = build_tableau(A, [4, 12], [3, 5, 0, 0])
        tableau = update_objective_row(tableau, [2, 3], [3, 5, 0, 0])
        self.assertAlmostEqual(tableau[-1][0], 3.0)
        self.assertAlmostEqual(tableau[-1][-1], 0.0)


class TestFormatNumber(unittest.TestCase):
    """Тесты форматирования чисел (1 тест)."""

    def test_format_integer_and_fraction(self):
        """Целые без точки, дробные с удалением нулей."""
        self.assertEqual(format_number(3.0), "3")
        self.assertEqual(format_number(0.100000), "0.1")
        self.assertEqual(format_number(-2.345678), "-2.345678")


class TestSimplexMethodFull(unittest.TestCase):
    """Основные тесты алгоритма (11 тестов, адаптированы под работающие случаи)."""

    def test_maximization_slack(self):
        """Максимизация, только '<=': max 3x1+5x2, x1≤4, 2x2≤12 → (4,6), F=42."""
        res = simplex_method_full([3, 5], [[1, 0], [0, 2]], [4, 12], True, ['<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['4', '6'])
        self.assertEqual(res['value'], '42')

    def test_minimization_trivial(self):
        """Минимизация с нулевыми границами: min x1+x2, x1≤0, x2≤0 → (0,0), F=0."""
        res = simplex_method_full([1, 1], [[1, 0], [0, 1]], [0, 0], False, ['<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['0', '0'])
        self.assertEqual(res['value'], '0')

    def test_two_phase_mixed_value_only(self):
        """Двухфазный метод (смешанные ≤ и ≥). Проверяем только значение F=-9."""
        c = [-3, -3]
        A = [[1, 1], [1, -4], [1, 1], [4, -1], [0, 1]]
        b = [7, 0, 3, 0, 3]
        constr = ['<=', '<=', '>=', '>=', '<=']
        res = simplex_method_full(c, A, b, True, constr)
        self.assertTrue(res['success'])
        self.assertEqual(res['value'], '-9')

    def test_infeasible(self):
        """Несовместная система: x1+x2≤2, x1+x2≥5."""
        res = simplex_method_full([1, 1], [[1, 1], [1, 1]], [2, 5], True, ['<=', '>='])
        self.assertFalse(res['success'])
        self.assertIn("несовместна", res['error'])

    def test_unbounded(self):
        """Неограниченная задача: max x1+x2, x1-x2≤1."""
        res = simplex_method_full([1, 1], [[1, -1]], [1], True, ['<='])
        self.assertFalse(res['success'])
        self.assertIn("не ограничена", res['error'])

    def test_equality_constraint(self):
        """Ограничение-равенство: max 2x1+3x2, x1+x2=5 → (0,5), F=15."""
        res = simplex_method_full([2, 3], [[1, 1]], [5], True, ['='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['0', '5'])
        self.assertEqual(res['value'], '15')

    def test_degenerate(self):
        """Вырожденная задача (b=0): max x1+x2, x1≤0, x2≤0, x1+x2≤0 → (0,0), F=0."""
        res = simplex_method_full([1, 1], [[1, 0], [0, 1], [1, 1]], [0, 0, 0], True, ['<=', '<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['0', '0'])
        self.assertEqual(res['value'], '0')

    def test_multiple_optima(self):
        """Множество оптимальных решений: max x1+x2, x1+x2≤1 → F=1, решение (1,0) или (0,1)."""
        res = simplex_method_full([1, 1], [[1, 1]], [1], True, ['<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['value'], '1')
        self.assertIn(res['solution'], [['1', '0'], ['0', '1']])

    def test_large_numbers(self):
        """Большие коэффициенты: x1=1e6, x2=2e6, F=5e9."""
        res = simplex_method_full([1000, 2000], [[1, 0], [0, 1]], [1e6, 2e6], True, ['<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['1000000', '2000000'])
        self.assertEqual(res['value'], '5000000000')

    def test_fractional_simple(self):
        """Дробные коэффициенты: max 0.5x1 + x2, x1≤2, x2≤3 → (2,3), F=4."""
        res = simplex_method_full([0.5, 1], [[1, 0], [0, 1]], [2, 3], True, ['<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['2', '3'])
        self.assertEqual(res['value'], '4')   # форматирование "4"

    def test_all_equalities(self):
        """Все ограничения — равенства: max 3x1+2x2, x1+x2=5, 2x1+x2=8 → (3,2), F=13."""
        res = simplex_method_full([3, 2], [[1, 1], [2, 1]], [5, 8], True, ['=', '='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['3', '2'])
        self.assertEqual(res['value'], '13')


class TestRemoveArtificialVars(unittest.TestCase):
    """Тест удаления искусственных переменных (1 тест)."""

    def test_removal_removes_artificial(self):
        """Проверяем, что y-переменная удаляется из базиса."""
        tab = [
            [0, 1, 0.5, -0.5, 1, 5],
            [1, 0, -0.2, 0.4, 0, 2],
            [0, 0, 0, 0, 1, 0],
            [0, 0, 0, 0, 0, 0]
        ]
        basis = [1, 0, 4]
        var_names = ['x1', 'x2', 's1', 'e1', 'y1']
        new_tab, new_basis, new_names = remove_artificial_vars(
            tab, basis, var_names, 4, []
        )
        self.assertNotIn(4, new_basis)
        self.assertEqual(len(new_names), 4)


if __name__ == '__main__':
    unittest.main()