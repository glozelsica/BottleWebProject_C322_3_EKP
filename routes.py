from bottle import static_file, template

from bottle import route, view, request, template, static_file, redirect
from datetime import datetime
import json
import os

# ==================== СТАТИЧЕСКИЕ ФАЙЛЫ ====================

@route('/static/<filepath:path>')
def serve_static(filepath):
    """Serve static files (CSS, images, etc.)"""
    return static_file(filepath, root='static/content')


# ==================== ОСНОВНЫЕ СТРАНИЦЫ ====================

@route('/')
@route('/home')
@view('index')
def home():
    """Renders the home page."""
    return dict(
        year=datetime.now().year,
        title='Главная страница'
    )


@route('/about')
@view('about')
def about():
    """Renders the about page."""
    return dict(
        title='О проекте',
        message='Веб-приложение для решения задач линейного программирования',
        year=datetime.now().year
    )


@route('/authors')
@view('authors')
def authors():
    """Renders the authors page."""
    return dict(
        title='Об авторах',
        year=datetime.now().year,
        authors=[
            {'name': 'Егармина В.А.', 'role': 'Прямая ЗЛП (симплекс-метод)', 'photo': 'egarmina.jpg'},
            {'name': 'Потылицына З.С.', 'role': 'Транспортная задача (метод потенциалов)', 'photo': 'potylitsyna.jpg'},
            {'name': 'Корнилов Л.О.', 'role': 'Задача о назначениях (венгерский метод)', 'photo': 'kornilov.jpg'}
        ]
    )


@route('/contact')
@view('contact')
def contact():
    """Renders the contact page."""
    return dict(
        title='Контакты',
        message='Свяжитесь с нами по любым вопросам',
        phone='+7 (921) 266-61-17',
        email='team3@mathmodel.ru',
        vk='https://vk.com/team3_lp',
        year=datetime.now().year
    )


@route('/video')
@view('video')
def video():
    """Renders the video instruction page."""
    return dict(
        title='Видео-инструкция',
        year=datetime.now().year,
        video_url='https://www.youtube.com/embed/dQw4w9WgXcQ'  # замените на реальную ссылку
    )


# ==================== ТРАНСПОРТНАЯ ЗАДАЧА (Потылицына) ====================

@route('/transport', method=['GET', 'POST'])
def transport():
    """Transport problem page with GET/POST handling."""
    from controllers.transport import solve_transport
    return solve_transport()


# ==================== ПРЯМАЯ ЗЛП (Егармина) ====================

@route('/direct_lp', method=['GET', 'POST'])
def direct_lp():
    """Direct linear programming problem page."""
    # Здесь будет код Егарминой
    return template('direct_lp', title='Прямая ЗЛП', year=datetime.now().year)


# ==================== ЗАДАЧА О НАЗНАЧЕНИЯХ (Корнилов) ====================

@route('/assignment', method=['GET', 'POST'])
def assignment():
    """Assignment problem page."""
    # Здесь будет код Льва
    return template('assignment', title='Задача о назначениях', year=datetime.now().year)


# ==================== ОБРАБОТЧИК ВОПРОСОВ ====================

@route('/send_question', method=['POST'])
def send_question():
    """Handle question form submission."""
    question = request.forms.get('question', '')
    name = request.forms.get('name', 'Аноним')
    
    # Сохраняем вопрос в файл
    os.makedirs('data', exist_ok=True)
    with open('data/questions.txt', 'a', encoding='utf-8') as f:
        f.write(f"[{datetime.now()}] От: {name}\n")
        f.write(f"Вопрос: {question}\n")
        f.write("-" * 50 + "\n")
    
    # Перенаправляем обратно на страницу контактов с сообщением
    return template('contact', 
        title='Контакты',
        message='Ваш вопрос отправлен! Мы ответим в ближайшее время.',
        phone='+7 (921) 266-61-17',
        email='team3@mathmodel.ru',
        vk='https://vk.com/team3_lp',
        year=datetime.now().year
    )


# ==================== ОБРАБОТЧИК ОШИБОК ====================

@route('/error')
@view('error')
def error_page():
    """Error page."""
    return dict(
        title='Ошибка',
        message='Произошла непредвиденная ошибка',
        year=datetime.now().year
    )


@route('/test')
def test():
    """Test route to verify everything works."""
    return "✅ Сервер работает! Все маршруты загружены."