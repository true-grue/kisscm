from typing import NamedTuple
from iuliia import WIKIPEDIA as wiki

import os
import sys


class Section(NamedTuple):
    title: str
    content: list
    tree: bool = False


def make_title(line):
    line = line.lstrip('#')
    line = line.split('{')[0]
    return line.strip()


def make_sections(lines):
    sections = []
    section = None
    in_code = False
    for line in lines:
        if line.startswith('```'):
            in_code = not in_code
            section.content.append(line)
        elif line.startswith('# ') and not in_code:
            section = Section(make_title(line), [line])
            sections.append(section)
        elif line.startswith('## ') and not in_code:
            section = Section(make_title(line), [line])
            sections[-1].content.append(section)
        elif section:
            section.content.append(line)
    return sections


def get_subsections(section):
    return [subsection
            for subsection in section.content
            if isinstance(subsection, Section)]


def cleanup_sections(sections):
    for section in sections:
        subsections = get_subsections(section)
        content = subsections or section.content
        yield Section(section.title, content, bool(subsections))


def file_name(title):
    name = ''.join(
        sym if sym.isalpha() else
        '-' if sym.isspace() else
        '' for sym in title).strip('-')
    return f'{wiki.translate(name)}.md'


def dump_file(sub, dirname):
    fname = file_name(sub.title)
    path = os.path.join(dirname, fname)
    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(sub.content)
    return fname


def dump_section(section, dirname):
    body = [f'# {section.title}\n', '\n']
    for sub in section.content:
        file = dump_file(sub, dirname)
        body.append(f'- [{sub.title}]({file})\n')
    return body


def dump_sections(sections, dirname):
    body = ['Summary\n', '\n']
    for sub in sections:
        if sub.tree:
            body += dump_section(sub, dirname)
        else:
            file = dump_file(sub, dirname)
            body.append(f'- [{sub.title}]({file})\n')
    dump_file(Section('SUMMARY', body), dirname)


src = sys.argv[1]
out = os.path.dirname(src)
with open(src, 'r', encoding='utf-8') as f:
    sections = make_sections(f.readlines())
dump_sections(cleanup_sections(sections), out)
