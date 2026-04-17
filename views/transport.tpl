% rebase('base', content_template='transport_content')

<!-- Этот файл будет вставлен в content блок base.tpl -->
<h1>🚚 Транспортная задача</h1>

<!-- Полная теория -->
<div class="theory-block">
    <h2>📖 {{theory.get('title', 'Транспортная задача')}}</h2>
    <p>{{theory.get('full_theory', '')}}</p>
    
    <h3>📌 Этапы решения:</h3>
    % for step in theory.get('steps', []):
    <div class="theory-step">
        <strong>{{step.get('name', '')}}</strong>
        <p>{{step.get('description', '')}}</p>
    </div>
    % end
    
    <div class="theory-image">
        <img src="/static/transport_scheme.png" alt="Схема транспортной задачи" style="max-width:100%;">
    </div>
</div>

<!-- Форма ввода данных -->
<form method="post" action="/transport" id="transportForm">
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
            <button type="button" class="btn btn-secondary" onclick="clearForm()">Очистить все поля</button>
            <button type="button" class="btn btn-info" onclick="loadExample()">Загрузить пример</button>
        </div>
    </div>
</form>

% if error:
<div class="error-box">
    <strong>❌ Ошибка:</strong> {{error}}
</div>
% end

% if result:
<!-- Результаты решения -->
<h2>📊 Результаты решения</h2>

<!-- Шаг 1: Метод северо-западного угла -->
<div class="result-box">
    <h3>Шаг 1: Метод северо-западного угла</h3>
    <p><strong>Стоимость перевозок:</strong> {{result['northwest_cost']}}</p>
    <table border="1" cellpadding="8" style="border-collapse:collapse; margin:10px 0;">
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
            <td style="text-align:center">{{ result['northwest_plan'][i][j] }}</td>
            % end
            <td style="text-align:center; background:#e9ecef;">{{ result['supply'][i] }}</td>
        </tr>
        % end
        <tr>
            <th>Потребности</th>
            % for j in range(result['consumers']):
            <td style="text-align:center; background:#e9ecef;">{{ result['demand'][j] }}</td>
            % end
            <td></td>
        </tr>
    </table>
</div>

<!-- Шаг 2: Метод минимального элемента -->
<div class="result-box">
    <h3>Шаг 2: Метод минимального элемента</h3>
    <p><strong>Стоимость перевозок:</strong> {{result['mincost_cost']}}</p>
    <table border="1" cellpadding="8" style="border-collapse:collapse; margin:10px 0;">
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
            <td style="text-align:center">{{ result['mincost_plan'][i][j] }}</td>
            % end
            <td style="text-align:center; background:#e9ecef;">{{ result['supply'][i] }}</td>
        </tr>
        % end
        <tr>
            <th>Потребности</th>
            % for j in range(result['consumers']):
            <td style="text-align:center; background:#e9ecef;">{{ result['demand'][j] }}</td>
            % end
            <td></td>
        </tr>
    </table>
</div>

<!-- Итоговое оптимальное решение -->
<div class="result-box" style="background:#d4edda; border-color:#c3e6cb;">
    <h3>✅ Итоговое оптимальное решение (метод потенциалов)</h3>
    <p><strong>Минимальная стоимость перевозок:</strong> {{result['optimal_cost']}}</p>
    <table border="1" cellpadding="8" style="border-collapse:collapse; margin:10px 0;">
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
            <td style="text-align:center; font-weight:bold;">{{ result['optimal_plan'][i][j] }}</td>
            % end
            <td style="text-align:center; background:#e9ecef;">{{ result['supply'][i] }}</td>
        </tr>
        % end
        <tr>
            <th>Потребности</th>
            % for j in range(result['consumers']):
            <td style="text-align:center; background:#e9ecef;">{{ result['demand'][j] }}</td>
            % end
            <td></td>
        </tr>
    </table>
    <p><strong>Матрица тарифов:</strong></p>
    <table border="1" cellpadding="8" style="border-collapse:collapse;">
        % for i in range(result['suppliers']):
        <tr>
            % for j in range(result['consumers']):
            <td style="text-align:center">{{ result['costs'][i][j] }}</td>
            % end
        </tr>
        % end
    </table>
</div>

<div class="button-group">
    <button class="btn btn-success" onclick="saveToExcel()">📎 Сохранить в Excel</button>
    <button class="btn btn-info" onclick="saveToCSV()">📄 Сохранить в CSV</button>
</div>
% end

<script>
    function updateMatrix() {
        const suppliers = document.getElementById('suppliers').value;
        const consumers = document.getElementById('consumers').value;
        const container = document.getElementById('matrixContainer');
        
        let html = '<div class="matrix-input"><h4>Матрица тарифов</h4><table>';
        
        // Шапка таблицы
        html += '<tr><th>Поставщики/Потребители</th>';
        for(let j = 1; j <= consumers; j++) {
            html += `<th>Потр. ${j}</th>`;
        }
        html += '<th>Запасы</th></tr>';
        
        // Строки поставщиков
        for(let i = 1; i <= suppliers; i++) {
            html += `<tr><th>Пост. ${i}</th>`;
            for(let j = 1; j <= consumers; j++) {
                html += `<td><input type="number" name="cost_${i-1}_${j-1}" step="any" value="0" style="width:80px;"></td>`;
            }
            html += `<td><input type="number" name="supply_${i-1}" step="any" value="0" style="width:80px;"></td>`;
            html += '</tr>';
        }
        
        // Строка потребностей
        html += '<tr><th>Потребности</th>';
        for(let j = 1; j <= consumers; j++) {
            html += `<td><input type="number" name="demand_${j-1}" step="any" value="0" style="width:80px;"></td>`;
        }
        html += '<td></td></tr>';
        
        html += '</table></div>';
        
        // Сохраняем размерность
        html += `<input type="hidden" name="suppliers" value="${suppliers}">`;
        html += `<input type="hidden" name="consumers" value="${consumers}">`;
        
        container.innerHTML = html;
    }
    
    function clearForm() {
        const inputs = document.querySelectorAll('input');
        inputs.forEach(input => {
            if(input.type === 'number') input.value = '0';
            localStorage.removeItem(input.name);
        });
        updateMatrix();
    }
    
    function loadExample() {
        document.getElementById('suppliers').value = '3';
        document.getElementById('consumers').value = '3';
        updateMatrix();
        
        // Пример: 3 поставщика, 3 потребителя
        const exampleSupplies = [200, 150, 100];
        const exampleDemands = [120, 180, 150];
        const exampleCosts = [
            [4, 6, 8],
            [5, 7, 9],
            [3, 5, 7]
        ];
        
        for(let i = 0; i < 3; i++) {
            document.querySelector(`[name="supply_${i}"]`).value = exampleSupplies[i];
        }
        for(let j = 0; j < 3; j++) {
            document.querySelector(`[name="demand_${j}"]`).value = exampleDemands[j];
        }
        for(let i = 0; i < 3; i++) {
            for(let j = 0; j < 3; j++) {
                document.querySelector(`[name="cost_${i}_${j}"]`).value = exampleCosts[i][j];
            }
        }
    }
    
    function saveToExcel() {
        alert('Сохранение в Excel — нажмите Ctrl+S на странице с результатами');
    }
    
    function saveToCSV() {
        alert('Сохранение в CSV — скопируйте таблицу результатов');
    }
    
    // Инициализация при загрузке
    document.addEventListener('DOMContentLoaded', function() {
        updateMatrix();
    });
</script>