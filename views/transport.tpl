<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Транспортная задача</title>
    <link rel="stylesheet" href="/static/content/site.css">
    <link rel="icon" href="/static/images/logo.png" type="image/png">
</head>
<body>
    <header>
        <div class="logo">
            <img src="/static/images/logo.png" alt="Логотип" class="logo-img"> 
            Математическое моделирование
        </div>
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
            
            <!-- ===== РЕЗУЛЬТАТЫ РЕШЕНИЯ ===== -->
            % if result:
            <h2>📊 Результаты решения</h2>
            
            <!-- Шаг 1 -->
            <div class="result-box">
                <h3>Шаг 1: Метод северо-западного угла</h3>
                <p><strong>Стоимость:</strong> {{result.get('northwest_cost', 0)}}</p>
                <table border="1" style="border-collapse:collapse;">
                    <tr><th></th>
                    % for j in range(result.get('consumers', 0)):
                    <th>Потр {{j+1}}</th>
                    % end
                    <th>Запасы</th>
                    </tr>
                    % for i in range(result.get('suppliers', 0)):
                    <tr>
                        <th>Пост {{i+1}}</th>
                        % for j in range(result.get('consumers', 0)):
                        <td style="text-align:center">{{ result.get('northwest_plan', [[]])[i][j] if result.get('northwest_plan') else 0 }}</td>
                        % end
                        <td style="text-align:center">{{ result.get('supply', [])[i] if result.get('supply') else 0 }}</td>
                    </tr>
                    % end
                </table>
            </div>
            
            <!-- Шаг 2 -->
            <div class="result-box">
                <h3>Шаг 2: Метод минимального элемента</h3>
                <p><strong>Стоимость:</strong> {{result.get('mincost_cost', 0)}}</p>
                <table border="1" style="border-collapse:collapse;">
                    <tr><th></th>
                    % for j in range(result.get('consumers', 0)):
                    <th>Потр {{j+1}}</th>
                    % end
                    <th>Запасы</th>
                    </tr>
                    % for i in range(result.get('suppliers', 0)):
                    <tr>
                        <th>Пост {{i+1}}</th>
                        % for j in range(result.get('consumers', 0)):
                        <td style="text-align:center">{{ result.get('mincost_plan', [[]])[i][j] if result.get('mincost_plan') else 0 }}</td>
                        % end
                        <td style="text-align:center">{{ result.get('supply', [])[i] if result.get('supply') else 0 }}</td>
                    </tr>
                    % end
                </table>
            </div>
            
            <!-- Итог -->
            <div class="result-box" style="background:#d4edda;">
                <h3>✅ Итоговое оптимальное решение (метод потенциалов)</h3>
                <p><strong>Минимальная стоимость перевозок:</strong> {{result.get('optimal_cost', 0)}}</p>
                <table border="1" style="border-collapse:collapse;">
                    <tr><th></th>
                    % for j in range(result.get('consumers', 0)):
                    <th>Потр {{j+1}}</th>
                    % end
                    <th>Запасы</th>
                    </tr>
                    % for i in range(result.get('suppliers', 0)):
                    <tr>
                        <th>Пост {{i+1}}</th>
                        % for j in range(result.get('consumers', 0)):
                        <td style="text-align:center"><strong>{{ result.get('optimal_plan', [[]])[i][j] if result.get('optimal_plan') else 0 }}</strong></td>
                        % end
                        <td style="text-align:center">{{ result.get('supply', [])[i] if result.get('supply') else 0 }}</td>
                    </tr>
                    % end
                    <tr>
                        <th>Потребности</th>
                        % for j in range(result.get('consumers', 0)):
                        <td style="text-align:center">{{ result.get('demand', [])[j] if result.get('demand') else 0 }}</td>
                        % end
                        <td></td>
                    </tr>
                </table>
                % if not result.get('balanced', True):
                <p><em>⚠️ Задача была несбалансирована, добавлены фиктивные участники с нулевыми тарифами.</em></p>
                % end
            </div>
            % end
            
            <!-- ===== ТЕОРИЯ (только если есть theory и она не пустая) ===== -->
            % if theory:
            <h2>📖 Теоретические основы</h2>
            
            % if theory.get('section1'):
            <div class="theory-block">
                <h3>{{theory['section1'].get('title', '')}}</h3>
                <p>{{theory['section1'].get('content', '')}}</p>
                % for formula in theory['section1'].get('formulas', []):
                <div class="formula-box">
                    <p><em>{{formula.get('description', '')}}</em></p>
                    <img src="{{formula.get('image', '')}}" alt="Формула" style="max-width:100%; margin:10px 0;">
                </div>
                % end
            </div>
            % end
            
            % if theory.get('section2'):
            <div class="theory-block">
                <h3>{{theory['section2'].get('title', '')}}</h3>
                <p>{{theory['section2'].get('content', '')}}</p>
                <div class="theorem-box"><strong>📐 Теорема:</strong> {{theory['section2'].get('theorem', '')}}</div>
                % for formula in theory['section2'].get('formulas', []):
                <img src="{{formula.get('image', '')}}" alt="Формула" style="max-width:100%; margin:10px 0;">
                % end
                <ul>
                % for remark in theory['section2'].get('remarks', []):
                    <li>{{remark}}</li>
                % end
                </ul>
            </div>
            % end
            
            % if theory.get('section3'):
            <div class="theory-block">
                <h3>{{theory['section3'].get('title', '')}}</h3>
                <p>{{theory['section3'].get('content', '')}}</p>
                <img src="{{theory['section3'].get('formula_image', '')}}" alt="Формула" style="max-width:100%;">
            </div>
            % end
            
            % if theory.get('section4'):
            <div class="theory-block">
                <h3>{{theory['section4'].get('title', '')}}</h3>
                <p>{{theory['section4'].get('content', '')}}</p>
                % for method in theory['section4'].get('methods', []):
                <div style="margin:15px 0;">
                    <strong>{{method.get('name', '')}}:</strong>
                    <p>{{method.get('description', '')}}</p>
                    <img src="{{method.get('image', '')}}" alt="Метод" style="max-width:100%; border-radius:8px;">
                </div>
                % end
            </div>
            % end
            
            % if theory.get('section5'):
            <div class="theory-block">
                <h3>{{theory['section5'].get('title', '')}}</h3>
                <p>{{theory['section5'].get('content', '')}}</p>
                <div class="theorem-box"><strong>📐 Теорема:</strong> {{theory['section5'].get('theorem', '')}}</div>
                % for formula in theory['section5'].get('formulas', []):
                <img src="{{formula.get('image', '')}}" alt="Формула" style="max-width:100%; margin:10px 0;">
                % end
                <strong>Алгоритм:</strong>
                <ol>
                % for step in theory['section5'].get('algorithm', []):
                    <li>{{step}}</li>
                % end
                </ol>
            </div>
            % end
            
            % if theory.get('section6'):
            <div class="theory-block">
                <h3>{{theory['section6'].get('title', '')}}</h3>
                <p>{{theory['section6'].get('content', '')}}</p>
                <ol>
                % for step in theory['section6'].get('algorithm', []):
                    <li>{{step}}</li>
                % end
                </ol>
                <img src="{{theory['section6'].get('image', '')}}" alt="Цикл" style="max-width:100%; margin:10px 0;">
            </div>
            % end
            
            % if theory.get('section7'):
            <div class="theory-block">
                <h3>{{theory['section7'].get('title', '')}}</h3>
                % for sub in theory['section7'].get('subsections', []):
                <div style="margin:15px 0;">
                    <strong>{{sub.get('title', '')}}:</strong>
                    <p>{{sub.get('content', '')}}</p>
                </div>
                % end
            </div>
            % end
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
        <div class="footer-content">
            <div class="footer-section">
                <h4>BottleWebProject_C322_3_EKP</h4>
                <p>Команда №3 | Егармина, Корнилов, Потылицына</p>
                <p>Группа C322 | ГУАП ФСПО №12</p>
            </div>
            <div class="footer-section">
                <h4>📅 2026</h4>
                <p>Учебная практика УП02</p>
                <p>ПМ02 «Осуществление интеграции программных модулей»</p>
            </div>
            <div class="footer-section">
                <h4>📞 Связь</h4>
                <a href="/contact" class="question-btn">📩 Задать вопрос</a>
            </div>
        </div>
        <div class="footer-bottom">
            <p>© 2026 Математическое моделирование. Все права защищены.</p>
        </div>
    </footer>

    <script>
        function updateMatrix() {
            const suppliers = parseInt(document.getElementById('suppliers').value);
            const consumers = parseInt(document.getElementById('consumers').value);
            const container = document.getElementById('matrixContainer');
            
            let html = '<div class="matrix-input"><h4>Матрица тарифов</h4><table border="1" style="border-collapse:collapse;">';
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
            
            const supplies = [70, 100, 110];
            const demands = [80, 50, 150];
            const costs = [[1,4,5],[3,5,2],[2,6,4]];
            
            for(let i = 0; i < 3; i++) {
                const supplyInput = document.querySelector(`[name="supply_${i}"]`);
                if(supplyInput) supplyInput.value = supplies[i];
                const demandInput = document.querySelector(`[name="demand_${i}"]`);
                if(demandInput) demandInput.value = demands[i];
                for(let j = 0; j < 3; j++) {
                    const costInput = document.querySelector(`[name="cost_${i}_${j}"]`);
                    if(costInput) costInput.value = costs[i][j];
                }
            }
        }
        
        document.addEventListener('DOMContentLoaded', updateMatrix);
    </script>
</body>
</html>