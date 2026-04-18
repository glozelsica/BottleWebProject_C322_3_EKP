<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Задача о назначениях</title>
    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body>
    <header>
        <div class="logo">Задача о назначениях</div>
        <nav>
            <a href="/">Главная</a>
            <a href="/direct_lp">Прямая ЗЛП</a>
            <a href="/transport">Транспортная задача</a>
            <a href="/assignment">Задача о назначениях</a>
            <a href="/video">Видео</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>
    
    <main class="container mt-4">
        
        <!-- === ПРАКТИКА: Форма ввода === -->
        <section class="input-form mb-4">
            <h2>Ввод исходных данных</h2>
            <form method="POST" action="/assignment">
                <div class="form-group">
                    <label for="matrix">Квадратная матрица стоимостей (числа через пробел, строки через Enter):</label>
                    <textarea 
                        id="matrix" 
                        name="matrix" 
                        class="form-control" 
                        rows="6" 
                        placeholder="10 20 30&#10;40 50 60&#10;70 80 90"
                        required
                    >{{matrix_value}}</textarea>
                    <small class="form-text text-muted">
                        Размер матрицы: до 6×6. Пример: 3 исполнителя на 3 работы.
                    </small>
                </div>
                <button type="submit" class="btn btn-primary mt-3">Рассчитать оптимальный план</button>
            </form>
        </section>

        <!-- === Блок результата === -->
        % if result is not None:
        <section class="result mb-4">
            <h2 class="text-success">{{ result['status'] }}</h2>
            <p class="lead"><strong>Минимальная суммарная стоимость:</strong> {{ result['cost'] }}</p>
            
            <table class="table table-bordered table-striped">
                <thead class="thead-dark">
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
            
            <a href="/assignment" class="btn btn-secondary">Новый расчёт</a>
        </section>
        % end

        <!-- === Блок ошибки === -->
        % if error is not None:
        <div class="alert alert-danger" role="alert">
            <strong>Ошибка ввода:</strong> {{ error }}
        </div>
        % end

        <!-- === ТЕОРИЯ: загружается из JSON === -->
        % if theory is not None:
        <section class="theory mb-4">
            <h2>{{ theory.get('title', 'Теоретические основы') }}</h2>
            
            % for section in theory.get('sections', []):
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
                
                % if 'objective' in section:
                <p><strong>{{ section['objective'].get('title', '') }}</strong><br>
                {{ section['objective'].get('formula', '') }}</p>
                % end
                
                % if 'constraints' in section:
                <p><strong>Ограничения:</strong></p>
                <ul>
                    % for item in section['constraints']:
                    <li>{{ item }}</li>
                    % end
                </ul>
                % end
                
                % if 'steps' in section:
                <ol>
                    % for step in section['steps']:
                    <li>
                        <strong>Шаг {{ step.get('step', '') }}: {{ step.get('name', '') }}</strong><br>
                        {{ step.get('description', '') }}
                    </li>
                    % end
                </ol>
                % end
            % end
        </section>
        % end

    </main>
    
    <footer>
        <p>&copy; {{year}} BottleWebProject_C322_3_EKP. Все права защищены.</p>
    </footer>
</body>
</html>