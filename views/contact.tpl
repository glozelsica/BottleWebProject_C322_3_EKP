<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Контакты</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <link rel="stylesheet" href="/static/css/contact.css">
    <link rel="icon" href="/static/images/logo.png" type="image/png">
</head>
<body>
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
            <h1>
                <span class="header-icon">
                    <img src="/static/images/icon_gphone.png" alt="Контакты">
                </span>
                Контакты
            </h1>
            
            % if message and 'Ваш вопрос отправлен' in message:
            <div class="result-box">
                <p>✅ {{message}}</p>
            </div>
            % end
            
            <div class="contact-grid">
                <div class="contact-card">
                    <div class="contact-icon">
                        <img src="/static/images/icon_phone.png" alt="Телефон">
                    </div>
                    <h3>Телефон</h3>
                    <p><a href="tel:+79312666117">+7 (931) 266-61-17</a></p>
                </div>
                
                <div class="contact-card">
                    <div class="contact-icon">
                        <img src="/static/images/icon_gmail.png" alt="Email">
                    </div>
                    <h3>Email</h3>
                    <p><a href="mailto:Leontiy.Zaytsev.06@mail.ru">Leontiy.Zaytsev.06@mail.ru</a></p>
                </div>
                
                <div class="contact-card">
                    <div class="contact-icon">
                        <img src="/static/images/icon_vk.png" alt="ВКонтакте">
                    </div>
                    <h3>ВКонтакте</h3>
                    <p><a href="https://vk.com/valerialion" target="_blank">vk.com/valerialion</a></p>
                </div>
                
                <div class="contact-card">
                    <div class="contact-icon">
                        <img src="/static/images/icon_silver_dog.png" alt="GitHub">
                    </div>
                    <h3>GitHub</h3>
                    <p><a href="https://github.com/glozelsica/BottleWebProject_C322_3_EKP" target="_blank">Репозиторий проекта</a></p>
                </div>
            </div>
            
            <div class="form-section">
                <h3>
                    <img src="/static/images/icon_gmail.png" alt="Письмо">
                    Задать вопрос
                </h3>
                <form method="post" action="/send_question">
                    <div class="form-group">
                        <label>Ваше имя:</label>
                        <input type="text" name="name" placeholder="Введите ваше имя">
                    </div>
                    <div class="form-group">
                        <label>Email для ответа:</label>
                        <input type="email" name="email" placeholder="your@email.com">
                    </div>
                    <div class="form-group">
                        <label>Вопрос:</label>
                        <textarea name="question" rows="5" placeholder="Опишите ваш вопрос..."></textarea>
                    </div>
                    <button type="submit" class="btn-primary">Отправить вопрос</button>
                </form>
            </div>
            
            <div class="theory-block">
                <div class="contact-icon">
                    <img src="/static/images/icon_map.png" alt="Адрес">
                </div>
                <h3>Адрес</h3>
                <p>Санкт-Петербург, Московский пр. 149б (корпус 4)</p>
                <p>Факультет среднего профессионального образования №12, ГУАП</p>
                <p>Аудитория 305 (кафедра информационных систем)</p>
            </div>
        </div>
        
        <div class="sidebar">
            <h3>Быстрые ссылки</h3>
            <ul>
                <li><a href="/">Главная страница</a></li>
                <li><a href="/transport">Транспортная задача</a></li>
                <li><a href="/direct_lp">Прямая ЗЛП</a></li>
                <li><a href="/assignment">Задача о назначениях</a></li>
                <li><a href="/video">Видео-инструкции</a></li>
                <li><a href="/authors">Об авторах</a></li>
            </ul>
            <div class="tip-box">
                <strong>Время ответа</strong>
                <p>Обычно мы отвечаем в течение 24 часов.</p>
                <p>По срочным вопросам звоните по телефону.</p>
            </div>
        </div>
    </div>

    <footer class="footer-with-texture">
        <div class="footer-texture"></div>
        <div class="footer-content">
            <div class="footer-inner">
                <div class="footer-section">
                    <h4>Главные разработчики</h4>
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