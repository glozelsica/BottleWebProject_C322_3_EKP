% rebase('base', content_template='authors_content')

<h1>👥 Об авторах</h1>

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem; margin-top: 2rem;">
    % for author in authors:
    <div style="text-align: center; background: #f8f9fa; border-radius: 12px; padding: 1.5rem;">
        <div style="width: 150px; height: 150px; background: #9B2226; border-radius: 50%; margin: 0 auto 1rem; display: flex; align-items: center; justify-content: center; color: white; font-size: 3rem;">
            👤
        </div>
        <h3>{{author['name']}}</h3>
        <p style="color: #9B2226; font-weight: bold;">{{author['role']}}</p>
        <p>Студент(ка) группы C322</p>
    </div>
    % end
</div>

<div style="margin-top: 2rem; padding: 1rem; background: #EDE7F6; border-radius: 12px;">
    <h3>📌 Распределение обязанностей</h3>
    <ul>
        <li><strong>Егармина В.А.</strong> — архитектура проекта, прямая ЗЛП (симплекс-метод), главная страница, UML-диаграммы</li>
        <li><strong>Потылицына З.С.</strong> — транспортная задача (метод потенциалов), стилевое оформление CSS, страница об авторах</li>
        <li><strong>Корнилов Л.О.</strong> — задача о назначениях (венгерский метод), страница контактов, юнит-тесты</li>
    </ul>
</div>