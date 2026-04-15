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
            <a href="/video">Видео</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>Задачи линейного программирования</h1>
            <p>Решение оптимизационных задач с помощью методов математического моделирования.</p>

            <div class="cards">
                <div class="card">
                    <h3>Прямая ЗЛП</h3>
                    <p>Симплекс-метод для нахождения максимума или минимума линейной функции при системе ограничений.</p>
                    <button onclick="location.href='/direct_lp'">Перейти</button>
                </div>
                
                <div class="card">
                    <h3>Транспортная задача</h3>
                    <p>Минимизация стоимости перевозок от поставщиков к потребителям.</p>
                    <button onclick="location.href='/transport'">Перейти</button>
                </div>
                
                <div class="card">
                    <h3>Задача о назначениях</h3>
                    <p>Оптимальное распределение работ между исполнителями.</p>
                    <button onclick="location.href='/assignment'">Перейти</button>
                </div>
            </div>
        </div>

        <aside class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками матрицы используйте стрелки на клавиатуре</li>
                <li>Для быстрого перехода по полям используйте клавишу Tab</li>
                <li>Результат можно сохранить в Excel или CSV</li>
                <li>Если задача не имеет решения - система сообщит об этом</li>
                <li>Ввод данных сохраняется при перезагрузке страницы</li>
            </ul>
            <div class="tip-box">
                <h4>Нужна помощь?</h4>
                <p>Посмотрите <a href="/video">видео-инструкцию</a></p>
            </div>
        </aside>
    </div>

    <footer>
        <p>2026 - Задачи линейного программирования</p>
        <a href="/contact" class="question-btn">Задать вопрос</a>
    </footer>
</body>
</html>