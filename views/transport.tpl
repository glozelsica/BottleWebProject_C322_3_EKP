<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Транспортная задача</title>
    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body>
    <header>
        <div class="logo">📊 Математическое моделирование</div>
        <nav>
            <a href="/">Главная</a>
            <a href="/direct_lp">Прямая ЗЛП</a>
            <a href="/transport">Транспортная</a>
            <a href="/assignment">Назначения</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>🚚 Транспортная задача</h1>
            
            <!-- Теория -->
            <div class="theory-block">
                <h2>📖 {{theory.get('title', 'Транспортная задача')}}</h2>
                <p>{{theory.get('full_theory', '')}}</p>
                
                <h3>📐 Математическая модель</h3>
                % if 'math_model' in theory:
                <pre style="background:#f4f4f4; padding:10px; border-radius:8px;">
Целевая функция: {{theory['math_model']['objective']}}
Ограничения по поставщикам: {{theory['math_model']['constraints_supply']}}
Ограничения по потребителям: {{theory['math_model']['constraints_demand']}}
Условие неотрицательности: {{theory['math_model']['non_negativity']}}
Условие сбалансированности: {{theory['math_model']['balance']}}
                </pre>
                % end
                
                <h3>📌 Этапы решения:</h3>
                % for step in theory.get('steps', []):
                <div class="theory-step">
                    <strong>{{step.get('name', '')}}</strong>
                    <p>{{step.get('description', '')}}</p>
                </div>
                % end
                
                % if 'literature' in theory:
                <h3>📚 Литература</h3>
                <ul>
                    % for lit in theory['literature']:
                    <li>{{lit}}</li>
                    % end
                </ul>
                % end
            </div>
            
            <!-- Форма ввода -->
            <form method="post" action="/transport">
                <div class="form-section">
                    <h3>📝 Ввод исходных данных</h3>
                    
                    <div class="dimension-controls">
                        <div class="form-group">
                            <label>Количество поставщиков:</label>
                            <input type="number" name="suppliers" id="suppliers" min="1" max="5" value="3">
                        </div>
                        <div class="form-group">
                            <label>Количество потребителей:</label>
                            <input type="number" name="consumers" id="consumers" min="1" max="5" value="3">
                        </div>
                        <button type="button" class="btn btn-secondary" onclick="updateMatrix()">Обновить таблицу</button>
                    </div>
                    
                    <div id="matrixContainer"></div>
                    
                    <div class="button-group">
                        <button type="submit" class="btn btn-primary">🚀 Решить задачу</button>
                        <button type="button" class="btn btn-secondary" onclick="clearForm()">Очистить</button>
                        <button type="button" class="btn btn-info" onclick="loadExample()">Пример</button>
                    </div>
                </div>
            </form>
            
            % if error:
            <div class="error-box">
                <strong>❌ Ошибка:</strong> {{error}}
            </div>
            % end
            
            % if result:
            <h2>📊 Результаты решения</h2>
            
            <!-- Шаг 1: Северо-западный угол -->
            <div class="result-box">
                <h3>Шаг 1: Метод северо-западного угла</h3>
                <p><strong>Стоимость:</strong> {{result['northwest_cost']}}</p>
                <table>
                    <tr>
                        <th></th>
                        % for j in range(result['consumers']):
                        <th>Потребитель {{j+1}}</th>
                        % end
                        <th>Запасы</th>
                    </tr>
                    % for i in range(result['suppliers']):
                    <tr>
                        <th>Поставщик {{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td>{{ result['northwest_plan'][i][j] }}</td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                </table>
            </div>
            
            <!-- Шаг 2: Минимальный элемент -->
            <div class="result-box">
                <h3>Шаг 2: Метод минимального элемента</h3>
                <p><strong>Стоимость:</strong> {{result['mincost_cost']}}</p>
                <table>
                    <tr>
                        <th></th>
                        % for j in range(result['consumers']):
                        <th>Потребитель {{j+1}}</th>
                        % end
                        <th>Запасы</th>
                    </tr>
                    % for i in range(result['suppliers']):
                    <tr>
                        <th>Поставщик {{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td>{{ result['mincost_plan'][i][j] }}</td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                </table>
            </div>
            
            <!-- Итог: Оптимальное решение -->
            <div class="result-box" style="background:#d4edda;">
                <h3>✅ Итоговое оптимальное решение (метод потенциалов)</h3>
                <p><strong>Минимальная стоимость перевозок:</strong> {{result['optimal_cost']}}</p>
                <table>
                    <tr>
                        <th></th>
                        % for j in range(result['consumers']):
                        <th>Потребитель {{j+1}}</th>
                        % end
                        <th>Запасы</th>
                    </tr>
                    % for i in range(result['suppliers']):
                    <tr>
                        <th>Поставщик {{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td><strong>{{ result['optimal_plan'][i][j] }}</strong></td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                    <tr>
                        <th>Потребности</th>
                        % for j in range(result['consumers']):
                        <td>{{ result['demand'][j] }}</td>
                        % end
                        <td></td>
                    </tr>
                </table>
                
                <h4>Матрица тарифов:</h4>
                <table>
                    % for i in range(result['suppliers']):
                    <tr>
                        % for j in range(result['consumers']):
                        <td>{{ result['costs'][i][j] }}</td>
                        % end
                    </tr>
                    % end
                </table>
            </div>
            
            <div class="button-group">
                <button class="btn btn-success" onclick="alert('Скопируйте таблицу результатов в Excel')">📎 Сохранить в Excel</button>
                <button class="btn btn-info" onclick="alert('Скопируйте таблицу результатов в CSV')">📄 Сохранить в CSV</button>
            </div>
            % end
        </div>
        
        <div class="sidebar">
            <h3>💡 Полезные советы</h3>
            <ul>
                <li>• Для перехода между ячейками используйте <kbd>Tab</kbd></li>
                <li>• Результат можно сохранить в Excel/CSV</li>
                <li>• При несбалансированности добавляются фиктивные участники</li>
                <li>• Метод минимального элемента даёт план ближе к оптимальному</li>
            </ul>
            <div class="tip-box">
                <strong>📹 Видео-инструкция</strong>
                <a href="/video" class="btn btn-info" style="display:block; margin-top:10px;">Смотреть урок</a>
            </div>
        </div>
    </div>

    <footer>
        <p>BottleWebProject_C322_3_EKP | Команда №3 | Егармина, Корнилов, Потылицына | {{year}}</p>
        <a href="/contact" class="question-btn">📩 Задать вопрос</a>
    </footer>

    <script>
        function updateMatrix() {
            const suppliers = document.getElementById('suppliers').value;
            const consumers = document.getElementById('consumers').value;
            const container = document.getElementById('matrixContainer');
            
            let html = '<div class="matrix-input"><h4>Матрица тарифов</h4><table>';
            html += '<tr><th></th>';
            for(let j = 1; j <= consumers; j++) html += `<th>Потр ${j}</th>`;
            html += '<th>Запасы</th></tr>';
            
            for(let i = 1; i <= suppliers; i++) {
                html += `<tr><th>Пост ${i}</th>`;
                for(let j = 1; j <= consumers; j++) {
                    html += `<td><input type="number" name="cost_${i-1}_${j-1}" step="any" value="0" style="width:80px;"></td>`;
                }
                html += `<td><input type="number" name="supply_${i-1}" step="any" value="0" style="width:80px;"></td></tr>`;
            }
            
            html += '<tr><th>Потребности</th>';
            for(let j = 1; j <= consumers; j++) {
                html += `<td><input type="number" name="demand_${j-1}" step="any" value="0" style="width:80px;"></td>`;
            }
            html += '<td></td></tr>';
            html += '</table></div>';
            html += `<input type="hidden" name="suppliers" value="${suppliers}">`;
            html += `<input type="hidden" name="consumers" value="${consumers}">`;
            
            container.innerHTML = html;
        }
        
        function clearForm() {
            document.querySelectorAll('input').forEach(input => {
                if(input.type === 'number') input.value = '0';
            });
        }
        
        function loadExample() {
            document.getElementById('suppliers').value = '3';
            document.getElementById('consumers').value = '3';
            updateMatrix();
            
            const supplies = [200, 150, 100];
            const demands = [120, 180, 150];
            const costs = [[4,6,8],[5,7,9],[3,5,7]];
            
            for(let i = 0; i < 3; i++) {
                document.querySelector(`[name="supply_${i}"]`).value = supplies[i];
                document.querySelector(`[name="demand_${i}"]`).value = demands[i];
                for(let j = 0; j < 3; j++) {
                    document.querySelector(`[name="cost_${i}_${j}"]`).value = costs[i][j];
                }
            }
        }
        
        document.addEventListener('DOMContentLoaded', updateMatrix);
    </script>
</body>
</html>