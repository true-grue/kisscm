import re
import os
import sys
import subprocess


with open('excluded.txt', encoding='utf8') as f:
    EXCLUDED = f.read().strip().split()


def should_keep(word):
    is_cyrillic = bool(re.search('[а-яА-Я]', word))
    return is_cyrillic and word not in EXCLUDED and len(word) > 1


path = sys.argv[1]
hunspell = os.path.join('tools', 'hunspell.bat')
for filename in os.listdir(path):
    filename = os.path.join(path, filename)
    if filename.endswith('.md'):
        r = subprocess.run([hunspell, filename], capture_output=True)
        words = [w.decode('utf8').lower() for w in r.stdout.strip().split()]
        words = set([w for w in words if should_keep(w)])
        if words:
            print(f'{filename}:\n{' '.join(words)}\n')
