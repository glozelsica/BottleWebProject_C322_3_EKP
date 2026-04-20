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
            <div class="giant-answer">
                <h2>✨ ОПТИМАЛЬНОЕ РЕШЕНИЕ ✨</h2>
                <div class="cost-value">{{result['best_cost']}} ден. ед.</div>
                <div class="cost-label">Минимальная стоимость перевозок</div>
            </div>
            
            <h2>Результаты решения</h2>
            
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
            <h2>Теоретические основы</h2>
            
            <div class="theory-block">
                <h3>Постановка транспортной задачи</h3>
                <div class="theory-text">
                    <p>Транспортная задача является одним из наиболее важных частных случаев общей задачи линейного программирования, в силу специфики ее построения и области применения.Транспортная модель изначально предназначена для выбора наиболее экономного планирования грузопотоков и работы различных видов транспорта.</p>
                    <p>Пусть в пунктах  А1,А2,...,Аm производится некоторый продукт, причем объем производства в п. Аi составляет ai единиц,  . Произведенный продукт должен быть доставлен в пункты потребления В1,В2,...,Вn, причем объем потребления в п. Вj составляет bj единиц,  . Предполагается, что транспортировка готовой продукции возможна из любого пункта производства в любой пункт потребления, транспортные издержки на перевозку единицы продукции из п. Аi в п. Вj составляют Cij денежных единиц. Задача состоит в организации такого плана перевозок, при котором суммарные транспортные издержки были бы минимальными.</p>
                    <p><strong>ОПРЕДЕЛЕНИЕ 1.</strong> Если общая потребность в продукте в пунктах потребления равна общему запасу продукта в пунктах производства, то модель транспортной задачи называется закрытой. Если это условие не выполняется, то модель называется открытой.</p>
                     <div style="text-align: center;">
                    <img src="/static/images/formula_balance.png" class="formula-img" onerror="this.style.display='none'">
                    </div>
                    <p><strong>ТЕОРЕМА</strong> Для разрешимости транспортной задачи необходимо и достаточно, чтобы запасы продукта в пунктах производства были равны потребностям в пунктах потребления, т.е. чтобы выполнялось равенство.</p>
                    <p><strong>ЗАМЕЧАНИЯ</strong> 1. Если запас превышает потребность вводится фиктивный  (n+1)-й пункт потребления с потребностью, а соответствующие транспортные издержки равны нулю.</p>
                    <div style="display: flex; flex-wrap: wrap; gap: 15px; justify-content: center;">
                    <img src="/static/images/requirement.png" class="theory-img" style="max-width: 200px;" onerror="this.style.display='none'">
                    <img src="/static/images/fixed_point.png" class="theory-img" style="max-width: 200px;" onerror="this.style.display='none'">
                    <img src="/static/images/zero_costs.png" class="theory-img" style="max-width: 200px;" onerror="this.style.display='none'">
                    </div>
                    <p><strong>ОПРЕДЕЛЕНИЕ 2.</strong> Всякое неотрицательное решение системы линейных уравнений называется планом транспортной задачи.</p>
                    <p><strong>ОПРЕДЕЛЕНИЕ 3.</strong></p>
                    <p>Часто план транспортной задачи, с которого начинают решение, называют опорным. Число переменных xij в транспортной задаче с m пунктами производства и n пунктами потребления равно m n, а число уравнений в системе равно m+n. Т.к. предполагается, что выполняется условие, то число линейно независимых уравнений равно n+m-1. Следовательно, опорный план может иметь не более n+m-1 отличных от нуля неизвестных. Если в опорном плане число отличных от нуля компонент равно в точности n+m-1, то план является невырожденным, а если меньше, то вырожденным.</p>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Методы построения опорного плана</h3>
                <div class="theory-text">
                    <p><strong>Метод северо-западного угла</strong></p>
                    <p>Метод позволяет за n+m-1 шаг заполнить клетки таблицы таким образом, чтобы удовлетворить все потребности, исчерпав при этом все запасы. Заполнение клеток таблицы начинается с левой верхней клетки ("северо-западной"), в которую ставят максимально возможное число, т.е. минимальное из чисел запасов и потребностей для этой клетки. При этом исчерпываются либо запасы, либо потребности (вычеркивается строка или столбец), выбирается следующая «северо-западная» клетка и т.д.</p>
                    <p><strong>Метод минимального элемента</strong></p>
                    <p>Заполнение клеток осуществляется по принципу: "Самая дешевая перевозка осуществляется первой". Выбирается клетка с минимальным тарифом и заполняется максимально возможным числом, при этом исчерпываются либо запасы, либо потребности (вычеркивается строка или столбец), выбирается следующая клетка с минимальным тарифом и т.д.</p>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>3. Метод потенциалов</h3>
                <div class="theory-text">
                    <p>Общий принцип определения оптимального плана транспортной задачи методом потенциалов аналогичен принципу решения задачи линейного программирования симплекс-методом: сначала находят опорный план (начальное допустимое базисное решение), а затем его последовательно улучшают до получения оптимального. Рассмотрим три метода построения опорного плана. При заполнении клеток таблицы необходимо помнить, что суммы величин по столбцам и строкам должны соответствовать потребностям и запасам.</p>
                </div>
            </div>

             <div class="theory-block">
                <h3>Схема решения</h3>
                <div class="theory-text">
                    <p>1. Строят опорный план одним из методов.
                    2. Построенный опорный план следует проверить на оптимальность, для чего используют следующую теорему.</p>
                    <p><strong>ТЕОРЕМА</strong></p>
                    <div>
                        <img src="/static/images/theorem.png" class="theory-img" onerror="this.style.display='none'">
                    </div>
                    <p><strong>ОПРЕДЕЛЕНИЕ 4</strong> Числа называются потенциалами, поставщиков и потребителей</p>
                    <div>
                        <img src="/static/images/potential.png" class="theory-img" onerror="this.style.display='none'">
                    </div>
                    <p>Найдя потенциалы поставщиков и потребителей, удовлетворяющие условиям теоремы, мы докажем оптимальность построенного плана. 
Число заполненных клеток, xij > 0, равно n+m-1 (невырожденный план), то система с n+m неизвестными содержит n+m-1 уравнение. Положим одно из неизвестных равным нулю и последовательно найдем значения остальных неизвестных.</p>
                    <div>
                        <img src="/static/images/free_cells.png" class="theory-img" onerror="this.style.display='none'">
                    </div>
                    <p>Если среди чисел  нет положительных, то условия теоремы выполнены, и план является оптимальным. Если существует  > 0, то построенный план не оптимален, и его следует улучшить.</p>
                    <p>Алгоритм улучшения плана:
         1) среди всех  > 0 выбирают максимальное;
         2) для соответствующей клетки строят цикл пересчета;
         3) помечают вершины цикла пересчета последовательно знаками "+" и "-" ,
             начиная с "+" в исходной клетке;
         4) среди чисел, стоящих в клетках, помеченных "-" , определяют минимальное;
         5) к значениям, стоящим в "+"-клетках, прибавляют это минимальное число, а из 
             значений, стоящих в "-"-клетках, это число вычитают</p>
                    <p><strong>ОПРЕДЕЛЕНИЕ 5.</strong> Циклом пересчета называется ломаная линия, вершины которой расположены в занятых клетках, а звенья - вдоль строк и столбцов, причем в каждой вершине цикла может быть только два звена. Измененный таким образом план опять проверяют на оптимальность</p>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>5. Дополнительные ограничения</h3>
                <div class="theory-text">
                    <p><strong>Запрещённые маршруты:</strong> Если по каким-либо причинам невозможно поставлять продукцию из п. Аi в п. Вj, предполагают тариф этого пути сколь угодно большой величиной М, сij = М, и решают задачу обычным способом.</p>
                    <p><strong>Обязательные поставки:</strong></p>
                    <p>а) Если необходимо из п. Аi перевезти в п. Вj определенное количество продукции dij, соответствующую клетку заполняют сразу числом dij, а в дальнейшем решают задачу, считая заполненную клетку свободной, но с тарифом, сij = М, равным очень большому числу, а запасы    и потребности    уменьшают на величину dij.             б) Если необходимо из п. Аi в п. Вj перевезти не меньше определенного количества продукции  dij, то считают запасы  и потребности   меньше на величину  dij, это количество  dij считают перевезенным по маршруту Аi   Вj, и решают задачу далее обычным способом.
в) Если необходимо перевезти из п. Аi в п. Вj не более определенного количества продукции dij, вводят дополнительный пункт назначения с потребностью, равной (  - dij), потребность в п. Вj делают равной dij. Тарифы на перевозки в дополнительный пункт назначения равны тарифам п. Вj, кроме i-той строки, тариф в которой будет равен сколь угодно большому числу М. Решают задачу обычным образом, а при записи ответа объединяют основного и дополнительного потребителя (складывают содержимое столбцов).
</p>
                </div>
            </div>
            
            <div class="theory-block">
                <h3>Пример решения</h3>
                <div>
                    <img src="/static/images/cycle_example.png" class="theory-img" onerror="this.style.display='none'">
                </div>
                <div class="theory-text">
                    <p>Запасы: [80, 60, 30, 60], Потребности: [10, 30, 40, 50, 70, 30]</p>
                    <p>Сумма запасов = 230, сумма потребностей = 230 — задача сбалансирована.</p>
                </div>
                <p><strong>Решение.</strong></p>
                <p>Предварительный этап решения транспортной задачи сводится к определению ее типа, открытой она является или закрытой. Проверим необходимое и достаточное условие разрешимости задачи.</p>
                <p><strong>
                ∑a = 80 + 60 + 30 + 60 = 230

                ∑b = 10 + 30 + 40 + 50 + 70 + 30 = 230
                </strong></p>
                <p>Условие баланса соблюдается. Запасы равны потребностям. Модель транспортной задачи является закрытой. Если бы модель получилась открытой, то потребовалось бы вводить дополнительных поставщиков или потребителей.
На втором этапе осуществляется поиск опорного плана методами, приведенными выше (наиболее распространенным является метод наименьшей стоимости).
Для демонстрации алгоритма приведем лишь несколько итераций.
</p>
                <p><strong>Итерация 1.</strong> Минимальный элемент матрицы равен нулю. Для этого элемента запасы равны 60, потребности 30. Выбираем из них минимальное число 30 и вычитаем его. При этом из таблицы вычеркиваем шестой столбец (потребности у него равны 0).</p>
                <div>
                    <img src="/static/images/example_iteration_1.png" class="theory-img" onerror="this.style.display='none'">
                </div>
                <p><strong>Итерация 2.</strong> Снова ищем минимум (0). Из пары (60;50) выбираем минимальное число 50. Вычеркиваем пятый столбец.</p>
                <div>
                    <img src="/static/images/example_iteration2.png" class="theory-img" onerror="this.style.display='none'">
                </div>
                <p><strong>Итерация 3.</strong> Процесс продолжаем до тех пор, пока не выберем все потребности и запасы.</p>
                <p><strong>Итерация N.</strong> Искомый элемент равен 8. Для этого элемента запасы равны потребностям (40).</p>
                <div>
                    <img src="/static/images/example_iteration3.png" class="theory-img" onerror="this.style.display='none'">
                </div>
                <div>
                    <img src="/static/images/example_iteration4.png" class="theory-img" onerror="this.style.display='none'">
                </div>
                <p>Подсчитаем число занятых клеток таблицы, их 8, а должно быть m + n - 1 = 9. Следовательно, опорный план является вырожденным. Строим новый план. Иногда приходится строить несколько опорных планов, прежде чем найти не вырожденный.</p>
                <div>
                    <img src="/static/images/example_iteration_5.png" class="theory-img" onerror="this.style.display='none'">
                </div>
                <p>В результате получен первый опорный план, который является опустимым, так как число занятых клеток таблицы равно 9 и соответствует формуле m + n - 1 = 6 + 4 - 1 = 9, т.е. опорный план является невырожденным. 
Третий этап заключается в улучшении найденного опорного плана. Здесь используют метод потенциалов или распределительный метод. На этом этапе правильность решения можно контролировать через функцию стоимости F(x). Если она уменьшается (при условии минимизации затрат), то ход решения верный.
</p>
            </div>
            
            <div class="theory-block">
                <h3>Литература</h3>
                <ul>
                    <li>Ваулин А.Е. Методы цифровой обработки данных. — СПб.: ВИККИ, 1993.</li>
                    <li>Таха Х.А. Введение в исследование операций. — М.: Вильямс, 2005.</li>
                    <li>Корбут А.А., Финкельштейн Ю.Ю. Дискретное программирование. — М.: Наука, 1969.</li>
                </ul>
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
        function updateMatrix() {
            var suppliers = parseInt(document.getElementById('suppliers').value);
            var consumers = parseInt(document.getElementById('consumers').value);
            var container = document.getElementById('matrixContainer');
            
            var html = '<div class="matrix-input"><h4>Матрица тарифов</h4>';
            html += '<table class="result-table">';
            
            // Шапка
            html += '<thead><tr><th></th>';
            for (var j = 1; j <= consumers; j++) {
                html += '<th>Потребитель ' + j + '</th>';
            }
            html += '<th>Запасы</th></tr></thead>';
            
            // Тело
            html += '<tbody>';
            for (var i = 1; i <= suppliers; i++) {
                html += '<tr>';
                html += '<th>Поставщик ' + i + '</th>';
                for (var j = 1; j <= consumers; j++) {
                    var saved = localStorage.getItem('cost_' + (i-1) + '_' + (j-1));
                    if (saved === null) saved = '0';
                    html += '<td><input type="number" name="cost_' + (i-1) + '_' + (j-1) + '" step="any" value="' + saved + '" style="width:80px;"></td>';
                }
                var savedSupply = localStorage.getItem('supply_' + (i-1));
                if (savedSupply === null) savedSupply = '0';
                html += '<td><input type="number" name="supply_' + (i-1) + '" step="any" value="' + savedSupply + '" style="width:80px;"></td>';
                html += '</tr>';
            }
            
            // Строка потребностей
            html += '<tr>';
            html += '<th>Потребности</th>';
            for (var j = 1; j <= consumers; j++) {
                var savedDemand = localStorage.getItem('demand_' + (j-1));
                if (savedDemand === null) savedDemand = '0';
                html += '<td><input type="number" name="demand_' + (j-1) + '" step="any" value="' + savedDemand + '" style="width:80px;"></td>';
            }
            html += '<td></td>';
            html += '</tr>';
            
            html += '</tbody></table></div>';
            html += '<input type="hidden" name="suppliers" value="' + suppliers + '">';
            html += '<input type="hidden" name="consumers" value="' + consumers + '">';
            
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
        
        document.addEventListener('DOMContentLoaded', function() { updateMatrix(); });
    </script>
</body>
</html>