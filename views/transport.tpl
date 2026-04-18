<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Транспортная задача</title>
    <link rel="icon" href="/static/images/logo.png" type="image/png">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #EDE7F6 0%, #d9cfe8 100%);
            color: #4a1a1a;
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        header {
            background: linear-gradient(135deg, #EDE7F6, #d9cfe8);
            color: #9B2226;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.3rem;
            font-weight: bold;
            color: #9B2226;
        }
        .logo-img {
            height: 40px;
            width: auto;
        }
        nav a {
            color: #9B2226;
            text-decoration: none;
            margin-left: 1.5rem;
            padding: 0.5rem 0;
            transition: 0.3s;
            font-weight: 500;
        }
        nav a:hover {
            border-bottom: 2px solid #9B2226;
        }
        .main-container {
            display: flex;
            max-width: 1400px;
            margin: 2rem auto;
            gap: 2rem;
            padding: 0 1rem;
            flex: 1;
        }
        .content {
            flex: 3;
            background: white;
            border-radius: 20px;
            padding: 1.5rem;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .sidebar {
            flex: 1;
            background: linear-gradient(135deg, #EDE7F6, #d9cfe8);
            border-radius: 20px;
            padding: 1.5rem;
            position: sticky;
            top: 1rem;
            height: fit-content;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .sidebar h3 {
            margin-bottom: 1rem;
            color: #9B2226;
        }
        .sidebar ul {
            list-style: none;
        }
        .sidebar li {
            margin-bottom: 0.8rem;
            font-size: 0.9rem;
        }
        .tip-box {
            background: #9B222620;
            padding: 1rem;
            border-radius: 12px;
            margin-top: 1.5rem;
            border-left: 4px solid #9B2226;
        }
        footer {
            background: linear-gradient(135deg, #9B2226, #6d181b);
            color: #EDE7F6;
            padding: 1.5rem;
            margin-top: 2rem;
            text-align: center;
        }
        .footer-content {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            max-width: 1400px;
            margin: 0 auto;
            gap: 2rem;
        }
        .question-btn {
            background: #EDE7F6;
            color: #9B2226;
            padding: 0.5rem 1.5rem;
            border-radius: 25px;
            text-decoration: none;
        }
        h1 {
            color: #9B2226;
            margin-bottom: 1rem;
        }
        h2 {
            color: #6d181b;
            margin: 1.5rem 0 1rem 0;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #dee2e6;
        }
        h3 {
            color: #9B2226;
            margin: 1rem 0 0.5rem 0;
        }
        .form-section {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
        }
        .form-group {
            margin-bottom: 1rem;
        }
        .form-group label {
            display: inline-block;
            width: 200px;
            font-weight: 500;
        }
        input[type="number"] {
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 14px;
        }
        input:focus {
            outline: none;
            border-color: #9B2226;
            box-shadow: 0 0 5px rgba(155,34,38,0.3);
        }
        .matrix-input {
            overflow-x: auto;
            margin: 1rem 0;
        }
        .matrix-input table {
            border-collapse: collapse;
            background: white;
            border-radius: 12px;
            overflow: hidden;
        }
        .matrix-input td, .matrix-input th {
            padding: 8px;
            border: 1px solid #ddd;
        }
        .matrix-input input {
            width: 80px;
            padding: 8px;
            text-align: center;
            border: 1px solid #ccc;
            border-radius: 6px;
        }
        .button-group {
            margin: 1.5rem 0;
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 1rem;
            transition: 0.3s;
            font-weight: bold;
        }
        .btn-primary {
            background: linear-gradient(135deg, #9B2226, #6d181b);
            color: white;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        .btn-info {
            background: #17a2b8;
            color: white;
        }
        .btn-success {
            background: #28a745;
            color: white;
        }
        .result-box {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            border-radius: 12px;
            padding: 1rem;
            margin: 1.5rem 0;
        }
        .error-box {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            border-radius: 12px;
            padding: 1rem;
            margin: 1rem 0;
            color: #721c24;
        }
        .theory-block {
            background: #EDE7F6;
            padding: 1rem;
            border-radius: 12px;
            margin: 1rem 0;
        }
        .iteration-block {
            background: #f8f9fa;
            border-left: 4px solid #9B2226;
            margin: 1rem 0;
            padding: 1rem;
            border-radius: 8px;
        }
        .delta-positive {
            color: #28a745;
            font-weight: bold;
        }
        .formula-detail {
            font-family: monospace;
            background: #e9ecef;
            padding: 0.5rem;
            border-radius: 4px;
            margin: 0.5rem 0;
        }
        .result-table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
        }
        .result-table th, .result-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: center;
        }
        .result-table th {
            background: linear-gradient(135deg, #EDE7F6, #d9cfe8);
            color: #9B2226;
        }
        .optimal {
            background: #d4edda;
            border: 1px solid #c3e6cb;
        }
        .dimension-controls {
            display: flex;
            gap: 1rem;
            align-items: center;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }
        kbd {
            background: #333;
            color: white;
            padding: 2px 6px;
            border-radius: 4px;
        }
        .theory-text {
            white-space: pre-line;
            line-height: 1.8;
        }
        .formula-text {
            font-family: monospace;
            background: #f4f4f4;
            padding: 8px;
            margin: 10px 0;
            border-radius: 6px;
            text-align: center;
            font-size: 1.1em;
        }
    </style>
</head>
<body>
    <header>
        <div class="logo">
            <img src="/static/images/logo.png" alt="Логотип" class="logo-img" onerror="this.style.display='none'"> 
            <span>Математическое моделирование</span>
        </div>
        <nav>
            <a href="/">Главная</a>
            <a href="/direct_lp">Прямая ЗЛП</a>
            <a href="/assignment">Назначения</a>
            <a href="/video">Видео</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>Транспортная задача</h1>
            
            <!-- Форма ввода -->
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
                        <button type="button" class="btn btn-secondary" onclick="updateMatrix()">Обновить таблицу</button>
                    </div>
                    
                    <div id="matrixContainer"></div>
                    
                    <div class="button-group">
                        <button type="submit" class="btn btn-primary">Решить задачу</button>
                        <button type="button" class="btn btn-secondary" onclick="clearForm()">Очистить</button>
                        <button type="button" class="btn btn-info" onclick="loadExample()">Загрузить пример</button>
                    </div>
                </div>
            </form>
            
            % if error:
            <div class="error-box">
                <strong>Ошибка:</strong> {{error}}
            </div>
            % end
            
            <!-- ========== РЕЗУЛЬТАТЫ РЕШЕНИЯ (сначала) ========== -->
            % if result:
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
            
            <!-- Метод северо-западного угла -->
            <div class="result-box">
                <h3>Метод северо-западного угла</h3>
                % for step in result['northwest_steps']['steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} → {{step['formula']}} единиц
                </div>
                % end
                
                <table class="result-table">
                    <tr><th></th>% for j in range(result['consumers']):<th>B{{j+1}}</th>% end<th>Запасы</th></tr>
                    % for i in range(result['suppliers']):
                    <tr><th>A{{i+1}}</th>% for j in range(result['consumers']):<td>{{ result['northwest_plan'][i][j] if result['northwest_plan'][i][j] > 0 else '-' }}</td>% end<td>{{ result['supply'][i] }}</td></tr>
                    % end
                </table>
                
                <p>Базисных клеток: {{result['northwest_steps']['basic_cells']}} (требуется {{result['northwest_steps']['expected_basic']}})</p>
                % if result['northwest_steps']['is_degenerate']:
                <p style="color:orange;">⚠️ План вырожденный</p>
                % else:
                <p style="color:green;">✅ План невырожденный</p>
                % end
                
                <div class="formula-detail">
                    % for calc in result['northwest_steps']['cost_calculation']:
                    {{calc}}<br>
                    % end
                    <strong>F = {{result['northwest_cost']}} ден. ед.</strong>
                </div>
            </div>
            
            <!-- Метод минимального элемента -->
            <div class="result-box">
                <h3>Метод минимального элемента</h3>
                % for step in result['mincost_steps']['steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} (тариф={{step['cost']}}) → {{step['formula']}} единиц
                </div>
                % end
                
                <table class="result-table">
                    <tr><th></th>% for j in range(result['consumers']):<th>B{{j+1}}</th>% end<th>Запасы</th></tr>
                    % for i in range(result['suppliers']):
                    <tr><th>A{{i+1}}</th>% for j in range(result['consumers']):<td>{{ result['mincost_plan'][i][j] if result['mincost_plan'][i][j] > 0 else '-' }}</td>% end<td>{{ result['supply'][i] }}</td></tr>
                    % end
                </table>
                
                <p>Базисных клеток: {{result['mincost_steps']['basic_cells']}} (требуется {{result['mincost_steps']['expected_basic']}})</p>
                % if result['mincost_steps']['is_degenerate']:
                <p style="color:orange;">⚠️ План вырожденный</p>
                % else:
                <p style="color:green;">✅ План невырожденный</p>
                % end
                
                <div class="formula-detail">
                    % for calc in result['mincost_steps']['cost_calculation']:
                    {{calc}}<br>
                    % end
                    <strong>F = {{result['mincost_cost']}} ден. ед.</strong>
                </div>
            </div>
            
            <!-- Сравнение -->
            <div class="theory-block">
                <h3>Сравнение начальных планов</h3>
                <p>Северо-западный угол: {{result['northwest_cost']}} ден. ед.</p>
                <p>Минимальный элемент: {{result['mincost_cost']}} ден. ед.</p>
                <p>Для оптимизации выбран план метода <strong>{{result['best_initial_name']}}</strong> (стоимость {{result['best_initial_cost']}} ден. ед.)</p>
            </div>
            
            <!-- Метод потенциалов -->
            <div class="result-box optimal">
                <h3>Метод потенциалов</h3>
                % for iter_data in result['optimal_iterations']:
                <div class="iteration-block">
                    <h4>Итерация {{iter_data['iteration']}}</h4>
                    <p><strong>Потенциалы uᵢ:</strong> {{iter_data['potentials_u']}}</p>
                    <p><strong>Потенциалы vⱼ:</strong> {{iter_data['potentials_v']}}</p>
                    
                    <table class="result-table">
                        <tr><th>Клетка</th><th>Формула</th><th>Оценка Δ</th></tr>
                        % for d in iter_data['deltas']:
                        <tr><td>{{d['cell']}}</td><td>{{d['formula']}}</td><td class="delta-positive">{{d['delta']}}</td></tr>
                        % end
                    </table>
                    
                    <p><strong>Максимальная Δ = {{iter_data['max_delta']}}</strong> в клетке {{iter_data['enter_cell']}}</p>
                    <p>{{iter_data['explanation']}}</p>
                    % if 'redistribution' in iter_data:
                    <p><strong>Перераспределение:</strong> {{iter_data['redistribution']}}</p>
                    <p><em>Цикл пересчёта — замкнутая ломаная линия по базисным клеткам, вершины чередуются со знаками «+» и «-».</em></p>
                    % end
                </div>
                % end
                
                <h4>Оптимальный план</h4>
                <table class="result-table">
                    <tr><th></th>% for j in range(result['consumers']):<th>B{{j+1}}</th>% end<th>Запасы</th></tr>
                    % for i in range(result['suppliers']):
                    <tr><th>A{{i+1}}</th>% for j in range(result['consumers']):<td><strong>{{ result['optimal_plan'][i][j] if result['optimal_plan'][i][j] > 0 else '-' }}</strong></td>% end<td>{{ result['supply'][i] }}</td></tr>
                    % end
                    <tr><th>Потребности</th>% for j in range(result['consumers']):<td>{{ result['demand'][j] }}</td>% end<td></td></tr>
                </table>
                
                <div class="formula-detail">
                    <strong>Минимальная стоимость: F_min = {{result['optimal_cost']}} ден. ед.</strong>
                </div>
            </div>
            
            <div class="button-group">
                <button class="btn btn-success" onclick="alert('Скопируйте таблицы в Excel')">Сохранить в Excel</button>
                <button class="btn btn-info" onclick="alert('Скопируйте таблицы в CSV')">Сохранить в CSV</button>
            </div>
            % end
            
            <!-- ========== ТЕОРИЯ (ПОСЛЕ решения) ========== -->
            <h2>📖 Теоретические основы</h2>
            
            % if theory:
            <!-- Раздел 1: Постановка задачи -->
            % if theory.get('sections') and theory['sections'][0]:
            <div class="theory-block">
                <h3>{{theory['sections'][0]['title']}}</h3>
                <div class="theory-text">{{theory['sections'][0]['content']}}</div>
                % if theory['sections'][0].get('formulas_text'):
                <div class="formula-text">
                    <strong>Основные формулы:</strong><br>
                    % for f in theory['sections'][0]['formulas_text']:
                    {{f}}<br>
                    % end
                </div>
                % end
            </div>
            % end
            
            <!-- Раздел 2: Метод потенциалов -->
            % if theory.get('sections') and len(theory['sections']) > 1:
            <div class="theory-block">
                <h3>{{theory['sections'][1]['title']}}</h3>
                <div class="theory-text">{{theory['sections'][1]['content']}}</div>
                % if theory['sections'][1].get('formulas_text'):
                <div class="formula-text">
                    <strong>Основные формулы:</strong><br>
                    % for f in theory['sections'][1]['formulas_text']:
                    {{f}}<br>
                    % end
                </div>
                % end
            </div>
            % end
            
            <!-- Раздел 3: Дополнительные ограничения -->
            % if theory.get('sections') and len(theory['sections']) > 2:
            <div class="theory-block">
                <h3>{{theory['sections'][2]['title']}}</h3>
                <div class="theory-text">{{theory['sections'][2]['content']}}</div>
            </div>
            % end
            
            <!-- Пример -->
            % if theory.get('example'):
            <div class="theory-block">
                <h3>{{theory['example']['title']}}</h3>
                <p>{{theory['example']['description']}}</p>
                <p><strong>Запасы:</strong> {{theory['example']['supply']}}</p>
                <p><strong>Потребности:</strong> {{theory['example']['demand']}}</p>
                <p><strong>Сумма запасов = Сумма потребностей = {{theory['example']['total_supply']}}</strong></p>
                <div class="theory-text">{{theory['example']['explanation']}}</div>
                % if theory['example'].get('images'):
                <div style="margin: 1rem 0;">
                    <p><strong>Иллюстрации к примеру:</strong></p>
                    % for img in theory['example']['images']:
                    <img src="{{img}}" alt="Итерация примера" style="max-width:100%; margin: 10px 0; border-radius: 8px;">
                    % end
                </div>
                % end
            </div>
            % end
            
            <!-- Литература -->
            % if theory.get('literature'):
            <div class="theory-block">
                <h3>📚 Литература</h3>
                <ul>
                % for lit in theory['literature']:
                    <li>{{lit}}</li>
                % end
                </ul>
            </div>
            % end
            % end
        </div>
        
        <div class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками используйте Tab</li>
                <li>Положительная оценка Δᵢⱼ означает, что стоимость можно уменьшить</li>
                <li>Цикл пересчёта строится только по базисным клеткам</li>
                <li>При несбалансированности добавляются фиктивные участники</li>
            </ul>
            <div class="tip-box">
                <strong>Видео-инструкция</strong>
                <a href="/video" class="btn btn-info" style="display:block; margin-top:10px;">Смотреть урок</a>
            </div>
        </div>
    </div>

    <footer>
        <div class="footer-content">
            <div class="footer-section">
                <h4>BottleWebProject_C322_3_EKP</h4>
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
    </footer>

    <script>
        function updateMatrix() {
            var suppliers = parseInt(document.getElementById('suppliers').value);
            var consumers = parseInt(document.getElementById('consumers').value);
            var container = document.getElementById('matrixContainer');
            
            var html = '<div class="matrix-input"><h4>Матрица тарифов</h4><table class="result-table">';
            html += '<tr><th></th>';
            for(var j = 1; j <= consumers; j++) {
                html += '<th>Потребитель ' + j + '</th>';
            }
            html += '<th>Запасы</th></tr>';
            
            for(var i = 1; i <= suppliers; i++) {
                html += '<tr><th>Поставщик ' + i + '</th>';
                for(var j = 1; j <= consumers; j++) {
                    var saved = localStorage.getItem('cost_' + (i-1) + '_' + (j-1));
                    if(saved === null) saved = '0';
                    html += '<td><input type="number" name="cost_' + (i-1) + '_' + (j-1) + '" step="any" value="' + saved + '" style="width:80px;"></td>';
                }
                var savedSupply = localStorage.getItem('supply_' + (i-1));
                if(savedSupply === null) savedSupply = '0';
                html += '<td><input type="number" name="supply_' + (i-1) + '" step="any" value="' + savedSupply + '" style="width:80px;"></td></tr>';
            }
            
            html += '<tr><th>Потребности</th>';
            for(var j = 1; j <= consumers; j++) {
                var savedDemand = localStorage.getItem('demand_' + (j-1));
                if(savedDemand === null) savedDemand = '0';
                html += '<td><input type="number" name="demand_' + (j-1) + '" step="any" value="' + savedDemand + '" style="width:80px;"></td>';
            }
            html += '<td>\n                </tr>\n            </table>\n        </div>';
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
            var inputs = document.querySelectorAll('input[type="number"]');
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
        
        document.addEventListener('DOMContentLoaded', function() {
            updateMatrix();
        });
    </script>
</body>
</html>