<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Видео-инструкции</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <link rel="icon" href="/static/images/logo.png" type="image/png">
</head>
<body>
    <!-- ШАПКА С ТЕКСТУРОЙ -->
    <header class="header-with-texture">
        <div class="header-texture"></div>
        <div class="header-content">
            <div class="logo">
                <img src="/static/images/logo.png" alt="Логотип" class="logo-img" onerror="this.style.display='none'">
                <span>Математическое моделирование</span>
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
        </div>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>Видео-инструкции</h1>
            <p>Подробные видеоуроки по всем трём методам решения задач линейного программирования.</p>
            
            <div class="video-grid">
                <!-- Транспортная задача -->
                <div class="video-card">
                    <h3>Транспортная задача</h3>
                    <div class="video-container">
                        <iframe src="https://www.youtube.com/embed/1R7fZ3YqX9M" 
                                frameborder="0" 
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                                allowfullscreen>
                        </iframe>
                    </div>
                    <div class="video-desc">
                        <p>Метод потенциалов: построение опорного плана, расчёт потенциалов, цикл пересчёта. Подробный разбор на примере.</p>
                        <p><strong>Длительность:</strong> ~25 минут</p>
                    </div>
                </div>
                
                <!-- Симплекс-метод -->
                <div class="video-card">
                    <h3>Симплекс-метод (прямая ЗЛП)</h3>
                    <div class="video-container">
                        <iframe src="https://www.youtube.com/embed/1R7fZ3YqX9M" 
                                frameborder="0" 
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                                allowfullscreen>
                        </iframe>
                    </div>
                    <div class="video-desc">
                        <p>Решение задач линейного программирования симплекс-методом: приведение к каноническому виду, симплекс-таблицы, критерий оптимальности.</p>
                        <p><strong>Длительность:</strong> ~30 минут</p>
                    </div>
                </div>
                
                <!-- Венгерский алгоритм -->
                <div class="video-card">
                    <h3>Венгерский алгоритм (задача о назначениях)</h3>
                    <div class="video-container">
                        <iframe src="https://www.youtube.com/embed/1R7fZ3YqX9M" 
                                frameborder="0" 
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                                allowfullscreen>
                        </iframe>
                    </div>
                    <div class="video-desc">
                        <p>Оптимальное распределение работ между исполнителями: редукция матрицы, поиск максимального паросочетания, улучшение назначения.</p>
                        <p><strong>Длительность:</strong> ~22 минуты</p>
                    </div>
                </div>
            </div>
            
            <div class="tip-box" style="margin-top: 2rem;">
                <strong>💡 Совет:</strong> Используйте паузу на каждом шаге алгоритма, чтобы разобраться в деталях. Для закрепления материала попробуйте решить задачу самостоятельно, а затем сравните с результатом программы.
            </div>
        </div>
        
        <div class="sidebar">
            <h3>Полезные ссылки</h3>
            <ul>
                <li><a href="/transport">Транспортная задача</a></li>
                <li><a href="/direct_lp">Прямая ЗЛП</a></li>
                <li><a href="/assignment">Задача о назначениях</a></li>
                <li><a href="/authors">Об авторах</a></li>
            </ul>
            <div class="tip-box">
                <strong>Нужна помощь?</strong>
                <p>Задайте вопрос на странице контактов</p>
                <a href="/contact" class="btn btn-primary" style="display:block; margin-top:10px;">Задать вопрос</a>
            </div>
        </div>
    </div>

    <!-- ПОДВАЛ С ТЕКСТУРОЙ -->
    <footer class="footer-with-texture">
        <div class="footer-texture"></div>
        <div class="footer-content">
            <div class="footer-inner">
                <div class="footer-section">
                    <h4>BottleWebProject_C322_3_EKP</h4>
                    <p>Команда №3 | Егармина, Корнилов, Потылицына</p>
                    <p>Группа C322 | ГУАП ФСПО №12</p>
                </div>
                <div class="footer-section">
                    <h4>2026</h4>
                    <p>Учебная практика УП02</p>
                    <p>ПМ02 «Интеграция программных модулей»</p>
                </div>
                <div class="footer-section">
                    <h4>Связь</h4>
                    <a href="/contact" class="question-btn">Задать вопрос</a>
                </div>
            </div>
            <div class="footer-bottom">
                <p>© 2026 Математическое моделирование. Все права защищены.</p>
            </div>
        </div>
    </footer>
</body>
</html>