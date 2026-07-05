import os
import re

def walk(dir):
    results = []
    for root, dirs, files in os.walk(dir):
        for file in files:
            if file.endswith('.dart'):
                results.append(os.path.join(root, file))
    return results

files = walk('lib')
for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if '.withOpacity(' in content:
        # replace .withOpacity(val) with .withValues(alpha: val)
        new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
        with open(file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print('Fixed', file)
print('Done')
