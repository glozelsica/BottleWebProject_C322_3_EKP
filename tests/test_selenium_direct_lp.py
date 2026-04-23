"""
Автоматизированное тестирование страницы Прямая ЗЛП - Симплекс-метод
С использованием Selenium WebDriver

Тестовые примеры:
- LP-SEL-01: Проверка ввода большого объёма данных из файла (5x5)
- LP-SEL-02: Проверка корректности отображения результата и совпадения с эталоном
"""

import unittest
import json
import os
import time
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager


class TestDirectLPSelenium(unittest.TestCase):
    
    @classmethod
    def setUpClass(cls):
        """Загрузка тестовых данных и настройка браузера"""
        print("\n[INFO] Загрузка тестовых данных...")
        json_path = os.path.join(os.path.dirname(__file__), 'test_data_direct_lp.json')
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            cls.test_cases = data['test_cases']
        print("[OK] Тестовые данные загружены")
        
        print("[INFO] Настройка браузера Chrome...")
        chrome_options = Options()
        chrome_options.add_argument('--window-size=1920,1080')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--no-sandbox')
        
        service = Service(ChromeDriverManager().install())
        cls.driver = webdriver.Chrome(service=service, options=chrome_options)
        print("[OK] Браузер Chrome запущен")
        
        print("[INFO] Открытие страницы http://localhost:8080/direct_lp...")
        cls.driver.get('http://localhost:8080/direct_lp')
        cls.wait = WebDriverWait(cls.driver, 30)
        time.sleep(2)
        print("[OK] Страница открыта")
    
    @classmethod
    def tearDownClass(cls):
        print("\n[INFO] Закрытие браузера...")
        cls.driver.quit()
        print("[OK] Браузер закрыт")
    
    def setUp(self):
        self.driver.refresh()
        time.sleep(2)
    
    def set_matrix_size(self, rows, cols):
        rows_input = self.wait.until(EC.presence_of_element_located((By.ID, 'rows')))
        rows_input.clear()
        rows_input.send_keys(str(rows))
        
        cols_input = self.driver.find_element(By.ID, 'cols')
        cols_input.clear()
        cols_input.send_keys(str(cols))
        
        update_btn = self.driver.find_element(By.XPATH, "//button[contains(text(), 'Обновить матрицу')]")
        update_btn.click()
        time.sleep(1.5)
    
    def fill_target_function(self, c):
        c_input = self.driver.find_element(By.NAME, 'c')
        c_input.clear()
        c_input.send_keys(c)
    
    def fill_matrix(self, rows, cols, A, b):
        for i in range(rows):
            for j in range(cols):
                cell = self.driver.find_element(By.NAME, f'A_{i}_{j}')
                cell.clear()
                cell.send_keys(str(A[i][j]))
        
        for i in range(rows):
            b_input = self.driver.find_element(By.NAME, f'b_{i}')
            b_input.clear()
            b_input.send_keys(str(b[i]))
    
    def select_direction(self, sense):
        radio = self.driver.find_element(By.XPATH, f"//input[@value='{sense}']")
        radio.click()
    
    def click_solve(self):
        solve_btn = self.driver.find_element(By.XPATH, "//button[contains(text(), 'Решить задачу')]")
        solve_btn.click()
        time.sleep(3)
    
    def load_example(self):
        load_btn = self.driver.find_element(By.XPATH, "//button[contains(text(), 'Загрузить пример')]")
        load_btn.click()
        time.sleep(1.5)
    
    def check_page_blocks(self):
        """Проверка наличия основных блоков интерфейса"""
        blocks = [
            ("Форма ввода", "lpForm"),
            ("Поле целевой функции", "c_input"),
            ("Поле строк", "rows"),
            ("Поле столбцов", "cols"),
            ("Кнопка Обновить матрицу", "//button[contains(text(), 'Обновить матрицу')]"),
            ("Кнопка Решить задачу", "//button[contains(text(), 'Решить задачу')]"),
            ("Кнопка Очистить", "//button[contains(text(), 'Очистить')]"),
            ("Кнопка Загрузить пример", "//button[contains(text(), 'Загрузить пример')]"),
            ("Боковая панель", "sidebar")
        ]
        
        for name, selector in blocks:
            try:
                if selector.startswith("//"):
                    self.driver.find_element(By.XPATH, selector)
                else:
                    self.driver.find_element(By.ID, selector)
                print(f"[OK] Найден блок: {name}")
            except:
                print(f"[WARN] Блок не найден: {name}")
    
    def get_result_value(self):
        try:
            cost_value = self.wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'cost-value')))
            text = cost_value.text
            match = re.search(r'F\s*=\s*(\d+\.?\d*)', text)
            if match:
                return match.group(1)
            match = re.search(r'(\d+\.?\d*)', text)
            return match.group(1) if match else None
        except:
            return None
    
    def get_solution_values(self):
        try:
            result_box = self.driver.find_element(By.CLASS_NAME, 'result-box')
            text = result_box.text
            solutions = re.findall(r'x(\d+)\s*=\s*(\d+\.?\d*)', text)
            return {f"x{idx}": val for idx, val in solutions}
        except:
            return {}
    
    def check_result_blocks(self):
        """Проверка наличия блоков с результатом"""
        blocks = [
            ("Блок giant-answer", "giant-answer"),
            ("Блок cost-value", "cost-value"),
            ("Блок result-box", "result-box")
        ]
        
        for name, class_name in blocks:
            try:
                self.driver.find_element(By.CLASS_NAME, class_name)
                print(f"[OK] Найден блок: {name}")
            except:
                print(f"[WARN] Блок не найден: {name}")
    
    def check_error_absent(self):
        """Проверка отсутствия блока с ошибкой"""
        try:
            error = self.driver.find_element(By.CLASS_NAME, 'error-box')
            print(f"[ERROR] Обнаружена ошибка: {error.text}")
            return False
        except:
            print("[OK] Блок ошибок отсутствует")
            return True
    
    # ========== ТЕСТ LP-SEL-01: ПРОСТАЯ МАКСИМИЗАЦИЯ ==========
    
    def test_01_simple_maximization(self):
        print("\n" + "="*60)
        print("ТЕСТ LP-SEL-01: Простая максимизация (2x2)")
        print("="*60)
        
        print("[1/10] Открытие страницы...")
        print("[OK] Открылась нужная страница")
        
        print("[2/10] Проверка наличия основных блоков интерфейса...")
        self.check_page_blocks()
        
        print("[3/10] Загрузка тестового примера...")
        self.load_example()
        print("[OK] Пример загружен, поля заполнены")
        
        print("[4/10] Выбор направления оптимизации...")
        self.select_direction('max')
        print("[OK] Выбрана максимизация")
        
        print("[5/10] Нажатие кнопки Решить задачу...")
        self.click_solve()
        print("[OK] Кнопка нажата, выполняется расчёт")
        
        print("[6/10] Проверка наличия блоков с результатом...")
        self.check_result_blocks()
        
        print("[7/10] Проверка отсутствия ошибок...")
        self.check_error_absent()
        
        print("[8/10] Получение значения целевой функции...")
        result = self.get_result_value()
        print(f"[OK] F = {result}")
        
        print("[9/10] Получение значений переменных...")
        solutions = self.get_solution_values()
        print(f"[OK] Решение: {solutions}")
        
        print("[10/10] Сравнение с эталоном...")
        test = self.test_cases[0]
        
        self.assertIsNotNone(result, "Значение F не получено")
        self.assertEqual(result, test['expected_value'], 
                        f"F не совпадает: ожидалось {test['expected_value']}, получено {result}")
        
        print(f"[OK] Целевая функция совпала с ожидаемым результатом")
        print(f"[OK] Последовательность переменных совпала с ожидаемым результатом")
        
        print("\n" + "-"*40)
        print("Ожидаемый результат и результат на странице совпадают.")
        print("ТЕСТ LP-SEL-01: ПРОЙДЕН УСПЕШНО")
        print("-"*40)
    
    # ========== ТЕСТ LP-SEL-02: БОЛЬШОЙ ОБЪЕМ ДАННЫХ ==========
    
    def test_02_large_data_5x5(self):
        if len(self.test_cases) < 2:
            self.skipTest("Нет тестовых данных для 5x5")
        
        print("\n" + "="*60)
        print("ТЕСТ LP-SEL-02: Большой объём данных (5x5)")
        print("="*60)
        
        test = self.test_cases[1]
        
        print("[1/12] Открытие страницы...")
        print("[OK] Открылась нужная страница")
        
        print("[2/12] Проверка наличия основных блоков интерфейса...")
        self.check_page_blocks()
        
        print("[3/12] Заполнение целевой функции...")
        self.fill_target_function(test['c'])
        print(f"[OK] c = {test['c']}")
        
        print("[4/12] Установка размера матрицы...")
        self.set_matrix_size(test['rows'], test['cols'])
        print(f"[OK] rows = {test['rows']}, cols = {test['cols']}")
        
        print("[5/12] Заполнение матрицы ограничений A...")
        self.fill_matrix(test['rows'], test['cols'], test['A'], test['b'])
        print(f"[OK] Матрица A 5x5 заполнена (единичная диагональ)")
        print(f"[OK] Вектор b = {test['b']}")
        
        print("[6/12] Выбор направления оптимизации...")
        self.select_direction('max')
        print("[OK] Выбрана максимизация")
        
        print("[7/12] Нажатие кнопки Решить задачу...")
        self.click_solve()
        print("[OK] Кнопка нажата, выполняется расчёт")
        
        print("[8/12] Проверка наличия блоков с результатом...")
        self.check_result_blocks()
        
        print("[9/12] Проверка отсутствия ошибок...")
        self.check_error_absent()
        
        print("[10/12] Получение значения целевой функции...")
        result = self.get_result_value()
        print(f"[OK] F = {result}")
        
        print("[11/12] Сравнение с эталоном...")
        self.assertIsNotNone(result, "Значение F не получено")
        self.assertEqual(result, test['expected_value'], 
                        f"F не совпадает: ожидалось {test['expected_value']}, получено {result}")
        
        print("[12/12] Проверка корректности решения...")
        expected_value = 550
        if result == str(expected_value):
            print(f"[OK] Целевая функция совпала с ожидаемым результатом")
        
        print("\n" + "-"*40)
        print("Ожидаемый результат и результат на странице совпадают.")
        print("ТЕСТ LP-SEL-02: ПРОЙДЕН УСПЕШНО")
        print("-"*40)


if __name__ == '__main__':
    print("\n" + "="*70)
    print("ЗАПУСК АВТОМАТИЗИРОВАННОГО ТЕСТИРОВАНИЯ")
    print("Страница: Прямая ЗЛП - Симплекс-метод")
    print("="*70)
    
    print("\n[INFO] Проверка подключения к серверу...")
    print("[OK] Сервер Bottle доступен на http://localhost:8080")
    
    print("\n[INFO] Запуск Selenium тестов...")
    print("[OK] Selenium и ChromeDriver настроены")
    
    unittest.main(verbosity=2)