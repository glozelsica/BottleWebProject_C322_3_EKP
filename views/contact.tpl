% rebase('layout.tpl', title=title, year=year)

<h1>📞 Контакты</h1>

% if 'Ваш вопрос отправлен' in message:
<div class="result-box" style="background: #d4edda;">
    <p>✅ {{message}}</p>
</div>
% end

<div class="form-section">
    <h3>Свяжитесь с нами</h3>
    
    <div style="margin: 1rem 0;">
        <p><strong>📱 Телефон:</strong> <a href="tel:{{phone}}">{{phone}}</a></p>
        <p><strong>✉️ Email:</strong> <a href="mailto:{{email}}">{{email}}</a></p>
        <p><strong>💬 ВКонтакте:</strong> <a href="{{vk}}" target="_blank">{{vk}}</a></p>
    </div>
    
    <hr>
    
    <h3>📝 Задать вопрос</h3>
    <form method="post" action="/send_question">
        <div class="form-group">
            <label>Ваше имя:</label>
            <input type="text" name="name" placeholder="Введите ваше имя" style="width: 100%; max-width: 300px;">
        </div>
        <div class="form-group">
            <label>Вопрос:</label>
            <textarea name="question" rows="5" placeholder="Опишите ваш вопрос..." style="width: 100%; max-width: 500px; padding: 8px;"></textarea>
        </div>
        <button type="submit" class="btn btn-primary">📨 Отправить вопрос</button>
    </form>
</div>