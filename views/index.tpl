<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Математическое моделирование</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <link rel="icon" href="/static/images/logo.png" type="image/png">
</head>
<body>
    <header>
        <div class="logo">
            <img src="/static/images/logo.png" alt="Логотип" style="height: 35px; width: auto; margin-right: 10px;">
            Математическое моделирование
        </div>
        <nav>
            <a href="/">Главная</a>
            <a href="/direct_lp">Прямая ЗЛП</a>
            <a href="/transport">Транспортная</a>
            <a href="/assignment">Назначения</a>
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
                <!-- Карточка 1: Прямая ЗЛП -->
                <div class="card">
                    <div style="font-size: 3rem; text-align: center;">
                        <img src="/static/images/icon_zlp.png" alt="ЗЛП" style="width: 70px; height: 70px; object-fit: contain;">
                    </div>
                    <h3>Прямая ЗЛП</h3>
                    <p>Симплекс-метод для нахождения максимума или минимума линейной функции при системе ограничений.</p>
                    <details>
                        <p>Линейное программирование — раздел математического моделирования. Симплекс-метод последовательно улучшает решение, переходя от одной вершины допустимого множества к другой.</p>
                    </details>
                    <button onclick="location.href='/direct_lp'">Перейти →</button>
                </div>
                
                <!-- Карточка 2: Транспортная задача -->
                <div class="card">
                    <div style="font-size: 3rem; text-align: center;">
                        <img src="/static/images/icon_transport.png" alt="Транспортная задача" style="width: 70px; height: 70px; object-fit: contain;">
                    </div>
                    <h3>Транспортная задача</h3>
                    <p>Минимизация стоимости перевозок от поставщиков к потребителям. Методы: северо-западного угла, минимального элемента, потенциалов.</p>
                    <details>
                        <p>Транспортная задача — частный случай ЗЛП. Оптимальный план перевозок находится методом потенциалов с итерационным улучшением.</p>
                    </details>
                    <button onclick="location.href='/transport'">Перейти →</button>
                </div>
                
                <!-- Карточка 3: Задача о назначениях -->
                <div class="card">
                    <div style="font-size: 3rem; text-align: center;">
                        <img src="/static/images/icon_assig.png" alt="Задача о назначениях" style="width: 70px; height: 70px; object-fit: contain;">
                    </div>
                    <h3>Задача о назначениях</h3>
                    <p>Оптимальное распределение работ между исполнителями. Реализован венгерский алгоритм.</p>
                    <details>
                        <p>Задача о назначениях — минимизация суммарной стоимости выполнения работ. Венгерский алгоритм находит оптимальное назначение за полиномиальное время.</p>
                    </details>
                    <button onclick="location.href='/assignment'">Перейти →</button>
                </div>
            </div>
        </div>
        
        <div class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками матрицы используйте <kbd>Tab</kbd></li>
                <li>Результат можно сохранить в Excel/CSV</li>
                <li>При несбалансированности добавляются фиктивные участники</li>
                <li>Все данные сохраняются в истории решений</li>
            </ul>
            <div class="tip-box">
                <strong>Нужна помощь?</strong>
                <p>Посмотрите видео-инструкцию</p>
                <a href="/video" class="btn btn-info" style="display:block;">Смотреть урок</a>
            </div>
        </div>
    </div>

    <footer>
        <div class="footer-bottom">
            <p>© 2026 Математическое моделирование. Все права защищены.</p>
        </div>
    </footer>
</body>
</html>