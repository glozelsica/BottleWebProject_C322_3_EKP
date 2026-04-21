<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{title}}</title>
    <link rel="stylesheet" href="/static/content/site.css">
    <style>
        .matrix-input table {
            border-collapse: collapse;
            margin: 1rem 0;
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .matrix-input td {
            padding: 10px;
            border: 1px solid #dee2e6;
            background: #f8f9fa;
            text-align: center;
        }
        .matrix-input input[type="number"] {
            width: 80px;
            padding: 8px;
            text-align: center;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
        }
        .matrix-input input[type="number"]:focus {
            outline: none;
            border-color: #9B2226;
            box-shadow: 0 0 5px rgba(155,34,38,0.3);
        }
        .dimension-controls {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <header style="position: relative; overflow: hidden; background: #9B2226;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; opacity: 0.4; pointer-events: none;"></div>
        
        <div style="position: relative; z-index: 1; display: flex; justify-content: space-between; align-items: center; padding: 1rem 2rem;">
            <div class="logo" style="display: flex; align-items: center; gap: 0.5rem;">
                <img src="/static/images/logo.png" alt="Лого" style="height: 35px; width: auto;">
                <span style="color: white; font-weight: bold;">Задача о назначениях</span>
            </div>
            <nav style="display: flex; gap: 1.5rem;">
                <a href="/" style="color: white; text-decoration: none;">Главная</a>
                <a href="/direct_lp" style="color: white; text-decoration: none;">Прямая ЗЛП</a>
                <a href="/transport" style="color: white; text-decoration: none;">Транспортная</a>
                <a href="/assignment" style="color: white; text-decoration: none; border-bottom: 2px solid white;">Назначения</a>
                <a href="/video" style="color: white; text-decoration: none;">Видео</a>
                <a href="/authors" style="color: white; text-decoration: none;">Об авторах</a>
                <a href="/contact" style="color: white; text-decoration: none;">Контакты</a>
            </nav>
        </div>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>Венгерский алгоритм решения задачи о назначениях</h1>
            
            <div class="form-section">
                <h2>Решение задачи</h2>
                <form id="assignmentForm" method="POST" onsubmit="return prepareAndSubmit(event)">
                    
                    <div class="dimension-controls">
                        <label for="matrix_size" style="font-weight: 500;">Размер матрицы (n × n):</label>
                        <input type="number" id="matrix_size" name="matrix_size" min="2" max="6" value="3" onchange="generateMatrix(false)" style="width: 80px; text-align: center; font-weight: bold;">
                        <span style="color: #6c757d; font-size: 0.9rem;">(от 2 до 6)</span>
                    </div>

                    <div id="matrix-container" class="matrix-input"></div>

                    <input type="hidden" name="matrix_data" id="matrix_data">
                    <input type="hidden" name="is_form_submit" id="is_form_submit" value="0">

                    <div class="button-group">
                        <button type="submit" class="btn btn-primary">Рассчитать</button>
                        <button type="button" class="btn btn-secondary" onclick="clearMatrix()">Очистить</button>
                        <button type="button" class="btn btn-info" onclick="loadExample()">Загрузить пример</button>
                    </div>
                </form>
            </div>

            % if result is not None:
            <div class="result-box" style="background: #d4edda; border-color: #c3e6cb; color: #155724;">
                <h3 style="color: #155724; margin-top: 0;">✅ {{ result['status'] }}</h3>
                <p style="font-size: 1.1rem;"><strong>Минимальная суммарная стоимость:</strong> {{ result['cost'] }}</p>
                
                <div style="overflow-x: auto;">
                    <table class="result-table" style="width: 100%; border-collapse: collapse; margin-top: 10px;">
                        <thead>
                            <tr style="background: #9B2226; color: white;">
                                <th style="padding: 10px; border: 1px solid #ddd;">№</th>
                                <th style="padding: 10px; border: 1px solid #ddd;">Исполнитель (строка)</th>
                                <th style="padding: 10px; border: 1px solid #ddd;">Работа (столбец)</th>
                            </tr>
                        </thead>
                        <tbody>
                            % for idx, (i, j) in enumerate(result['assignment'], 1):
                            <tr>
                                <td style="padding: 8px; border: 1px solid #ddd; text-align: center;">{{ idx }}</td>
                                <td style="padding: 8px; border: 1px solid #ddd; text-align: center;">{{ i + 1 }}</td>
                                <td style="padding: 8px; border: 1px solid #ddd; text-align: center;">{{ j + 1 }}</td>
                            </tr>
                            % end
                        </tbody>
                    </table>
                </div>
            </div>
            % end

            % if error is not None:
            <div class="error-box" style="background: #f8d7da; border-color: #f5c6cb; color: #721c24; padding: 1rem; border-radius: 12px; margin: 1rem 0;">
                <h3 style="color: #721c24; margin-top: 0;">❌ Ошибка ввода</h3>
                <p>{{ error }}</p>
            </div>
            % end

            <div class="theory-section">
                <h2>Теоретические основы</h2>
                % if theory is not None:
                    % for section in theory.get('sections', []):
                    <div class="theory-block">
                        <h3>{{ section.get('heading', '') }}</h3>
                        % if 'content' in section:
                        <p>{{ section['content'] }}</p>
                        % end
                        % if 'description' in section:
                        <p>{{ section['description'] }}</p>
                        % end
                        % if 'conditions' in section:
                        <ul style="margin-left: 20px;">
                            % for item in section['conditions']:
                            <li style="margin-bottom: 8px;">{{ item }}</li>
                            % end
                        </ul>
                        % end
                        % if 'steps' in section:
                        <ol style="margin-left: 20px;">
                            % for step in section['steps']:
                            <li style="margin-bottom: 8px;"><strong>Шаг {{ step.get('step', '') }}: {{ step.get('name', '') }}</strong><br>{{ step.get('description', '') }}</li>
                            % end
                        </ol>
                        % end
                    </div>
                    % end
                % end
            </div>
        </div>

        <div class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Вводите только целые числа.</li>
                <li>Матрица должна быть строго квадратной.</li>
                <li>При выборе максимизации система автоматически преобразует матрицу.</li>
            </ul>

            <div class="tip-box">
                <h4>Тестовый пример</h4>
                <p><strong>Минимизация:</strong><br>
                <code style="background: #d9cfe8; padding: 2px 5px; border-radius: 4px;">
                10 20 30<br>40 50 60<br>70 80 90
                </code><br>
                → Оптимальная стоимость: 150</p>
            </div>

            <div class="tip-box" style="margin-top: 1.2rem;">
                <h4>Нужна помощь?</h4>
                <p>Посмотрите <a href="/video" style="color: #6d181b; font-weight: 500;">видео-инструкцию</a>.</p>
            </div>
        </div>
    </div>

    <footer style="position: relative; overflow: hidden; background: #9B2226;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; opacity: 0.4; pointer-events: none;"></div>
        <div class="footer-bottom" style="position: relative; z-index: 1; text-align: center; padding: 1.5rem; color: #EDE7F6;">
            <p>© 2026 Математическое моделирование. Все права защищены.</p>
        </div>
    </footer>

    <script>
        // Получаем данные от сервера
        // serverMatrixData теперь приходит как валидный JSON благодаря json.dumps()
        const serverMatrixSize = {{ matrix_size if defined('matrix_size') else 3 }};
        const serverMatrixData = {{ matrix_values_json if defined('matrix_values_json') else '[]' }};
        const hasError = {{ 'true' if error is not None else 'false' }};
        const hasResult = {{ 'true' if result is not None else 'false' }};

        document.addEventListener('DOMContentLoaded', function() {
            if (hasError || hasResult) {
                document.getElementById('matrix_size').value = serverMatrixSize;
                generateMatrix(true, serverMatrixData);
            } else {
                generateMatrix(false);
            }
        });

        function generateMatrix(restoreValues = false, values = []) {
            const n = parseInt(document.getElementById('matrix_size').value) || 3;
            const container = document.getElementById('matrix-container');
    
            if (n < 2 || n > 6) {
                alert('Размер должен быть от 2 до 6');
                document.getElementById('matrix_size').value = 3;
                return;
            }
    
            let html = '<table>';
            for (let i = 0; i < n; i++) {
                html += '<tr>';
                for (let j = 0; j < n; j++) {
                    const val = (restoreValues && values[i] && values[i][j] !== undefined) ? values[i][j] : '';
                    // 🔥 Добавлены: min="0", onkeydown, oninput, onblur
                    html += `<td>
                        <input type="number" 
                               id="cell_${i}_${j}" 
                               value="${val}" 
                               placeholder="0" 
                               min="0" 
                               step="1"
                               onkeydown="return blockSigns(event)"
                               oninput="sanitizeInput(this)"
                               onblur="clampToZero(this)">
                    </td>`;
                }
                html += '</tr>';
            }
            html += '</table>';
            container.innerHTML = html;
        }

        function prepareAndSubmit(event) {
            event.preventDefault(); // Отменяем стандартную отправку
            
            const n = parseInt(document.getElementById('matrix_size').value);
            let matrixRows = [];
            let allFilled = true;

            for (let i = 0; i < n; i++) {
                let currentRow = [];
                for (let j = 0; j < n; j++) {
                    const input = document.getElementById('cell_' + i + '_' + j);
                    const val = input.value.trim();
                    
                    if (val === '' || isNaN(val)) {
                        input.style.borderColor = '#dc3545';
                        input.style.boxShadow = '0 0 5px rgba(220,53,69,0.5)';
                        allFilled = false;
                    } else {
                        input.style.borderColor = '#ccc';
                        input.style.boxShadow = 'none';
                        currentRow.push(val);
                    }
                }
                matrixRows.push(currentRow);
            }

            if (!allFilled) {
                alert('Пожалуйста, заполните все ячейки матрицы числами!');
                return false;
            }

            // Формируем строку для отправки
            const matrixString = matrixRows.map(row => row.join(' ')).join('\n');
            document.getElementById('matrix_data').value = matrixString;
            document.getElementById('is_form_submit').value = '1';
            
            // Ручная отправка формы. 
            // ВАЖНО: Не возвращаем false после этого, иначе браузер может отменить отправку.
            document.getElementById('assignmentForm').submit();
        }

        function clearMatrix() {
            const n = parseInt(document.getElementById('matrix_size').value);
            for (let i = 0; i < n; i++) {
                for (let j = 0; j < n; j++) {
                    const input = document.getElementById('cell_' + i + '_' + j);
                    if (input) {
                        input.value = '';
                        input.style.borderColor = '#ccc';
                    }
                }
            }
        }

        function loadExample() {
            document.getElementById('matrix_size').value = 3;
            generateMatrix(false);
            
            const example = [[10, 20, 30], [40, 50, 60], [70, 80, 90]];
            for (let i = 0; i < 3; i++) {
                for (let j = 0; j < 3; j++) {
                    document.getElementById('cell_' + i + '_' + j).value = example[i][j];
                }
            }
        }
    </script>
</body>
</html>