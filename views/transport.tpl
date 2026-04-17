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
            <a href="/video">Видео</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>🚚 Транспортная задача</h1>
            
            <!-- ===== ФОРМА ВВОДА ===== -->
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
                        <button type="button" class="btn btn-info" onclick="loadExample()">📋 Загрузить пример</button>
                    </div>
                </div>
            </form>
            
            % if error:
            <div class="error-box"><strong>❌ Ошибка:</strong> {{error}}</div>
            % end
            
            <!-- ===== РЕЗУЛЬТАТЫ РЕШЕНИЯ (сначала!) ===== -->
            % if result:
            <h2>📊 Результаты решения</h2>
            
            <!-- Типовой пример из теории -->
            <div class="theory-block" style="background:#e8f5e9;">
                <h3>📌 Типовой пример (из теории)</h3>
                <p>Для наглядности рассмотрим пример с 3 поставщиками и 3 потребителями:</p>
                <p><strong>Запасы:</strong> 70, 100, 110 &nbsp;&nbsp; <strong>Потребности:</strong> 80, 50, 150</p>
                <p><strong>Матрица тарифов:</strong></p>
                <table style="width:auto; margin:10px 0;">
                    <tr><th></th><th>B1</th><th>B2</th><th>B3</th></tr>
                    <tr><th>A1</th><td>1</td><td>4</td><td>5</td></tr>
                    <tr><th>A2</th><td>3</td><td>5</td><td>2</td></tr>
                    <tr><th>A3</th><td>2</td><td>6</td><td>4</td></tr>
                </table>
                <p><strong>Оптимальный план перевозок (стоимость = 790):</strong></p>
                <table style="width:auto; margin:10px 0;">
                    <tr><th></th><th>B1</th><th>B2</th><th>B3</th><th>Запасы</th></tr>
                    <tr><th>A1</th><td>70</td><td>0</td><td>0</td><td>70</td></tr>
                    <tr><th>A2</th><td>0</td><td>0</td><td>100</td><td>100</td></tr>
                    <tr><th>A3</th><td>10</td><td>50</td><td>50</td><td>110</td></tr>
                    <tr><th>Потребности</th><td>80</td><td>50</td><td>150</td><td></td></tr>
                </table>
                <p><em>Формула расчёта: 70×1 + 100×2 + 10×2 + 50×6 + 50×4 = 70 + 200 + 20 + 300 + 200 = 790</em></p>
            </div>
            
            <!-- Шаг 1: Северо-западный угол -->
            <div class="result-box">
                <h3>Шаг 1: Метод северо-западного угла</h3>
                <p><strong>Стоимость:</strong> {{result['northwest_cost']}}</p>
                <table>
                    <tr><th></th>% for j in range(result['consumers']):<th>Потребитель {{j+1}}</th>% end<th>Запасы</th></tr>
                    % for i in range(result['suppliers']):
                    <tr><th>Поставщик {{i+1}}</th>
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
                    <tr><th></th>% for j in range(result['consumers']):<th>Потребитель {{j+1}}</th>% end<th>Запасы</th></tr>
                    % for i in range(result['suppliers']):
                    <tr><th>Поставщик {{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td>{{ result['mincost_plan'][i][j] }}</td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                </table>
            </div>
            
            <!-- Итоговое оптимальное решение -->
            <div class="result-box" style="background:#d4edda;">
                <h3>✅ Итоговое оптимальное решение (метод потенциалов)</h3>
                <p><strong>Минимальная стоимость перевозок:</strong> {{result['optimal_cost']}}</p>
                <table>
                    <tr><th></th>% for j in range(result['consumers']):<th>Потребитель {{j+1}}</th>% end<th>Запасы</th></tr>
                    % for i in range(result['suppliers']):
                    <tr><th>Поставщик {{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td><strong>{{ result['optimal_plan'][i][j] }}</strong></td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                    <tr><th>Потребности</th>
                        % for j in range(result['consumers']):
                        <td>{{ result['demand'][j] }}</td>
                        % end
                        <td></td>
                    </tr>
                </table>
                <h4>Матрица тарифов:</h4>
                <table>
                    % for i in range(result['suppliers']):
                    <tr>% for j in range(result['consumers']):<td>{{ result['costs'][i][j] }}</td>% end</tr>
                    % end
                </table>
                % if not result['balanced']:
                <p><em>⚠️ Задача была несбалансирована, добавлены фиктивные участники с нулевыми тарифами.</em></p>
                % end
            </div>
            
            <div class="button-group">
                <button class="btn btn-success" onclick="alert('Скопируйте таблицу результатов в Excel')">📎 Сохранить в Excel</button>
                <button class="btn btn-info" onclick="alert('Скопируйте таблицу результатов в CSV')">📄 Сохранить в CSV</button>
            </div>
            % end
            
            <!-- ===== ТЕОРИЯ (после решения) ===== -->
            <h2>📖 Теоретические основы</h2>
            
            <!-- Раздел 1: Постановка задачи -->
            <div class="theory-block">
                <h3>{{theory['theory']['section1']['title']}}</h3>
                <p>{{theory['theory']['section1']['content']}}</p>
                % for formula in theory['theory']['section1']['formulas']:
                <div class="formula-box">
                    <p><em>{{formula['description']}}</em></p>
                    <img src="{{formula['image']}}" alt="{{formula['description']}}" style="max-width:100%; margin:10px 0;">
                </div>
                % end
            </div>
            
            <!-- Раздел 2: Закрытая модель -->
            <div class="theory-block">
                <h3>{{theory['theory']['section2']['title']}}</h3>
                <p>{{theory['theory']['section2']['content']}}</p>
                <div class="theorem-box">
                    <strong>📐 Теорема:</strong> {{theory['theory']['section2']['theorem']}}
                </div>
                % for formula in theory['theory']['section2']['formulas']:
                <img src="{{formula['image']}}" alt="{{formula['description']}}" style="max-width:100%; margin:10px 0;">
                % end
                <ul>
                % for remark in theory['theory']['section2']['remarks']:
                    <li>{{remark}}</li>
                % end
                </ul>
            </div>
            
            <!-- Раздел 3: Опорный план -->
            <div class="theory-block">
                <h3>{{theory['theory']['section3']['title']}}</h3>
                <p>{{theory['theory']['section3']['content']}}</p>
                <img src="{{theory['theory']['section3']['formulas'][0]['image']}}" alt="Число базисных клеток" style="max-width:100%;">
            </div>
            
            <!-- Раздел 4: Методы построения опорного плана -->
            <div class="theory-block">
                <h3>{{theory['theory']['section4']['title']}}</h3>
                % for method in theory['theory']['section4']['methods']:
                <div style="margin: 15px 0;">
                    <strong>{{method['name']}}:</strong>
                    <p>{{method['description']}}</p>
                    <img src="{{method['image']}}" alt="{{method['name']}}" style="max-width:100%; border-radius:8px;">
                </div>
                % end
            </div>
            
            <!-- Раздел 5: Метод потенциалов -->
            <div class="theory-block">
                <h3>{{theory['theory']['section5']['title']}}</h3>
                <p>{{theory['theory']['section5']['content']}}</p>
                <div class="theorem-box">
                    <strong>📐 Теорема:</strong> {{theory['theory']['section5']['theorem']}}
                </div>
                % for formula in theory['theory']['section5']['formulas']:
                <img src="{{formula['image']}}" alt="{{formula['description']}}" style="max-width:100%; margin:10px 0;">
                % end
                <strong>Алгоритм:</strong>
                <ol>
                % for step in theory['theory']['section5']['algorithm']:
                    <li>{{step}}</li>
                % end
                </ol>
            </div>
            
            <!-- Раздел 6: Цикл пересчёта -->
            <div class="theory-block">
                <h3>{{theory['theory']['section6']['title']}}</h3>
                <p>{{theory['theory']['section6']['content']}}</p>
                <ol>
                % for step in theory['theory']['section6']['algorithm']:
                    <li>{{step}}</li>
                % end
                </ol>
                <img src="{{theory['theory']['section6']['image']}}" alt="Цикл пересчёта" style="max-width:100%; margin:10px 0;">
            </div>
            
            <!-- Раздел 7: Дополнительные ограничения -->
            <div class="theory-block">
                <h3>{{theory['theory']['section7']['title']}}</h3>
                % for sub in theory['theory']['section7']['subsections']:
                <div style="margin: 15px 0;">
                    <strong>{{sub['title']}}:</strong>
                    <p>{{sub['content']}}</p>
                </div>
                % end
            </div>
        </div>
        
        <!-- ===== БОКОВАЯ ПАНЕЛЬ ===== -->
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
            const suppliers = parseInt(document.getElementById('suppliers').value);
            const consumers = parseInt(document.getElementById('consumers').value);
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
            document.querySelectorAll('input[type="number"]').forEach(input => input.value = '0');
        }
        
        function loadExample() {
            document.getElementById('suppliers').value = '3';
            document.getElementById('consumers').value = '3';
            updateMatrix();
            
            // Пример из теории
            const supplies = [70, 100, 110];
            const demands = [80, 50, 150];
            const costs = [[1,4,5],[3,5,2],[2,6,4]];
            
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