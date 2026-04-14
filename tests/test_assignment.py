"""
Юнит-тесты для модуля решения задачи о назначениях.
Содержит 5+ тестовых случаев для проверки корректности Венгерского алгоритма.
"""
import unittest
import sys
import os

# Добавляем путь к модулю controllers
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from controllers.assignment import solve_assignment, solve_assignment_hungarian


class TestAssignmentProblem(unittest.TestCase):
    """Тесты для задачи о назначениях."""

    def test_correct_3x3_matrix(self):
        """
        Тест 1: Корректная квадратная матрица 3x3.
        Проверка базового случая минимизации.
        """
        matrix = [
            [10, 20, 30],
            [40, 50, 60],
            [70, 80, 90]
        ]
        assignment, cost = solve_assignment(matrix)
        
        self.assertEqual(len(assignment), 3, "Должно быть 3 назначения")
        self.assertEqual(cost, 150, "Оптимальная стоимость: 10+50+90=150")
        # Проверяем, что все строки и столбцы уникальны
        rows = [i for i, j in assignment]
        cols = [j for i, j in assignment]
        self.assertEqual(sorted(rows), [0, 1, 2])
        self.assertEqual(sorted(cols), [0, 1, 2])

    def test_zero_cost_matrix(self):
        """
        Тест 2: Матрица с нулевыми затратами.
        Все элементы равны нулю.
        """
        matrix = [
            [0, 0, 0],
            [0, 0, 0],
            [0, 0, 0]
        ]
        assignment, cost = solve_assignment(matrix)
        
        self.assertEqual(len(assignment), 3)
        self.assertEqual(cost, 0.0)

    def test_diagonal_optimal(self):
        """
        Тест 3: Оптимальное назначение по диагонали.
        Диагональные элементы минимальны.
        """
        matrix = [
            [1, 9, 9],
            [9, 2, 9],
            [9, 9, 3]
        ]
        assignment, cost = solve_assignment(matrix)
        
        self.assertEqual(cost, 6, "Оптимально: 1+2+3=6 (диагональ)")
        # Проверяем, что назначена диагональ
        for i, j in assignment:
            self.assertEqual(i, j, f"Должно быть назначено ({i},{i})")

    def test_large_values(self):
        """
        Тест 4: Большие числа (граничные значения).
        Проверка устойчивости алгоритма к большим числам.
        """
        matrix = [
            [1000, 2000, 3000],
            [4000, 5000, 6000],
            [7000, 8000, 9000]
        ]
        assignment, cost = solve_assignment(matrix)
        
        self.assertEqual(len(assignment), 3)
        self.assertGreater(cost, 0)
        self.assertEqual(cost, 15000)  # 1000+5000+9000

    def test_negative_costs(self):
        """
        Тест 5: Отрицательные затраты.
        Допустимо в некоторых постановках задачи.
        """
        matrix = [
            [-5, 2, 8],
            [3, -7, 4],
            [6, 1, -9]
        ]
        assignment, cost = solve_assignment(matrix)
        
        self.assertEqual(len(assignment), 3)
        # Оптимально: -5 + (-7) + (-9) = -21 (диагональ)
        self.assertEqual(cost, -21)

    def test_4x4_matrix(self):
        """
        Тест 6: Матрица 4x4.
        Проверка работы с большим размером.
        """
        matrix = [
            [9, 2, 7, 8],
            [6, 4, 3, 7],
            [5, 8, 1, 8],
            [7, 6, 9, 4]
        ]
        assignment, cost = solve_assignment(matrix)
        
        self.assertEqual(len(assignment), 4)
        # Проверяем корректность назначения
        rows = [i for i, j in assignment]
        cols = [j for i, j in assignment]
        self.assertEqual(sorted(rows), [0, 1, 2, 3])
        self.assertEqual(sorted(cols), [0, 1, 2, 3])

    def test_2x2_matrix(self):
        """
        Тест 7: Минимальная матрица 2x2.
        """
        matrix = [
            [5, 8],
            [6, 3]
        ]
        assignment, cost = solve_assignment(matrix)
        
        self.assertEqual(len(assignment), 2)
        # Оптимально: 5+3=8 или 8+6=14, значит 8
        self.assertEqual(cost, 8)

    def test_identity_matrix(self):
        """
        Тест 8: Единичная матрица.
        """
        matrix = [
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1]
        ]
        assignment, cost = solve_assignment(matrix)
        
        self.assertEqual(cost, 0, "Можно назначить все нули")

    def test_uniform_matrix(self):
        """
        Тест 9: Все элементы одинаковы.
        """
        matrix = [
            [5, 5, 5],
            [5, 5, 5],
            [5, 5, 5]
        ]
        assignment, cost = solve_assignment(matrix)
        
        self.assertEqual(cost, 15, "Любое назначение: 5+5+5=15")

    def test_hungarian_vs_bruteforce(self):
        """
        Тест 10: Сравнение полной реализации Венгерского метода 
        и упрощённого перебора.
        """
        matrix = [
            [82, 83, 69, 92],
            [77, 37, 49, 92],
            [11, 69, 5, 86],
            [8, 9, 98, 23]
        ]
        
        assign1, cost1 = solve_assignment(matrix)
        assign2, cost2 = solve_assignment_hungarian(matrix)
        
        self.assertEqual(cost1, cost2, "Оба метода должны дать одинаковую стоимость")


if __name__ == '__main__':
    # Запуск тестов с выводом подробной информации
    unittest.main(verbosity=2)
