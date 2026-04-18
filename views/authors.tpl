<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Об авторах</title>
    <link rel="stylesheet" href="/static/content/site.css">
    <link rel="icon" href="/static/images/logo.png" type="image/png">
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
            <h1>Об авторах проекта</h1>
            
            <!-- Информация о колледже -->
            <div class="college-section" style="background: linear-gradient(135deg, #9B2226, #6d181b); color: #EDE7F6; padding: 1.5rem; border-radius: 12px; margin-bottom: 2rem; text-align: center;">
                <h2 style="color: #EDE7F6;">Санкт-Петербургский государственный университет аэрокосмического приборостроения (ГУАП)</h2>
                <h3 style="color: #EDE7F6;">Факультет среднего профессионального образования №12</h3>
                <p>ГУАП — один из ведущих технических вузов России, основанный в 1941 году. Факультет СПО готовит высококвалифицированных специалистов в области информационных систем и программирования. Наш проект — результат усердной работы в рамках учебной практики по профессиональному модулю «Осуществление интеграции программных модулей».</p>
                <p style="margin-top: 1rem;"><strong>Специальность:</strong> 09.02.07 «Информационные системы и программирование»</p>
                <p><strong>Группа:</strong> C322</p>
            </div>
            
            <!-- Карточки авторов -->
            <div class="authors-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1.5rem; margin: 2rem 0;">
                <!-- Егармина -->
                <div class="author-card" style="background: #f8f9fa; border-radius: 12px; padding: 1.5rem; text-align: center;">
                    <div class="author-photo" style="font-size: 4rem;">👩‍💻</div>
                    <div class="author-name" style="font-size: 1.3rem; font-weight: bold; color: #9B2226;">Егармина В.А.</div>
                    <div class="author-role" style="color: #6d181b;">Ответственная за прямую ЗЛП и архитектуру</div>
                    <div class="author-bio" style="text-align: left;">
                        <p>В рамках проекта разработала симплекс-метод для решения задач линейного программирования. Также отвечала за создание общей архитектуры веб-приложения, построение UML-диаграмм, разработку главной страницы и координацию командной работы.</p>
                        <p><strong>Вклад:</strong> Симплекс-метод, routes.py, app.py, главная страница, UML.</p>
                    </div>
                </div>
                
                <!-- Потылицына -->
                <div class="author-card" style="background: #f8f9fa; border-radius: 12px; padding: 1.5rem; text-align: center;">
                    <div class="author-photo" style="font-size: 4rem;">👩‍🎓</div>
                    <div class="author-name" style="font-size: 1.3rem; font-weight: bold; color: #9B2226;">Потылицына З.С.</div>
                    <div class="author-role" style="color: #6d181b;">Ответственная за транспортную задачу</div>
                    <div class="author-bio" style="text-align: left;">
                        <p>Реализовала полный алгоритм решения транспортной задачи: методы северо-западного угла, минимального элемента и метод потенциалов. Занималась стилевым оформлением сайта (лавандовые и бордовые тона, градиенты).</p>
                        <p><strong>Вклад:</strong> Транспортная задача, CSS-дизайн, теория, страница видео.</p>
                    </div>
                </div>
                
                <!-- Корнилов -->
                <div class="author-card" style="background: #f8f9fa; border-radius: 12px; padding: 1.5rem; text-align: center;">
                    <div class="author-photo" style="font-size: 4rem;">👨‍💻</div>
                    <div class="author-name" style="font-size: 1.3rem; font-weight: bold; color: #9B2226;">Корнилов Л.О.</div>
                    <div class="author-role" style="color: #6d181b;">Ответственный за задачу о назначениях</div>
                    <div class="author-bio" style="text-align: left;">
                        <p>Разработал венгерский алгоритм для задачи о назначениях с возможностью минимизации и максимизации. Отвечал за создание страницы контактов, интеграцию формы обратной связи и написание юнит-тестов.</p>
                        <p><strong>Вклад:</strong> Венгерский алгоритм, контакты, тестирование, документация.</p>
                    </div>
                </div>
            </div>
            
            <div class="theory-block" style="text-align: center;">
                <h3>Наши достижения</h3>
                <p>За время учебной практики (13-25 апреля 2026) нами был разработан полноценный веб-сервис для решения трёх классов оптимизационных задач.</p>
                <ul style="text-align: left; display: inline-block;">
                    <li>✅ Полностью рабочий симплекс-метод для ЗЛП</li>
                    <li>✅ Транспортную задачу с методами северо-западного угла, минимального элемента и потенциалов</li>
                    <li>✅ Венгерский алгоритм для задачи о назначениях</li>
                    <li>✅ Интуитивно понятный веб-интерфейс с лавандово-бордовой цветовой гаммой</li>
                    <li>✅ Видео-инструкции по каждому методу</li>
                    <li>✅ Систему логирования и юнит-тесты</li>
                </ul>
                <p style="margin-top: 1rem;">Проект выполнен на высоком уровне и может быть использован в образовательных целях студентами и преподавателями.</p>
            </div>
        </div>
        
        <div class="sidebar">
            <h3>Навигация</h3>
            <ul>
                <li><a href="/">Главная</a></li>
                <li><a href="/transport">Транспортная задача</a></li>
                <li><a href="/direct_lp">Прямая ЗЛП</a></li>
                <li><a href="/assignment">Задача о назначениях</a></li>
                <li><a href="/video">Видео-инструкции</a></li>
                <li><a href="/contact">Контакты</a></li>
            </ul>
            <div class="tip-box">
                <strong>Связь с нами</strong>
                <p>По всем вопросам обращайтесь через форму на странице контактов.</p>
                <a href="/contact" class="btn btn-primary" style="display:block; margin-top:10px;">Написать</a>
            </div>
        </div>
    </div>

    <!-- ПОДВАЛ С ТЕКСТУРОЙ -->
    <footer style="position: relative; overflow: hidden; background: linear-gradient(135deg, #9B2226, #6d181b); margin-top: 2rem;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.15; pointer-events: none;"></div>
        <div style="position: relative; z-index: 1; padding: 2rem 2rem 1rem;">
            <div class="footer-content" style="display: flex; justify-content: space-between; flex-wrap: wrap; gap: 2rem; max-width: 1400px; margin: 0 auto;">
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