<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Задачи линейного программирования</title>
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <header>
        <div class="logo">Математическое моделирование</div>
        <nav>
            <a href="/">Главная</a>
            <a href="/direct_lp">Прямая ЗЛП</a>
            <a href="/transport">Транспортная задача</a>
            <a href="/assignment">Задача о назначениях</a>
            <a href="/video">Видеоинструкция</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        <div class="content">
            % include(content_template, **locals())
        </div>
        <aside class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перемещения между ячейками матрицы используйте стрелки на клавиатуре</li>
                <li>Результат можно сохранить в Excel или CSV</li>
                <li>Если задача не имеет решения, система сообщит об этом</li>
                <li>Введённые данные сохраняются автоматически</li>
            </ul>
            <div class="tip-box">
                <h4>Нужна помощь?</h4>
                <p><a href="/video">Смотреть видеоинструкцию</a></p>
            </div>
        </aside>
    </div>

    <footer>
        <p>2026 - Задачи линейного программирования</p>
        <a href="/contact" class="question-btn">Задать вопрос</a>
    </footer>

    <script src="/static/js/direct_lp.js"></script>
</body>
</html>
