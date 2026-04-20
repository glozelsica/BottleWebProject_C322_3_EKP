<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Прямая ЗЛП - Симплекс-метод</title>
    <link rel="icon" href="/static/images/logo.png" type="image/png">
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <header style="position: relative; overflow: hidden;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.4; pointer-events: none;"></div>
        <div style="position: relative; z-index: 1; display: flex; justify-content: space-between; align-items: center; padding: 1rem 2rem; flex-wrap: wrap;">
            <div class="logo" style="display: flex; align-items: center; gap: 0.5rem;">
                <img src="/static/images/logo.png" alt="Логотип" style="height: 35px; width: 35px; object-fit: contain;" onerror="this.style.display='none'"> 
                <span style="color: white;">Математическое моделирование</span>
            </div>
            <nav style="display: flex; gap: 1.5rem; flex-wrap: wrap;">
                <a href="/" style="color: white; text-decoration: none;">Главная</a>
                <a href="/transport" style="color: white; text-decoration: none;">Транспортная</a>
                <a href="/direct_lp" style="color: white; text-decoration: none;">Прямая ЗЛП</a>
                <a href="/assignment" style="color: white; text-decoration: none;">Назначения</a>
                <a href="/video" style="color: white; text-decoration: none;">Видео</a>
                <a href="/authors" style="color: white; text-decoration: none;">Об авторах</a>
                <a href="/contact" style="color: white; text-decoration: none;">Контакты</a>
            </nav>
        </div>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>Прямая задача линейного программирования</h1>
            <h2>Симплекс-метод решения</h2>
            
            <form method="post" id="lpForm">
                <div class="form-section">
                    <h3>Ввод исходных данных</h3>
                    
                    <div class="dimension-controls">
                        <div class="form-group">
                            <label>Коэффициенты целевой функции (через запятую):</label>
                            <input type="text" name="c" id="c_input" value="{{c}}" size="50" placeholder="пример: 3,5" required style="width: 300px;">
                        </div>
                        
                        <div class="form-group">
                            <label>Количество ограничений (строк):</label>
                            <input type="number" name="rows" id="rows" value="{{rows}}" min="1" max="10" step="1">
                        </div>
                        
                        <div class="form-group">
                            <label>Количество переменных (столбцов):</label>
                            <input type="number" name="cols" id="cols" value="{{cols}}" min="1" max="10" step="1">
                        </div>
                        
                        <button type="button" class="btn btn-update" onclick="updateMatrix()">Обновить матрицу</button>
                    </div>
                    
                    <div id="matrixContainer"></div>
                    
                    <div class="form-group">
                        <label>Направление оптимизации:</label>
                        <label><input type="radio" name="sense" value="max" {{'checked' if sense=='max' else ''}}> Максимизация</label>
                        <label><input type="radio" name="sense" value="min" {{'checked' if sense=='min' else ''}}> Минимизация</label>
                    </div>
                    
                    <div class="button-group">
                        <button type="submit" class="btn btn-primary">Решить задачу</button>
                        <button type="button" class="btn btn-clear" onclick="clearForm()">Очистить</button>
                        <button type="button" class="btn btn-info" onclick="loadExample()">Загрузить пример</button>
                    </div>
                </div>
            </form>
            
            % if error:
            <div class="error-box"><strong>Ошибка:</strong> {{error}}</div>
            % end
            
            % if result:
                % if result.get('success'):
                <div class="giant-answer">
                    <h2>ОПТИМАЛЬНОЕ РЕШЕНИЕ</h2>
                    <div class="cost-value">F = {{"{:.6f}".format(result['value'])}}</div>
                    <div class="cost-label">Значение целевой функции</div>
                </div>
                
                <div class="result-box">
                    <h3>Оптимальный план</h3>
                    % for i, val in enumerate(result['solution']):
                    <p><strong>x{{i+1}} = {{"{:.6f}".format(val)}}</strong></p>
                    % end
                    <p><strong>Количество итераций:</strong> {{result['iterations']}}</p>
                </div>
                % else:
                <div class="error-box">
                    <strong>Ошибка решения:</strong> {{result.get('error', 'Неизвестная ошибка')}}
                </div>
                % end
            % end
            
            <!-- ТЕОРИЯ -->
            <h2>Теоретические основы</h2>
            
            <div class="theory-block">
                <h3>Постановка задачи линейного программирования</h3>
                <div class="theory-text">
                    <p>Задача линейного программирования (ЗЛП) — это задача нахождения экстремума (максимума или минимума) линейной функции на множестве, заданном линейными ограничениями.</p>
                    <p><strong>Стандартная форма записи:</strong></p>
                    <p>Найти максимум (или минимум) целевой функции:</p>
                    <div style="text-align: center; font-family: monospace; font-size: 16px; margin: 15px 0;">
                        F = c₁x₁ + c₂x₂ + ... + cₙxₙ → max (min)
                    </div>
                    <p>при ограничениях:</p>
                    <div style="text-align: center; font-family: monospace; font-size: 14px; margin: 15px 0;">
                        a₁₁x₁ + a₁₂x₂ + ... + a₁ₙxₙ ≤ b₁<br>
                        a₂₁x₁ + a₂₂x₂ + ... + a₂ₙxₙ ≤ b₂<br>
                        ...<br>
                        aₘ₁x₁ + aₘ₂x₂ + ... + aₘₙxₙ ≤ bₘ<br>
                        x₁, x₂, ..., xₙ ≥ 0
                    </div>
                    <p><strong>ОПРЕДЕЛЕНИЕ 1.</strong> Допустимым решением (планом) ЗЛП называется вектор X = (x₁, x₂, ..., xₙ), удовлетворяющий всем ограничениям задачи.</p>
                    <p><strong>ОПРЕДЕЛЕНИЕ 2.</strong> Оптимальным решением называется допустимое решение, при котором целевая функция достигает экстремального значения.</p>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Каноническая форма ЗЛП</h3>
                <div class="theory-text">
                    <p>Для применения симплекс-метода задача должна быть приведена к каноническому виду, когда все ограничения являются равенствами:</p>
                    <div style="text-align: center; font-family: monospace; font-size: 14px; margin: 15px 0;">
                        a₁₁x₁ + a₁₂x₂ + ... + a₁ₙxₙ = b₁<br>
                        a₂₁x₁ + a₂₂x₂ + ... + a₂ₙxₙ = b₂<br>
                        ...<br>
                        aₘ₁x₁ + aₘ₂x₂ + ... + aₘₙxₙ = bₘ<br>
                        xⱼ ≥ 0, bᵢ ≥ 0
                    </div>
                    <p><strong>Приведение неравенств к равенствам:</strong></p>
                    <ul>
                        <li>Неравенство типа ≤ преобразуется добавлением дополнительной (балансовой) переменной: aᵢ₁x₁ + ... + aᵢₙxₙ + s = bᵢ, s ≥ 0</li>
                        <li>Неравенство типа ≥ преобразуется вычитанием остаточной переменной: aᵢ₁x₁ + ... + aᵢₙxₙ - s = bᵢ, s ≥ 0</li>
                    </ul>
                    <div style="text-align: center;">
                        <img src="/static/images/canonical_form.png" class="theory-img" onerror="this.style.display='none'">
                    </div>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Симплекс-метод</h3>
                <div class="theory-text">
                    <p>Симплекс-метод — это универсальный итерационный алгоритм решения задач линейного программирования, основанный на направленном переборе вершин многогранника допустимых решений.</p>
                    <p><strong>Алгоритм симплекс-метода:</strong></p>
                    <ol>
                        <li>Привести задачу к каноническому виду</li>
                        <li>Найти начальное допустимое базисное решение</li>
                        <li>Построить симплекс-таблицу</li>
                        <li>Проверить критерий оптимальности:
                            <ul>
                                <li>Для задачи на минимум: если все оценки Δⱼ ≥ 0 → решение оптимально</li>
                                <li>Для задачи на максимум: если все оценки Δⱼ ≤ 0 → решение оптимально</li>
                            </ul>
                        </li>
                        <li>Если решение не оптимально, выбрать разрешающий столбец (по наибольшей по модулю отрицательной оценке)</li>
                        <li>Выбрать разрешающую строку (по минимальному симплекс-отношению Θ = bᵢ / aᵢₛ при aᵢₛ > 0)</li>
                        <li>Выполнить преобразование Жордана-Гаусса с разрешающим элементом</li>
                        <li>Повторить шаги 4-7 до достижения оптимальности</li>
                    </ol>
                    <div style="text-align: center;">
                        <img src="/static/images/simplex_flowchart.png" class="theory-img" onerror="this.style.display='none'">
                    </div>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Структура симплекс-таблицы</h3>
                <div class="theory-text">
                    <p>Симплекс-таблица имеет размер (m + 1) × (n + 1) и содержит:</p>
                    <table class="result-table">
                        <thead>
                            <tr style="background: #e9ecef;">
                                <th>Базис</th>
                                <th>b</th>
                                <th>x₁</th>
                                <th>x₂</th>
                                <th>...</th>
                                <th>xₙ</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr><td>x_B₁</td><td>b₁</td><td>a₁₁</td><td>a₁₂</td><td>...</td><td>a₁ₙ</td></tr>
                            <tr><td>x_B₂</td><td>b₂</td><td>a₂₁</td><td>a₂₂</td><td>...</td><td>a₂ₙ</td></tr>
                            <tr><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td></tr>
                            <tr><td>x_Bₘ</td><td>bₘ</td><td>aₘ₁</td><td>aₘ₂</td><td>...</td><td>aₘₙ</td></tr>
                            <tr style="background: #f0f0f0;"><td>F</td><td>F₀</td><td>Δ₁</td><td>Δ₂</td><td>...</td><td>Δₙ</td></tr>
                        </tbody>
                    </table>
                    <p><strong>Столбец «Базис»</strong> — текущие базисные переменные.</p>
                    <p><strong>Столбец «b»</strong> — значения базисных переменных (свободные члены).</p>
                    <p><strong>Строки 1..m</strong> — коэффициенты при переменных в ограничениях.</p>
                    <p><strong>Индексная строка (F)</strong> — оценки Δⱼ и текущее значение целевой функции.</p>
                    <div style="text-align: center;">
                        <img src="/static/images/simplex_tableau.png" class="theory-img" onerror="this.style.display='none'">
                    </div>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Преобразование Жордана-Гаусса (правило прямоугольника)</h3>
                <div class="theory-text">
                    <p>После выбора разрешающего элемента aᵣₛ таблица пересчитывается:</p>
                    <ol>
                        <li><strong>Разрешающая строка r</strong>: все элементы делятся на aᵣₛ</li>
                        <li><strong>Разрешающий столбец s</strong>: все элементы (кроме aᵣₛ) заменяются нулями</li>
                        <li><strong>Остальные элементы</strong>: вычисляются по формуле прямоугольника</li>
                    </ol>
                    <div style="text-align: center; font-family: monospace; font-size: 14px; margin: 15px 0;">
                        новый_элемент = текущий_элемент − (aᵣⱼ × aᵢₛ) / aᵣₛ
                    </div>
                    <div style="text-align: center;">
                        <img src="/static/images/rectangle_rule.png" class="theory-img" onerror="this.style.display='none'">
                    </div>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Метод искусственного базиса (двухфазный метод)</h3>
                <div class="theory-text">
                    <p>Если в канонической задаче нет очевидного единичного базиса, применяется двухфазный метод.</p>
                    <p><strong>Фаза 1:</strong></p>
                    <ul>
                        <li>В каждое уравнение без базисной переменной добавляется искусственная переменная yᵢ ≥ 0</li>
                        <li>Формируется вспомогательная целевая функция: F_иск = Σ yᵢ → min</li>
                        <li>Решается вспомогательная задача симплекс-методом</li>
                        <li>Если min F_иск > 0 — исходная задача несовместна</li>
                        <li>Если min F_иск = 0 — все искусственные переменные обнулены, получен допустимый базис</li>
                    </ul>
                    <p><strong>Фаза 2:</strong></p>
                    <ul>
                        <li>Удаляются столбцы искусственных переменных</li>
                        <li>Восстанавливается исходная целевая функция</li>
                        <li>Продолжается решение симплекс-методом до оптимальности</li>
                    </ul>
                    <div style="text-align: center;">
                        <img src="/static/images/two_phase_method.png" class="theory-img" onerror="this.style.display='none'">
                    </div>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Правило Блэнда (антицикл)</h3>
                <div class="theory-text">
                    <p>При вырожденности (bᵢ = 0 для некоторых базисных переменных) симплекс-метод может зациклиться. Правило Блэнда гарантирует конечность алгоритма:</p>
                    <ol>
                        <li><strong>Выбор вводимой переменной (столбец s)</strong>: среди всех столбцов с отрицательной Δⱼ выбрать столбец с наименьшим индексом</li>
                        <li><strong>Выбор выводимой переменной (строка r)</strong>: если несколько строк дают одинаковое минимальное симплекс-отношение Θ, выбрать строку с наименьшим индексом базисной переменной</li>
                    </ol>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Особые случаи и интерпретация результатов</h3>
                <div class="theory-text">
                    <table class="result-table">
                        <thead>
                            <tr style="background: #e9ecef;">
                                <th>Случай</th>
                                <th>Признак</th>
                                <th>Результат</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr><td>Оптимум найден</td><td>Все Δⱼ ≥ 0 (для min) или Δⱼ ≤ 0 (для max)</td><td>X* — оптимальный план, F* — оптимальное значение</td></tr>
                            <tr><td>Неограниченность</td><td>В разрешающем столбце s нет aᵢₛ > 0</td><td>F → −∞ (min) или F → +∞ (max)</td></tr>
                            <tr><td>Несовместность</td><td>min Σy > 0 в фазе 1</td><td>Допустимых решений нет</td></tr>
                            <tr><td>Альтернативный оптимум</td><td>В оптимальной таблице Δⱼ = 0 для небазисной переменной</td><td>Бесконечное множество оптимальных планов</td></tr>
                            <tr><td>Вырожденность</td><td>bᵢ = 0 для некоторых базисных переменных</td><td>Применяется правило Блэнда</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Геометрическая интерпретация</h3>
                <div class="theory-text">
                    <p>Для задачи с двумя переменными допустимое множество — это выпуклый многоугольник на плоскости. Целевая функция достигает экстремума в одной из вершин этого многоугольника.</p>
                    <div style="text-align: center;">
                        <img src="/static/images/simplex_geometry.png" class="theory-img" onerror="this.style.display='none'">
                    </div>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Пример решения</h3>
                <div class="theory-text">
                    <p><strong>Пример:</strong> Найти максимум функции F = 3x₁ + 5x₂ при ограничениях:</p>
                    <div style="text-align: center; font-family: monospace; margin: 15px 0;">
                        x₁ ≤ 4<br>
                        2x₂ ≤ 12<br>
                        x₁ ≥ 0, x₂ ≥ 0
                    </div>
                    <p><strong>Решение:</strong></p>
                    <p>1. Приводим к каноническому виду, добавляя дополнительные переменные:</p>
                    <div style="font-family: monospace;">
                        x₁ + s₁ = 4<br>
                        2x₂ + s₂ = 12<br>
                        F - 3x₁ - 5x₂ = 0
                    </div>
                    <p>2. Строим начальную симплекс-таблицу:</p>
                    <table class="result-table">
                        <tr><th>Базис</th><th>b</th><th>x₁</th><th>x₂</th><th>s₁</th><th>s₂</th></tr>
                        <tr><td>s₁</td><td>4</td><td>1</td><td>0</td><td>1</td><td>0</td></tr>
                        <tr><td>s₂</td><td>12</td><td>0</td><td>2</td><td>0</td><td>1</td></tr>
                        <tr><td>F</td><td>0</td><td>-3</td><td>-5</td><td>0</td><td>0</td></tr>
                    </table>
                    <p>3. Выбираем разрешающий столбец x₂ (Δ₂ = -5 — наибольшая по модулю отрицательная оценка).</p>
                    <p>4. Выбираем разрешающую строку: min(12/2=6) → строка s₂.</p>
                    <p>5. Выполняем преобразование и получаем оптимальное решение: x₁=4, x₂=6, F=42.</p>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Литература</h3>
                <ul>
                    <li>Ваулин А.Е. Методы цифровой обработки данных. — СПб.: ВИККИ, 1993.</li>
                    <li>Таха Х.А. Введение в исследование операций. — М.: Вильямс, 2005.</li>
                    <li>Корбут А.А., Финкельштейн Ю.Ю. Дискретное программирование. — М.: Наука, 1969.</li>
                    <li>Юдин Д.Б., Гольштейн Е.Г. Задачи и методы линейного программирования. — М.: Советское радио, 1964.</li>
                </ul>
            </div>
        </div>
        
        <div class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками матрицы используйте стрелки на клавиатуре</li>
                <li>Для быстрого перехода по полям используйте клавишу Tab</li>
                <li>Результат можно сохранить в Excel или CSV</li>
                <li>Если задача не имеет решения — система сообщит об этом</li>
                <li>Ввод данных сохраняется при перезагрузке страницы</li>
                <li>Признак оптимальности: все Δⱼ ≤ 0 (max) или Δⱼ ≥ 0 (min)</li>
            </ul>
            <div class="tip-box">
                <strong>Видео-инструкция</strong>
                <a href="/video" class="btn-video">Смотреть урок</a>
            </div>
            <div class="tip-box" style="margin-top: 15px;">
                <strong>Тестовый пример</strong>
                <p>Нажмите "Загрузить пример"</p>
            </div>
        </div>
    </div>

    <footer class="footer-with-texture">
        <div class="footer-texture"></div>
        <div class="footer-content">
            <div class="footer-inner">
                <div class="footer-section">
                    <h4>Главные разработчики</h4>
                    <p>Группа C322 | ГУАП ФСПО №12</p>
                    <p>Егармина, Корнилов, Потылицына</p>
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
        function updateMatrix() {
            const rows = parseInt(document.getElementById('rows').value) || 2;
            const cols = parseInt(document.getElementById('cols').value) || 2;
            
            const container = document.getElementById('matrixContainer');
            
            let html = '<div class="matrix-input"><h4>Матрица ограничений A</h4>';
            html += '<table class="result-table">';
            
            for (let i = 0; i < rows; i++) {
                html += '<tr>';
                html += `<th>Ограничение ${i+1}</th>`;
                for (let j = 0; j < cols; j++) {
                    const saved = localStorage.getItem(`A_${i}_${j}`);
                    const val = saved !== null ? saved : '0';
                    html += `<td><input type="number" step="any" name="A_${i}_${j}" value="${val}" style="width:80px;" class="matrix-cell"></td>`;
                }
                html += `<td><input type="number" step="any" name="b_${i}" value="${localStorage.getItem(`b_${i}`) || '0'}" style="width:80px;"></td>`;
                html += '</tr>';
            }
            
            html += '</table></div>';
            html += '<input type="hidden" name="rows" value="' + rows + '">';
            html += '<input type="hidden" name="cols" value="' + cols + '">';
            
            container.innerHTML = html;
            
            const inputs = container.querySelectorAll('input');
            inputs.forEach(input => {
                input.addEventListener('change', function() {
                    if (this.name) localStorage.setItem(this.name, this.value);
                });
            });
            
            setTimeout(addArrowNavigation, 100);
        }
        
        function addArrowNavigation() {
            const cells = document.querySelectorAll('.matrix-cell');
            const rows = parseInt(document.getElementById('rows').value) || 2;
            const cols = parseInt(document.getElementById('cols').value) || 2;
            
            cells.forEach((cell, index) => {
                const row = Math.floor(index / cols);
                const col = index % cols;
                cell.removeEventListener('keydown', arrowHandler);
                cell.addEventListener('keydown', function(e) {
                    arrowHandler(e, row, col, rows, cols);
                });
            });
        }
        
        function arrowHandler(e, row, col, rows, cols) {
            let newRow = row;
            let newCol = col;
            
            switch(e.key) {
                case 'ArrowUp':
                    newRow = Math.max(0, row - 1);
                    e.preventDefault();
                    break;
                case 'ArrowDown':
                    newRow = Math.min(rows - 1, row + 1);
                    e.preventDefault();
                    break;
                case 'ArrowLeft':
                    newCol = Math.max(0, col - 1);
                    e.preventDefault();
                    break;
                case 'ArrowRight':
                    newCol = Math.min(cols - 1, col + 1);
                    e.preventDefault();
                    break;
                default:
                    return;
            }
            
            const newIndex = newRow * cols + newCol;
            const newCell = document.querySelectorAll('.matrix-cell')[newIndex];
            if (newCell) newCell.focus();
        }
        
        function clearForm() {
            localStorage.clear();
            document.getElementById('c_input').value = '';
            const rows = parseInt(document.getElementById('rows').value) || 2;
            const cols = parseInt(document.getElementById('cols').value) || 2;
            for (let i = 0; i < rows; i++) {
                for (let j = 0; j < cols; j++) {
                    const input = document.querySelector(`input[name='A_${i}_${j}']`);
                    if (input) input.value = '0';
                }
                const bInput = document.querySelector(`input[name='b_${i}']`);
                if (bInput) bInput.value = '0';
            }
            updateMatrix();
        }
        
        function loadExample() {
            document.getElementById('rows').value = '2';
            document.getElementById('cols').value = '2';
            updateMatrix();
            document.getElementById('c_input').value = '3,5';
            setTimeout(() => {
                const a00 = document.querySelector('input[name="A_0_0"]');
                const a01 = document.querySelector('input[name="A_0_1"]');
                const a10 = document.querySelector('input[name="A_1_0"]');
                const a11 = document.querySelector('input[name="A_1_1"]');
                const b0 = document.querySelector('input[name="b_0"]');
                const b1 = document.querySelector('input[name="b_1"]');
                if (a00) a00.value = '1';
                if (a01) a01.value = '0';
                if (a10) a10.value = '0';
                if (a11) a11.value = '2';
                if (b0) b0.value = '4';
                if (b1) b1.value = '12';
                document.querySelector('input[value="max"]').checked = true;
                localStorage.setItem('A_0_0', '1');
                localStorage.setItem('A_0_1', '0');
                localStorage.setItem('A_1_0', '0');
                localStorage.setItem('A_1_1', '2');
                localStorage.setItem('b_0', '4');
                localStorage.setItem('b_1', '12');
            }, 50);
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            updateMatrix();
        });
    </script>
</body>
</html>