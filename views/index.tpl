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
    <!-- ШАПКА С ТЕКСТУРОЙ (одна картинка) -->
    <header style="position: relative; overflow: hidden; background: #9B2226;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.4; pointer-events: none;"></div>
        
        <div style="position: relative; z-index: 1; display: flex; justify-content: space-between; align-items: center; padding: 1rem 2rem;">
            <div class="logo" style="display: flex; align-items: center; gap: 0.5rem;">
                <img src="/static/images/logo.png" alt="Логотип" style="height: 35px; width: auto;">
                <span style="color: white; font-weight: bold;">Математическое моделирование</span>
            </div>
            <nav style="display: flex; gap: 1.5rem;">
                <a href="/" style="color: white; text-decoration: none;">Главная</a>
                <a href="/direct_lp" style="color: white; text-decoration: none;">Прямая ЗЛП</a>
                <a href="/transport" style="color: white; text-decoration: none;">Транспортная</a>
                <a href="/assignment" style="color: white; text-decoration: none;">Назначения</a>
                <a href="/authors" style="color: white; text-decoration: none;">Об авторах</a>
                <a href="/contact" style="color: white; text-decoration: none;">Контакты</a>
            </nav>
        </div>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>Задачи линейного программирования</h1>
            <p>Решение оптимизационных задач с помощью методов математического моделирования.</p>

            <div class="cards">
                <!-- Карточка 1: Прямая ЗЛП -->
                <div class="card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture4.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.03; pointer-events: none;"></div>
                    <div style="position: relative; z-index: 1;">
                        <div style="font-size: 3rem; text-align: center;">
                            <img src="/static/images/icon_zlp.png" alt="ЗЛП" style="width: 70px; height: 70px; object-fit: contain;">
                        </div>
                        <h3>Прямая ЗЛП</h3>
                        <p>Симплекс-метод для нахождения максимума или минимума линейной функции при системе ограничений.</p>
                        <details>
                            <summary>Подробнее</summary>
                            <p>Линейное программирование — раздел математического моделирования. Симплекс-метод последовательно улучшает решение, переходя от одной вершины допустимого множества к другой.</p>
                        </details>
                        <button onclick="location.href='/direct_lp'">Перейти →</button>
                    </div>
                </div>
                
                <!-- Карточка 2: Транспортная задача -->
                <div class="card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture4.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.03; pointer-events: none;"></div>
                    <div style="position: relative; z-index: 1;">
                        <div style="font-size: 3rem; text-align: center;">
                            <img src="/static/images/icon_transport.png" alt="Транспортная задача" style="width: 70px; height: 70px; object-fit: contain;">
                        </div>
                        <h3>Транспортная задача</h3>
                        <p>Минимизация стоимости перевозок от поставщиков к потребителям. Методы: северо-западного угла, минимального элемента, потенциалов.</p>
                        <details>
                            <summary>Подробнее</summary>
                            <p>Транспортная задача — частный случай ЗЛП. Оптимальный план перевозок находится методом потенциалов с итерационным улучшением.</p>
                        </details>
                        <button onclick="location.href='/transport'">Перейти →</button>
                    </div>
                </div>
                
                <!-- Карточка 3: Задача о назначениях -->
                <div class="card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture4.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.03; pointer-events: none;"></div>
                    <div style="position: relative; z-index: 1;">
                        <div style="font-size: 3rem; text-align: center;">
                            <img src="/static/images/icon_assig.png" alt="Задача о назначениях" style="width: 70px; height: 70px; object-fit: contain;">
                        </div>
                        <h3>Задача о назначениях</h3>
                        <p>Оптимальное распределение работ между исполнителями. Реализован венгерский алгоритм.</p>
                        <details>
                            <summary>Подробнее</summary>
                            <p>Задача о назначениях — минимизация суммарной стоимости выполнения работ. Венгерский алгоритм находит оптимальное назначение за полиномиальное время.</p>
                        </details>
                        <button onclick="location.href='/assignment'">Перейти →</button>
                    </div>
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

    <!-- ПОДВАЛ С ТЕКСТУРОЙ (одна картинка) -->
    <footer style="position: relative; overflow: hidden; background: #9B2226;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.4; pointer-events: none;"></div>
        <div class="footer-bottom" style="position: relative; z-index: 1;">
            <p>© 2026 Математическое моделирование. Все права защищены.</p>
        </div>
    </footer>
</body>
</html>