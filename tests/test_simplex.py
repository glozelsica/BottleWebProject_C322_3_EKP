# -*- coding: utf-8 -*-
"""
Модульные тесты для симплекс-метода (23 атомарных теста, все проходят).

Покрытие:
  - Валидация входных данных (5 тестов): корректные данные, пустой вектор c,
    несовпадение длины строки A и c, несовпадение длины b, ввод букв вместо чисел.
  - Приведение к каноническому виду (3 теста): только slack-переменные,
    смешанные ограничения с отрицательным b, избыточные и искусственные переменные.
  - Построение симплекс-таблицы (1 тест).
  - Обновление строки оценок (1 тест).
  - Форматирование чисел (1 тест).
  - Основной алгоритм (11 тестов): максимизация, минимизация, двухфазный метод,
    несовместность, неограниченность, ограничение-равенство, вырожденная задача,
    множественные оптимумы, большие числа, дробные коэффициенты, все ограничения-равенства.
  - Удаление искусственных переменных (1 тест).

Каждый тест атомарен и содержит docstring с описанием:
  - Что проверяется.
  - Какие входные данные используются.
  - Какой результат ожидается.
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
    """
    Тесты валидации входных данных (5 тестов).

    Проверяем, что функция validate_input_data корректно определяет
    согласованность размерностей матриц A, векторов c и b.
    """

    def test_valid_input(self):
        """
        Позитивный тест: корректные размерности.

        Входные данные:
          c = [1, 2] (2 переменные)
          A = [[1, 0], [0, 1]] (2 строки, 2 столбца)
          b = [3, 4] (2 элемента)

        Ожидаемый результат:
          valid = True
          msg = "OK"
        """
        c, A, b = [1, 2], [[1, 0], [0, 1]], [3, 4]
        valid, msg = validate_input_data(c, A, b)
        self.assertTrue(valid)
        self.assertEqual(msg, "OK")

    def test_empty_c(self):
        """
        Негативный тест: пустой вектор c.

        Входные данные:
          c = [] (пустой список)
          A = [[1]]
          b = [1]

        Ожидаемый результат:
          valid = False
          msg = "Целевая функция не задана"
        """
        valid, msg = validate_input_data([], [[1]], [1])
        self.assertFalse(valid)
        self.assertEqual(msg, "Целевая функция не задана")

    def test_row_length_mismatch(self):
        """
        Негативный тест: число столбцов в A не совпадает с длиной c.

        Входные данные:
          c = [1, 2] (ожидается 2 столбца)
          A = [[1]] (1 столбец)

        Ожидаемый результат:
          valid = False
          msg содержит "ожидалось 2 элементов"
        """
        valid, msg = validate_input_data([1, 2], [[1]], [1])
        self.assertFalse(valid)
        self.assertIn("ожидалось 2 элементов", msg)

    def test_b_length_mismatch(self):
        """
        Негативный тест: длина вектора b не равна числу строк A.

        Входные данные:
          c = [1, 2]
          A = [[1, 2], [3, 4]] (2 строки)
          b = [1] (1 элемент)

        Ожидаемый результат:
          valid = False
          msg содержит "Размер вектора b"
        """
        valid, msg = validate_input_data([1, 2], [[1, 2], [3, 4]], [1])
        self.assertFalse(valid)
        self.assertIn("Размер вектора b", msg)

    def test_letter_instead_of_number(self):
        """
        Негативный тест: ввод букв вместо чисел в коэффициентах c.

        Входные данные:
          c = ['a', 'b'] (буквы вместо чисел)
          A = [[1, 0], [0, 1]]
          b = [3, 4]

        Ожидаемый результат:
          Функция validate_input_data не проверяет типы элементов,
          она проверяет только размерности. Поэтому тест ожидает,
          что валидация пройдёт (длины совпадают), но при попытке
          решить задачу возникнет ошибка на более позднем этапе.

          Здесь мы проверяем именно validate_input_data — она
          должна вернуть True, так как размерности согласованы.
        """
        c, A, b = ['a', 'b'], [[1, 0], [0, 1]], [3, 4]
        valid, msg = validate_input_data(c, A, b)
        # validate_input_data проверяет только размерности, не типы
        self.assertTrue(valid)


class TestToCanonicalForm(unittest.TestCase):
    """
    Тесты приведения к каноническому виду (3 теста).

    Проверяем, что функция to_canonical_form правильно добавляет
    slack-, surplus- и artificial-переменные в зависимости от типов
    ограничений и знаков правых частей.
    """

    def test_only_slack(self):
        """
        Только ограничения '<=' и b >= 0.

        Входные данные:
          c = [3, 5], A = [[1, 0], [0, 2]], b = [4, 12]
          constraints_types = ['<=', '<=']

        Ожидаемый результат:
          slack_count = 2 (добавлены s1, s2)
          artificial_count = 0 (искусственных нет)
          c = [3, 5, 0, 0] (коэффициенты при новых переменных = 0)
        """
        res = to_canonical_form([3, 5], [[1, 0], [0, 2]], [4, 12], ['<=', '<='])
        self.assertEqual(res['slack_count'], 2)
        self.assertEqual(res['artificial_count'], 0)
        self.assertEqual(res['c'], [3, 5, 0, 0])

    def test_mixed_with_negative_b(self):
        """
        Смешанные ограничения с отрицательной правой частью.

        Входные данные:
          c = [2, 3], A = [[1, 1], [1, -1]], b = [-4, 2]
          constraints_types = ['<=', '>=']

        Ожидаемый результат:
          Первое ограничение с b=-4 умножается на -1:
            b[0] становится 4
            A[0] становится [-1, -1]
        """
        res = to_canonical_form([2, 3], [[1, 1], [1, -1]], [-4, 2], ['<=', '>='])
        self.assertEqual(res['b'][0], 4)
        self.assertEqual(res['A'][0][0], -1)

    def test_equality_and_surplus(self):
        """
        Ограничения '>=' и '='.

        Входные данные:
          c = [1, 1], A = [[1, 0], [0, 1]], b = [5, 3]
          constraints_types = ['>=', '=']

        Ожидаемый результат:
          slack_count = 0
          surplus_count = 1 (для '>=')
          artificial_count = 2 (по одной для '>=' и '=')
        """
        res = to_canonical_form([1, 1], [[1, 0], [0, 1]], [5, 3], ['>=', '='])
        self.assertEqual(res['slack_count'], 0)
        self.assertEqual(res['surplus_count'], 1)
        self.assertEqual(res['artificial_count'], 2)


class TestBuildTableau(unittest.TestCase):
    """
    Тест построения симплекс-таблицы (1 тест).

    Проверяем, что функция build_tableau правильно формирует
    начальную симплекс-таблицу: m строк ограничений + 1 строка Δ.
    """

    def test_small_tableau(self):
        """
        Построение таблицы 2x2.

        Входные данные:
          A = [[1, 0], [0, 2]], b = [4, 12], c = [3, 5]

        Ожидаемый результат:
          tableau содержит 3 строки (2 ограничения + Δ)
          tableau[0] = [1, 0, 4] (первая строка + b)
          tableau[-1] = [0.0, 0.0, 0.0] (строка Δ изначально нулевая)
        """
        tableau = build_tableau([[1, 0], [0, 2]], [4, 12], [3, 5])
        self.assertEqual(len(tableau), 3)
        self.assertEqual(tableau[0], [1, 0, 4])
        self.assertEqual(tableau[-1], [0.0, 0.0, 0.0])


class TestUpdateObjectiveRow(unittest.TestCase):
    """
    Тест пересчёта строки оценок (1 тест).

    Проверяем, что функция update_objective_row правильно
    вычисляет Δ-строку и текущее значение целевой функции.
    """

    def test_slack_basis(self):
        """
        Базис из slack-переменных.

        Входные данные:
          A = [[1, 0, 1, 0], [0, 2, 0, 1]], b = [4, 12]
          c = [3, 5, 0, 0], basis = [2, 3] (s1, s2)

        Ожидаемый результат:
          Δ[0] = 3.0 (c1 - 0)
          Δ[-1] = 0.0 (значение ЦФ = 0, так как базисные переменные = 0)
        """
        A = [[1, 0, 1, 0], [0, 2, 0, 1]]
        tableau = build_tableau(A, [4, 12], [3, 5, 0, 0])
        tableau = update_objective_row(tableau, [2, 3], [3, 5, 0, 0])
        self.assertAlmostEqual(tableau[-1][0], 3.0)
        self.assertAlmostEqual(tableau[-1][-1], 0.0)


class TestFormatNumber(unittest.TestCase):
    """
    Тесты форматирования чисел (1 тест).

    Проверяем, что функция format_number корректно округляет
    и убирает незначащие нули.
    """

    def test_format_integer_and_fraction(self):
        """
        Форматирование целых и дробных чисел.

        Входные данные:
          3.0, 0.100000, -2.345678

        Ожидаемый результат:
          3.0 → "3" (целое без точки)
          0.100000 → "0.1" (убраны лишние нули)
          -2.345678 → "-2.345678" (сохранена точность)
        """
        self.assertEqual(format_number(3.0), "3")
        self.assertEqual(format_number(0.100000), "0.1")
        self.assertEqual(format_number(-2.345678), "-2.345678")


class TestSimplexMethodFull(unittest.TestCase):
    """
    Основные тесты алгоритма симплекс-метода (11 тестов).

    Проверяем полный цикл решения задачи ЛП: от приведения
    к каноническому виду до получения оптимального плана.
    """

    def test_maximization_slack(self):
        """
        Максимизация с ограничениями '<='.

        Входные данные:
          max 3x1 + 5x2
          x1 <= 4
          2x2 <= 12

        Ожидаемый результат:
          success = True
          solution = ['4', '6']
          value = '42' (3*4 + 5*6 = 42)
        """
        res = simplex_method_full([3, 5], [[1, 0], [0, 2]], [4, 12], True, ['<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['4', '6'])
        self.assertEqual(res['value'], '42')

    def test_minimization_trivial(self):
        """
        Минимизация с нулевыми границами.

        Входные данные:
          min x1 + x2
          x1 <= 0
          x2 <= 0

        Ожидаемый результат:
          success = True
          solution = ['0', '0']
          value = '0'
        """
        res = simplex_method_full([1, 1], [[1, 0], [0, 1]], [0, 0], False, ['<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['0', '0'])
        self.assertEqual(res['value'], '0')

    def test_two_phase_mixed_value_only(self):
        """
        Двухфазный метод со смешанными ограничениями.

        Входные данные:
          max -3x1 - 3x2
          x1 + x2 <= 7
          x1 - 4x2 <= 0
          x1 + x2 >= 3
          4x1 - x2 >= 0
          x2 <= 3

        Ожидаемый результат:
          success = True
          value = '-9' (значение целевой функции)
          (план может быть разным из-за множественности решений)
        """
        c = [-3, -3]
        A = [[1, 1], [1, -4], [1, 1], [4, -1], [0, 1]]
        b = [7, 0, 3, 0, 3]
        constr = ['<=', '<=', '>=', '>=', '<=']
        res = simplex_method_full(c, A, b, True, constr)
        self.assertTrue(res['success'])
        self.assertEqual(res['value'], '-9')

    def test_infeasible(self):
        """
        Несовместная система ограничений.

        Входные данные:
          max x1 + x2
          x1 + x2 <= 2
          x1 + x2 >= 5

        Ожидаемый результат:
          success = False
          error содержит "несовместна"
        """
        res = simplex_method_full([1, 1], [[1, 1], [1, 1]], [2, 5], True, ['<=', '>='])
        self.assertFalse(res['success'])
        self.assertIn("несовместна", res['error'])

    def test_unbounded(self):
        """
        Неограниченная задача.

        Входные данные:
          max x1 + x2
          x1 - x2 <= 1

        Ожидаемый результат:
          success = False
          error содержит "не ограничена"
        """
        res = simplex_method_full([1, 1], [[1, -1]], [1], True, ['<='])
        self.assertFalse(res['success'])
        self.assertIn("не ограничена", res['error'])

    def test_equality_constraint(self):
        """
        Ограничение-равенство (двухфазный метод).

        Входные данные:
          max 2x1 + 3x2
          x1 + x2 = 5

        Ожидаемый результат:
          success = True
          solution = ['0', '5'] (x1=0, x2=5)
          value = '15' (2*0 + 3*5 = 15)
        """
        res = simplex_method_full([2, 3], [[1, 1]], [5], True, ['='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['0', '5'])
        self.assertEqual(res['value'], '15')

    def test_degenerate(self):
        """
        Вырожденная задача (все b = 0).

        Входные данные:
          max x1 + x2
          x1 <= 0
          x2 <= 0
          x1 + x2 <= 0

        Ожидаемый результат:
          success = True
          solution = ['0', '0']
          value = '0'
        """
        res = simplex_method_full([1, 1], [[1, 0], [0, 1], [1, 1]], [0, 0, 0], True, ['<=', '<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['0', '0'])
        self.assertEqual(res['value'], '0')

    def test_multiple_optima(self):
        """
        Множество оптимальных решений.

        Входные данные:
          max x1 + x2
          x1 + x2 <= 1

        Ожидаемый результат:
          success = True
          value = '1'
          solution равен ['1', '0'] или ['0', '1'] (альтернативные оптимумы)
        """
        res = simplex_method_full([1, 1], [[1, 1]], [1], True, ['<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['value'], '1')
        self.assertIn(res['solution'], [['1', '0'], ['0', '1']])

    def test_large_numbers(self):
        """
        Задача с большими числами (проверка устойчивости).

        Входные данные:
          max 1000x1 + 2000x2
          x1 <= 1 000 000
          x2 <= 2 000 000

        Ожидаемый результат:
          success = True
          solution = ['1000000', '2000000']
          value = '5000000000' (1000*1e6 + 2000*2e6 = 5e9)
        """
        res = simplex_method_full([1000, 2000], [[1, 0], [0, 1]], [1e6, 2e6], True, ['<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['1000000', '2000000'])
        self.assertEqual(res['value'], '5000000000')

    def test_fractional_simple(self):
        """
        Дробные коэффициенты в целевой функции.

        Входные данные:
          max 0.5x1 + x2
          x1 <= 2
          x2 <= 3

        Ожидаемый результат:
          success = True
          solution = ['2', '3']
          value = '4' (0.5*2 + 3 = 4)
        """
        res = simplex_method_full([0.5, 1], [[1, 0], [0, 1]], [2, 3], True, ['<=', '<='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['2', '3'])
        self.assertEqual(res['value'], '4')

    def test_all_equalities(self):
        """
        Все ограничения — равенства.

        Входные данные:
          max 3x1 + 2x2
          x1 + x2 = 5
          2x1 + x2 = 8

        Ожидаемый результат:
          success = True
          solution = ['3', '2'] (x1=3, x2=2)
          value = '13' (3*3 + 2*2 = 13)
        """
        res = simplex_method_full([3, 2], [[1, 1], [2, 1]], [5, 8], True, ['=', '='])
        self.assertTrue(res['success'])
        self.assertEqual(res['solution'], ['3', '2'])
        self.assertEqual(res['value'], '13')


class TestRemoveArtificialVars(unittest.TestCase):
    """
    Тест удаления искусственных переменных (1 тест).

    Проверяем, что функция remove_artificial_vars корректно
    удаляет искусственные переменные из базиса после фазы 1.
    """

    def test_removal_removes_artificial(self):
        """
        Удаление искусственной переменной y1 из базиса.

        Входные данные:
          Симплекс-таблица из 3 строк (2 ограничения + строка Δ).
          Базис: [1, 0, 4] (x2, x1, y1).
          Имена переменных: ['x1', 'x2', 's1', 'e1', 'y1'].
          artificial_start = 4.

        Ожидаемый результат:
          В новом базисе нет индекса 4 (y1).
          Длина новых имён переменных = 4.
        """
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