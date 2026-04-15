import pandas as pd
import csv
import os

def export_to_excel(data, filename, sheet_name='Result'):
    os.makedirs('data/results', exist_ok=True)
    
    if isinstance(data, dict):
        df = pd.DataFrame([data])
    elif isinstance(data, list):
        if len(data) > 0 and isinstance(data[0], (list, tuple)):
            df = pd.DataFrame(data)
        else:
            df = pd.DataFrame(data, columns=['Value'])
    else:
        df = pd.DataFrame([[data]], columns=['Result'])
    
    filepath = f'data/results/{filename}.xlsx'
    df.to_excel(filepath, sheet_name=sheet_name, index=False)
    return filepath

def export_to_csv(data, filename):
    os.makedirs('data/results', exist_ok=True)
    filepath = f'data/results/{filename}.csv'
    
    with open(filepath, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.writer(f)
        
        if isinstance(data, dict):
            for key, value in data.items():
                writer.writerow([key, value])
        elif isinstance(data, list):
            for row in data:
                if isinstance(row, (list, tuple)):
                    writer.writerow(row)
                else:
                    writer.writerow([row])
        else:
            writer.writerow([data])
    
    return filepath