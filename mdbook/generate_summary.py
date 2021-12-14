import os
import re


def transliteration(text):
    cyrillic = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ. '
    latin = 'a|b|v|g|d|e|e|zh|z|i|i|k|l|m|n|o|p|r|s|t|u|f|kh|tc|ch|sh|shch||y||e|iu|ia|A|B|V|G|D|E|E|Zh|Z|I|I|K|L|M|N|O|P|R|S|T|U|F|Kh|Tc|Ch|Sh|Shch||Y||E|Iu|Ia|_|-'.split(
        '|')
    return text.translate({ord(k): v for k, v in zip(cyrillic, latin)})


def generate_summary(titles):
    summary_text = '# Summary\n\n'
    for title in titles:
        clear_title = title['title'].replace('#', '').strip()
        meta_string = f"- [{clear_title}]({title['file_name'] if title['file_name'] is not None else ''})\n"
        if title['title'].find('##') != -1:
            summary_text += "    " + meta_string
        else:
            summary_text += meta_string

    return summary_text


def clear_folder(folder_path):
    for filename in os.listdir(folder_path):
        if filename != 'kisscm.md':
            file_path = os.path.join(folder_path, filename)
            os.remove(file_path)


stc_folder_path = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), 'src')
md_file_path = os.path.join(stc_folder_path, 'kisscm.md')

clear_folder(stc_folder_path)

with open(md_file_path, 'r', encoding='utf-8') as fp:
    data = fp.read()

headline_regexp = r'^(?:#{1,2} +.+)$'
found_headlines = list(re.finditer(headline_regexp, data, flags=re.MULTILINE))

titles = []

for i in range(1, len(found_headlines)):
    current_start_pos = found_headlines[i - 1].span()[0]
    next_start_pos = found_headlines[i].span()[0]

    if i != len(found_headlines) - 1:
        text_block = data[current_start_pos:next_start_pos]
    else:
        text_block = data[next_start_pos:]

    title = re.findall(headline_regexp, text_block, flags=re.MULTILINE)[
        0].strip()

    new_file_name = transliteration(title.replace('#', '').strip()) + '.md'

    title_without_nums = re.sub(r'(?:\d\.?)+', '', title).strip()

    if len(text_block.replace(title, '').strip()) > 1:
        with open(os.path.join(stc_folder_path, new_file_name), 'w', encoding='utf-8') as f:
            f.write(text_block)

        titles.append({'title': title_without_nums,
                      'file_name': new_file_name})
    else:
        titles.append({'title': title_without_nums, 'file_name': None})

with open(os.path.join(stc_folder_path, 'SUMMARY.md'), 'w', encoding='utf-8') as f:
    f.write(generate_summary(titles))
