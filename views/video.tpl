% rebase('base', content_template='video_content')

<h1>📹 Видео-инструкция</h1>

<div class="form-section">
    <p>В этом видео подробно объясняются все три метода решения задач линейного программирования:</p>
    <ul>
        <li>Симплекс-метод для прямой ЗЛП</li>
        <li>Метод потенциалов для транспортной задачи</li>
        <li>Венгерский алгоритм для задачи о назначениях</li>
    </ul>
    
    <div style="position: relative; padding-bottom: 56.25%; height: 0; margin: 2rem 0;">
        <iframe 
            src="{{video_url}}" 
            style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;" 
            frameborder="0" 
            allowfullscreen>
        </iframe>
    </div>
    
    <div class="tip-box">
        <strong>💡 Совет:</strong> Используйте паузу, чтобы разобрать каждый шаг алгоритма.
    </div>
</div>
