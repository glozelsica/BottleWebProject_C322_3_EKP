<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Контакты</title>
    <link rel="stylesheet" href="/static/css/style.css">
   
<header>
    <div class="logo">
        <img src="/static/images/logo.png" alt="Логотип" class="logo-img" onerror="this.style.display='none'">
        Математическое моделирование
    </div>
    <nav>
        <a href="/">Главная</a>
        <a href="/direct_lp">Прямая ЗЛП</a>
        <a href="/transport">Транспортная</a>
        <a href="/assignment">Назначения</a>
        <a href="/authors">Об авторах</a>

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
    <div class="footer-content">
        <div class="footer-section">
            <h4>О проекте</h4>
            <p>Решение задач линейного программирования</p>
            <p>Симплекс-метод, транспортная задача, задача о назначениях</p>
        </div>
        <div class="footer-section">
            <h4>Контакты</h4>
            <p>Email: team3@mathmodel.ru</p>
            <p>Телефон: +7 (921) 266-61-17</p>
        </div>
    </div>
    <div class="footer-bottom">
        2026 - Математическое моделирование. Все права защищены.
    </div>
</footer>
</body>
</html>