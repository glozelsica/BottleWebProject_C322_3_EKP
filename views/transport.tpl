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
    <header style="position: relative; overflow: hidden;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('/static/images/texture3.png'); background-size: cover; background-position: center; background-repeat: no-repeat; opacity: 0.4; pointer-events: none;"></div>
        <div style="position: relative; z-index: 1; display: flex; justify-content: space-between; align-items: center; padding: 1rem 2rem; flex-wrap: wrap;">
            <div class="logo" style="display: flex; align-items: center; gap: 0.5rem;">
                <img src="/static/images/logo.png" alt="Логотип приложения Математическое моделирование" style="height: 35px; width: 35px; object-fit: contain;" onerror="this.style.display='none'"> 
                <span style="color: white;">Математическое моделирование</span>
            </div>
            <nav style="display: flex; gap: 1.5rem; flex-wrap: wrap;">
                <a href="/" style="color: white; text-decoration: none;">Главная</a>
                <a href="/direct_lp" style="color: white; text-decoration: none;">Прямая ЗЛП</a>
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
            <h1>Транспортная задача</h1>
            
            <form method="post" action="/transport" id="transportForm" onsubmit="return validateForm()">
                <div class="form-section">
                    <h2>Ввод исходных данных</h2>
                    
                    <div class="dimension-controls">
                        <div class="form-group">
                            <label>Количество поставщиков:</label>
                            <input type="number" name="suppliers" id="suppliers" min="1" max="5" value="{{form_data.get('suppliers', 3)}}">
                        </div>
                        <div class="form-group">
                            <label>Количество потребителей:</label>
                            <input type="number" name="consumers" id="consumers" min="1" max="5" value="{{form_data.get('consumers', 3)}}">
                        </div>
                        <button type="button" class="btn btn-update" onclick="updateMatrix()">Обновить таблицу</button>
                    </div>
                    
                    <div id="matrixContainer"></div>
                    
                    <!-- Скрытые поля вынесены ЗА пределы таблицы (исправление ошибки валидации) -->
                    <input type="hidden" name="suppliers_hidden" id="suppliers_hidden" value="">
                    <input type="hidden" name="consumers_hidden" id="consumers_hidden" value="">
                    
                    <div class="button-group">
                        <button type="submit" class="btn btn-primary">Решить задачу</button>
                        <button type="button" class="btn btn-clear" onclick="clearForm()">Очистить</button>
                        <button type="button" class="btn btn-info" onclick="loadExample()">Загрузить пример</button>
                        % if result:
                        <button type="button" class="btn btn-success" onclick="exportToCSV()">Экспорт в CSV</button>
                        <button type="button" class="btn btn-success" onclick="exportToExcel()">Экспорт в Excel</button>
                        % end
                    </div>
                </div>
            </form>
            
            % if error:
            <div class="error-box"><strong>Ошибка:</strong> {{error}}</div>
            % end
            
            % if result:
            <div class="giant-answer">
                <h2>ОПТИМАЛЬНОЕ РЕШЕНИЕ</h2>
                <div class="cost-value">{{result['best_cost']}} ден. ед.</div>
                <div class="cost-label">Минимальная стоимость перевозок</div>
            </div>
            
            <h2>Результаты решения</h2>
            
            <div class="theory-block">
                <h3>Проверка сбалансированности</h3>
                <p>Сумма запасов: Σaᵢ = {{result['total_supply']}}</p>
                <p>Сумма потребностей: Σbⱼ = {{result['total_demand']}}</p>
                % if result['balanced']:
                <p style="color:green;">Задача сбалансирована (закрытая модель)</p>
                % else:
                <p style="color:orange;">Задача несбалансирована, добавлены фиктивные участники</p>
                % end
            </div>
            
            <div class="result-box">
                <h3>Метод северо-западного угла</h3>
                % for step in result['northwest_steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} → {{step['formula']}} единиц
                </div>
                % end
                <table class="result-table">
                    <thead>
                        <tr>
                            <th></th>
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
            
            <div class="result-box">
                <h3>Метод минимального элемента</h3>
                % for step in result['mincost_steps']:
                <div class="formula-detail">
                    <strong>Шаг {{step['step']}}:</strong> Клетка {{step['cell']}} (тариф={{step['cost']}}) → {{step['formula']}} единиц
                </div>
                % end
                <table class="result-table">
                    <thead>
                        <tr>
                            <th></th>
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
                <p><strong>Оптимальный план получен при оптимизации плана метода {{result.get('best_initial_name', result.get('best_method', 'неизвестного'))}}</strong></p>

                % for iter_data in result['best_iterations']:
                    % if iter_data.get('type') == 'comparison':
                        <div style="margin: 20px 0;">
                            {{!iter_data.get('html', '')}}
                        </div>
                    % elif iter_data.get('type') == 'iteration':
                        <div style="margin: 30px 0; padding: 20px; border-left: 4px solid #2196f3; background: #fafbfc; border-radius: 12px;">
                            <h3 style="color: #2196f3; margin: 0 0 15px 0;">ИТЕРАЦИЯ {{iter_data['iteration']}}</h3>
                            {{!iter_data.get('html', '')}}
                        </div>
                    % elif iter_data.get('type') == 'optimal':
                        <div style="margin: 30px 0; padding: 20px; border-left: 4px solid #28a745; background: #f0fff4; border-radius: 12px;">
                            <h3 style="color: #28a745; margin: 0 0 15px 0;">ЗАВЕРШЕНИЕ</h3>
                            {{!iter_data.get('html', '')}}
                        </div>
                    % elif iter_data.get('type') == 'error':
                        <div class="error-box" style="margin: 20px 0;">{{!iter_data.get('html', '')}}</div>
                    % end
                % end

                <h4>ОПТИМАЛЬНЫЙ ПЛАН ПЕРЕВОЗОК</h4>
                <table class="result-table">
                    <thead>
                        <tr>
                            <th></th>
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
                        <td><strong>{{ result['best_plan'][row][col] if result['best_plan'][row][col] > 0 else '—' }}</strong><br><small>(c={{result['costs'][row][col]}})</small></td>
                        % end
                        <td>{{ result['supply'][row] }}</td>
                    </tr>
                    % end
                    </tbody>
                </table>

                <div class="min-cost-highlight">
                    МИНИМАЛЬНАЯ СТОИМОСТЬ ПЕРЕВОЗОК: <span>{{result['best_cost']}} ден. ед.</span>
                </div>
            </div>
            % end
            
            <!-- ТЕОРИЯ -->
            <h2>Теоретические основы</h2>
            
            <div class="theory-block">
                <h3>1. Постановка транспортной задачи</h3>
                <div class="theory-text">
                    <p>Транспортная задача является одним из наиболее важных частных случаев общей задачи линейного программирования, в силу специфики ее построения и области применения. Транспортная модель изначально предназначена для выбора наиболее экономного планирования грузопотоков и работы различных видов транспорта.</p>
                    <p>Пусть в пунктах А₁, А₂, ..., Аₘ производится некоторый продукт, причем объем производства в п. Аᵢ составляет aᵢ единиц. Произведенный продукт должен быть доставлен в пункты потребления В₁, В₂, ..., Вₙ, причем объем потребления в п. Вⱼ составляет bⱼ единиц. Транспортные издержки на перевозку единицы продукции из п. Аᵢ в п. Вⱼ составляют Cᵢⱼ денежных единиц. Задача состоит в организации такого плана перевозок, при котором суммарные транспортные издержки были бы минимальными.</p>
                    <p><strong>ОПРЕДЕЛЕНИЕ 1.</strong> Если общая потребность в продукте в пунктах потребления равна общему запасу продукта в пунктах производства, то модель транспортной задачи называется закрытой. Если это условие не выполняется, то модель называется открытой.</p>
                     <div style="text-align: center;">
                    <img src="/static/images/formula_balance.png" class="formula-img" alt="Формула баланса: сумма запасов равна сумме потребностей" onerror="this.style.display='none'">
                    </div>
                    <p><strong>ТЕОРЕМА</strong> Для разрешимости транспортной задачи необходимо и достаточно, чтобы запасы продукта в пунктах производства были равны потребностям в пунктах потребления, т.е. чтобы выполнялось равенство.</p>
                    <p><strong>ЗАМЕЧАНИЯ</strong> 1. Если запас превышает потребность вводится фиктивный (n+1)-й пункт потребления с потребностью, а соответствующие транспортные издержки равны нулю.</p>
                    <div style="display: flex; flex-wrap: wrap; gap: 15px; justify-content: center;">
                    <img src="/static/images/requirement.png" class="theory-img" style="max-width: 200px;" alt="Иллюстрация условия баланса" onerror="this.style.display='none'">
                    <img src="/static/images/fixed_point.png" class="theory-img" style="max-width: 200px;" alt="Иллюстрация фиктивного пункта" onerror="this.style.display='none'">
                    <img src="/static/images/zero_costs.png" class="theory-img" style="max-width: 200px;" alt="Нулевые тарифы для фиктивных участников" onerror="this.style.display='none'">
                    </div>
                    <p><strong>ОПРЕДЕЛЕНИЕ 2.</strong> Всякое неотрицательное решение системы линейных уравнений называется планом транспортной задачи.</p>
                    <p><strong>ОПРЕДЕЛЕНИЕ 3.</strong></p>
                    <p>Часто план транспортной задачи, с которого начинают решение, называют опорным. Число переменных xij в транспортной задаче с m пунктами производства и n пунктами потребления равно m n, а число уравнений в системе равно m+n. Т.к. предполагается, что выполняется условие, то число линейно независимых уравнений равно n+m-1. Следовательно, опорный план может иметь не более n+m-1 отличных от нуля неизвестных. Если в опорном плане число отличных от нуля компонент равно в точности n+m-1, то план является невырожденным, а если меньше, то вырожденным.</p>
                    <p><strong>Целевая функция:</strong> F = ΣᵢΣⱼ cᵢⱼ · xᵢⱼ → min</p>
                    <p><strong>Ограничения по запасам:</strong> Σⱼ xᵢⱼ = aᵢ</p>
                    <p><strong>Ограничения по потребностям:</strong> Σᵢ xᵢⱼ = bⱼ</p>
                    <p><strong>Условие неотрицательности:</strong> xᵢⱼ ≥ 0</p>
                    <p><strong>Закрытая модель:</strong> Σaᵢ = Σbⱼ</p>
                    <p><strong>Число базисных клеток:</strong> N = m + n - 1</p>
                </div>
                <div style="text-align: center;">
                    <img src="/static/images/formula_supply.png" class="formula-img" alt="Формула ограничений по запасам" onerror="this.style.display='none'">
                    <img src="/static/images/formula_demand.png" class="formula-img" alt="Формула ограничений по потребностям" onerror="this.style.display='none'">
                </div>
            </div>
            
            <div class="theory-block">
                <h3>2. Методы построения опорного плана</h3>
                <div class="theory-text">
                    <p><strong>Метод северо-западного угла</strong></p>
                    <p>Метод позволяет за n+m-1 шаг заполнить клетки таблицы таким образом, чтобы удовлетворить все потребности, исчерпав при этом все запасы. Заполнение клеток таблицы начинается с левой верхней клетки ("северо-западной"), в которую ставят максимально возможное число, т.е. минимальное из чисел запасов и потребностей для этой клетки. При этом исчерпываются либо запасы, либо потребности (вычеркивается строка или столбец), выбирается следующая «северо-западная» клетка и т.д.</p>
                    <p><strong>Метод минимального элемента</strong></p>
                    <p>Заполнение клеток осуществляется по принципу: "Самая дешевая перевозка осуществляется первой". Выбирается клетка с минимальным тарифом и заполняется максимально возможным числом, при этом исчерпываются либо запасы, либо потребности (вычеркивается строка или столбец), выбирается следующая клетка с минимальным тарифом и т.д.</p>
                </div>
                <img src="/static/images/northwest_method.png" class="theory-img" alt="Иллюстрация метода северо-западного угла" onerror="this.style.display='none'">
                <img src="/static/images/mincost_method.png" class="theory-img" alt="Иллюстрация метода минимального элемента" onerror="this.style.display='none'">
            </div>
            
            <div class="theory-block">
                <h3>3. Метод потенциалов</h3>
                <div class="theory-text">
                    <p>Общий принцип определения оптимального плана транспортной задачи методом потенциалов аналогичен принципу решения задачи линейного программирования симплекс-методом: сначала находят опорный план (начальное допустимое базисное решение), а затем его последовательно улучшают до получения оптимального. Рассмотрим три метода построения опорного плана. При заполнении клеток таблицы необходимо помнить, что суммы величин по столбцам и строкам должны соответствовать потребностям и запасам.</p>
                    <p><strong>Теорема:</strong> Если для базисных клеток βⱼ — αᵢ = cᵢⱼ, а для свободных βⱼ — αᵢ ≤ cᵢⱼ, то план оптимален.</p>
                    <p><strong>Оценка свободной клетки:</strong> Δᵢⱼ = αᵢ + βⱼ — cᵢⱼ</p>
                    <p><strong>Величина перераспределения:</strong> θ = min{xᵢⱼ} по клеткам со знаком «-»</p>
                    <p><strong>Цикл пересчёта</strong> — ломаная линия по базисным клеткам с чередованием знаков «+» и «-».</p>
                </div>
                <div style="text-align: center;">
                    <img src="/static/images/formula_basic_condition.png" class="formula-img" alt="Условие для базисных клеток: u_i + v_j = c_ij" onerror="this.style.display='none'">
                    <img src="/static/images/formula_delta.png" class="formula-img" alt="Оценка свободной клетки: Δ_ij = u_i + v_j - c_ij" onerror="this.style.display='none'">
                    <img src="/static/images/formula_theta.png" class="formula-img" alt="Величина перераспределения: θ = min x_ij" onerror="this.style.display='none'">
                </div>
            </div>

             <div class="theory-block">
                <h3>4. Схема решения</h3>
                <div class="theory-text">
                    <p>1. Строят опорный план одним из методов.</p>
                    <p>2. Построенный опорный план следует проверить на оптимальность, для чего используют следующую теорему.</p>
                    <p><strong>ТЕОРЕМА</strong></p>
                    <div>
                        <img src="/static/images/theorem.png" class="theory-img" alt="Теорема о потенциалах" onerror="this.style.display='none'">
                    </div>
                    <p><strong>ОПРЕДЕЛЕНИЕ 4</strong> Числа называются потенциалами, поставщиков и потребителей</p>
                    <div>
                        <img src="/static/images/potential.png" class="theory-img" alt="Формула потенциалов" onerror="this.style.display='none'">
                    </div>
                    <p>Найдя потенциалы поставщиков и потребителей, удовлетворяющие условиям теоремы, мы докажем оптимальность построенного плана. 
Число заполненных клеток, xij > 0, равно n+m-1 (невырожденный план), то система с n+m неизвестными содержит n+m-1 уравнение. Положим одно из неизвестных равным нулю и последовательно найдем значения остальных неизвестных. Затем для всех свободных клеток, xij = 0, определим числа.</p>
                    <p><strong>ЗАМЕЧАНИЯ</strong> 1. Если запас превышает потребность вводится фиктивный (n+1)-й пункт потребления с потребностью, а соответствующие транспортные издержки равны нулю.</p>
                    <div style="display: flex; flex-wrap: wrap; gap: 15px; justify-content: center;">
                    <img src="/static/images/requirement.png" class="theory-img" style="max-width: 200px;" alt="Условие баланса" onerror="this.style.display='none'">
                    <img src="/static/images/fixed_point.png" class="theory-img" style="max-width: 200px;" alt="Фиктивный пункт" onerror="this.style.display='none'">
                    <img src="/static/images/zero_costs.png" class="theory-img" style="max-width: 200px;" alt="Нулевые тарифы" onerror="this.style.display='none'">
                    </div>
                    <p><strong>ОПРЕДЕЛЕНИЕ 5.</strong> Циклом пересчета называется ломаная линия, вершины которой расположены в занятых клетках, а звенья - вдоль строк и столбцов, причем в каждой вершине цикла может быть только два звена.</p>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>5. Дополнительные ограничения</h3>
                <div class="theory-text">
                    <p><strong>Запрещённые маршруты</strong></p>
                    <p>Если по каким-либо причинам невозможно поставлять продукцию из п. Аi в п. Вj , предполагают тариф этого пути сколь угодно большой величиной М, сij = М, и решают задачу обычным способом.</p>
                    <p><strong>Обязательные поставки:</strong></p>
                    <p>а) Если необходимо из п. Аi перевезти в п. Вj определенное количество продукции dij, соответствующую клетку заполняют сразу числом dij, а в дальнейшем решают задачу, считая заполненную клетку свободной, но с тарифом, сij = М, равным очень большому числу, а запасы    и потребности    уменьшают на величину dij. 
                    б) Если необходимо из п. Аi в п. Вj перевезти не меньше определенного количества продукции  dij, то считают запасы  и потребности   меньше на величину  dij, это количество  dij считают перевезенным по маршруту Аi   Вj, и решают задачу далее обычным способом.
                    в) Если необходимо перевезти из п. Аi в п. Вj не более определенного количества продукции dij, вводят дополнительный пункт назначения с потребностью, равной (  - dij), потребность в п. Вj делают равной dij. Тарифы на перевозки в дополнительный пункт назначения равны тарифам п. Вj, кроме i-той строки, тариф в которой будет равен сколь угодно большому числу М. Решают задачу обычным образом, а при записи ответа объединяют основного и дополнительного потребителя (складывают содержимое столбцов).
</p>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>6. Пример решения</h3>
                <div class="theory-text">
                    <p>Запасы: 80, 60, 30, 60. Потребности: 10, 30, 40, 50, 70, 30.</p>
                    <p>Сумма запасов = 230, сумма потребностей = 230 — задача сбалансирована.</p>
                    <div>
                    <img src="/static/images/cycle_example.png" class="theory-img" alt="Пример цикла перераспределения" onerror="this.style.display='none'">
                    </div>
                    <p>Предварительный этап решения транспортной задачи сводится к определению ее типа, открытой она является или закрытой. Проверим необходимое и достаточное условие разрешимости задачи.</p>
                    <p><strong>∑a = 80 + 60 + 30 + 60 = 230</strong></p>
                    <p><strong>∑b = 10 + 30 + 40 + 50 + 70 + 30 = 230</strong></p>
                    <p>Условие баланса соблюдается. Запасы равны потребностям. Модель транспортной задачи является закрытой. Если бы модель получилась открытой, то потребовалось бы вводить дополнительных поставщиков или потребителей.
На втором этапе осуществляется поиск опорного плана методами, приведенными выше (наиболее распространенным является метод наименьшей стоимости).
Для демонстрации алгоритма приведем лишь несколько итераций.
</p>
                    <p><strong>Итерация 1.</strong> Минимальный элемент матрицы равен нулю. Для этого элемента запасы равны 60, потребности 30. Выбираем из них минимальное число 30 и вычитаем его. При этом из таблицы вычеркиваем шестой столбец (потребности у него равны 0).</p>
                    <div>
                    <img src="/static/images/example_iteration_1.png" class="theory-img" alt="Пример итерации 1 метода минимального элемента" onerror="this.style.display='none'">
                    </div>
                    <p><strong>Итерация 2.</strong> Снова ищем минимум (0). Из пары (60;50) выбираем минимальное число 50. Вычеркиваем пятый столбец.</p>
                    <div>
                    <img src="/static/images/example_iteration2.png" class="theory-img" alt="Пример итерации 2 метода минимального элемента" onerror="this.style.display='none'">
                    </div>
                    <p><strong>Итерация 3.</strong> Процесс продолжаем до тех пор, пока не выберем все потребности и запасы.</p>
                    <p><strong>Итерация 4.</strong> Искомый элемент равен 8. Для этого элемента запасы равны потребностям (40).</p>
                    <div>
                    <img src="/static/images/example_iteration3.png" class="theory-img" alt="Пример итерации 3 метода минимального элемента" onerror="this.style.display='none'">
                    </div>
                    <div>
                    <img src="/static/images/example_iteration4.png" class="theory-img" alt="Пример итерации 4 метода минимального элемента" onerror="this.style.display='none'">
                    </div>
                    <p>Подсчитаем число занятых клеток таблицы, их 8, а должно быть m + n - 1 = 9. Следовательно, опорный план является вырожденным. Строим новый план. Иногда приходится строить несколько опорных планов, прежде чем найти не вырожденный.</p>
                    <div>
                    <img src="/static/images/example_iteration_5.png" class="theory-img" alt="Пример итерации 5 - невырожденный план" onerror="this.style.display='none'">
                    </div>
                    <p>В результате получен первый опорный план, который является опустимым, так как число занятых клеток таблицы равно 9 и соответствует формуле m + n - 1 = 6 + 4 - 1 = 9, т.е. опорный план является невырожденным. 
Третий этап заключается в улучшении найденного опорного плана. Здесь используют метод потенциалов или распределительный метод. На этом этапе правильность решения можно контролировать через функцию стоимости F(x). Если она уменьшается (при условии минимизации затрат), то ход решения верный.
</p>
                    </div>
                
            </div>
            
            <div class="theory-block">
                <h3>Литература</h3>
                <div style="padding-left: 1.5rem;">
                    <p>Ваулин А.Е. Методы цифровой обработки данных. — СПб.: ВИККИ, 1993.</p>
                    <p>Таха Х.А. Введение в исследование операций. — М.: Вильямс, 2005.</p>
                    <p>Корбут А.А., Финкельштейн Ю.Ю. Дискретное программирование. — М.: Наука, 1969.</p>
                </div>
            </div>
        </div>

        <div class="sidebar">
            <h3>Полезные советы</h3>
            <ul>
                <li>Для перехода между ячейками используйте Tab</li>
                <li>Положительная оценка Δᵢⱼ → стоимость можно уменьшить</li>
                <li>Цикл пересчёта строится по базисным клеткам</li>
                <li>Количество базисных клеток = m + n - 1</li>
                <li>При несбалансированности добавляются фиктивные участники</li>
                <li>Метод минимального элемента даёт лучший начальный план</li>
                <li>Вводите только положительные числа!</li>
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
        // Данные формы из Python
        var formSuppliers = {{form_data.get('suppliers', 3)}};
        var formConsumers = {{form_data.get('consumers', 3)}};
        var formSupply = [];
        var formDemand = [];
        var formCosts = [];
        
        // Заполняем supply
        % for val in form_data.get('supply', []):
        formSupply.push({{val}});
        % end
        
        // Заполняем demand
        % for val in form_data.get('demand', []):
        formDemand.push({{val}});
        % end
        
        // Заполняем costs
        % for row in form_data.get('costs', []):
        var rowArr = [];
        % for val in row:
        rowArr.push({{val}});
        % end
        formCosts.push(rowArr);
        % end
        
        var savedFormData = {
            suppliers: formSuppliers,
            consumers: formConsumers,
            supply: formSupply,
            demand: formDemand,
            costs: formCosts
        };
        
        // Данные для экспорта
        % if result:
        var exportBestCost = {{result['best_cost']}};
        var exportBestPlan = {{!result['best_plan']}};
        var exportNorthwestCost = {{result['northwest_cost']}};
        var exportMincostCost = {{result['mincost_cost']}};
        var exportSupplies = {{!result['supply']}};
        var exportDemands = {{!result['demand']}};
        var exportCosts = {{!result['costs']}};
        % end
        
        // Функция валидации формы (запрет отрицательных чисел)
        function validateForm() {
            // Обновляем скрытые поля перед отправкой
            document.getElementById('suppliers_hidden').value = document.getElementById('suppliers').value;
            document.getElementById('consumers_hidden').value = document.getElementById('consumers').value;
            
            var inputs = document.querySelectorAll('#matrixContainer input[type="number"]');
            for (var i = 0; i < inputs.length; i++) {
                var val = parseFloat(inputs[i].value);
                if (isNaN(val) || val < 0) {
                    alert('Ошибка: Все значения должны быть неотрицательными числами!');
                    inputs[i].focus();
                    return false;
                }
            }
            return true;
        }
        
        function updateMatrix() {
            var suppliers = parseInt(document.getElementById('suppliers').value);
            var consumers = parseInt(document.getElementById('consumers').value);
            var container = document.getElementById('matrixContainer');
            
            // Обновляем скрытые поля
            document.getElementById('suppliers_hidden').value = suppliers;
            document.getElementById('consumers_hidden').value = consumers;
            
            var html = '<div class="matrix-input"><h3>Матрица тарифов</h3>';
            html += '<table class="result-table">';
            html += '<thead><tr><th></th>';
            for (var j = 1; j <= consumers; j++) {
                html += '<th>Потребитель ' + j + '</th>';
            }
            html += '<th>Запасы</th></tr></thead>';
            html += '<tbody>';
            
            for (var i = 1; i <= suppliers; i++) {
                html += '<tr>';
                html += '<th>Поставщик ' + i + '</th>';
                for (var j = 1; j <= consumers; j++) {
                    var val = 0;
                    if (savedFormData.costs.length > i-1 && savedFormData.costs[i-1] && savedFormData.costs[i-1].length > j-1) {
                        val = savedFormData.costs[i-1][j-1];
                    } else {
                        var saved = localStorage.getItem('cost_' + (i-1) + '_' + (j-1));
                        val = (saved !== null && saved !== '0') ? saved : '0';
                    }
                    html += '<td><input type="number" name="cost_' + (i-1) + '_' + (j-1) + '" step="any" min="0" value="' + val + '" style="width:80px;"></td>';
                }
                var supplyVal = (savedFormData.supply.length > i-1 && savedFormData.supply[i-1] != 0) ? savedFormData.supply[i-1] : (localStorage.getItem('supply_' + (i-1)) || '0');
                html += '<td><input type="number" name="supply_' + (i-1) + '" step="any" min="0" value="' + supplyVal + '" style="width:80px;"></td>';
                html += '</td>';
            }
            
            html += '<tr>';
            html += '<th>Потребности</th>';
            for (var j = 1; j <= consumers; j++) {
                var demandVal = (savedFormData.demand.length > j-1 && savedFormData.demand[j-1] != 0) ? savedFormData.demand[j-1] : (localStorage.getItem('demand_' + (j-1)) || '0');
                html += '<td><input type="number" name="demand_' + (j-1) + '" step="any" min="0" value="' + demandVal + '" style="width:80px;"></td>';
            }
            html += '<td>\n                </tr>';
            html += '</tbody></table></div>';
            
            container.innerHTML = html;
            
            var inputs = document.querySelectorAll('#matrixContainer input');
            for (var k = 0; k < inputs.length; k++) {
                inputs[k].addEventListener('change', function() {
                    if (this.name) localStorage.setItem(this.name, this.value);
                });
            }
        }
        
        function clearForm() {
            var inputs = document.querySelectorAll('#matrixContainer input[type="number"]');
            for (var i = 0; i < inputs.length; i++) {
                inputs[i].value = '0';
                if (inputs[i].name) localStorage.removeItem(inputs[i].name);
            }
            savedFormData.supply = [];
            savedFormData.demand = [];
            savedFormData.costs = [];
            var supCount = parseInt(document.getElementById('suppliers').value);
            var consCount = parseInt(document.getElementById('consumers').value);
            for (var i = 0; i < supCount; i++) {
                savedFormData.supply.push(0);
            }
            for (var j = 0; j < consCount; j++) {
                savedFormData.demand.push(0);
            }
            updateMatrix();
        }
        
        function loadExample() {
            document.getElementById('suppliers').value = '3';
            document.getElementById('consumers').value = '3';
            
            var supplies = [70, 100, 110];
            var demands = [80, 50, 150];
            var costs = [[1,4,5],[3,5,2],[2,6,4]];
            
            savedFormData.supply = supplies;
            savedFormData.demand = demands;
            savedFormData.costs = costs;
            
            updateMatrix();
            
            setTimeout(function() {
                for (var i = 0; i < 3; i++) {
                    var si = document.querySelector('[name="supply_' + i + '"]');
                    if (si) si.value = supplies[i];
                    var di = document.querySelector('[name="demand_' + i + '"]');
                    if (di) di.value = demands[i];
                    for (var j = 0; j < 3; j++) {
                        var ci = document.querySelector('[name="cost_' + i + '_' + j + '"]');
                        if (ci) ci.value = costs[i][j];
                    }
                }
            }, 50);
        }
        
        function exportToCSV() {
            % if result:
            var bestCost = exportBestCost;
            var bestPlan = exportBestPlan;
            var northwestCost = exportNorthwestCost;
            var mincostCost = exportMincostCost;
            var supplies = exportSupplies;
            var demands = exportDemands;
            var costs = exportCosts;
    
            let csv = '\uFEFF';
            csv += 'Транспортная задача - Результаты решения\n\n';
            csv += 'Исходные данные\n';
            csv += 'Запасы поставщиков: ' + supplies.join(', ') + '\n';
            csv += 'Потребности потребителей: ' + demands.join(', ') + '\n\n';
    
            csv += 'Матрица тарифов\n';
            for (var i = 0; i < costs.length; i++) {
                csv += 'Поставщик ' + (i+1) + ': ' + costs[i].join(', ') + '\n';
            }
            csv += '\n';
    
            csv += 'Результаты методов\n';
            csv += 'Метод северо-западного угла: ' + northwestCost + ' ден. ед.\n';
            csv += 'Метод минимального элемента: ' + mincostCost + ' ден. ед.\n\n';
    
            csv += 'Оптимальный план перевозок (метод потенциалов)\n';
            csv += 'Стоимость: ' + bestCost + ' ден. ед.\n';
            csv += 'Матрица перевозок:\n';
            for (var i = 0; i < bestPlan.length; i++) {
                csv += 'Поставщик ' + (i+1) + ': ' + bestPlan[i].join(', ') + '\n';
            }
    
            var blob = new Blob([csv], {type: 'text/csv;charset=utf-8;'});
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'transport_solution.csv';
            link.click();
            URL.revokeObjectURL(link.href);
            % end
        }

        function exportToExcel() {
            % if result:
            var bestCost = exportBestCost;
            var bestPlan = exportBestPlan;
            var northwestCost = exportNorthwestCost;
            var mincostCost = exportMincostCost;
            var supplies = exportSupplies;
            var demands = exportDemands;
            var costs = exportCosts;
    
            let html = '<html><head><meta charset="UTF-8">';
            html += '<style>';
            html += 'body { font-family: "Segoe UI", Arial, sans-serif; margin: 20px; }';
            html += 'h1, h2, h3 { color: #9B2226; }';
            html += 'table { border-collapse: collapse; margin: 10px 0; }';
            html += 'th, td { border: 1px solid #999; padding: 8px; text-align: center; }';
            html += 'th { background-color: #EDE7F6; }';
            html += '</style>';
            html += '</head><body>';
            html += '<h1>Транспортная задача - Результаты решения</h1>';
    
            html += '<h2>Исходные данные</h2>';
            html += '<p><strong>Запасы поставщиков:</strong> ' + supplies.join(', ') + '</p>';
            html += '<p><strong>Потребности потребителей:</strong> ' + demands.join(', ') + '</p>';
    
            html += '<h3>Матрица тарифов</h3>';
            html += '<table border="1">';
            html += '<tr><th>Поставщик/Потребитель</th>';
            for (var j = 0; j < costs[0].length; j++) {
                html += '<th>B' + (j+1) + '</th>';
            }
            html += '<th>Запасы</th></tr>';
            for (var i = 0; i < costs.length; i++) {
                html += '<tr><th>A' + (i+1) + '</th>';
                for (var j = 0; j < costs[i].length; j++) {
                    html += '<td>' + costs[i][j] + '</td>';
                }
                html += '<td>' + supplies[i] + '</td></tr>';
            }
            html += '<tr><th>Потребности</th>';
            for (var j = 0; j < demands.length; j++) {
                html += '<td>' + demands[j] + '</td>';
            }
            html += '<td>\n                </tr>';
            html += '</table>';
    
            html += '<h2>Результаты методов</h2>';
            html += '<p><strong>Метод северо-западного угла:</strong> ' + northwestCost + ' ден. ед.</p>';
            html += '<p><strong>Метод минимального элемента:</strong> ' + mincostCost + ' ден. ед.</p>';
    
            html += '<h2>Оптимальный план перевозок (метод потенциалов)</h2>';
            html += '<p><strong>Минимальная стоимость:</strong> ' + bestCost + ' ден. ед.</p>';
            html += '<h3>Матрица перевозок</h3>';
            html += '<table border="1">';
            html += '<tr><th>Поставщик/Потребитель</th>';
            for (var j = 0; j < bestPlan[0].length; j++) {
                html += '<th>B' + (j+1) + '</th>';
            }
            html += '<th>Запасы</th></tr>';
            for (var i = 0; i < bestPlan.length; i++) {
                html += '<tr><th>A' + (i+1) + '</th>';
                for (var j = 0; j < bestPlan[i].length; j++) {
                    html += '<td>' + (bestPlan[i][j] > 0 ? bestPlan[i][j] : '-') + '</td>';
                }
                html += '<td>' + supplies[i] + '</td></tr>';
            }
            html += '</table>';
            html += '</body></html>';
    
            var blob = new Blob(['\uFEFF' + html], {type: 'application/vnd.ms-excel;charset=utf-8'});
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'transport_solution.xls';
            link.click();
            URL.revokeObjectURL(link.href);
            % end
        }
        
        document.addEventListener('DOMContentLoaded', function() { 
            updateMatrix(); 
        });
    </script>
</body>
</html>