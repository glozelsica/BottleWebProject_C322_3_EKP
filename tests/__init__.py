import os
import sys
import unittest

# Настройка путей
ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT_DIR)

# Явное обнаружение тестов (опционально)
def load_tests(loader, tests, pattern):
    """Автоматически загружает все тесты из папки tests"""
    suite = unittest.TestSuite()
    test_dir = os.path.dirname(__file__)
    
    # Ищем все файлы test_*.py
    for filename in os.listdir(test_dir):
        if filename.startswith('test_') and filename.endswith('.py'):
            module_name = filename[:-3]  # Убираем .py
            module = __import__(module_name)
            suite.addTests(unittest.TestLoader().loadTestsFromModule(module))
    
    return suite
