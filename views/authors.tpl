<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Об авторах</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <link rel="stylesheet" href="/static/css/authors.css">
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
            <h1>Об авторах проекта</h1>
            
            <!-- Информация о колледже -->
            <div class="college-section">
                <h2>Санкт-Петербургский государственный университет аэрокосмического приборостроения</h2>
                <h3>Факультет среднего профессионального образования №12</h3>
                <p>ГУАП — один из ведущих технических вузов России, основанный в 1941 году. Факультет СПО готовит высококвалифицированных специалистов в области информационных систем и программирования. Наш проект — результат усердной работы в рамках учебной практики по профессиональному модулю «Осуществление интеграции программных модулей».</p>
                <p><strong>Специальность:</strong> 09.02.07 «Информационные системы и программирование»</p>
                <p><strong>Группа:</strong> C322</p>
            </div>
            
            <!-- Карточки авторов с фото -->
            <div class="authors-grid">
                <!-- Егармина -->
                <div class="author-card">
                    <div class="author-photo">
                        <img src="/static/images/avatar_egarmina.png" alt="Егармина В.А." onerror="this.parentElement.innerHTML='<div class=author-photo-placeholder>👩‍💻</div>'">
                    </div>
                    <div class="author-name">Егармина В.А.</div>
                    <div class="author-role">Ответственная за прямую ЗЛП и архитектуру</div>
                    <div class="author-bio">
                        <p>В рамках проекта разработала симплекс-метод для решения задач линейного программирования. Также отвечала за создание общей архитектуры веб-приложения, построение UML-диаграмм, разработку главной страницы и координацию командной работы.</p>
                        <div class="author-contribution">
                            <strong>📌 Вклад:</strong> Симплекс-метод, routes.py, app.py, главная страница, UML-диаграммы
                        </div>
                    </div>
                </div>
                
                <!-- Потылицына -->
                <div class="author-card">
                    <div class="author-photo">
                        <img src="/static/images/avatar_potylitsyna.png" alt="Потылицына З.С." onerror="this.parentElement.innerHTML='<div class=author-photo-placeholder>👩‍🎓</div>'">
                    </div>
                    <div class="author-name">Потылицына З.С.</div>
                    <div class="author-role">Ответственная за транспортную задачу</div>
                    <div class="author-bio">
                        <p>Реализовала полный алгоритм решения транспортной задачи: методы северо-западного угла, минимального элемента и метод потенциалов. Занималась стилевым оформлением сайта (лавандовые и бордовые тона, градиенты, текстуры).</p>
                        <div class="author-contribution">
                            <strong>📌 Вклад:</strong> Транспортная задача, CSS-дизайн, теория, страница видео
                        </div>
                    </div>
                </div>
                
                <!-- Корнилов -->
                <div class="author-card">
                    <div class="author-photo">
                        <img src="/static/images/avatar_kornilov.png" alt="Корнилов Л.О." onerror="this.parentElement.innerHTML='<div class=author-photo-placeholder>👨‍💻</div>'">
                    </div>
                    <div class="author-name">Корнилов Л.О.</div>
                    <div class="author-role">Ответственный за задачу о назначениях</div>
                    <div class="author-bio">
                        <p>Разработал венгерский алгоритм для задачи о назначениях с возможностью минимизации и максимизации. Отвечал за создание страницы контактов, интеграцию формы обратной связи и написание юнит-тестов.</p>
                        <div class="author-contribution">
                            <strong>📌 Вклад:</strong> Венгерский алгоритм, контакты, тестирование, документация
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Блок достижений -->
            <div class="achievements-block">
                <h3>🏆 Наши достижения</h3>
                <p>За время учебной практики (13-25 апреля 2026) нами был разработан полноценный веб-сервис для решения трёх классов оптимизационных задач.</p>
                <div class="achievements-grid">
                    <div class="achievement-item"><span>✅</span> Симплекс-метод для ЗЛП</div>
                    <div class="achievement-item"><span>✅</span> Транспортная задача</div>
                    <div class="achievement-item"><span>✅</span> Венгерский алгоритм</div>
                    <div class="achievement-item"><span>✅</span> Интуитивно понятный интерфейс</div>
                    <div class="achievement-item"><span>✅</span> Видео-инструкции</div>
                    <div class="achievement-item"><span>✅</span> Юнит-тесты и логирование</div>
                </div>
                <p style="margin-top: 1.5rem;">Проект выполнен на высоком уровне и может быть использован в образовательных целях студентами и преподавателями.</p>
            </div>
        </div>
        
        <!-- Боковая панель с текстурой -->
        <div class="sidebar">
            <h3>📚 Навигация</h3>
            <ul>
                <li><a href="/">🏠 Главная</a></li>
                <li><a href="/transport">🚚 Транспортная задача</a></li>
                <li><a href="/direct_lp">📊 Прямая ЗЛП</a></li>
                <li><a href="/assignment">👥 Задача о назначениях</a></li>
                <li><a href="/video">🎥 Видео-инструкции</a></li>
                <li><a href="/contact">📧 Контакты</a></li>
            </ul>
            <div class="tip-box" style="margin-top: 1.5rem;">
                <strong>💬 Связь с нами</strong>
                <p style="margin-top: 10px;">По всем вопросам обращайтесь через форму на странице контактов.</p>
                <a href="/contact" class="btn btn-primary" style="display:block; margin-top:10px; text-align:center;">Написать</a>
            </div>
            <div class="tip-box" style="margin-top: 1rem;">
                <strong>⭐ О проекте</strong>
                <p style="margin-top: 10px; font-size: 0.85rem;">Веб-приложение разработано в рамках учебной практики УП02 по модулю «Интеграция программных модулей».</p>
            </div>
        </div>
    </div>

    <!-- ПОДВАЛ -->
    <footer class="footer-main">
        <div class="footer-content">
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
    </footer>
</body>
</html>