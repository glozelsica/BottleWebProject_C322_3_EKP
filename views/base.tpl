<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Задачи линейного программирования</title>
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <header>
        <nav>
            <a href="/">Главная</a>
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
            <ul>
            </ul>
            <div class="tip-box">
            </div>
        </aside>
    </div>

    <footer>
    </footer>

</body>
</html>
