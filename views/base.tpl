<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{title or 'Математическое моделирование'}}</title>
    <link rel="stylesheet" href="/static/site.css">
</head>
<body>
    <header>
        <div class="logo">📊 Математическое моделирование</div>
        <nav>
            <a href="/">Главная</a>
            <a href="/transport">Транспортная</a>
            <a href="/direct_lp">ЗЛП</a>
            <a href="/assignment">Назначения</a>
            <a href="/authors">Об авторах</a>
            <a href="/contact">Контакты</a>
        </nav>
    </header>

    <div class="main-container">
        <div class="content">
            % if content_template:
                % include(content_template, **locals())
            % else:
                {{!base}}
            % end
        </div>
        <div class="sidebar">
            <h3>💡 Полезные советы</h3>
            <ul>
                <li>• Для перехода между ячейками матрицы используйте <kbd>Tab</kbd></li>
                <li>• Результат можно сохранить в Excel/CSV</li>
                <li>• При несбалансированности добавляются фиктивные участники</li>
                <li>• Все данные сохраняются автоматически</li>
            </ul>
            <div class="tip-box">
                <strong>📹 Видео-инструкция</strong>
                <p>Подробный разбор всех методов смотрите в видеоуроке.</p>
                <a href="/video" class="btn btn-info" style="display:inline-block; margin-top:10px;">Смотреть урок</a>
            </div>
        </div>
    </div>

    <footer>
        <p>BottleWebProject_C322_3_EKP | Команда №3 | Егармина, Корнилов, Потылицына | {{year}}</p>
        <a href="/contact" class="question-btn">📩 Задать вопрос</a>
    </footer>

    <script>
        // Автосохранение введённых данных
        document.addEventListener('DOMContentLoaded', function() {
            const inputs = document.querySelectorAll('input, textarea');
            inputs.forEach(input => {
                if (input.type !== 'submit' && input.type !== 'button') {
                    const saved = localStorage.getItem(input.name);
                    if (saved) input.value = saved;
                    input.addEventListener('input', function() {
                        localStorage.setItem(this.name, this.value);
                    });
                }
            });
        });
    </script>
</body>
</html>