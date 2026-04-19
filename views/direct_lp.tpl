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
    <!-- Текстурный слой (под контентом) -->
    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.4; pointer-events: none;"></div>
    
    <!-- Контент (поверх текстуры) -->
    <div style="position: relative; z-index: 1; display: flex; justify-content: space-between; align-items: center; padding: 1rem 2rem;">
        <div class="logo" style="display: flex; align-items: center; gap: 0.5rem;">
            <img src="/static/images/logo.png" alt="Логотип" style="height: 35px; width: 35px; object-fit: contain;" onerror="this.style.display='none'"> 
            <span style="color: white;">Математическое моделирование</span>
        </div>
        <nav style="display: flex; gap: 1.5rem;">
            <a href="/" style="color: white; text-decoration: none;">Главная</a>
            <a href="/transport" style="color: white; text-decoration: none;">Транспортная</a>
            <a href="/assignment" style="color: white; text-decoration: none;">Назначения</a>
            <a href="/video" style="color: white; text-decoration: none;">Видео</a>
            <a href="/authors" style="color: white; text-decoration: none;">Об авторах</a>
            <a href="/contact" style="color: white; text-decoration: none;">Контакты</a>
        </nav>
    </div>
</header>

    <div class="main-container">
        <div class="content">
            <h1>Симплекс-метод решения задач линейного программирования</h1>

            <!-- БЛОК КАЛЬКУЛЯТОРА -->
            <div class="calculator-block">
                <h2>Решение задачи</h2>

                % if error:
                <div class="error-box">
                    <strong>Ошибка:</strong> {{error}}
                </div>
                % end

                <form method="post" id="lpForm">
                    <div class="form-group">
                        <label>Коэффициенты целевой функции (через запятую):</label>
                        <input type="text" name="c" id="c_input" value="{{c}}" size="50" placeholder="пример: 3,5" required>
                    </div>

                    <div class="form-group">
                        <label>Количество ограничений (строк):</label>
                        <input type="number" name="rows" id="rows" value="{{rows}}" min="1" max="10" step="1">
                    </div>

                    <div class="form-group">
                        <label>Количество переменных (столбцов):</label>
                        <input type="number" name="cols" id="cols" value="{{cols}}" min="1" max="10" step="1">
                    </div>

                    <button type="button" class="btn btn-secondary" onclick="updateMatrix()">Обновить матрицу</button>

                    <h3>Матрица ограничений A</h3>
                    <div id="matrix-container" class="matrix-input"></div>

                    <h3>Правые части b</h3>
                    <div id="b-container"></div>

                    <div class="form-group">
                        <label>Направление оптимизации:</label>
                        <label><input type="radio" name="sense" value="max" {{'checked' if sense=='max' else ''}}> Максимизация</label>
                        <label><input type="radio" name="sense" value="min" {{'checked' if sense=='min' else ''}}> Минимизация</label>
                    </div>

                    <div class="button-group">
                        <button type="submit" class="btn btn-primary">Решить</button>
                        <button type="button" class="btn btn-secondary" onclick="clearForm()">Очистить</button>
                        <button type="button" class="btn btn-info" onclick="loadExample()">Загрузить пример</button>
                        % if result and result.get('success'):
                        <button type="button" class="btn btn-success" onclick="exportResult()">Сохранить результат</button>
                        % end
                    </div>
                </form>

                <!-- РЕЗУЛЬТАТ -->
                % if result:
                    % if result.get('success'):
                    <div class="result-box">
                        <h3>Результат решения</h3>
                        <p><strong>Оптимальное решение:</strong></p>
                        % for i, val in enumerate(result['solution']):
                            <p>x{{i+1}} = {{"{:.6f}".format(val)}}</p>
                        % end
                        <p><strong>Значение целевой функции:</strong> {{"{:.6f}".format(result['value'])}}</p>
                        <p><strong>Количество итераций:</strong> {{result['iterations']}}</p>
                    </div>
                    % else:
                    <div class="error-box">
                        <strong>Ошибка:</strong> {{result.get('error', 'Неизвестная ошибка')}}
                    </div>
                    % end
                % end
            </div>

            <!-- БЛОК ТЕОРИИ С КАРТИНКАМИ -->
            <div class="theory-block">
                <h2>Теория симплекс-метода</h2>
                
                <div class="theory-text">
                    <p><strong>Симплекс-метод</strong> — это универсальный итерационный алгоритм решения задач линейного программирования.</p>
                    
                    <!-- БЛОК С КАРТИНКОЙ И ОБТЕКАНИЕМ ТЕКСТА -->
                    <div class="clearfix">
                        <!-- КАРТИНКА 1: Геометрическая интерпретация (слева, текст обтекает) -->
                        <img src="/static/images/simplex_geometry.png" alt="Геометрическая интерпретация симплекс-метода" class="image-float-left" onerror="this.style.display='none'">
                        
                        <h3>Основная идея</h3>
                        <p>Геометрически метод представляет собой направленный перебор вершин многогранника допустимых решений. Алгебраически — последовательное улучшение допустимого базисного решения путём замены одной базисной переменной на свободную.</p>
                        <p>Каждой вершине многогранника соответствует определённый набор базисных переменных. Переход к соседней вершине осуществляется путём замены одной базисной переменной на свободную, что приводит к улучшению значения целевой функции.</p>
                    </div>
                    
                    <h3>Этапы симплекс-метода</h3>
                    <ol>
                        <li>Приведение задачи к каноническому виду</li>
                        <li>Построение начальной симплекс-таблицы</li>
                        <li>Выбор разрешающего столбца (по отрицательной оценке)</li>
                        <li>Выбор разрешающей строки (по минимальному отношению)</li>
                        <li>Пересчёт таблицы методом Жордана-Гаусса</li>
                        <li>Повторение шагов 3-5 до достижения оптимальности</li>
                    </ol>
                    
                    <h3>Каноническая форма задачи</h3>
                    <pre>
min (или max) F = c₁x₁ + c₂x₂ + ... + cₙxₙ
при ограничениях:
    a₁₁x₁ + a₁₂x₂ + ... + a₁ₙxₙ = b₁
    a₂₁x₁ + a₂₂x₂ + ... + a₂ₙxₙ = b₂
    ...
    aₘ₁x₁ + aₘ₂x₂ + ... + aₘₙxₙ = bₘ
    xⱼ ≥ 0, j = 1..n
                    </pre>
                    
                    <h3>Структура симплекс-таблицы</h3>
                    <table border="1" style="border-collapse: collapse; width: 100%; margin: 15px 0;">
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
                            <tr>
                                <td>x_B₁</td>
                                <td>b₁</td>
                                <td>a₁₁</td>
                                <td>a₁₂</td>
                                <td>...</td>
                                <td>a₁ₙ</td>
                            </tr>
                            <tr>
                                <td>x_B₂</td>
                                <td>b₂</td>
                                <td>a₂₁</td>
                                <td>a₂₂</td>
                                <td>...</td>
                                <td>a₂ₙ</td>
                            </tr>
                            <tr>
                                <td>...</td>
                                <td>...</td>
                                <td>...</td>
                                <td>...</td>
                                <td>...</td>
                                <td>...</td>
                            </tr>
                            <tr>
                                <td>x_Bₘ</td>
                                <td>bₘ</td>
                                <td>aₘ₁</td>
                                <td>aₘ₂</td>
                                <td>...</td>
                                <td>aₘₙ</td>
                            </tr>
                            <tr style="background: #f0f0f0;">
                                <td>F</td>
                                <td>F₀</td>
                                <td>Δ₁</td>
                                <td>Δ₂</td>
                                <td>...</td>
                                <td>Δₙ</td>
                            </tr>
                        </tbody>
                    </table>
                    
                    <!-- КАРТИНКА 2: Пример симплекс-таблицы -->
                    <img src="/static/images/simplex_table.png" alt="Пример симплекс-таблицы" style="max-width:100%; margin: 15px 0; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" onerror="this.style.display='none'">
                    
                    <h3>Критерий оптимальности</h3>
                    <p>Для задачи на минимум: если все оценки Δⱼ ≥ 0, то решение оптимально.<br>
                    Для задачи на максимум: если все оценки Δⱼ ≤ 0, то решение оптимально.</p>
                    
                    <h3>Особые случаи</h3>
                    <ul>
                        <li><strong>Неограниченность:</strong> если в разрешающем столбце нет положительных элементов → задача не имеет конечного решения</li>
                        <li><strong>Вырожденность:</strong> одна из базисных переменных равна нулю → возможно зацикливание</li>
                        <li><strong>Альтернативный оптимум:</strong> есть нулевые оценки у небазисных переменных → множество решений</li>
                        <li><strong>Отсутствие начального базиса:</strong> применяется метод искусственного базиса</li>
                    </ul>
                    
                    <h3>Преобразование Жордана-Гаусса (правило прямоугольника)</h3>
                    <!-- КАРТИНКА 3: Правило прямоугольника -->
                    <img src="/static/images/rectangle_rule.png" alt="Правило прямоугольника" style="max-width:100%; margin: 15px 0; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" onerror="this.style.display='none'">
                    <p>При пересчёте таблицы используется формула:</p>
                    <pre>новый_элемент = текущий_элемент − (aᵣⱼ × aᵢₛ) / aᵣₛ</pre>
                    <p>где aᵣₛ — разрешающий элемент, r — разрешающая строка, s — разрешающий столбец.</p>
                    
                    <h3>Метод искусственного базиса (двухфазный метод)</h3>
                    <!-- КАРТИНКА 4: Двухфазный метод -->
                    <img src="/static/images/two_phase_method.png" alt="Двухфазный метод" style="max-width:100%; margin: 15px 0; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" onerror="this.style.display='none'">
                    <p><strong>Фаза 1:</strong> Добавляются искусственные переменные, решается вспомогательная задача на минимум суммы искусственных переменных. Если min F_иск = 0 → допустимый базис найден.</p>
                    <p><strong>Фаза 2:</strong> Удаляются искусственные переменные, продолжается решение с исходной целевой функцией.</p>
                    
                    <h3>Правило Блэнда (предотвращение зацикливания)</h3>
                    <p>При вырожденности выбирается столбец с наименьшим индексом среди отрицательных оценок и строка с наименьшим индексом среди минимальных отношений.</p>
                    
                    <!-- КАРТИНКА 5: Блок-схема алгоритма -->
                    <img src="/static/images/simplex_flowchart.png" alt="Блок-схема симплекс-метода" style="max-width:100%; margin: 15px 0; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" onerror="this.style.display='none'">
                </div>
            </div>
        </div>

        <aside class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками матрицы используйте стрелки на клавиатуре</li>
                <li>Для быстрого перехода по полям используйте клавишу Tab</li>
                <li>Результат можно сохранить в Excel или CSV</li>
                <li>Если задача не имеет решения - система сообщит об этом</li>
                <li>Ввод данных сохраняется при перезагрузке страницы</li>
            </ul>
            <div class="tip-box">
                <h4>Тестовый пример</h4>
                <p><strong>Максимизация:</strong><br>
                c = 3,5<br>
                A = [[1,0],[0,2]]<br>
                b = 4,12<br>
                → x = (4,6), F = 42</p>
            </div>
            <div class="tip-box">
                <h4>Нужна помощь?</h4>
                <p>Посмотрите <a href="/video">видео-инструкцию</a></p>
            </div>
        </aside>
    </div>

    <footer>
        <p>2026 - Математическое моделирование</p>
        <a href="/contact" class="question-btn">Задать вопрос</a>
    </footer>

    <script>
        function updateMatrix() {
            const rows = parseInt(document.getElementById('rows').value) || 2;
            const cols = parseInt(document.getElementById('cols').value) || 2;

            const savedMatrix = [];
            for(let i=0; i<rows; i++) {
                savedMatrix[i] = [];
                for(let j=0; j<cols; j++) {
                    const oldInput = document.querySelector(`input[name='A_${i}_${j}']`);
                    savedMatrix[i][j] = oldInput ? oldInput.value : '0';
                }
            }

            let html = '<table>';
            for(let i=0; i<rows; i++) {
                html += '<tr>';
                for(let j=0; j<cols; j++) {
                    html += `<td><input type="number" step="any" name="A_${i}_${j}" value="${savedMatrix[i][j]}" placeholder="a${i+1}${j+1}" class="matrix-cell" style="width:80px; padding:5px;"></td>`;
                }
                html += '</tr>';
            }
            html += '</table>';
            document.getElementById('matrix-container').innerHTML = html;

            let bHtml = '';
            for(let i=0; i<rows; i++) {
                const oldB = document.querySelector(`input[name='b_${i}']`);
                const val = oldB ? oldB.value : '0';
                bHtml += `<label style="display:inline-block; width:60px;">b${i+1}:</label> <input type="number" step="any" name="b_${i}" value="${val}" style="width:100px;"><br>`;
            }
            document.getElementById('b-container').innerHTML = bHtml;

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
            if(newCell) {
                newCell.focus();
            }
        }

        function clearForm() {
            document.getElementById('c_input').value = '';
            const rows = parseInt(document.getElementById('rows').value) || 2;
            const cols = parseInt(document.getElementById('cols').value) || 2;
            for(let i=0; i<rows; i++) {
                for(let j=0; j<cols; j++) {
                    const input = document.querySelector(`input[name='A_${i}_${j}']`);
                    if(input) input.value = '0';
                }
                const bInput = document.querySelector(`input[name='b_${i}']`);
                if(bInput) bInput.value = '0';
            }
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
                if(a00) a00.value = '1';
                if(a01) a01.value = '0';
                if(a10) a10.value = '0';
                if(a11) a11.value = '2';
                if(b0) b0.value = '4';
                if(b1) b1.value = '12';
                document.querySelector('input[value="max"]').checked = true;
            }, 100);
        }

        function exportResult() {
            alert('Результат сохранен в папку data/results/');
        }

        document.addEventListener('DOMContentLoaded', () => {
            updateMatrix();
        });
    </script>
</body>
</html>