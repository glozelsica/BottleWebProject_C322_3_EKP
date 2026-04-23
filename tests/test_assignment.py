import unittest
import sys
import os
import random

TESTS_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(TESTS_DIR)
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

# Импортируем тестируемую функцию
from controllers.assignment import _hungarian_algorithm_with_steps

class TestAssignmentAlgorithm(unittest.TestCase):

    
    # Тест 1: Проверяет обработку пустой матрицы.
    # Алгоритм не должен падать, а должен вернуть нулевую стоимость и пустой список назначений.
    def test_empty_matrix(self):
        """Test: empty matrix should return 0"""
        matrix = []
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(assign, [])
        self.assertEqual(cost, 0)
        self.assertEqual(len(steps), 0)

    # Тест 2: Проверяет тривиальный случай матрицы 1x1.
    # Единственный исполнитель назначается на единственную работу, стоимость равна значению ячейки.
    def test_1x1_matrix(self):
        """Test: 1x1 matrix"""
        matrix = [[42]]
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(cost, 42)
        self.assertEqual(assign, [(0, 0)])

    # Тест 3: Проверяет минимальный нетривиальный размер 2x2.
    # Проверяем, что алгоритм выбирает комбинацию с меньшей суммой (5+5=10), а не главную диагональ (10+10=20).
    def test_2x2_matrix(self):
        """Test: 2x2 matrix"""
        matrix = [[10, 5], [5, 10]]
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(cost, 10)
        self.assertEqual(len(assign), 2)

    # Тест 4: Проверяет стандартный пример 3x3 из описания проекта.
    # Это регрессионный тест: убеждаемся, что на известном примере ответ всегда правильный (150).
    def test_3x3_matrix_example(self):
        """Test: 3x3 matrix from project example"""
        matrix = [[10, 20, 30], 
                  [40, 50, 60], 
                  [70, 80, 90]]
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(cost, 150)
        self.assertEqual(len(assign), 3)


    # Тест 5: Проверяет корректность для матрицы 4x4.
    # Убеждаемся, что алгоритм масштабируется без ошибок.
    def test_4x4_matrix(self):
        """Test: correct calculation for 4x4 matrix"""
        matrix = [
            [2, 4, 3, 5],
            [5, 3, 6, 2],
            [4, 5, 2, 3],
            [3, 2, 4, 5]
        ]
        assign, cost, _ = _hungarian_algorithm_with_steps(matrix)
        calculated = sum(matrix[i][j] for i, j in assign)
        self.assertEqual(cost, calculated)
        self.assertEqual(len(assign), 4)

    # Тест 6: Проверяет промежуточный размер матрицы 5x5.
    # Генерируем случайные данные для проверки универсальности алгоритма.
    def test_5x5_matrix(self):
        """Test: correct calculation for 5x5 matrix (intermediate size)"""
        random.seed(123) # Фиксируем случайность для повторяемости теста
        matrix = [[random.randint(1, 50) for _ in range(5)] for _ in range(5)]
        
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        
        calculated = sum(matrix[i][j] for i, j in assign)
        self.assertEqual(cost, calculated)
        self.assertEqual(len(assign), 5)
        self.assertEqual(len(steps), 5)

    # Тест 7: Проверяет максимальный допустимый размер 6x6.
    # Это граничный тест: проверяем, что программа справляется с нагрузкой на пределе лимита.
    def test_6x6_max_size(self):
        """Test: maximum allowed size 6x6 works correctly"""
        random.seed(42)
        matrix = [[random.randint(1, 100) for _ in range(6)] for _ in range(6)]
        assign, cost, _ = _hungarian_algorithm_with_steps(matrix)
        calculated = sum(matrix[i][j] for i, j in assign)
        self.assertEqual(cost, calculated)
        self.assertEqual(len(assign), 6)

    # Тест 8: Проверяет математическую сходимость результата.
    # Мы вручную пересчитываем сумму выбранных ячеек и сверяем её с тем, что вернул алгоритм.
    def test_cost_matches_assignments(self):
        """Test: returned cost exactly matches manual sum of assigned cells"""
        matrix = [[5, 8, 6], [7, 3, 9], [4, 6, 2]]
        assign, cost, _ = _hungarian_algorithm_with_steps(matrix)
        calculated = sum(matrix[i][j] for i, j in assign)
        self.assertEqual(cost, calculated)

    # Тест 9: Проверяет валидность перестановки (Правило 1 к 1).
    # Гарантирует, что каждому исполнителю назначена ровно одна работа, и наоборот (нет дублей).
    def test_assignment_validity(self):
        """Test: assignments must be a valid permutation (unique rows & cols)"""
        matrix = [[10, 20, 30], [40, 50, 60], [70, 80, 90]]
        assign, _, _ = _hungarian_algorithm_with_steps(matrix)
        rows = [i for i, j in assign]
        cols = [j for i, j in assign]
        
        self.assertEqual(len(assign), len(matrix))
        self.assertEqual(len(set(rows)), len(matrix))  # Проверка уникальности строк
        self.assertEqual(len(set(cols)), len(matrix))  # Проверка уникальности столбцов

    # Тест 10: Проверяет, что алгоритм ищет оптимальное решение, а не берет диагональ.
    # В этой матрице диагональ стоит 200, а перекрестное решение — всего 2.
    def test_off_diagonal_optimal(self):
        """Test: algorithm finds optimal even when it's NOT on main diagonal"""
        matrix = [[100, 1], [1, 100]]
        assign, cost, _ = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(cost, 2)
        self.assertIn((0, 1), assign)
        self.assertIn((1, 0), assign)


    # Тест 11: Проверяет поведение на матрице из одних нулей.
    # Минимальная стоимость должна быть 0.
    def test_all_zeros_matrix(self):
        """Test: matrix filled with zeros returns cost 0"""
        matrix = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
        assign, cost, _ = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(cost, 0)
        self.assertEqual(len(assign), 3)

    # Тест 12: Проверяет матрицу, где все значения одинаковы.
    # Убеждаемся, что алгоритм не зацикливается при равенстве всех вариантов.
    def test_identical_values_matrix(self):
        """Test: matrix with all identical values"""
        matrix = [[7, 7, 7], [7, 7, 7], [7, 7, 7]]
        assign, cost, _ = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(cost, 21)  # 7 * 3
        self.assertEqual(len(assign), 3)


    # Тест 13: Проверяет целостность структуры данных для шагов.
    # Убеждаемся, что каждый шаг содержит ключи, необходимые для HTML-шаблона.
    def test_step_structure_consistency(self):
        """Test: all steps contain required keys and valid matrix dimensions"""
        matrix = [[10, 20], [30, 40]]
        _, _, steps = _hungarian_algorithm_with_steps(matrix)
        required_keys = ['step_num', 'title', 'description', 'matrix_cells']
        
        for step in steps:
            for key in required_keys:
                self.assertIn(key, step)

    # Тест 14: Проверяет логику подсветки ячеек (CSS-классы).
    # На шаге "Нули" класс должен быть 'zero', на шаге "Результат" — 'assigned'.
    def test_step_highlighting_logic(self):
        """Test: step 3 highlights zeros, step 4 highlights assignments"""
        matrix = [[0, 5], [3, 0]]
        assign, _, steps = _hungarian_algorithm_with_steps(matrix)
        step3 = steps[3]
        step4 = steps[4]

        zeros_highlighted = sum(1 for row in step3['matrix_cells'] for cell in row if cell['css_class'] == 'zero')
        self.assertGreater(zeros_highlighted, 0)

        assigned_highlighted = sum(1 for row in step4['matrix_cells'] for cell in row if cell['css_class'] == 'assigned')
        self.assertEqual(assigned_highlighted, 2)

    # Тест 15: Проверяет количество шагов и их правильную нумерацию.
    # Всего должно быть 5 этапов решения.
    def test_steps_generation(self):
        """Test: check steps count and numbering"""
        matrix = [[1, 2], [3, 4]]
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(len(steps), 5)
        self.assertEqual(steps[0]['step_num'], 0)
        self.assertEqual(steps[1]['title'], 'Редукция по строкам')
        self.assertEqual(steps[4]['title'], 'Оптимальное назначение')

if __name__ == '__main__':
    unittest.main(verbosity=2)