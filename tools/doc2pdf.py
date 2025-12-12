import sys
from docx2pdf import convert

convert(sys.argv[1], sys.argv[2])
