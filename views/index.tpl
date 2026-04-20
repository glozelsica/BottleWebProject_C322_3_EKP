<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Математическое моделирование</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <link rel="stylesheet" href="/static/css/index.css">
    <link rel="icon" href="/static/images/logo.png" type="image/png">
</head>
<body>
    <!-- ШАПКА С ТЕКСТУРОЙ (одна картинка) -->
    <header style="position: relative; overflow: hidden; background: #9B2226;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.4; pointer-events: none;"></div>
        
        <div style="position: relative; z-index: 1; display: flex; justify-content: space-between; align-items: center; padding: 1rem 2rem;">
            <div class="logo" style="display: flex; align-items: center; gap: 0.5rem;">
                <img src="/static/images/logo.png" alt="Логотип" style="height: 35px; width: auto;">
                <span style="color: white; font-weight: bold;">Математическое моделирование</span>
            </div>
            <nav style="display: flex; gap: 1.5rem;">
                <a href="/" style="color: white; text-decoration: none;">Главная</a>
                <a href="/direct_lp" style="color: white; text-decoration: none;">Прямая ЗЛП</a>
                <a href="/transport" style="color: white; text-decoration: none;">Транспортная</a>
                <a href="/assignment" style="color: white; text-decoration: none;">Назначения</a>
                <a href="/authors" style="color: white; text-decoration: none;">Об авторах</a>
                <a href="/contact" style="color: white; text-decoration: none;">Контакты</a>
                <a href="/video" style="color: white; text-decoration: none;">Видео</a>
            </nav>
        </div>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>Задачи линейного программирования</h1>
            <p>Решение оптимизационных задач с помощью методов математического моделирования.</p>

            <div class="cards">
                <!-- Карточка 1: Прямая ЗЛП -->
                <div class="card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture4.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.03; pointer-events: none;"></div>
                    <div style="position: relative; z-index: 1;">
                        <div style="font-size: 3rem; text-align: center;">
                            <img src="/static/images/icon_zlp.png" alt="ЗЛП" style="width: 70px; height: 70px; object-fit: contain;">
                        </div>
                        <h3>Прямая ЗЛП</h3>
                        <p>Симплекс-метод для нахождения максимума или минимума линейной функции при системе ограничений.</p>
                        <details>
                            <summary>Подробнее</summary>
                            <p>Линейное программирование — раздел математического моделирования. Симплекс-метод последовательно улучшает решение, переходя от одной вершины допустимого множества к другой.</p>
                        </details>
                        <button onclick="location.href='/direct_lp'">Перейти →</button>
                    </div>
                </div>
                
                <!-- Карточка 2: Транспортная задача -->
                <div class="card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture4.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.03; pointer-events: none;"></div>
                    <div style="position: relative; z-index: 1;">
                        <div style="font-size: 3rem; text-align: center;">
                            <img src="/static/images/icon_transport.png" alt="Транспортная задача" style="width: 70px; height: 70px; object-fit: contain;">
                        </div>
                        <h3>Транспортная задача</h3>
                        <p>Минимизация стоимости перевозок от поставщиков к потребителям. Методы: северо-западного угла, минимального элемента, потенциалов.</p>
                        <details>
                            <summary>Подробнее</summary>
                            <p>Транспортная задача — частный случай ЗЛП. Оптимальный план перевозок находится методом потенциалов с итерационным улучшением.</p>
                        </details>
                        <button onclick="location.href='/transport'">Перейти →</button>
                    </div>
                </div>
                
                <!-- Карточка 3: Задача о назначениях -->
                <div class="card" style="position: relative; overflow: hidden;">
                    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture4.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.03; pointer-events: none;"></div>
                    <div style="position: relative; z-index: 1;">
                        <div style="font-size: 3rem; text-align: center;">
                            <img src="/static/images/icon_assig.png" alt="Задача о назначениях" style="width: 70px; height: 70px; object-fit: contain;">
                        </div>
                        <h3>Задача о назначениях</h3>
                        <p>Оптимальное распределение работ между исполнителями. Реализован венгерский алгоритм.</p>
                        <details>
                            <summary>Подробнее</summary>
                            <p>Задача о назначениях — минимизация суммарной стоимости выполнения работ. Венгерский алгоритм находит оптимальное назначение за полиномиальное время.</p>
                        </details>
                        <button onclick="location.href='/assignment'">Перейти →</button>
                    </div>
                </div>
            </div>
            
            <!-- ==================== СТАТЬИ ==================== -->
            <div class="articles-section">
                <h2 class="articles-title">Интересные статьи</h2>
                
                <div class="articles-grid">
                    <!-- Статья 1 -->
                    <div class="article-card" onclick="openArticle(1)">
                        <div class="article-cover">
                            <img src="/static/images/article1_cover.png" alt="Математика — язык Вселенной" onerror="this.src='/static/images/logo.png'">
                            <div class="article-overlay">
                                <h3>Математика — это не просто цифры, а язык Вселенной</h3>
                            </div>
                        </div>
                        <button class="btn-read">Читать статью</button>
                    </div>
                    
                    <!-- Статья 2 -->
                    <div class="article-card" onclick="openArticle(2)">
                        <div class="article-cover">
                            <img src="/static/images/article2_cover.png" alt="Гений Пифагора" onerror="this.src='/static/images/logo.png'">
                            <div class="article-overlay">
                                <h3>Гений Пифагора и тайна треугольника как символ эволюции</h3>
                            </div>
                        </div>
                        <button class="btn-read">Читать статью</button>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками матрицы используйте <kbd>Tab</kbd></li>
                <li>Результат можно сохранить в Excel/CSV</li>
                <li>При несбалансированности добавляются фиктивные участники</li>
                <li>Все данные сохраняются в истории решений</li>
            </ul>
            <div class="tip-box">
                <strong>Нужна помощь?</strong>
                <p>Посмотрите видео-инструкцию</p>
                <a href="/video" class="btn btn-info" style="display:block;">Смотреть урок</a>
            </div>
        </div>
    </div>

    <!-- ПОДВАЛ С ТЕКСТУРОЙ -->
    <footer style="position: relative; overflow: hidden; background: #9B2226;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.4; pointer-events: none;"></div>
        <div class="footer-bottom" style="position: relative; z-index: 1;">
            <p>© 2026 Математическое моделирование. Все права защищены.</p>
        </div>
    </footer>

    <!-- Модальное окно для статьи 1 -->
    <div id="modal1" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <img src="/static/images/article1_cover.png" alt="Математика — язык Вселенной" onerror="this.src='/static/images/logo.png'">
                <div class="modal-header-text">
                    <h2>Математика — это не просто цифры, а язык Вселенной</h2>
                </div>
                <span class="modal-close" onclick="closeModal(1)">&times;</span>
            </div>
            <div class="modal-body">
                <h3>От абстрактных чисел до покорения космоса</h3>
                <p>Многие привыкли считать математику скучным набором формул и бесконечных вычислений. Однако на самом деле это самый мощный инструмент, который когда-либо создавало человечество. Это фундамент, на котором строится всё: от музыки до межпланетных перелетов.</p>
                
                <h3>Почему мы смогли выйти за пределы Земли?</h3>
                <p>Ответ кроется в математике. Без точных расчетов полет в космос был бы невозможен по нескольким причинам:</p>
                <ul>
                    <li><strong>Траектории и орбиты</strong> — Чтобы отправить аппарат к Марсу, недостаточно просто направить ракету в нужную сторону. Нужно рассчитать положение планет с точностью до сантиметра, учитывая гравитацию Солнца и других тел. Математика позволяет вычислить «окно запуска», когда планеты находятся в идеальном положении.</li>
                    <li><strong>Балистика и тяга</strong> — Расчет необходимой скорости для преодоления земного притяжения требует сложнейших дифференциальных уравнений. Ошибка в расчетах на долю процента приведет к тому, что аппарат либо сгорит в атмосфере, либо улетит в пустоту.</li>
                    <li><strong>Навигация</strong> — Современные системы GPS работают на основе теории относительности Эйнштейна. Если бы математические модели не учитывали разницу во времени из-за гравитации и скорости спутников, навигатор в вашем телефоне ошибался бы на километры каждый день.</li>
                </ul>
                
                <h3>Математическое моделирование как суперсила в жизни</h3>
                <p>Математическое моделирование — это создание виртуальной копии реального процесса. Вместо того чтобы проводить опасные или слишком дорогие эксперименты в реальности, ученые и инженеры проигрывают их на компьютерах.</p>
                
                <h4>1. Медицина и фармакология</h4>
                <p>Перед тем как выпить таблетку, ученые создают математическую модель того, как молекула лекарства будет взаимодействовать с рецепторами в организме. Моделирование помогает предсказать скорость распространения вирусов (как это было с COVID-19) и понять, какие меры карантина будут эффективны.</p>
                
                <h4>2. Экономика и финансы</h4>
                <p>Банки и фондовые рынки работают на алгоритмах. Математические модели анализируют миллионы транзакций, чтобы предсказать курсы валют, оценить риски кредитования или обнаружить мошеннические операции (фрод) в реальном времени.</p>
                
                <h4>3. Архитектура и строительство</h4>
                <p>Прежде чем построить небоскреб, инженеры создают его цифровую модель. Моделирование позволяет проверить, как здание поведет себя при землетрясении, ураганном ветре или сильном снегопаде. Это гарантирует, что конструкция не рухнет.</p>
                
                <h4>4. Логистика и доставка</h4>
                <p>Когда вы заказываете еду или посылку, за этим стоит математическая задача оптимизации. Алгоритмы рассчитывают кратчайший маршрут для сотен курьеров, учитывая пробки, время работы ресторанов и приоритетность заказов, чтобы минимизировать затраты и время.</p>
                
                <h3>Итог</h3>
                <p>Математика — это не про умение быстро считать в уме. Это про умение видеть закономерности, предсказывать будущее и управлять реальностью. Изучая цифры, мы учимся понимать правила, по которым играет сама природа.</p>
            </div>
        </div>
    </div>

    <!-- Модальное окно для статьи 2 -->
    <div id="modal2" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <img src="/static/images/article2_cover.png" alt="Гений Пифагора" onerror="this.src='/static/images/logo.png'">
                <div class="modal-header-text">
                    <h2>Гений Пифагора и тайна треугольника как символ эволюции</h2>
                </div>
                <span class="modal-close" onclick="closeModal(2)">&times;</span>
            </div>
            <div class="modal-body">
                <h3>Пифагор и рождение логического порядка</h3>
                <p>Пифагор Самосский не просто открыл теорему, связывающую стороны прямоугольного треугольника (a² + b² = c²). Он совершил нечто большее — он провозгласил, что «всё есть число».</p>
                <p>Его гениальность заключалась в том, что он перевел физический мир на язык абстрактных закономерностей. До него люди видели объекты, а Пифагор увидел структуру. Он первым понял, что Вселенная — это не хаос, а упорядоченная система, подчиняющаяся математическим ритмам. Его учение заложило фундамент всей западной науки, превратив математику из инструмента измерения в философию познания.</p>
                
                <h3>Треугольник как признак эволюции разума</h3>
                <p>Почему именно треугольник является ключом к пониманию эволюции интеллекта?</p>
                <ul>
                    <li><strong>Минимальная устойчивость</strong> — Треугольник — это самая простая и устойчивая геометрическая фигура. В физическом мире он является базовой единицей прочности.</li>
                    <li><strong>Переход к абстракции</strong> — Чтобы понять свойства треугольника, человеческий мозг должен совершить эволюционный скачок: от восприятия конкретного «камня» или «дерева» к пониманию идеальной формы, которой не существует в чистом виде в природе, но которая управляет всеми формами.</li>
                    <li><strong>Символ структуры</strong> — Способность мозга оперировать свойствами треугольника (углами, соотношениями сторон) означает переход от инстинктивного выживания к высокоуровневому логическому мышлению. Это момент, когда биологический вид начинает конструировать реальность, а не просто подстраиваться под неё.</li>
                </ul>
                
                <h3>Тайные знания Древнего Египта</h3>
                <p>Существует миф, что греки открыли всё с нуля. Однако египтяне обладали глубочайшими практическими знаниями за тысячи лет до Пифагора.</p>
                <p>Их связь с геометрией была жизненно необходимой. Ежегодные разливы Нила смывали границы земельных участков, и египетским «землемерам» (геометрам) приходилось заново вычислять площади полей.</p>
                <ul>
                    <li><strong>Мастера пропорций</strong> — Строительство пирамид невозможно без понимания сложных геометрических соотношений. Использование «золотого сечения» и точных углов наклона свидетельствует о том, что египтяне владели методами, которые мы сегодня называем прикладной геометрией.</li>
                    <li><strong>Верёвочники</strong> — Существуют свидетельства, что египтяне использовали верёвки с узлами на равных расстояниях для создания идеальных прямых углов (метод, предвосхитивший египетский треугольник со сторонами 3, 4 и 5).</li>
                </ul>
                
                <h3>Заключение</h3>
                <p>Гениальность Пифагора заключалась в том, что он систематизировал древние эмпирические знания (такие как у египтян) и превратил их в строгую научную систему. Треугольник стал мостом между грубой материей и чистым разумом, ознаменовав эпоху, когда человек перестал быть просто частью природы и стал её исследователем.</p>
            </div>
        </div>
    </div>

    <script>
        function openArticle(num) {
            var modal = document.getElementById('modal' + num);
            if (modal) {
                modal.style.display = 'block';
                document.body.style.overflow = 'hidden';
            }
        }
        
        function closeModal(num) {
            var modal = document.getElementById('modal' + num);
            if (modal) {
                modal.style.display = 'none';
                document.body.style.overflow = 'auto';
            }
        }
        
        // Закрытие модального окна при клике вне его
        window.onclick = function(event) {
            var modals = document.getElementsByClassName('modal');
            for (var i = 0; i < modals.length; i++) {
                if (event.target == modals[i]) {
                    modals[i].style.display = 'none';
                    document.body.style.overflow = 'auto';
                }
            }
        }
    </script>
</body>
</html>