<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Транспортная задача</title>
    <link rel="icon" href="/static/images/logo.png" type="image/png">
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <!-- КРАСИВАЯ ШАПКА С ТЕКСТУРОЙ -->
    <header class="header-with-texture">
        <div class="header-texture"></div>
        <div class="header-content">
            <div class="logo">
                <img src="/static/images/logo.png" alt="Логотип" class="logo-img" onerror="this.style.display='none'"> 
                <span>Математическое моделирование</span>
            </div>
            <nav>
                <a href="/">Главная</a>
                <a href="/transport">Транспортная</a>
                <a href="/direct_lp">Прямая ЗЛП</a>
                <a href="/assignment">Назначения</a>
                <a href="/video">Видео</a>
                <a href="/authors">Об авторах</a>
                <a href="/contact">Контакты</a>
            </nav>
        </div>
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
                            <input type="number" name="suppliers" id="suppliers" min="1" max="5" value="{{form_data.get('suppliers', 3)}}">
                        </div>
                        <div class="form-group">
                            <label>Количество потребителей:</label>
                            <input type="number" name="consumers" id="consumers" min="1" max="5" value="{{form_data.get('consumers', 3)}}">
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
            
            <!-- Проверка баланса -->
            <div class="theory-block">
                <h3>Проверка сбалансированности</h3>
                <p>Сумма запасов: Σaᵢ = {{result['total_supply']}}</p>
                <p>Сумма потребностей: Σbⱼ = {{result['total_demand']}}</p>
                % if result['balanced']:
                <p style="color:green;">✅ Задача сбалансирована (закрытая модель)</p>
                % else:
                <p style="color:orange;">⚠️ Задача несбалансирована, требуется введение фиктивного участника</p>
                % end
            </div>
            
            <!-- Метод северо-западного угла -->
            <div class="result-box">
                <h3>Метод северо-западного угла</h3>
                <p><strong>Пошаговое построение опорного плана:</strong></p>
                % for step in result['northwest_steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} → {{step['formula']}} единиц
                </div>
                % end
                
                <p><strong>Полученный опорный план:</strong></p>
                <table class="result-table">
                    <thead>
                        <tr><th></th>
                        % for j in range(result['consumers']):
                        <th>B{{j+1}}</th>
                        % end
                        <th>Запасы</th>
                    </tr>
                    </thead>
                    <tbody>
                    % for i in range(result['suppliers']):
                    <tr>
                        <th>A{{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td style="background-color: {{'#e8f5e9' if result['northwest_plan'][i][j] > 0 else 'white'}}">
                            <strong>{{ result['northwest_plan'][i][j] if result['northwest_plan'][i][j] > 0 else '-' }}</strong>
                            <br><small>(c={{result['costs'][i][j]}})</small>
                        </td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                    <tr>
                        <th>Потребности</th>
                        % for j in range(result['consumers']):
                        <td>{{ result['demand'][j] }}</td>
                        % end
                        <td>\n                </td>
                    </tbody>
                </table>
                
                <p>{{result['northwest_degenerate']['message']}}</p>
                
                <p><strong>Расчет стоимости перевозок:</strong></p>
                <div class="formula-detail">
                    <strong>F = {{result['northwest_cost']}} ден. ед.</strong>
                </div>
            </div>
            
            <!-- Метод минимального элемента -->
            <div class="result-box">
                <h3>Метод минимального элемента</h3>
                <p><strong>Пошаговое построение опорного плана:</strong></p>
                % for step in result['mincost_steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} (тариф={{step['cost']}}) → {{step['formula']}} единиц
                </div>
                % end
                
                <p><strong>Полученный опорный план:</strong></p>
                <table class="result-table">
                    <thead>
                        <tr><th></th>
                        % for j in range(result['consumers']):
                        <th>B{{j+1}}</th>
                        % end
                        <th>Запасы</th>
                    <tr>
                    </thead>
                    <tbody>
                    % for i in range(result['suppliers']):
                    <tr>
                        <th>A{{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td style="background-color: {{'#e8f5e9' if result['mincost_plan'][i][j] > 0 else 'white'}}">
                            <strong>{{ result['mincost_plan'][i][j] if result['mincost_plan'][i][j] > 0 else '-' }}</strong>
                            <br><small>(c={{result['costs'][i][j]}})</small>
                        </td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                    <tr>
                        <th>Потребности</th>
                        % for j in range(result['consumers']):
                        <td>{{ result['demand'][j] }}</td>
                        % end
                        <td>\n                </tr>
                    </tbody>
                </table>
                
                <p>{{result['mincost_degenerate']['message']}}</p>
                
                <p><strong>Расчет стоимости перевозок:</strong></p>
                <div class="formula-detail">
                    <strong>F = {{result['mincost_cost']}} ден. ед.</strong>
                </div>
            </div>
            
            <!-- Метод потенциалов -->
            <div class="result-box optimal">
                <h3>Метод потенциалов (оптимизация)</h3>
                <p><strong>Оптимальный план получен при оптимизации плана метода {{result['best_method']}}</strong></p>
                
                % for iter_data in result['best_iterations']:
                <div class="iteration-block">
                    <h4>Итерация {{iter_data['iteration']}}</h4>
                    <p><strong>Потенциалы поставщиков uᵢ:</strong> {{iter_data['potentials_u']}}</p>
                    <p><strong>Потенциалы потребителей vⱼ:</strong> {{iter_data['potentials_v']}}</p>
                    <p><em>{{iter_data.get('potentials_explanation', '')}}</em></p>
                    
                    <p><strong>Оценки свободных клеток Δᵢⱼ = uᵢ + vⱼ - cᵢⱼ:</strong></p>
                    <table class="result-table">
                        <thead>
                            <tr><th>Клетка</th><th>Формула</th><th>Оценка Δ</th></tr>
                        </thead>
                        <tbody>
                        % for d in iter_data['deltas']:
                        <tr style="background-color: {{'#ffeb3b' if d['delta'] > 0 else 'white'}}">
                            <td>{{d['cell']}}</td>
                            <td>{{d['formula']}}</td>
                            <td class="delta-positive">{{d['delta']}}</td>
                        </tr>
                        % end
                        </tbody>
                    </table>
                    
                    <p><strong>{{iter_data['enter_explanation']}}</strong></p>
                    <p>{{iter_data['check_optimal']}}</p>
                    
                    % if 'cycle' in iter_data:
                    <p><strong>Построение цикла пересчёта:</strong></p>
                    <p><em>{{iter_data['cycle']['description']}}</em></p>
                    <p><strong>Цикл:</strong> 
                        % for cell in iter_data['cycle']['cells']:
                            {{cell['cell']}}<sup>{{cell['sign']}}</sup> → 
                        % end
                    </p>
                    <p><strong>{{iter_data['cycle']['theta_explanation']}}</strong></p>
                    <p><strong>{{iter_data['cycle']['redistribution']}}</strong></p>
                    % end
                </div>
                % end
                
                <h4>Оптимальный план перевозок</h4>
                <table class="result-table">
                    <thead>
                        <tr><th></th>
                        % for j in range(result['consumers']):
                        <th>B{{j+1}}</th>
                        % end
                        <th>Запасы</th>
                    </tr>
                    </thead>
                    <tbody>
                    % for i in range(result['suppliers']):
                    <tr>
                        <th>A{{i+1}}</th>
                        % for j in range(result['consumers']):
                        <td><strong>{{ result['best_plan'][i][j] if result['best_plan'][i][j] > 0 else '-' }}</strong></td>
                        % end
                        <td>{{ result['supply'][i] }}</td>
                    </tr>
                    % end
                    </tbody>
                </table>
                <div class="formula-detail">
                    <strong>Минимальная стоимость: F_min = {{result['best_cost']}} ден. ед.</strong>
                </div>
            </div>
            % end
            
            <!-- ТЕОРИЯ (МИНИМАЛЬНЫЙ ТЕКСТ ПРЯМО В TPL) -->
            <h2>📖 Теоретические основы</h2>
            
            <div class="theory-block">
                <h3>1. Постановка транспортной задачи. Закрытая модель</h3>
                <div class="theory-text">
                    Транспортная задача является одним из наиболее важных частных случаев общей задачи линейного программирования.
                    <br><br>
                    <strong>Целевая функция (минимизация стоимости перевозок):</strong> F = ΣᵢΣⱼ cᵢⱼ · xᵢⱼ → min
                    <br><br>
                    <strong>Ограничения по запасам поставщиков:</strong> Σⱼ xᵢⱼ = aᵢ, i = 1..m
                    <br>
                    <strong>Ограничения по потребностям потребителей:</strong> Σᵢ xᵢⱼ = bⱼ, j = 1..n
                    <br>
                    <strong>Условие неотрицательности переменных:</strong> xᵢⱼ ≥ 0
                    <br><br>
                    <strong>ОПРЕДЕЛЕНИЕ:</strong> Если общая потребность в продукте в пунктах потребления равна общему запасу продукта в пунктах производства, т.е. Σaᵢ = Σbⱼ, то модель транспортной задачи называется <strong>закрытой</strong>.
                    <br><br>
                    <strong>ТЕОРЕМА:</strong> Для разрешимости транспортной задачи необходимо и достаточно, чтобы выполнялось равенство Σaᵢ = Σbⱼ.
                    <br><br>
                    <strong>Число базисных клеток в невырожденном плане:</strong> N = m + n - 1
                </div>
                <div class="formula-text">
                    <strong>Основные формулы:</strong><br>
                    F = ΣᵢΣⱼ cᵢⱼ · xᵢⱼ → min<br>
                    Σⱼ xᵢⱼ = aᵢ, i = 1..m<br>
                    Σᵢ xᵢⱼ = bⱼ, j = 1..n<br>
                    Σaᵢ = Σbⱼ (закрытая модель)<br>
                    N = m + n - 1
                </div>
            </div>
            
            <div class="theory-block">
                <h3>2. Метод потенциалов</h3>
                <div class="theory-text">
                    Метод потенциалов используется для проверки оптимальности опорного плана и его улучшения.
                    <br><br>
                    <strong>Методы построения опорного плана:</strong>
                    <br>
                    а) <strong>Метод северо-западного угла</strong> - заполнение начинается с левой верхней клетки.
                    <br>
                    б) <strong>Метод минимального элемента</strong> - выбирается клетка с минимальным тарифом.
                    <br><br>
                    <strong>Схема решения методом потенциалов:</strong>
                    <br>
                    1. Строят опорный план одним из методов.
                    <br>
                    2. Находят потенциалы поставщиков (αᵢ) и потребителей (βⱼ).
                    <br>
                    3. Вычисляют оценки свободных клеток Δᵢⱼ = αᵢ + βⱼ - cᵢⱼ.
                    <br>
                    4. Если все Δᵢⱼ ≤ 0, план оптимален.
                    <br>
                    5. Если есть Δᵢⱼ > 0, строят цикл пересчёта и улучшают план.
                    <br><br>
                    <strong>Алгоритм улучшения плана:</strong>
                    <br>
                    1) Среди всех Δᵢⱼ > 0 выбирают максимальное.
                    <br>
                    2) Для соответствующей клетки строят цикл пересчета.
                    <br>
                    3) Помечают вершины цикла знаками «+» и «-», начиная с «+».
                    <br>
                    4) Среди чисел в клетках со знаком «-» определяют минимальное (θ).
                    <br>
                    5) К «+»-клеткам прибавляют θ, из «-»-клеток вычитают θ.
                    <br><br>
                    <strong>ОПРЕДЕЛЕНИЕ:</strong> Циклом пересчета называется ломаная линия, вершины которой расположены в занятых клетках, а звенья — вдоль строк и столбцов.
                </div>
                <div class="formula-text">
                    <strong>Основные формулы:</strong><br>
                    αᵢ + βⱼ = cᵢⱼ (для базисных клеток)<br>
                    Δᵢⱼ = αᵢ + βⱼ - cᵢⱼ<br>
                    θ = min{xᵢⱼ} по клеткам со знаком «-»
                </div>
            </div>
            
            <div class="theory-block">
                <h3>3. Дополнительные ограничения транспортной задачи</h3>
                <div class="theory-text">
                    <strong>1. Запрещенные маршруты.</strong> Если по каким-либо причинам невозможно поставлять продукцию из п. Аᵢ в п. Вⱼ, тариф принимают равным большому числу М.
                    <br><br>
                    <strong>2. Обязательные поставки.</strong> Если необходимо перевезти определенное количество продукции, соответствующую клетку заполняют сразу, а запасы и потребности уменьшают.
                    <br><br>
                    <strong>3. Открытая модель.</strong> При несбалансированности (Σaᵢ ≠ Σbⱼ) вводят фиктивного поставщика или потребителя с нулевыми тарифами.
                </div>
            </div>
            
            <div class="theory-block">
                <h3>📚 Литература</h3>
                <ul>
                    <li>Ваулин А.Е. Методы цифровой обработки данных. — СПб.: ВИККИ, 1993.</li>
                    <li>Таха Х.А. Введение в исследование операций. 7-е изд. — М.: Вильямс, 2005.</li>
                    <li>Корбут А.А., Финкельштейн Ю.Ю. Дискретное программирование. — М.: Наука, 1969.</li>
                </ul>
            </div>
        </div>
        
        <!-- ПОЛЕЗНЫЕ СОВЕТЫ (СПРАВА) -->
        <div class="sidebar">
            <h3>💡 Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками используйте Tab</li>
                <li>Положительная оценка Δᵢⱼ означает, что стоимость можно уменьшить</li>
                <li>Цикл пересчёта строится только по базисным клеткам</li>
                <li>Количество базисных клеток = m + n - 1</li>
                <li>При несбалансированности добавляются фиктивные участники</li>
                <li>Метод минимального элемента обычно даёт лучший начальный план</li>
                <li>Потенциалы находятся из системы uᵢ + vⱼ = cᵢⱼ для базисных клеток</li>
            </ul>
            <div class="tip-box">
                <strong>🎥 Видео-инструкция</strong>
                <p style="margin-top: 10px;">Подробное объяснение метода потенциалов</p>
                <a href="/video" class="btn btn-info" style="display:block; margin-top:10px;">Смотреть урок</a>
            </div>
            <div class="tip-box" style="margin-top: 15px;">
                <strong>📖 Тестовый пример</strong>
                <p style="margin-top: 10px;">Нажмите "Загрузить пример" для быстрого тестирования</p>
            </div>
        </div>
    </div>

    <!-- КРАСИВЫЙ ПОДВАЛ (ВНИЗУ) -->
    <footer class="footer-main">
        <div class="footer-content">
            <div class="footer-section">
                <h4>BottleWebProject_C322_3_EKP</h4>
                <p>Команда №3 | Егармина, Корнилов, Потылицына</p>
                <p>Группа C322 | ГУАП ФСПО №12</p>
            </div>
            <div class="footer-section">
                <h4>{{year if 'year' in locals() else '2026'}}</h4>
                <p>Учебная практика УП02</p>
                <p>ПМ02 «Интеграция программных модулей»</p>
            </div>
            <div class="footer-section">
                <h4>Связь</h4>
                <a href="/contact" class="question-btn">Задать вопрос</a>
            </div>
        </div>
        <div class="footer-bottom">
            <p>© {{year if 'year' in locals() else '2026'}} Математическое моделирование. Все права защищены.</p>
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
        
        document.addEventListener('DOMContentLoaded', function() {
            updateMatrix();
        });
    </script>
</body>
</html>