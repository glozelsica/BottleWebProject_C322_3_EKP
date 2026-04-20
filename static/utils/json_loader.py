import json
import os

def load_theory(method_name):
    """
    Загружает теорию из JSON-файла.
    Сначала ищет в static/data/, потом в data/, потом в корне.
    """
    possible_paths = [
        os.path.join('static', 'data', f'theory_{method_name}.json'),
        os.path.join('data', f'theory_{method_name}.json'),
        f'theory_{method_name}.json'
    ]
    
    for file_path in possible_paths:
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
    
    # Если файл не найден нигде
    return {
        'title': f'Теория для {method_name} временно недоступна',
        'full_theory': f'Файл теории не найден. Проверенные пути: {possible_paths}',
        'canonical_form': {'title': 'Нет данных', 'content': 'Файл теории отсутствует'},
        'simplex_table': {'title': 'Нет данных', 'content': 'Файл теории отсутствует'},
        'jordan_transform': {'title': 'Нет данных', 'content': 'Файл теории отсутствует'},
        'artificial_basis': {'title': 'Нет данных', 'content': 'Файл теории отсутствует'},
        'bland_rule': {'title': 'Нет данных', 'content': 'Файл теории отсутствует'},
        'special_cases': {'title': 'Нет данных', 'content': 'Файл теории отсутствует'},
        'images': {},
        'video_url': '/video'
    }