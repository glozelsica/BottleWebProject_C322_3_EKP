<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Контакты</title>
    <link rel="stylesheet" href="/static/content/site.css">
    <style>
        .contact-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin: 2rem 0;
        }
        .contact-card {
            background: linear-gradient(135deg, #ffffff, #f8f9fa);
            border-radius: 20px;
            padding: 1.5rem;
            text-align: center;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        .contact-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        .contact-card a {
            color: #9B2226;
            text-decoration: none;
        }
        .contact-card a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <header style="background: linear-gradient(135deg, #EDE7F6, #d9cfe8); color: #9B2226;">
        <div class="logo" style="color: #9B2226;">📊 Математическое моделирование</div>
        <nav>
            <a href="/" style="color: #9B2226;">Главная</a>
            <a href="/direct_lp" style="color: #9B2226;">Прямая ЗЛП</a>
            <a href="/transport" style="color: #9B2226;">Транспортная</a>
            <a href="/assignment" style="color: #9B2226;">Назначения</a>
            <a href="/video" style="color: #9B2226;">Видео</a>
            <a href="/authors" style="color: #9B2226;">Об авторах</a>
            <a href="/contact" style="color: #9B2226;">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>📞 Контакты</h1>
            
            % if 'Ваш вопрос отправлен' in message:
            <div class="result-box" style="background: #d4edda;">
                <p>✅ {{message}}</p>
            </div>
            % end
            
            <div class="contact-grid">
                <div class="contact-card">
                    <div class="contact-icon">📱</div>
                    <h3>Телефон</h3>
                    <p><a href="tel:+79212666117">+7 (921) 266-61-17</a></p>
                </div>
                <div class="contact-card">
                    <div class="contact-icon">✉️</div>
                    <h3>Email</h3>
                    <p><a href="mailto:team3@mathmodel.ru">team3@mathmodel.ru</a></p>
                </div>
                <div class="contact-card">
                    <div class="contact-icon">💬</div>
                    <h3>ВКонтакте</h3>
                    <p><a href="https://vk.com/team3_lp" target="_blank">vk.com/team3_lp</a></p>
                </div>
                <div class="contact-card">
                    <div class="contact-icon">🐙</div>
                    <h3>GitHub</h3>
                    <p><a href="https://github.com/team3/BottleWebProject_C322_3_EKP" target="_blank">Репозиторий проекта</a></p>
                </div>
            </div>
            
            <div class="form-section">
                <h3>📝 Задать вопрос</h3>
                <form method="post" action="/send_question">
                    <div class="form-group">
                        <label>Ваше имя:</label>
                        <input type="text" name="name" placeholder="Введите ваше имя" style="width: 100%; max-width: 400px;">
                    </div>
                    <div class="form-group">
                        <label>Email для ответа:</label>
                        <input type="email" name="email" placeholder="your@email.com" style="width: 100%; max-width: 400px;">
                    </div>
                    <div class="form-group">
                        <label>Вопрос:</label>
                        <textarea name="question" rows="5" placeholder="Опишите ваш вопрос..." style="width: 100%; max-width: 600px; padding: 8px;"></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">📨 Отправить вопрос</button>
                </form>
            </div>
            
            <div class="theory-block">
                <h3>📍 Адрес</h3>
                <p>Санкт-Петербург, ул. Ленина, д. 101 (корпус 4)</p>
                <p>Факультет среднего профессионального образования №12, ГУАП</p>
                <p>Аудитория 321 (кафедра информационных систем)</p>
            </div>
        </div>
        
        <div class="sidebar">
            <h3>📌 Быстрые ссылки</h3>
            <ul>
                <li>• <a href="/">Главная страница</a></li>
                <li>• <a href="/transport">Транспортная задача</a></li>
                <li>• <a href="/video">Видео-инструкции</a></li>
                <li>• <a href="/authors">Об авторах</a></li>
            </ul>
            <div class="tip-box">
                <strong>⏰ Время ответа</strong>
                <p>Обычно мы отвечаем в течение 24 часов.</p>
                <p>По срочным вопросам звоните по телефону.</p>
            </div>
        </div>
    </div>

    <footer>
        <p>BottleWebProject_C322_3_EKP | Команда №3 | Егармина, Корнилов, Потылицына | {{year}}</p>
        <a href="/contact" class="question-btn">📩 Задать вопрос</a>
    </footer>
</body>
</html>