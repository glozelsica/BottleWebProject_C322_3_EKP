% include('header.tpl', title=title, message=message)

<div class="container mt-4">
    
    <!-- Блок теории -->
    <section class="theory mb-4">
        <h2>Теоретические основы</h2>
        <p>
            <strong>Задача о назначениях</strong> — частный случай транспортной задачи, 
            в которой количество исполнителей равно количеству работ, а каждый исполнитель 
            может выполнить только одну работу.
        </p>
        <p>
            <strong>Метод решения:</strong> Венгерский алгоритм основан на преобразовании 
            матрицы стоимостей путём вычитания минимальных элементов из строк и столбцов 
            до получения системы независимых нулей.
        </p>
    </section>

    <!-- Форма ввода -->
    <section class="input-form mb-4">
        <h2>Ввод исходных данных</h2>
        <form method="POST" action="/assignment">
            <div class="form-group">
                <label for="matrix">Квадратная матрица стоимостей (числа через пробел, строки через Enter):</label>
                <textarea 
                    id="matrix" 
                    name="matrix" 
                    class="form-control" 
                    rows="6" 
                    placeholder="10 20 30&#10;40 50 60&#10;70 80 90"
                    required
                >{{matrix_value}}</textarea>
                <small class="form-text text-muted">
                    Размер матрицы: до 6×6. Пример: 3 исполнителя на 3 работы.
                </small>
            </div>
            <button type="submit" class="btn btn-primary mt-3">Рассчитать оптимальный план</button>
        </form>
    </section>

    <!-- Блок результата (отображается только после POST) -->
    % if result:
    <section class="result mb-4">
        <h2 class="text-success">{{ result['status'] }}</h2>
        <p class="lead"><strong>Минимальная суммарная стоимость:</strong> {{ result['cost'] }}</p>
        
        <table class="table table-bordered table-striped">
            <thead class="thead-dark">
                <tr>
                    <th>№</th>
                    <th>Исполнитель (строка)</th>
                    <th>Работа (столбец)</th>
                </tr>
            </thead>
            <tbody>
                % for idx, (i, j) in enumerate(result['assignment'], 1):
                <tr>
                    <td>{{ idx }}</td>
                    <td>{{ i + 1 }}</td>
                    <td>{{ j + 1 }}</td>
                </tr>
                % end
            </tbody>
        </table>
        
        <a href="/assignment" class="btn btn-secondary">Новый расчёт</a>
    </section>
    % end

    <!-- Блок ошибки -->
    % if error:
    <div class="alert alert-danger" role="alert">
        <strong>Ошибка ввода:</strong> {{ error }}
    </div>
    % end

</div>

% include('footer.tpl')