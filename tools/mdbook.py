import typing
import os
import sys
import iuliia


class Section(typing.NamedTuple):
    title: str
    content: list
    tree: bool = False


def make_title(line):
    line = line.lstrip('#')
    line = line.split('{')[0]
    return line.strip()


def make_sections(md):
    with open(md, 'r', encoding='utf-8') as file:
        lines = file.readlines()
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
    return [s for s in section.content if isinstance(s, Section)]


def cleanup_sections(sections):
    for section in sections:
        subsections = get_subsections(section)
        content = subsections or section.content
        yield Section(section.title, content, bool(subsections))


def file_name(title):
    title = ''.join(
        sym if sym.isalpha() else
        '-' if sym.isspace() else
        '' for sym in title)
    title = title.strip('-')
    title = iuliia.WIKIPEDIA.translate(title)
    return title + '.md'


def dump_file(sub, dirname):
    fname = file_name(sub.title)
    path = os.path.join(dirname, fname)
    with open(path, 'w', encoding='utf-8') as file:
        file.writelines(sub.content)
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
        match sub.tree:
            case True:
                body += dump_section(sub, dirname)
            case False:
                file = dump_file(sub, dirname)
                body.append(f'- [{sub.title}]({file})\n')
    dump_file(Section('SUMMARY', body), dirname)


book = sys.argv[1]
sections = make_sections(book)
sections = cleanup_sections(sections)
dump_sections(sections, os.path.dirname(book))
