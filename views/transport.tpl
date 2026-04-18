<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Транспортная задача</title>
    <link rel="icon" href="/static/images/logo.png" type="image/png">
    <link rel="stylesheet" href="/static/css/style.css">
    <link rel="stylesheet" href="/static/css/transport.css">
</head>
<body>
    <!-- ШАПКА -->
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
            <h1>Транспортная задача</h1>
            
            <!-- ФОРМА ВВОДА -->
            <form method="post" action="/transport" id="transportForm">
                <div class="form-section">
                    <h3>Ввод исходных данных</h3>
                    
                    <div class="dimension-controls">
                        <div class="form-group">
                            <label>Количество поставщиков:</label>
                            <input type="number" name="suppliers" id="suppliers" min="1" max="5" value="3">
                        </div>
                        <div class="form-group">
                            <label>Количество потребителей:</label>
                            <input type="number" name="consumers" id="consumers" min="1" max="5" value="3">
                        </div>
                        <button type="button" class="btn btn-update" onclick="updateMatrix()">Обновить таблицу</button>
                    </div>
                    
                    <div id="matrixContainer"></div>
                    
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
            <!-- ОТВЕТ -->
            <div class="giant-answer">
                <h2>✨ ОПТИМАЛЬНОЕ РЕШЕНИЕ ✨</h2>
                <div class="cost-value">{{result['best_cost']}} ден. ед.</div>
                <div class="cost-label">Минимальная стоимость перевозок</div>
            </div>
            
            <h2>Результаты решения</h2>
            
            <!-- Баланс -->
            <div class="theory-block">
                <h3>Проверка сбалансированности</h3>
                <p>Сумма запасов: Σaᵢ = {{result['total_supply']}}</p>
                <p>Сумма потребностей: Σbⱼ = {{result['total_demand']}}</p>
                % if result['balanced']:
                <p style="color:green;">✅ Задача сбалансирована (закрытая модель)</p>
                % else:
                <p style="color:orange;">⚠️ Задача несбалансирована, добавлены фиктивные участники</p>
                % end
            </div>
            
            <!-- Северо-западный угол -->
            <div class="result-box">
                <h3>Метод северо-западного угла</h3>
                % for step in result['northwest_steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} → {{step['formula']}} единиц
                </div>
                % end
                <table class="result-table">
                    <thead>
                        <tr><th></th>
                        % for col in range(result['consumers']):
                        <th>B{{col+1}}</th>
                        % end
                        <th>Запасы</th>
                    </tr>
                    </thead>
                    <tbody>
                    % for row in range(result['suppliers']):
                    <tr>
                        <th>A{{row+1}}</th>
                        % for col in range(result['consumers']):
                        <td><strong>{{ result['northwest_plan'][row][col] if result['northwest_plan'][row][col] > 0 else '-' }}</strong><br><small>(c={{result['costs'][row][col]}})</small></td>
                        % end
                        <td>{{ result['supply'][row] }}</td>
                    </tr>
                    % end
                    </tbody>
                </table>
                <p>{{result['northwest_degenerate']['message']}}</p>
                <div class="formula-detail"><strong>F = {{result['northwest_cost']}} ден. ед.</strong></div>
            </div>
            
            <!-- Минимальный элемент -->
            <div class="result-box">
                <h3>Метод минимального элемента</h3>
                % for step in result['mincost_steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} (тариф={{step['cost']}}) → {{step['formula']}} единиц
                </div>
                % end
                <table class="result-table">
                    <thead>
                        <tr><th></th>
                        % for col in range(result['consumers']):
                        <th>B{{col+1}}</th>
                        % end
                        <th>Запасы</th>
                    </tr>
                    </thead>
                    <tbody>
                    % for row in range(result['suppliers']):
                    <tr>
                        <th>A{{row+1}}</th>
                        % for col in range(result['consumers']):
                        <td><strong>{{ result['mincost_plan'][row][col] if result['mincost_plan'][row][col] > 0 else '-' }}</strong><br><small>(c={{result['costs'][row][col]}})</small></td>
                        % end
                        <td>{{ result['supply'][row] }}</td>
                    </tr>
                    % end
                    </tbody>
                </table>
                <p>{{result['mincost_degenerate']['message']}}</p>
                <div class="formula-detail"><strong>F = {{result['mincost_cost']}} ден. ед.</strong></div>
            </div>
            
            <!-- Метод потенциалов -->
            <div class="result-box optimal">
                <h3>Метод потенциалов (оптимизация)</h3>
                <p><strong>Оптимальный план получен при оптимизации плана метода {{result['best_method']}}</strong></p>
                
                % for iter_data in result['best_iterations']:
                <div class="iteration-block">
                    <h4>Итерация {{iter_data['iteration']}}</h4>
                    <p><strong>Потенциалы uᵢ:</strong> {{iter_data['potentials_u']}}</p>
                    <p><strong>Потенциалы vⱼ:</strong> {{iter_data['potentials_v']}}</p>
                    
                    <p><strong>Оценки свободных клеток:</strong></p>
                    <table class="result-table">
                        <thead><tr><th>Клетка</th><th>Формула</th><th>Оценка Δ</th></tr></thead>
                        <tbody>
                        % for d in iter_data['deltas']:
                        <tr style="background-color: {{'#ffeb3b' if d['is_positive'] else 'white'}}">
                            <td>{{d['cell']}}</td>
                            <td>{{d['formula']}}</td>
                            <td class="delta-positive">{{d['delta']}}</td>
                        </tr>
                        % end
                        </tbody>
                    </table>
                    
                    <p>{{iter_data['enter_explanation']}}</p>
                    <p><strong>{{iter_data['check_optimal']}}</strong></p>
                    
                    % if iter_data.get('cycle') and iter_data['cycle'].get('cells'):
                    <div style="margin-top: 15px; padding: 10px; background: #e8e8e8; border-radius: 8px;">
                        <p><strong>🔄 Построение цикла пересчёта:</strong></p>
                        <p><em>{{iter_data['cycle']['description']}}</em></p>
                        <p><strong>Цикл:</strong> 
                        % for idx, cell in enumerate(iter_data['cycle']['cells']):
                            {{cell['cell']}}<sup>{{cell['sign']}}</sup> {% if idx < len(iter_data['cycle']['cells']) - 1 %} → {% endif %}
                        % end
                        </p>
                        <p><strong>{{iter_data['cycle']['theta_explanation']}}</strong></p>
                        <p><strong>{{iter_data['cycle']['redistribution']}}</strong></p>
                        % if 'new_cost' in iter_data:
                        <p class="cost-decrease">💰 Новая стоимость: {{iter_data['new_cost']}} ден. ед.</p>
                        % end
                    </div>
                    % end
                </div>
                % end
                
                <h4>Оптимальный план перевозок</h4>
                <table class="result-table">
                    <thead>
                        <tr><th></th>
                        % for col in range(result['consumers']):
                        <th>B{{col+1}}</th>
                        % end
                        <th>Запасы</th>
                    </tr>
                    </thead>
                    <tbody>
                    % for row in range(result['suppliers']):
                    <tr>
                        <th>A{{row+1}}</th>
                        % for col in range(result['consumers']):
                        <td><strong>{{ result['best_plan'][row][col] if result['best_plan'][row][col] > 0 else '-' }}</strong></td>
                        % end
                        <td>{{ result['supply'][row] }}</td>
                    </tr>
                    % end
                    </tbody>
                </table>
                
                <div class="min-cost-highlight">
                    🚚 Минимальная стоимость перевозок: <span>{{result['best_cost']}} ден. ед.</span> 🚚
                </div>
            </div>
            % end
            
            <!-- ТЕОРИЯ -->
            <h2>📖 Теоретические основы</h2>
            
            <div class="theory-block">
                <h3>1. Постановка транспортной задачи</h3>
                <div class="theory-text">
                    <p><strong>Целевая функция:</strong> F = ΣᵢΣⱼ cᵢⱼ · xᵢⱼ → min</p>
                    <p><strong>Ограничения по запасам:</strong> Σⱼ xᵢⱼ = aᵢ</p>
                    <p><strong>Ограничения по потребностям:</strong> Σᵢ xᵢⱼ = bⱼ</p>
                    <p><strong>Условие неотрицательности:</strong> xᵢⱼ ≥ 0</p>
                    <p><strong>Закрытая модель:</strong> Σaᵢ = Σbⱼ</p>
                    <p><strong>Число базисных клеток:</strong> N = m + n - 1</p>
                </div>
                <div style="text-align: center;">
                    <img src="/static/images/formula_objective.png" class="formula-img" onerror="this.style.display='none'">
                    <img src="/static/images/formula_supply.png" class="formula-img" onerror="this.style.display='none'">
                    <img src="/static/images/formula_demand.png" class="formula-img" onerror="this.style.display='none'">
                    <img src="/static/images/formula_balance.png" class="formula-img" onerror="this.style.display='none'">
                </div>
            </div>
            
            <div class="theory-block">
                <h3>2. Методы построения опорного плана</h3>
                <div class="theory-text">
                    <p><strong>Метод северо-западного угла</strong> — заполнение с левой верхней клетки.</p>
                    <p><strong>Метод минимального элемента</strong> — выбор клетки с минимальным тарифом.</p>
                </div>
                <img src="/static/images/northwest_method.png" class="theory-img" onerror="this.style.display='none'">
                <img src="/static/images/mincost_method.png" class="theory-img" onerror="this.style.display='none'">
            </div>
            
            <div class="theory-block">
                <h3>3. Метод потенциалов</h3>
                <div class="theory-text">
                    <p><strong>Теорема:</strong> Если для базисных клеток βⱼ — αᵢ = cᵢⱼ, а для свободных βⱼ — αᵢ ≤ cᵢⱼ, то план оптимален.</p>
                    <p><strong>Оценка свободной клетки:</strong> Δᵢⱼ = αᵢ + βⱼ — cᵢⱼ</p>
                    <p><strong>Величина перераспределения:</strong> θ = min{xᵢⱼ} по клеткам со знаком «-»</p>
                    <p><strong>Цикл пересчёта</strong> — ломаная линия по базисным клеткам с чередованием знаков «+» и «-».</p>
                </div>
                <div style="text-align: center;">
                    <img src="/static/images/formula_basic_condition.png" class="formula-img" onerror="this.style.display='none'">
                    <img src="/static/images/formula_delta.png" class="formula-img" onerror="this.style.display='none'">
                    <img src="/static/images/formula_theta.png" class="formula-img" onerror="this.style.display='none'">
                </div>
                <img src="/static/images/cycle_example.png" class="theory-img" onerror="this.style.display='none'">
            </div>
            
            <div class="theory-block">
                <h3>4. Дополнительные ограничения</h3>
                <div class="theory-text">
                    <p><strong>Запрещённые маршруты:</strong> тариф = M</p>
                    <p><strong>Обязательные поставки:</strong> корректировка запасов</p>
                    <p><strong>Открытая модель:</strong> ввод фиктивного участника</p>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>5. Пример решения</h3>
                <div class="theory-text">
                    <p>Запасы: [80, 60, 30, 60], Потребности: [10, 30, 40, 50, 70, 30]</p>
                    <p>Сумма запасов = 230, сумма потребностей = 230 — задача сбалансирована.</p>
                </div>
                <div style="display: flex; flex-wrap: wrap; gap: 15px; justify-content: center;">
                    <img src="/static/images/example_iteration_1.png" class="theory-img" style="max-width: 200px;" onerror="this.style.display='none'">
                    <img src="/static/images/example_iteration2.png" class="theory-img" style="max-width: 200px;" onerror="this.style.display='none'">
                    <img src="/static/images/example_iteration3.png" class="theory-img" style="max-width: 200px;" onerror="this.style.display='none'">
                    <img src="/static/images/example_iteration4.png" class="theory-img" style="max-width: 200px;" onerror="this.style.display='none'">
                </div>
            </div>
            
            <div class="theory-block">
                <h3>📚 Литература</h3>
                <ul>
                    <li>Ваулин А.Е. Методы цифровой обработки данных. — СПб.: ВИККИ, 1993.</li>
                    <li>Таха Х.А. Введение в исследование операций. — М.: Вильямс, 2005.</li>
                    <li>Корбут А.А., Финкельштейн Ю.Ю. Дискретное программирование. — М.: Наука, 1969.</li>
                </ul>
            </div>
        </div>
        
        <!-- ПОЛЕЗНЫЕ СОВЕТЫ -->
        <div class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками используйте Tab</li>
                <li>Положительная оценка Δᵢⱼ → стоимость можно уменьшить</li>
                <li>Цикл пересчёта строится по базисным клеткам</li>
                <li>Количество базисных клеток = m + n - 1</li>
                <li>При несбалансированности добавляются фиктивные участники</li>
                <li>Метод минимального элемента даёт лучший начальный план</li>
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

    <!-- ПОДВАЛ -->
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
            var suppliers = parseInt(document.getElementById('suppliers').value);
            var consumers = parseInt(document.getElementById('consumers').value);
            var container = document.getElementById('matrixContainer');
            
            var html = '<div class="matrix-input"><h4>Матрица тарифов</h4><table class="result-table">';
            html += '<thead><tr><th></th>';
            for(var j = 1; j <= consumers; j++) {
                html += '<th>Потребитель ' + j + '</th>';
            }
            html += '<th>Запасы</th></tr></thead><tbody>';
            
            for(var i = 1; i <= suppliers; i++) {
                html += '<tr><th>Поставщик ' + i + '</th>';
                for(var j = 1; j <= consumers; j++) {
                    var saved = localStorage.getItem('cost_' + (i-1) + '_' + (j-1));
                    html += '<td><input type="number" name="cost_' + (i-1) + '_' + (j-1) + '" step="any" value="' + (saved || '0') + '" style="width:80px;"></td>';
                }
                var savedSupply = localStorage.getItem('supply_' + (i-1));
                html += '<td><input type="number" name="supply_' + (i-1) + '" step="any" value="' + (savedSupply || '0') + '" style="width:80px;"></td></tr>';
            }
            
            html += '<tr><th>Потребности</th>';
            for(var j = 1; j <= consumers; j++) {
                var savedDemand = localStorage.getItem('demand_' + (j-1));
                html += '<td><input type="number" name="demand_' + (j-1) + '" step="any" value="' + (savedDemand || '0') + '" style="width:80px;"><td>';
            }
            html += '<td>\n                <tr>\n            </tbody>\n        </table>\n    </div>';
            html += '<input type="hidden" name="suppliers" value="' + suppliers + '">';
            html += '<input type="hidden" name="consumers" value="' + consumers + '">';
            
            container.innerHTML = html;
            
            var inputs = document.querySelectorAll('#matrixContainer input');
            for(var k = 0; k < inputs.length; k++) {
                inputs[k].addEventListener('change', function() {
                    if(this.name) localStorage.setItem(this.name, this.value);
                });
            }
        }
        
        function clearForm() {
            var inputs = document.querySelectorAll('#matrixContainer input[type="number"]');
            for(var i = 0; i < inputs.length; i++) {
                inputs[i].value = '0';
                if(inputs[i].name) localStorage.removeItem(inputs[i].name);
            }
            updateMatrix();
        }
        
        function loadExample() {
            document.getElementById('suppliers').value = '3';
            document.getElementById('consumers').value = '3';
            updateMatrix();
            setTimeout(function() {
                var supplies = [70, 100, 110];
                var demands = [80, 50, 150];
                var costs = [[1,4,5],[3,5,2],[2,6,4]];
                for(var i = 0; i < 3; i++) {
                    var si = document.querySelector('[name="supply_' + i + '"]');
                    if(si) si.value = supplies[i];
                    var di = document.querySelector('[name="demand_' + i + '"]');
                    if(di) di.value = demands[i];
                    for(var j = 0; j < 3; j++) {
                        var ci = document.querySelector('[name="cost_' + i + '_' + j + '"]');
                        if(ci) ci.value = costs[i][j];
                    }
                }
            }, 50);
        }
        
        document.addEventListener('DOMContentLoaded', function() { updateMatrix(); });
    </script>
</body>
</html>