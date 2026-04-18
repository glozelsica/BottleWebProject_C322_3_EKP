<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Видео-инструкции</title>
    <link rel="stylesheet" href="/static/content/site.css">
    <link rel="icon" href="/static/images/logo.png" type="image/png">
    <style>
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 2rem;
            margin: 2rem 0;
        }
        .video-card {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            transition: transform 0.3s;
        }
        .video-card:hover {
            transform: translateY(-5px);
        }
        .video-card h3 {
            padding: 1rem;
            margin: 0;
            background: linear-gradient(135deg, #9B2226, #6d181b);
            color: #EDE7F6;
        }
        .video-container {
            position: relative;
            padding-bottom: 56.25%;
            height: 0;
        }
        .video-container iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }
        .video-desc {
            padding: 1rem;
            background: #f8f9fa;
        }
        .video-desc p {
            margin: 0.5rem 0;
        }
    </style>
</head>
<body>
    <!-- ШАПКА С ТЕКСТУРОЙ -->
    <header style="position: relative; overflow: hidden; background: linear-gradient(135deg, #9B2226, #6d181b);">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.15; pointer-events: none;"></div>
        <div style="position: relative; z-index: 1; display: flex; justify-content: space-between; align-items: center; padding: 1rem 2rem; flex-wrap: wrap;">
            <div class="logo" style="display: flex; align-items: center; gap: 10px;">
                <img src="/static/images/logo.png" alt="Логотип" class="logo-img" style="height: 35px; width: auto;">
                <span style="color: #EDE7F6; font-weight: bold;">Математическое моделирование</span>
            </div>
            <nav style="display: flex; gap: 1.5rem; flex-wrap: wrap;">
                <a href="/" style="color: #EDE7F6; text-decoration: none;">Главная</a>
                <a href="/direct_lp" style="color: #EDE7F6; text-decoration: none;">Прямая ЗЛП</a>
                <a href="/transport" style="color: #EDE7F6; text-decoration: none;">Транспортная</a>
                <a href="/assignment" style="color: #EDE7F6; text-decoration: none;">Назначения</a>
                <a href="/video" style="color: #EDE7F6; text-decoration: none;">Видео</a>
                <a href="/authors" style="color: #EDE7F6; text-decoration: none;">Об авторах</a>
                <a href="/contact" style="color: #EDE7F6; text-decoration: none;">Контакты</a>
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
                <strong>Совет:</strong> Используйте паузу на каждом шаге алгоритма, чтобы разобраться в деталях. Для закрепления материала попробуйте решить задачу самостоятельно, а затем сравните с результатом программы.
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
    <footer style="position: relative; overflow: hidden; background: linear-gradient(135deg, #9B2226, #6d181b); margin-top: 2rem;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.15; pointer-events: none;"></div>
        <div style="position: relative; z-index: 1; padding: 2rem 2rem 1rem;">
            <div class="footer-content" style="display: flex; justify-content: space-between; flex-wrap: wrap; gap: 2rem; max-width: 1400px; margin: 0 auto;">
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
            <div class="footer-bottom" style="text-align: center; padding-top: 1.5rem; margin-top: 1.5rem; border-top: 1px solid rgba(237,231,246,0.2); font-size: 0.8rem;">
                <p>© 2026 Математическое моделирование. Все права защищены.</p>
            </div>
        </div>
    </footer>
</body>
</html>