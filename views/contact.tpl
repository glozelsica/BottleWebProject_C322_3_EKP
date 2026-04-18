<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Контакты</title>
    <link rel="stylesheet" href="/static/css/style.css">
   
<header style="position: relative; overflow: hidden; background: #9B2226;">
    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.4; pointer-events: none;"></div>
        <div style="position: relative; z-index: 1; display: flex; justify-content: space-between; align-items: center; padding: 1rem 2rem;">
            <div class="logo" style="display: flex; align-items: center; gap: 0.5rem;">
                <img src="/static/images/logo.png" alt="Логотип" style="height: 35px; width: auto;">
                <span style="color: white; font-weight: bold;">Контакты</span>
        </div>
        <nav style="display: flex; gap: 1.5rem;">
            <a href="/" style="color: white; text-decoration: none;">Главная</a>
            <a href="/direct_lp" style="color: white; text-decoration: none;">Прямая ЗЛП</a>
            <a href="/transport" style="color: white; text-decoration: none;">Транспортная</a>
            <a href="/assignment" style="color: white; text-decoration: none;">Задача о назначениях</a>
            <a href="/video" style="color: white; text-decoration: none;">Видео</a>
            <a href="/authors" style="color: white; text-decoration: none;">Об авторах</a>
        </nav>
    </div>
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
                    <p><a href="tel:+79312666117">+7 (931) 266-61-17</a></p>
                </div>
                <div class="contact-card">
                    <div class="contact-icon">✉️</div>
                    <h3>Email</h3>
                    <p><a href="mailto:Leontiy.Zaytsev.06@mail.ru">Leontiy.Zaytsev.06@mail.ru</a></p>
                </div>
                <div class="contact-card">
                    <div class="contact-icon">💬</div>
                    <h3>ВКонтакте</h3>
                    <p><a href="https://vk.com/valerialion" target="_blank">vk.com/valerialion</a></p>
                </div>
                <div class="contact-card">
                    <div class="contact-icon">🐙</div>
                    <h3>GitHub</h3>
                    <p><a href="https://github.com/glozelsica/BottleWebProject_C322_3_EKP" target="_blank">Репозиторий проекта</a></p>
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
                <p>Санкт-Петербург, Московский пр. 149б (корпус 4)</p>
                <p>Факультет среднего профессионального образования №12, ГУАП</p>
                <p>Аудитория 305 (кафедра информационных систем)</p>
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

    <footer style="position: relative; overflow: hidden; background: #9B2226;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.4; pointer-events: none;"></div>
        <div class="footer-bottom" style="position: relative; z-index: 1;">
            <p>© 2026 Математическое моделирование. Все права защищены.</p>
        </div>
    </footer>
</body>
</html>