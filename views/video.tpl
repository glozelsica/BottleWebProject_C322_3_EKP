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
    </style>
</head>
<body>
    <header>
        <div class="logo">
            <img src="/static/images/logo.png" alt="Логотип" class="logo-img"> 
            Математическое моделирование
        </div>
        <nav>
            <a href="/">Главная</a>
            <a href="/direct_lp">Прямая ЗЛП</a>
            <a href="/transport">Транспортная</a>
            <a href="/assignment">Назначения</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>📹 Видео-инструкции</h1>
            <p>Подробные видеоуроки по всем трём методам решения задач линейного программирования.</p>
            
            <div class="video-grid">
                <!-- Транспортная задача -->
                <div class="video-card">
                    <h3>🚚 Транспортная задача</h3>
                    <div class="video-container">
                        <iframe src="https://www.youtube.com/embed/1R7fZ3YqX9M?si=example1" 
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
                    <h3>📐 Симплекс-метод (прямая ЗЛП)</h3>
                    <div class="video-container">
                        <iframe src="https://www.youtube.com/embed/1R7fZ3YqX9M?si=example2" 
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
                    <h3>👥 Венгерский алгоритм (задача о назначениях)</h3>
                    <div class="video-container">
                        <iframe src="https://www.youtube.com/embed/1R7fZ3YqX9M?si=example3" 
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
            <h3>📌 Полезные ссылки</h3>
            <ul>
                <li>• <a href="/transport">Транспортная задача</a></li>
                <li>• <a href="/direct_lp">Прямая ЗЛП</a></li>
                <li>• <a href="/assignment">Задача о назначениях</a></li>
                <li>• <a href="/authors">Об авторах</a></li>
            </ul>
            <div class="tip-box">
                <strong>❓ Нужна помощь?</strong>
                <p>Задайте вопрос на странице контактов</p>
                <a href="/contact" class="btn btn-primary" style="display:block; margin-top:10px;">Задать вопрос</a>
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