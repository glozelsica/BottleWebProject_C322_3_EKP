<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{title}}</title>
    <link rel="stylesheet" href="/static/content/style.css">
</head>
<body>
    <header>
        <div class="logo">Задача о назначениях</div>
        <nav>
            <a href="/">Главная</a>
            <a href="/direct_lp">Прямая ЗЛП</a>
            <a href="/transport">Транспортная</a>
            <a href="/video">Видео</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        
        <div class="content">
            <h1>Венгерский алгоритм решения задачи о назначениях</h1>
            
            <div class="form-section">
                <h2>Решение задачи</h2>
                <form method="POST" action="/assignment">
                    
                    <div class="form-group">
                        <label for="matrix" style="display: block; margin-bottom: 8px; font-weight: 500; white-space: nowrap;">
                            Квадратная матрица стоимостей (числа через пробел, строки через Enter):
                        </label>
                        <textarea 
                            id="matrix" 
                            name="matrix" 
                            rows="6" 
                            style="width: 100%; max-width: 450px; font-family: 'Courier New', monospace;" 
                            placeholder="10 20 30&#10;40 50 60&#10;70 80 90" 
                            required>{{matrix_value}}</textarea>
                        <small style="color: #6c757d; display: block; margin-top: 5px;">
                            Размер матрицы: до 6×6. Пример: 3 исполнителя на 3 работы.
                        </small>
                    </div>

                    <div class="button-group">
                        <button type="submit" class="btn btn-primary">Рассчитать</button>
                        <button type="reset" class="btn btn-secondary">Очистить</button>
                        <button type="button" class="btn btn-info" onclick="document.getElementById('matrix').value='10 20 30\n40 50 60\n70 80 90';">Загрузить пример</button>
                    </div>
                </form>
            </div>

            % if result is not None:
            <div class="result-success">
                <h3>✅ {{ result['status'] }}</h3>
                <p style="font-size: 1.1rem;"><strong>Минимальная суммарная стоимость:</strong> {{ result['cost'] }}</p>
                
                <div class="tableau-container">
                    <table class="simplex-tableau">
                        <thead>
                            <tr>
                                <th>№</th>
                                <th>Исполнитель (строка)</th>
                                <th>Работа (столбец)</th>
                            </tr>
                        </thead>
                        <tbody>
                            % for idx, (i, j) in enumerate(result['assignment'], 1):
                            <tr>
                                <td>{{ idx }}</td>
                                <td>{{ i + 1 }}</td>
                                <td>{{ j + 1 }}</td>
                            </tr>
                            % end
                        </tbody>
                    </table>
                </div>
            </div>
            % end

            % if error is not None:
            <div class="result-error">
                <h3>❌ Ошибка ввода</h3>
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
                        <ul>
                            % for item in section['conditions']:
                            <li>{{ item }}</li>
                            % end
                        </ul>
                        % end
                        
                        % if 'steps' in section:
                        <ol>
                            % for step in section['steps']:
                            <li><strong>Шаг {{ step.get('step', '') }}: {{ step.get('name', '') }}</strong><br>{{ step.get('description', '') }}</li>
                            % end
                        </ol>
                        % end
                    </div>
                    % end
                % else:
                <p>Загрузка теоретических данных...</p>
                % end
            </div>
        </div>

        <div class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Вводите числа через пробел, строки разделяйте клавишей Enter.</li>
                <li>Матрица должна быть строго квадратной (до 6×6).</li>
                <li>При выборе максимизации система автоматически преобразует матрицу.</li>
                <li>Все запуски сохраняются в лог-файл с датой и временем.</li>
            </ul>

            <div class="tip-box">
                <h4>Тестовый пример</h4>
                <p><strong>Минимизация:</strong><br>
                <code style="background: #d9cfe8; padding: 2px 5px; border-radius: 4px;">
                10 20 30<br>
                40 50 60<br>
                70 80 90
                </code><br>
                → Оптимальная стоимость: 150</p>
            </div>

            <div class="tip-box" style="margin-top: 1.2rem;">
                <h4>Нужна помощь?</h4>
                <p>Посмотрите <a href="/video" style="color: #6d181b; font-weight: 500;">видео-инструкцию</a> или обратитесь к разделу «Контакты».</p>
            </div>
        </div>

    </div>

    <footer>
        <p>&copy; {{year}} BottleWebProject_C322_3_EKP. Все права защищены.</p>
    </footer>
</body>
</html>