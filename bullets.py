import os
import sys
from zipfile import ZipFile

BULLETS = [
    ('w:val="•"', 'w:val="–"')
]

docx_file = sys.argv[1]
temp_file = docx_file + '.temp'

with ZipFile(docx_file, 'r') as zipread:
    with ZipFile(temp_file, 'w') as zipwrite:
        for item in zipread.infolist():
            data = zipread.read(item.filename)
            if item.filename == 'word/numbering.xml':
                data = data.decode('utf8')
                for (src, dst) in BULLETS:
                    data = data.replace(src, dst)
            zipwrite.writestr(item, data)

os.remove(docx_file)
os.rename(temp_file, docx_file)
