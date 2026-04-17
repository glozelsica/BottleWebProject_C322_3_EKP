import json
import os

def load_theory(method_name):
    file_path = os.path.join('data', f'theory_{method_name}.json')
    
    if not os.path.exists(file_path):
        return {
            'title': 'Теория временно недоступна',
            'full_theory': 'Файл с теорией не найден. Пожалуйста, проверьте наличие файла theory_{method_name}.json',
            'step1': 'Нет данных',
            'step2': 'Нет данных',
            'step1_content': 'Нет данных',
            'step2_content': 'Нет данных',
            'image': '/static/images/placeholder.jpg',
            'video_url': '/video'
        }
    
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)