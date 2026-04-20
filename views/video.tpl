<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Видео-инструкции</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <link rel="stylesheet" href="/static/css/video.css">
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
            <p style="margin-bottom: 1.5rem;">Подробные видеоуроки по всем трём методам решения задач линейного программирования. Выберите интересующий раздел:</p>
            
            <!-- Вкладки в новом порядке: Симплекс-метод → Транспортная → Назначения -->
            <div class="video-tabs">
                <button class="tab-btn active" onclick="showTab('simplex')">Симплекс-метод</button>
                <button class="tab-btn" onclick="showTab('transport')">Транспортная задача</button>
                <button class="tab-btn" onclick="showTab('assignment')">Задача о назначениях</button>
            </div>
            
            <!-- Симплекс-метод (первая вкладка) -->
            <div id="simplex-tab" class="tab-content active">
                <div class="video-grid">
                    <div class="video-card">
                        <h3>Урок 1: Основы симплекс-метода</h3>
                        <div class="video-container">
                            <video controls preload="metadata" poster="/static/images/simplex_preview.png">
                                <source src="/static/videos/simplex_video.mp4" type="video/mp4">
                                Ваш браузер не поддерживает видео
                            </video>
                        </div>
                        <div class="video-desc">
                            <p><strong>Симплекс-метод:</strong> приведение к каноническому виду, построение симплекс-таблиц, критерий оптимальности, правило прямоугольника.</p>
                            <span class="video-duration">⏱️ Длительность: ~11 минут</span>
                            <a href="/direct_lp" class="btn-video">Перейти к решению</a>
                        </div>
                    </div>
                    
                    <div class="video-card">
                        <h3>Урок 2: Особые случаи</h3>
                        <div class="video-container">
                            <video controls preload="metadata">
                                <source src="/static/videos/simplex_special.mp4" type="video/mp4">
                                Ваш браузер не поддерживает видео
                            </video>
                        </div>
                        <div class="video-desc">
                            <p><strong>Особые случаи:</strong> вырожденность, альтернативный оптимум, неограниченность, метод искусственного базиса.</p>
                            <span class="video-duration">⏱️ Длительность: ~11 минут</span>
                            <a href="/direct_lp" class="btn-video">Перейти к решению</a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Транспортная задача (вторая вкладка) -->
            <div id="transport-tab" class="tab-content">
                <div class="video-grid">
                    <div class="video-card">
                        <h3>Урок 1: Метод потенциалов</h3>
                        <div class="video-container">
                            <video controls preload="metadata">
                                <source src="/static/videos/transport_video.mp4" type="video/mp4">
                                Ваш браузер не поддерживает видео
                            </video>
                        </div>
                        <div class="video-desc">
                            <p><strong>Метод потенциалов:</strong> построение опорного плана, расчёт потенциалов, цикл пересчёта. Подробный разбор на примере с 3 поставщиками и 3 потребителями.</p>
                            <span class="video-duration">⏱️ Длительность: ~11 минут</span>
                            <a href="/transport" class="btn-video">Перейти к решению</a>
                        </div>
                    </div>
                    
                    <div class="video-card">
                        <h3>Урок 2: Практический разбор</h3>
                        <div class="video-container">
                            <video controls preload="metadata">
                                <source src="/static/videos/transport_practice.mp4" type="video/mp4">
                                Ваш браузер не поддерживает видео
                            </video>
                        </div>
                        <div class="video-desc">
                            <p><strong>Практический разбор:</strong> решение транспортной задачи с большим количеством поставщиков и потребителей, особенности вырожденных планов.</p>
                            <span class="video-duration">⏱️ Длительность: ~15 минут</span>
                            <a href="/transport" class="btn-video">Перейти к решению</a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Задача о назначениях (третья вкладка) -->
            <div id="assignment-tab" class="tab-content">
                <div class="video-grid">
                    <div class="video-card">
                        <h3>Урок 1: Венгерский алгоритм</h3>
                        <div class="video-container">
                            <video controls preload="metadata" poster="/static/images/assignment_preview.png">
                                <source src="/static/videos/assignment_video.mp4" type="video/mp4">
                                Ваш браузер не поддерживает видео
                            </video>
                        </div>
                        <div class="video-desc">
                            <p><strong>Венгерский алгоритм:</strong> редукция матрицы, поиск максимального паросочетания, улучшение назначения. Задача минимизации и максимизации.</p>
                            <span class="video-duration">⏱️ Длительность: ~18 минут</span>
                            <a href="/assignment" class="btn-video">Перейти к решению</a>
                        </div>
                    </div>
                    
                    <div class="video-card">
                        <h3>Урок 2: Разбор на примере</h3>
                        <div class="video-container">
                            <video controls preload="metadata">
                                <source src="/static/videos/assignment_example1.mp4" type="video/mp4">
                                Ваш браузер не поддерживает видео
                            </video>
                        </div>
                        <div class="video-desc">
                            <p><strong>Пример №1:</strong> распределение 5 рабочих на 5 задач с подробным пошаговым объяснением каждого этапа алгоритма.</p>
                            <span class="video-duration">⏱️ Длительность: ~19 минут</span>
                            <a href="/assignment" class="btn-video">Перейти к решению</a>
                        </div>
                    </div>
                    
                    <div class="video-card">
                        <h3>Урок 3: Продвинутый уровень</h3>
                        <div class="video-container">
                            <video controls preload="metadata">
                                <source src="/static/videos/assignment_example2.mp4" type="video/mp4">
                                Ваш браузер не поддерживает видео
                            </video>
                        </div>
                        <div class="video-desc">
                            <p><strong>Пример №2:</strong> решение задачи о назначениях с неполной матрицей и с дополнительными ограничениями.</p>
                            <span class="video-duration">⏱️ Длительность: ~14 минут</span>
                            <a href="/assignment" class="btn-video">Перейти к решению</a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Блок с советом -->
            <div class="tip-box" style="margin-top: 1rem;">
                <strong>Совет:</strong> Начинайте с основного урока, затем переходите к дополнительным материалам. Используйте паузу на каждом шаге алгоритма, чтобы разобраться в деталях.
            </div>
        </div>
        
        <!-- Боковая панель с текстурой -->
        <div class="sidebar">
            <h3>📚 Полезные ссылки</h3>
            <ul>
                <li><a href="/transport">🚚 Транспортная задача</a></li>
                <li><a href="/direct_lp">📊 Прямая ЗЛП</a></li>
                <li><a href="/assignment">🎯 Задача о назначениях</a></li>
                <li><a href="/authors">👥 Об авторах</a></li>
                <li><a href="/contact">📧 Контакты</a></li>
            </ul>
            <div class="tip-box">
                <strong>❓ Нужна помощь?</strong>
                <p>Задайте вопрос на странице контактов</p>
                <a href="/contact" class="btn btn-primary" style="display:block; margin-top:10px; text-align:center;">Задать вопрос</a>
            </div>
            <div class="tip-box" style="margin-top: 1rem;">
                <strong>⭐ О проекте</strong>
                <p style="font-size: 0.85rem;">Веб-приложение разработано в рамках учебной практики УП02 по модулю «Интеграция программных модулей».</p>
            </div>
            <div class="tip-box" style="margin-top: 1rem;">
                <strong>📖 Рекомендация</strong>
                <p style="font-size: 0.85rem;">Для лучшего понимания рекомендуем сначала посмотреть основной урок, затем закрепить материал на практических примерах.</p>
            </div>
        </div>
    </div>

    <!-- ПОДВАЛ С ТЕКСТУРОЙ -->
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

    <script>
        function showTab(tabName) {
            // Скрываем все вкладки
            document.getElementById('simplex-tab').classList.remove('active');
            document.getElementById('transport-tab').classList.remove('active');
            document.getElementById('assignment-tab').classList.remove('active');
            
            // Убираем активный класс со всех кнопок
            const buttons = document.querySelectorAll('.tab-btn');
            buttons.forEach(btn => btn.classList.remove('active'));
            
            // Показываем выбранную вкладку
            document.getElementById(tabName + '-tab').classList.add('active');
            
            // Активируем соответствующую кнопку
            const buttonsArray = Array.from(buttons);
            if (tabName === 'simplex') buttonsArray[0].classList.add('active');
            if (tabName === 'transport') buttonsArray[1].classList.add('active');
            if (tabName === 'assignment') buttonsArray[2].classList.add('active');
        }
    </script>
</body>
</html>