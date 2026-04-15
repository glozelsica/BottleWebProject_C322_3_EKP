<h1>{{theory['title']}}</h1>

<!-- БЛОК КАЛЬКУЛЯТОРА И РЕШЕНИЯ -->
<div class="calculator-block">
    <h2>Решение задачи</h2>
    
    % if error:
    <div class="error-box">
        <strong>Ошибка:</strong> {{error}}
    </div>
    % end
    
    <form method="post" id="lpForm">
        <div class="input-group">
            <label>Коэффициенты целевой функции (через запятую):</label>
            <input type="text" name="c" id="c_input" value="{{c}}" size="50" placeholder="пример: 3,5" required>
        </div>
        
        <div class="input-group">
            <label>Количество ограничений (строк):</label>
            <input type="number" name="rows" id="rows" value="{{rows}}" min="1" max="10" step="1">
        </div>
        
        <div class="input-group">
            <label>Количество переменных (столбцов):</label>
            <input type="number" name="cols" id="cols" value="{{cols}}" min="1" max="10" step="1">
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
        
        <div>
            <button type="submit" class="btn-solve">Решить</button>
            % if result and result.get('success'):
            <button type="button" class="btn-solve btn-export" onclick="exportResult()">Сохранить результат в Excel/CSV</button>
            % end
        </div>
    </form>
    
    <!-- БЛОК ВЫВОДА РЕЗУЛЬТАТА -->
    % if result:
        % if result.get('success'):
        <div class="result-box">
            <h3>Результат решения</h3>
            <p><strong>Оптимальное решение:</strong></p>
            % for i, val in enumerate(result['solution']):
                <p>x{{i+1}} = {{"{:.6f}".format(val)}}</p>
            % end
            <p><strong>Значение целевой функции:</strong> {{"{:.6f}".format(result['value'])}}</p>
            <p><strong>Количество итераций:</strong> {{result['iterations']}}</p>
        </div>
        % else:
        <div class="error-box">
            <strong>Задача не может быть решена:</strong> {{result.get('error', 'Неизвестная ошибка')}}
        </div>
        % end
    % end
</div>

<!-- БЛОК ТЕОРИИ (ПОСЛЕ КАЛЬКУЛЯТОРА) -->
<div class="theory-block">
    <h2>Теория</h2>
    <p>{{!theory['full_theory'].replace(chr(10), '<br>')}}</p>
</div>

<!-- НАВИГАЦИЯ ПО ШАГАМ -->
<div class="step-nav">
    <button id="btn_step1" onclick="showStep(1)">Шаг 1</button>
    <button id="btn_step2" onclick="showStep(2)">Шаг 2</button>
</div>

<!-- БЛОК ШАГА 1 -->
<div id="step1_block" class="step" style="display: none;">
    <h3>{{theory['step1']}}</h3>
    <p>{{!theory['step1_content'].replace(chr(10), '<br>')}}</p>
    <img src="{{theory['image']}}" alt="Симплекс-метод шаг 1">
</div>

<!-- БЛОК ШАГА 2 -->
<div id="step2_block" class="step" style="display: none;">
    <h3>{{theory['step2']}}</h3>
    <p>{{!theory['step2_content'].replace(chr(10), '<br>')}}</p>
    <img src="{{theory['image']}}" alt="Симплекс-метод шаг 2">
</div>

<div class="theory-block">
    <p>Видео-инструкция: <a href="{{theory['video_url']}}">Смотреть</a></p>
</div>

<script>
// функция обновления матрицы с поддержкой стрелок на клавиатуре
function updateMatrix() {
    const rows = parseInt(document.getElementById('rows').value);
    const cols = parseInt(document.getElementById('cols').value);
    
    // сохраняем старые значения
    const savedMatrix = [];
    for(let i=0; i<rows; i++) {
        savedMatrix[i] = [];
        for(let j=0; j<cols; j++) {
            const oldInput = document.querySelector(`input[name='A_${i}_${j}']`);
            savedMatrix[i][j] = oldInput ? oldInput.value : '0';
        }
    }
    
    let html = '<table>';
    for(let i=0; i<rows; i++) {
        html += '<tr>';
        for(let j=0; j<cols; j++) {
            html += `<td><input type="number" step="any" name="A_${i}_${j}" value="${savedMatrix[i][j]}" placeholder="a${i+1}${j+1}" class="matrix-cell"></td>`;
        }
        html += '</tr>';
    }
    html += '</table>';
    document.getElementById('matrix-container').innerHTML = html;
    
    // правые части
    let bHtml = '';
    for(let i=0; i<rows; i++) {
        const oldB = document.querySelector(`input[name='b_${i}']`);
        const val = oldB ? oldB.value : '0';
        bHtml += `<label>b${i+1}:</label> <input type="number" step="any" name="b_${i}" value="${val}"><br>`;
    }
    document.getElementById('b-container').innerHTML = bHtml;
    
    // добавляем обработчики для стрелок
    setTimeout(addArrowNavigation, 100);
}

function addArrowNavigation() {
    const cells = document.querySelectorAll('.matrix-cell');
    const rows = parseInt(document.getElementById('rows').value);
    const cols = parseInt(document.getElementById('cols').value);
    
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
    let newRow = row;
    let newCol = col;
    
    switch(e.key) {
        case 'ArrowUp':
            newRow = Math.max(0, row - 1);
            e.preventDefault();
            break;
        case 'ArrowDown':
            newRow = Math.min(rows - 1, row + 1);
            e.preventDefault();
            break;
        case 'ArrowLeft':
            newCol = Math.max(0, col - 1);
            e.preventDefault();
            break;
        case 'ArrowRight':
            newCol = Math.min(cols - 1, col + 1);
            e.preventDefault();
            break;
        default:
            return;
    }
    
    const newIndex = newRow * cols + newCol;
    const newCell = document.querySelectorAll('.matrix-cell')[newIndex];
    if(newCell) {
        newCell.focus();
    }
}

function showStep(step) {
    const step1 = document.getElementById('step1_block');
    const step2 = document.getElementById('step2_block');
    const btn1 = document.getElementById('btn_step1');
    const btn2 = document.getElementById('btn_step2');
    
    if(step === 1) {
        step1.style.display = 'block';
        step2.style.display = 'none';
        btn1.classList.add('active');
        btn2.classList.remove('active');
    } else {
        step1.style.display = 'none';
        step2.style.display = 'block';
        btn1.classList.remove('active');
        btn2.classList.add('active');
    }
}

function exportResult() {
    alert('После решения задачи нажмите кнопку "Решить", затем для экспорта используйте кнопку "Сохранить результат". Файлы сохраняются в папку data/results/');
}

// инициализация при загрузке страницы
document.addEventListener('DOMContentLoaded', () => {
    updateMatrix();
    showStep(1);
});
</script>