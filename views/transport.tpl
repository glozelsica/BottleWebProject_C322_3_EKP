<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Транспортная задача</title>
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<input type="hidden" name="suppliers" value="{{form_data.get('suppliers', 3)}}">
<input type="hidden" name="consumers" value="{{form_data.get('consumers', 3)}}">
<body>
    <header>
        <div class="logo">
            <span>Математическое моделирование</span>
        </div>
        <nav>
            <a href="/">Главная</a>
            <a href="/transport">Транспортная задача</a>
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
            
            % if result:
            <h2>Результаты решения</h2>
            
            <div class="theory-block">
                <h3>Проверка сбалансированности</h3>
                <p>Сумма запасов: Σaᵢ = {{result['total_supply']}}</p>
                <p>Сумма потребностей: Σbⱼ = {{result['total_demand']}}</p>
                % if result['balanced']:
                <p style="color:green;">✅ Задача сбалансирована (закрытая модель)</p>
                % else:
                <p style="color:orange;">⚠️ Задача несбалансирована</p>
                % end
            </div>
            
            <div class="result-box">
                <h3>Метод северо-западного угла</h3>
                % for step in result['northwest_steps']['steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} → {{step['formula']}} единиц
                </div>
                % end
                
                <table class="result-table">
                    <thead>
                        <tr><th></th>% for j in range(result['consumers']):<th>B{{j+1}}</th>% end<th>Запасы</th></tr>
                    </thead>
                    <tbody>
                    % for i in range(result['suppliers']):
                    <tr>
                        <th>A{{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td>{{ result['northwest_plan'][i][j] if result['northwest_plan'][i][j] > 0 else '-' }}</td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                    </tbody>
                </table>
                
                <p>Базисных клеток: {{result['northwest_steps']['basic_cells']}} (требуется {{result['northwest_steps']['expected_basic']}})</p>
                <div class="formula-detail">
                    % for calc in result['northwest_steps']['cost_calculation']:
                    {{calc}}<br>
                    % end
                    <strong>F = {{result['northwest_cost']}} ден. ед.</strong>
                </div>
            </div>
            
            <div class="result-box">
                <h3>Метод минимального элемента</h3>
                % for step in result['mincost_steps']['steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} (тариф={{step['cost']}}) → {{step['formula']}} единиц
                </div>
                % end
                
                <table class="result-table">
                    <thead>
                        <tr><th></th>% for j in range(result['consumers']):<th>B{{j+1}}</th>% end<th>Запасы</th></tr>
                    </thead>
                    <tbody>
                    % for i in range(result['suppliers']):
                    <tr>
                        <th>A{{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td>{{ result['mincost_plan'][i][j] if result['mincost_plan'][i][j] > 0 else '-' }}</td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                    </tbody>
                </table>
                
                <p>Базисных клеток: {{result['mincost_steps']['basic_cells']}} (требуется {{result['mincost_steps']['expected_basic']}})</p>
                <div class="formula-detail">
                    % for calc in result['mincost_steps']['cost_calculation']:
                    {{calc}}<br>
                    % end
                    <strong>F = {{result['mincost_cost']}} ден. ед.</strong>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Сравнение начальных планов</h3>
                <p>Северо-западный угол: {{result['northwest_cost']}} ден. ед.</p>
                <p>Минимальный элемент: {{result['mincost_cost']}} ден. ед.</p>
                <p>Для оптимизации выбран план метода <strong>{{result['best_initial_name']}}</strong> (стоимость {{result['best_initial_cost']}} ден. ед.)</p>
            </div>
            
            <div class="result-box optimal">
                <h3>Метод потенциалов</h3>
                % for iter_data in result['optimal_iterations']:
                <div class="iteration-block">
                    <h4>Итерация {{iter_data['iteration']}}</h4>
                    <p><strong>Потенциалы uᵢ:</strong> {{iter_data['potentials_u']}}</p>
                    <p><strong>Потенциалы vⱼ:</strong> {{iter_data['potentials_v']}}</p>
                    
                    <table class="result-table">
                        <thead>
                            <tr><th>Клетка</th><th>Формула</th><th>Оценка Δ</th></tr>
                        </thead>
                        <tbody>
                        % for d in iter_data['deltas']:
                        <tr>
                            <td>{{d['cell']}}</td>
                            <td>{{d['formula']}}</td>
                            <td class="delta-positive">{{d['delta']}}</td>
                        </tr>
                        % end
                        </tbody>
                    </table>
                    
                    <p><strong>Максимальная Δ = {{iter_data['max_delta']}}</strong> в клетке {{iter_data['enter_cell']}}</p>
                    <p>{{iter_data['explanation']}}</p>
                    % if 'redistribution' in iter_data:
                    <p><strong>Перераспределение:</strong> {{iter_data['redistribution']}}</p>
                    % end
                </div>
                % end
                
                <h4>Оптимальный план</h4>
                <table class="result-table">
                    <thead>
                        <tr><th></th>% for j in range(result['consumers']):<th>B{{j+1}}</th>% end<th>Запасы</th></tr>
                    </thead>
                    <tbody>
                    % for i in range(result['suppliers']):
                    <tr>
                        <th>A{{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td><strong>{{ result['optimal_plan'][i][j] if result['optimal_plan'][i][j] > 0 else '-' }}</strong></td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                    </tbody>
                </table>
                
                <div class="formula-detail">
                    <strong>Минимальная стоимость: F_min = {{result['optimal_cost']}} ден. ед.</strong>
                </div>
            </div>
            % end
            
            <!-- ТЕОРИЯ -->
<h2>📖 Теоретические основы</h2>

% if theory and theory.get('sections'):
    % for section in theory['sections']:
    <div class="theory-block">
        <h3>{{section['title']}}</h3>
        <div class="theory-text">{{!section['content'].replace('\n', '<br>')}}</div>
        % if section.get('formulas_text'):
        <div class="formula-text">
            <strong>Основные формулы:</strong><br>
            % for f in section['formulas_text']:
            {{f}}<br>
            % end
        </div>
        % end
    </div>
    % end
    
    % if theory.get('example'):
    <div class="theory-block">
        <h3>{{theory['example']['title']}}</h3>
        <p>{{theory['example']['description']}}</p>
        <p><strong>Запасы:</strong> {{theory['example']['supply']}}</p>
        <p><strong>Потребности:</strong> {{theory['example']['demand']}}</p>
        <div class="theory-text">{{!theory['example']['explanation'].replace('\n', '<br>')}}</div>
    </div>
    % end
    
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
% else:
<div class="theory-block">
    <p>Теоретический материал временно недоступен. Проверьте наличие файла data/theory_transport.json</p>
</div>
% end
        
        <div class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками используйте Tab</li>
                <li>Положительная оценка Δᵢⱼ означает, что стоимость можно уменьшить</li>
                <li>Цикл пересчёта строится только по базисным клеткам</li>
                <li>Количество базисных клеток = m + n - 1</li>
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
                <h4>{{year}}</h4>
                <p>Учебная практика УП02</p>
                <p>ПМ02 «Интеграция программных модулей»</p>
            </div>
            <div class="footer-section">
                <h4>Связь</h4>
                <a href="/contact" class="question-btn">Задать вопрос</a>
            </div>
        </div>
        <div class="footer-bottom">
            <p>© {{year}} Математическое моделирование. Все права защищены.</p>
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
            html += '<td></td></tr>';
            html += '</tbody></table></div>';
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