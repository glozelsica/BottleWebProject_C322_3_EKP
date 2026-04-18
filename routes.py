"""
Маршруты веб-приложения BottleWebProject_C322_3_EKP
Авторы: Егармина В.А., Потылицына З.С., Корнилов Л.О.
"""

from bottle import route, view, request, template, static_file, redirect
from datetime import datetime
import json
import os


def setup_routes(app):
    """Регистрация всех маршрутов в приложении Bottle"""
    
    # ==================== СТАТИЧЕСКИЕ ФАЙЛЫ ====================
    
    @app.route('/static/<filepath:path>')
    def serve_static(filepath):
        """Обслуживание статических файлов (CSS, изображения)"""
        return static_file(filepath, root='static')
    
    @app.route('/static/content/<filepath:path>')
    def serve_static_content(filepath):
        """Обслуживание статических файлов из папки content"""
        return static_file(filepath, root='static/')

    @route('/static/images/<filename:path>')
    def serve_images(filename):
        return static_file(filename, root='static/images')
    
    # ==================== ОСНОВНЫЕ СТРАНИЦЫ ====================
    
    @app.route('/')
    @app.route('/home')
    def home():
        """Главная страница с тремя блоками задач"""
        return template('index', 
            year=datetime.now().year, 
            title='Главная страница')
    
    @app.route('/authors')
    def authors():
        """Страница 'Об авторах' с фотографиями и вкладом каждого"""
        return template('authors', 
            title='Об авторах', 
            year=datetime.now().year,
            authors=[
                {'name': 'Егармина В.А.', 'role': 'Прямая ЗЛП (симплекс-метод)', 
                 'contribution': 'Архитектура проекта, главная страница, UML-диаграммы'},
                {'name': 'Потылицына З.С.', 'role': 'Транспортная задача (метод потенциалов)', 
                 'contribution': 'Страница транспортной задачи, стилевое оформление CSS, теория'},
                {'name': 'Корнилов Л.О.', 'role': 'Задача о назначениях (венгерский метод)', 
                 'contribution': 'Страница задачи о назначениях, контакты, тестирование'}
            ])
    
    @app.route('/contact')
    def contact():
        """Страница контактов и обратной связи"""
        return template('contact', 
            title='Контакты',
            message='Свяжитесь с нами по любым вопросам',
            phone='+7 (921) 266-61-17',
            email='team3@mathmodel.ru',
            vk='https://vk.com/team3_lp',
            year=datetime.now().year)
    
    @app.route('/video')
    def video():
        """Страница с видео-инструкциями по решению задач"""
        return template('video',
            title='Видео-инструкция',
            year=datetime.now().year,
            video_url='https://www.youtube.com/embed/dQw4w9WgXcQ')
    
    # ==================== ТРАНСПОРТНАЯ ЗАДАЧА ====================
    
    @app.route('/transport', method=['GET', 'POST'])
    def transport():
        """Страница решения транспортной задачи (метод потенциалов)"""
        from controllers.transport import solve_transport
        return solve_transport()
    
    # ==================== ПРЯМАЯ ЗЛП (СИМПЛЕКС-МЕТОД) ====================
    
    @app.route('/direct_lp', method=['GET', 'POST'])
    def direct_lp():
        """Страница решения прямой ЗЛП (симплекс-метод)"""
        from controllers.direct_lp import solve_direct_lp
        return solve_direct_lp()
    
    # ==================== ЗАДАЧА О НАЗНАЧЕНИЯХ (заглушка) ====================
    
    @app.route('/assignment', method=['GET', 'POST'])
    def assignment():
        """Страница решения задачи о назначениях (венгерский метод)"""
        from controllers.assignment import solve_assignment
        return solve_assignment()
    
    # ==================== ОБРАБОТЧИК ВОПРОСОВ ====================
    
    @app.route('/send_question', method=['POST'])
    def send_question():
        """Обработка формы отправки вопроса"""
        question = request.forms.get('question', '')
        name = request.forms.get('name', 'Аноним')
        
        os.makedirs('data', exist_ok=True)
        with open('data/questions.txt', 'a', encoding='utf-8') as f:
            f.write(f"[{datetime.now()}] От: {name}\n")
            f.write(f"Вопрос: {question}\n")
            f.write("-" * 50 + "\n")
        
        return template('contact', 
            title='Контакты',
            message='✅ Ваш вопрос отправлен! Мы ответим в ближайшее время.',
            phone='+7 (921) 266-61-17',
            email='team3@mathmodel.ru',
            vk='https://vk.com/team3_lp',
            year=datetime.now().year)
    
    # ==================== ТЕСТОВЫЙ МАРШРУТ ====================
    
    @app.route('/test')
    def test():
        """Тестовый маршрут для проверки работы сервера"""
        return "✅ Сервер работает! Все маршруты загружены."