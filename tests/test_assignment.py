import unittest
import sys
import os

# === ВАЖНО: Добавляем корень проекта в путь ===
# Получаем путь к папке, где лежит этот файл (tests/)
TESTS_DIR = os.path.dirname(os.path.abspath(__file__))
# Поднимаемся на уровень выше (корень проекта)
ROOT_DIR = os.path.dirname(TESTS_DIR)
# Добавляем в sys.path
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

# Теперь импорт будет работать
from controllers.assignment import _hungarian_algorithm_with_steps

class TestAssignmentAlgorithm(unittest.TestCase):

    def test_empty_matrix(self):
        """Test: empty matrix should return 0"""
        matrix = []
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(assign, [])
        self.assertEqual(cost, 0)
        self.assertEqual(len(steps), 0)

    def test_2x2_matrix(self):
        """Test: 2x2 matrix"""
        matrix = [[10, 5], [5, 10]]
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(cost, 10)
        self.assertEqual(len(assign), 2)

    def test_3x3_matrix_example(self):
        """Test: 3x3 matrix from project example"""
        matrix = [[10, 20, 30], 
                  [40, 50, 60], 
                  [70, 80, 90]]
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(cost, 150)
        self.assertEqual(len(assign), 3)

    def test_steps_generation(self):
        """Test: check steps creation"""
        matrix = [[1, 2], [3, 4]]
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(len(steps), 5)
        self.assertEqual(steps[0]['step_num'], 0)
        self.assertEqual(steps[4]['title'], 'Оптимальное назначение')

    def test_single_element(self):
        """Test: 1x1 matrix"""
        matrix = [[42]]
        assign, cost, steps = _hungarian_algorithm_with_steps(matrix)
        self.assertEqual(cost, 42)
        self.assertEqual(assign, [(0, 0)])

if __name__ == '__main__':
    unittest.main(verbosity=2)