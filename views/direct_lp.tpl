<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Прямая ЗЛП - Симплекс-метод</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <style>
        .step-container {
            margin-top: 25px;
            border: 1px solid #ddd;
            border-radius: 12px;
            padding: 25px;
            background: #fafbfc;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .step-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e0e7ef;
        }
        .step-header h3 {
            margin: 0;
            color: #1e3a5f;
            font-size: 1.4rem;
        }
        .step-nav-buttons {
            display: flex;
            gap: 10px;
        }
        .step-nav-buttons button {
            padding: 8px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
        }
        .btn-prev {
            background: #6c757d;
            color: white;
        }
        .btn-next {
            background: #007bff;
            color: white;
        }
        .btn-prev:disabled, .btn-next:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .tableau-container {
            overflow-x: auto;
            margin: 20px 0;
        }
        .simplex-tableau {
            border-collapse: collapse;
            width: 100%;
            text-align: center;
            background: white;
            border-radius: 8px;
            overflow: hidden;
        }
        .simplex-tableau th {
            background: #2c3e50;
            color: white;
            padding: 10px 15px;
        }
        .simplex-tableau td {
            padding: 8px 15px;
            border: 1px solid #dee2e6;
        }
        .simplex-tableau tr:last-child {
            border-top: 2px solid #2c3e50;
            background: #f8f9fa;
            font-weight: 500;
        }
        .result-success {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 20px;
            border-radius: 8px;
        }
        .result-error {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 20px;
            border-radius: 8px;
        }
        .step-controls {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
        }
        .btn-solve {
            background: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
        }
        .btn-step {
            background: #6c757d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
        }
        .theory-section {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #e0e7ef;
        }
    </style>
</head>
<body>
    <header>
        <div class="logo">Математическое моделирование</div>
        <nav>
            <a href="/">Главная</a>
            <a href="/direct_lp">Прямая ЗЛП</a>
            <a href="/transport">Транспортная задача</a>
            <a href="/assignment">Задача о назначениях</a>
            <a href="/video">Видео</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        <div class="content">
            <h1>{{theory.get('title', 'Симплекс-метод')}}</h1>

            <!-- ==================== КАЛЬКУЛЯТОР ==================== -->
            <div class="calculator-block">
                <h2>Решение задачи</h2>

                % if error:
                <div class="error-box"><strong>Ошибка:</strong> {{error}}</div>
                % end

                <form method="post" id="lpForm">
                    <input type="hidden" name="action" id="formAction" value="solve">
                    
                    <div class="input-group">
                        <label>Коэффициенты целевой функции (через запятую):</label>
                        <input type="text" name="c" id="c_input" value="{{c}}" size="50" placeholder="пример: 3,5" required>
                    </div>

                    <div class="input-group">
                        <label>Количество ограничений:</label>
                        <input type="number" name="rows" id="rows" value="{{rows}}" min="1" max="10">
                    </div>

                    <div class="input-group">
                        <label>Количество переменных:</label>
                        <input type="number" name="cols" id="cols" value="{{cols}}" min="1" max="10">
                    </div>

                    <button type="button" onclick="updateMatrix()">Обновить матрицу</button>

                    <h3>Матрица ограничений A</h3>
                    <div id="matrix-container" class="matrix-input"></div>

                    <h3>Правые части b</h3>
                    <div id="b-container"></div>

                    <div class="input-group">
                        <label>Направление оптимизации:</label>
                        <label><input type="radio" name="sense" value="max" {{'checked' if sense=='max' else ''}}> Максимизация</label>
                        <label><input type="radio" name="sense" value="min" {{'checked' if sense=='min' else ''}}> Минимизация</label>
                    </div>

                    <div class="step-controls">
                        <button type="submit" class="btn-solve" onclick="setAction('solve')">Решить сразу</button>
                        <button type="submit" class="btn-step" onclick="setAction('step_init')">Решать по шагам</button>
                    </div>
                </form>

                <!-- ==================== ПОШАГОВОЕ ОТОБРАЖЕНИЕ ==================== -->
                % if step_data:
                <div class="step-container">
                    <div class="step-header">
                        <h3>{{step_data.get('title', 'Шаг')}}</h3>
                        <div class="step-nav-buttons">
                            <form method="post" style="display: inline;">
                                <input type="hidden" name="action" value="step_prev">
                                <input type="hidden" name="c" value="{{c}}">
                                <input type="hidden" name="rows" value="{{rows}}">
                                <input type="hidden" name="cols" value="{{cols}}">
                                % for i in range(int(rows)):
                                    % for j in range(int(cols)):
                                        <input type="hidden" name="A_{{i}}_{{j}}" value="{{A[i][j] if i < len(A) and j < len(A[0]) else 0}}">
                                    % end
                                    <input type="hidden" name="b_{{i}}" value="{{b[i] if i < len(b) else 0}}">
                                % end
                                <input type="hidden" name="sense" value="{{sense}}">
                                <button type="submit" class="btn-prev" {{!'disabled' if step_data.get('step') == 1 else ''}}>← Назад</button>
                            </form>
                            <form method="post" style="display: inline;">
                                <input type="hidden" name="action" value="step_next">
                                <input type="hidden" name="c" value="{{c}}">
                                <input type="hidden" name="rows" value="{{rows}}">
                                <input type="hidden" name="cols" value="{{cols}}">
                                % for i in range(int(rows)):
                                    % for j in range(int(cols)):
                                        <input type="hidden" name="A_{{i}}_{{j}}" value="{{A[i][j] if i < len(A) and j < len(A[0]) else 0}}">
                                    % end
                                    <input type="hidden" name="b_{{i}}" value="{{b[i] if i < len(b) else 0}}">
                                % end
                                <input type="hidden" name="sense" value="{{sense}}">
                                <button type="submit" class="btn-next" {{!'disabled' if step_data.get('status') in ['infeasible', 'unbounded', 'optimal'] or step_data.get('step') == 'result' else ''}}>Далее →</button>
                            </form>
                        </div>
                    </div>
                    <div class="step-content">
                        % if step_data.get('step') == 1:
                            <p><strong>Целевая функция:</strong> F = {{step_data.get('c_expr', '')}} → {{step_data.get('sense', 'max')}}</p>
                            <p><strong>Ограничения:</strong></p>
                            <ul>
                            % for constr in step_data.get('constraints', []):
                                <li>{{constr}}</li>
                            % end
                            </ul>
                            <p>{{step_data.get('vars', '')}}</p>
                        % elif step_data.get('step') == 2:
                            <p><strong>Добавленные переменные:</strong></p>
                            % if step_data.get('slack_vars'):
                                <p>Slack (для ≤): {{', '.join(step_data['slack_vars'])}}</p>
                            % end
                            % if step_data.get('artificial_vars'):
                                <p>Искусственные: {{', '.join(step_data['artificial_vars'])}}</p>
                            % end
                            % if step_data.get('matrix_A'):
                                <p><strong>Матрица A:</strong></p>
                                <pre>{{step_data['matrix_A']}}</pre>
                            % end
                        % elif step_data.get('step') == 3:
                            <p><strong>Базисные переменные:</strong> {{', '.join(step_data.get('basis_vars', []))}}</p>
                            <p><strong>Свободные переменные:</strong> {{', '.join(step_data.get('free_vars', []))}}</p>
                            <p><strong>X₀ =</strong> ({{', '.join(["{:.2f}".format(x) for x in step_data.get('x0', [])])}})</p>
                            % if step_data.get('f0') is not None:
                                <p><strong>F(X₀) =</strong> {{"{:.4f}".format(step_data['f0'])}}</p>
                            % end
                        % elif step_data.get('step') == 4:
                            <p><strong>Базис:</strong> {{', '.join(step_data.get('basis', []))}}</p>
                            % if step_data.get('tableau'):
                                <div class="tableau-container">
                                    <table class="simplex-tableau">
                                        <thead><tr>% for h in step_data['tableau']['headers']:<th>{{h}}</th>% end</tr></thead>
                                        <tbody>
                                        % for row in step_data['tableau']['rows']:
                                            <tr>% for cell in row:<td>{{cell}}</td>% end</tr>
                                        % end
                                        </tbody>
                                    </table>
                                </div>
                            % end
                            % if step_data.get('is_optimal') == False:
                                <p><strong>Оценки Δⱼ:</strong> [{{', '.join(["{:.3f}".format(d) for d in step_data.get('delta', [])])}}]</p>
                                <p style="color: #d9534f;">❌ План не оптимален</p>
                                <p><strong>Вводится:</strong> {{step_data.get('pivot_col_name', '')}} (столбец {{step_data.get('pivot_col', '')}})</p>
                                <p><strong>Выводится:</strong> {{step_data.get('pivot_row_name', '')}} (строка {{step_data.get('pivot_row', '')}})</p>
                                <p><strong>Разрешающий элемент:</strong> {{"{:.4f}".format(step_data.get('pivot_val', 0))}}</p>
                            % else:
                                <p style="color: #28a745;">✅ Все Δⱼ ≥ 0 — план оптимален</p>
                            % end
                        % elif step_data.get('step') == 'result':
                            % if step_data.get('status') == 'optimal':
                                <div class="result-success">
                                    <h3>✅ Оптимум найден</h3>
                                    % for i, val in enumerate(step_data.get('solution', [])):
                                        <p>x<sub>{{i+1}}</sub> = {{"{:.6f}".format(val)}}</p>
                                    % end
                                    <p><strong>F* =</strong> {{"{:.6f}".format(step_data.get('optimal_value', 0))}}</p>
                                    <p><strong>Итераций:</strong> {{step_data.get('iterations', 0)}}</p>
                                </div>
                            % elif step_data.get('status') == 'infeasible':
                                <div class="result-error"><h3>❌ Система несовместна (∅)</h3></div>
                            % elif step_data.get('status') == 'unbounded':
                                <div class="result-error"><h3>⚠️ F → ∞ (не ограничена)</h3></div>
                            % end
                            % if step_data.get('tableau_final'):
                                <h4>Финальная таблица:</h4>
                                <div class="tableau-container">
                                    <table class="simplex-tableau">
                                        <thead><tr>% for h in step_data['tableau_final']['headers']:<th>{{h}}</th>% end</tr></thead>
                                        <tbody>
                                        % for row in step_data['tableau_final']['rows']:
                                            <tr>% for cell in row:<td>{{cell}}</td>% end</tr>
                                        % end
                                        </tbody>
                                    </table>
                                </div>
                            % end
                        % end
                    </div>
                </div>
                % end

                <!-- ==================== ОБЫЧНЫЙ РЕЗУЛЬТАТ ==================== -->
                % if result and not step_data:
                    % if result.get('success'):
                    <div class="result-success">
                        <h3>✅ Результат решения</h3>
                        % for i, val in enumerate(result['solution']):
                            <p>x<sub>{{i+1}}</sub> = {{"{:.6f}".format(val)}}</p>
                        % end
                        <p><strong>F =</strong> {{"{:.6f}".format(result['value'])}}</p>
                        <p><strong>Итераций:</strong> {{result['iterations']}}</p>
                    </div>
                    % else:
                    <div class="result-error">
                        <h3>❌ Ошибка</h3>
                        <p>{{result.get('error', 'Неизвестная ошибка')}}</p>
                    </div>
                    % end
                % end
            </div>

            <!-- ==================== ТЕОРИЯ ==================== -->
            <div class="theory-section">
                <h2>📚 Теория симплекс-метода</h2>
                
                % if theory.get('full_theory'):
                <p>{{!theory['full_theory'].replace('\n', '<br>')}}</p>
                % end
                
                % if theory.get('canonical_form'):
                <h3>{{theory['canonical_form'].get('title', 'Приведение к каноническому виду')}}</h3>
                <p>{{!theory['canonical_form'].get('content', '').replace('\n', '<br>')}}</p>
                % end
                
                % if theory.get('simplex_table'):
                <h3>{{theory['simplex_table'].get('title', 'Симплекс-таблица')}}</h3>
                <p>{{!theory['simplex_table'].get('content', '').replace('\n', '<br>')}}</p>
                % end
                
                % if theory.get('jordan_transform'):
                <h3>{{theory['jordan_transform'].get('title', 'Жорданово исключение')}}</h3>
                <p>{{!theory['jordan_transform'].get('content', '').replace('\n', '<br>')}}</p>
                % end
                
                % if theory.get('artificial_basis'):
                <h3>{{theory['artificial_basis'].get('title', 'Метод искусственного базиса')}}</h3>
                <p>{{!theory['artificial_basis'].get('content', '').replace('\n', '<br>')}}</p>
                % end
                
                % if theory.get('bland_rule'):
                <h3>{{theory['bland_rule'].get('title', 'Правило Блэнда')}}</h3>
                <p>{{!theory['bland_rule'].get('content', '').replace('\n', '<br>')}}</p>
                % end
                
                % if theory.get('special_cases'):
                <h3>{{theory['special_cases'].get('title', 'Особые случаи')}}</h3>
                <p>{{!theory['special_cases'].get('content', '').replace('\n', '<br>')}}</p>
                % end
            </div>
        </div>

        <aside class="sidebar">
            <h3>💡 Советы</h3>
            <ul>
                <li>Используйте стрелки для навигации по матрице</li>
                <li>«Решать по шагам» показывает каждый этап</li>
                <li>При вырожденности применяется правило Блэнда</li>
            </ul>
            <div class="tip-box">
                <h4>🧪 Тестовые данные</h4>
                <p><strong>Максимизация:</strong> c=3,5; A=[1,0;0,2]; b=4,12 → x=(4,6), F=42</p>
                <p><strong>Минимизация:</strong> c=2,3; A=[1,1;2,1]; b=4,6 → x=(2,2), F=10</p>
            </div>
        </aside>
    </div>

    <footer>
        <p>© 2026 — Команда N3 (Егармина, Корнилов, Потылицына)</p>
        <a href="/contact" class="question-btn">Задать вопрос</a>
    </footer>

    <script>
        function setAction(action) {
            document.getElementById('formAction').value = action;
        }

        function updateMatrix() {
            const rows = parseInt(document.getElementById('rows').value) || 2;
            const cols = parseInt(document.getElementById('cols').value) || 2;

            let html = '<table>';
            for(let i = 0; i < rows; i++) {
                html += '<tr>';
                for(let j = 0; j < cols; j++) {
                    const oldInput = document.querySelector(`input[name='A_${i}_${j}']`);
                    let val = '0';
                    if (oldInput) {
                        val = oldInput.value;
                    } else if (i === 0 && j === 0) {
                        val = '1';
                    } else if (i === 0 && j === 1) {
                        val = '0';
                    } else if (i === 1 && j === 0) {
                        val = '0';
                    } else if (i === 1 && j === 1) {
                        val = '2';
                    }
                    html += `<td><input type="number" step="any" name="A_${i}_${j}" value="${val}" class="matrix-cell"></td>`;
                }
                html += '</tr>';
            }
            html += '</table>';
            document.getElementById('matrix-container').innerHTML = html;

            let bHtml = '';
            for(let i = 0; i < rows; i++) {
                const oldB = document.querySelector(`input[name='b_${i}']`);
                let val = '0';
                if (oldB) {
                    val = oldB.value;
                } else if (i === 0) {
                    val = '4';
                } else if (i === 1) {
                    val = '12';
                }
                bHtml += `<label>b${i+1}:</label> <input type="number" step="any" name="b_${i}" value="${val}"><br>`;
            }
            document.getElementById('b-container').innerHTML = bHtml;

            setTimeout(addArrowNavigation, 100);
        }

        function addArrowNavigation() {
            const cells = document.querySelectorAll('.matrix-cell');
            const rows = parseInt(document.getElementById('rows').value) || 2;
            const cols = parseInt(document.getElementById('cols').value) || 2;

            cells.forEach((cell, index) => {
                const row = Math.floor(index / cols);
                const col = index % cols;
                cell.removeEventListener('keydown', arrowHandler);
                cell.addEventListener('keydown', function(e) {
                    arrowHandler(e, row, col, rows, cols);
                });
            });
        }

        function arrowHandler(e, row, col, rows, cols) {
            let newRow = row, newCol = col;
            switch(e.key) {
                case 'ArrowUp': newRow = Math.max(0, row - 1); e.preventDefault(); break;
                case 'ArrowDown': newRow = Math.min(rows - 1, row + 1); e.preventDefault(); break;
                case 'ArrowLeft': newCol = Math.max(0, col - 1); e.preventDefault(); break;
                case 'ArrowRight': newCol = Math.min(cols - 1, col + 1); e.preventDefault(); break;
                default: return;
            }
            const newIndex = newRow * cols + newCol;
            const newCell = document.querySelectorAll('.matrix-cell')[newIndex];
            if(newCell) newCell.focus();
        }

        document.addEventListener('DOMContentLoaded', updateMatrix);
    </script>
</body>
</html>