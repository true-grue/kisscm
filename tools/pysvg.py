import sys
import subprocess

sys.stdout.reconfigure(encoding='utf-8')

def dot(src):
    p = subprocess.run(['dot', '-Tsvg'], input=src.encode('utf8'),
                       capture_output=True)
    print(p.stdout.decode('utf8'))
