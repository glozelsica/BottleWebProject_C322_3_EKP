from bottle import route, view, request, template, static_file, redirect
from datetime import datetime
import json
import os

# ==================== СТАТИЧЕСКИЕ ФАЙЛЫ ====================

@route('/static/<filepath:path>')
def serve_static(filepath):
    """Serve static files (CSS, images, etc.)"""
    return static_file(filepath, root='static')


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
        video_url='https://www.youtube.com/embed/dQw4w9WgXcQ'
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
    from controllers.direct_lp import solve_direct_lp
    return solve_direct_lp()


# ==================== ЗАДАЧА О НАЗНАЧЕНИЯХ (Корнилов) ====================

@route('/assignment', method=['GET', 'POST'])
def assignment():
    """Assignment problem page."""
    from controllers.assignment import solve_assignment
    return solve_assignment()


# ==================== ОБРАБОТЧИК ВОПРОСОВ ====================

@route('/send_question', method=['POST'])
def send_question():
    """Handle question form submission."""
    question = request.forms.get('question', '')
    name = request.forms.get('name', 'Аноним')
    
    os.makedirs('data', exist_ok=True)
    with open('data/questions.txt', 'a', encoding='utf-8') as f:
        f.write(f"[{datetime.now()}] От: {name}\n")
        f.write(f"Вопрос: {question}\n")
        f.write("-" * 50 + "\n")
    
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


# ==================== НАСТРОЙКА МАРШРУТОВ ДЛЯ APP.PY ====================

def setup_routes(app):
    """Register all routes with the Bottle app."""
    
    @app.route('/static/<filepath:path>')
    def serve_static(filepath):
        return static_file(filepath, root='static')
    
    @app.route('/')
    @app.route('/home')
    def home():
        return template('index', year=datetime.now().year, title='Главная страница')
    
    @app.route('/about')
    def about():
        return template('about', title='О проекте', 
                       message='Веб-приложение для решения задач линейного программирования',
                       year=datetime.now().year)
    
    @app.route('/authors')
    def authors():
        return template('authors', title='Об авторах', year=datetime.now().year,
                       authors=[
                           {'name': 'Егармина В.А.', 'role': 'Прямая ЗЛП (симплекс-метод)', 'photo': 'egarmina.jpg'},
                           {'name': 'Потылицына З.С.', 'role': 'Транспортная задача (метод потенциалов)', 'photo': 'potylitsyna.jpg'},
                           {'name': 'Корнилов Л.О.', 'role': 'Задача о назначениях (венгерский метод)', 'photo': 'kornilov.jpg'}
                       ])
    
    @app.route('/contact')
    def contact():
        return template('contact', title='Контакты',
                       message='Свяжитесь с нами по любым вопросам',
                       phone='+7 (921) 266-61-17',
                       email='team3@mathmodel.ru',
                       vk='https://vk.com/team3_lp',
                       year=datetime.now().year)
    
    @app.route('/video')
    def video():
        return template('video', title='Видео-инструкция',
                       year=datetime.now().year,
                       video_url='https://www.youtube.com/embed/dQw4w9WgXcQ')
    
    @app.route('/transport', method=['GET', 'POST'])
    def transport():
        from controllers.transport import solve_transport
        return solve_transport()
    
    @app.route('/direct_lp', method=['GET', 'POST'])
    def direct_lp():
        from controllers.direct_lp import solve_direct_lp
        return solve_direct_lp()
    
    @app.route('/assignment', method=['GET', 'POST'])
    def assignment():
        from controllers.assignment import solve_assignment
        return solve_assignment()
    
    @app.route('/send_question', method=['POST'])
    def send_question():
        question = request.forms.get('question', '')
        name = request.forms.get('name', 'Аноним')
        
        os.makedirs('data', exist_ok=True)
        with open('data/questions.txt', 'a', encoding='utf-8') as f:
            f.write(f"[{datetime.now()}] От: {name}\n")
            f.write(f"Вопрос: {question}\n")
            f.write("-" * 50 + "\n")
        
        return template('contact', 
            title='Контакты',
            message='Ваш вопрос отправлен! Мы ответим в ближайшее время.',
            phone='+7 (921) 266-61-17',
            email='team3@mathmodel.ru',
            vk='https://vk.com/team3_lp',
            year=datetime.now().year)
    
    @app.route('/test')
    def test():
        return "✅ Сервер работает! Все маршруты загружены."