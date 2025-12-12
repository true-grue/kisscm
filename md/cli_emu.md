## Эмулятор командной оболочки Linux

В этом разделе рассмотрим процесс разработки эмулятора командной оболочки Linux на языке программирования Python. В нашем эмуляторе будут поддерживаться как простые команды, так и команды для работы с виртуальной файловой системой.

### Простые команды

Начнём с заготовки эмулятора с поддержкой команд `echo`, `date`, `exit` @sovietov2021scm, работающей в режиме REPL (Read-Eval-Print Loop, цикл «чтение – вычисление – вывод»). Перед тем, как приступить к разработке эмулятора, изучим, как работают перечисленные команды в командной оболочке Linux:

```bash
~$ echo Hello, world!
Hello, world!
~$ date
Пн 13 янв 2025 02:22:54 MSK
~$ exit
```

Команда `echo` печатает в stdout введённый пользователем текст, `date` позволяет получить текущую дату и время, а `exit` завершает выполнение процесса командной оболочки.

Создадим файл `emu.py` и поместим в него код, выполняющий эмуляцию указанных команд:

```python
import time

def repl():
    while True:
        match input('> ').split():
            case ('exit',):
                return
            case ('echo', *args):
                print(*args)
            case ('date',):
                print(time.asctime())

repl()
```

При выполнении программы `emu.py` запускается бесконечный цикл `while`, на каждой итерации которого демонстрируется приглашение к вводу `>`. Команда, введённая пользователем в stdin, при помощи метода `split` разделяется по пробельным символам на отдельные слова.

Для распознавания команд используется структурное сопоставление с образцом @pep634. Первое слово, встречающееся во введённой пользователем команде, считается её именем, а все последующие слова – аргументами. Команда `exit` позволяет выйти из бесконечного цикла, команда `echo` печатает введённые пользователем аргументы, а команда `date` печатает текущее время.

Сеанс работы с нашим эмулятором сейчас выглядит так:

```bash
~$ python emu.py
> echo Hello, world!
Hello, world!
> date
Mon Jan 13 02:28:33 2025
> echo Bye, world!
Bye, world!
> exit
```

### Виртуальная файловая система

Теперь добавим в эмулятор поддержку работы с виртуальной файловой системой. Сначала ограничимся отображением текущей директории в приглашении к вводу и поддержкой команд `cd` и `pwd`. Простой сеанс работы с файловой системой из командной оболочки Linux может иметь вид:

```bash
~$ mkdir repo
~$ cd repo
~/repo$ mkdir src
~/repo$ cd src
~/repo/src$ pwd
/home/user/repo/src
~/repo/src$ cd ..
~/repo$ cd ..
~$ cd unknown
bash: cd: unknown: No such file or directory
~$ rm -r repo
```

Команда `mkdir` создаёт пустую папку с указанным именем, а при помощи команды `cd` можно изменить текущую директорию на указанную пользователем. Директория, в которой находится пользователь, отображается в приглашении к вводу @sovietov2021scm. Например, команда `cd repo` меняет текущую директорию с `~` на `~/repo`, и приглашение к вводу имеет вид `~/repo$` вместо `~$`. Команда `pwd` печатает абсолютный путь к текущей директории. Команда `cd ..` позволяет перейти в родительскую директорию по отношению к текущей директории. При попытке перейти в несуществующую директорию `unknown` в консоль выводится сообщение об ошибке.

В файловой системе Linux папка содержит только имя для каждого находящегося внутри файла, а также численный указатель на расположение файла, связанный с его именем. Этот численный указатель также известен как индексный дескриптор (inode number) @unixbook. Структура данных inode, связанная с этим дескриптором, содержит метаданные файла – сведения о файле, за исключением содержащихся в файле данных.

Реализуем в нашем эмуляторе упрощённую модель файловой системы Linux. Создадим класс `Node`, содержащий сведения о типе файла, а также связанные с файлом данные. Реализуем также команды `cd` и `pwd` и подготовим образ виртуальной файловой системы по диаграмме, показанной на @fig:simplefs.

```{#fig:simplefs .pysvg caption="Структура файловой системы, включающей папки `repo` и `src`" width=85%}
dot('''
digraph {
ranksep=0.1
edge [arrowsize=0.5]
node [shape=none, fontsize=14]
rankdir=LR
5 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Node</b></td></tr>
<tr><td port="data" bgcolor="azure3">→</td></tr>
<tr><td>...</td></tr>
</table>>]
5:data -> 6:title
7 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Node</b></td></tr>
<tr><td port="data" bgcolor="azure3">→</td></tr>
<tr><td>...</td></tr>
</table>>]
7:data -> 8:title
9 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Node</b></td></tr>
<tr><td port="data" bgcolor="azure3">→</td></tr>
<tr><td>...</td></tr>
</table>>]
9:data -> 10:title
10 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>Data</b></td></tr>
<tr><td><b>Name</b></td><td><b>Node</b></td></tr>

</table>>]
8:9 -> 9:title
8 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>Data</b></td></tr>
<tr><td><b>Name</b></td><td><b>Node</b></td></tr>
<tr>
<td>src</td>
<td port="9" bgcolor="azure3">→</td>
</tr>
</table>>]
6:7 -> 7:title
6 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>Data</b></td></tr>
<tr><td><b>Name</b></td><td><b>Node</b></td></tr>
<tr>
<td>repo</td>
<td port="7" bgcolor="azure3">→</td>
</tr>
</table>>]
}
''')
```

Обновлённая версия нашего эмулятора теперь имеет вид:

```python
class Node:
    def __init__(self, file_type, data=''):
        self.file_type = file_type
        self.data = data

def cd(node, name):
    if name in node.data and node.data[name].file_type == 'dir':
        return node.data[name]
    print('No such file or directory')
    return node

def pwd(node):
    if par := node.data.get('..'):
        for name in par.data:
            if par.data[name] == node:
                return pwd(par) + name + '/'
    return '/'

def repl(node):
    while True:
        match input(f'{pwd(node)}> ').split():
            case ('exit',):
                return
            case ('cd', name):
                node = cd(node, name)
            case ('pwd',):
                print(pwd(node))
            # Реализация команд echo, date.

src = Node('dir', {})
repo = Node('dir', {'src': src})
root = Node('dir', {'repo': repo})

src.data['..'] = repo
repo.data['..'] = root
repl(root)
```

На вход функции `repl` передаётся подготовленный образ виртуальной файловой системы. Переменная `node` в функции `repl` представляет собой директорию, в которой находится пользователь. В цикл обработки ввода была добавлена поддержка команд `cd` и `pwd`, а реализация команд `echo` и `date` осталась без изменений.

Новая команда `cd` в нашем эмуляторе позволяет перемещаться по файловой системе. Если аргументом команды является слово `..`, текущая директория `node` меняется на родительскую директорию. Новая команда `pwd` позволяет получить путь к текущей директории, в качестве разделителя фрагментов пути используется символ `/`. Путь к текущей директории также печатается в приглашении к вводу, как в командной оболочке Linux.

Проверим работу обновлённого эмулятора:

```bash
~$ python emu.py
/> cd repo
/repo/> cd src
/repo/src/> echo It works!
It works!
/repo/src/> pwd
/repo/src/
/repo/src/> cd ..
/repo/> cd ..
/> cd unknown
No such file or directory
/> exit
```

Для работы с файловой системой полезно иметь возможность создавать как папки, так и файлы – для этого в командной оболочке Linux используются команды `mkdir` и `touch`. Кроме того, нужна возможность просмотра содержимого текущей директории – для этого подойдёт команда `ls` @sovietov2021scm.

Добавим в `emu.py` поддержку команд `mkdir`, `touch` и `ls` :

```python
def mkdir(node, names):
    for name in names:
        node.data[name] = Node('dir', {'..': node})

def touch(node, names):
    for name in names:
        node.data[name] = Node('file')

def ls(node):
    for name in sorted(node.data):
        if name != '..':
            print(name, end=' ')
    print()

def repl(node):
    while True:
        match input(f'{pwd(node)}> ').split():
            case ('exit',):
                return
            case ('mkdir', *names):
                mkdir(node, names)
            case ('touch', *names):
                touch(node, names)
            case ('ls',):
                ls(node)
            # Реализация команд cd, pwd, echo, date.

repl(Node('dir', {}))
```

Функция `ls` возвращает имена файлов и папок, находящихся внутри текущей директории `node`. Команды `mkdir` и `touch` в нашем эмуляторе создают пустые папки и файлы с указанными именами. Функция `mkdir` создаёт объект `Node` с типом файла `dir` и ссылкой `..` на текущую директорию, а функция `touch` создаёт объект `Node` с типом файла `file` с пустым содержимым.

Проверим работу новых команд `mkdir`, `touch` и `ls`:

```bash
~$ python emu.py
/> mkdir repo
/> cd repo
/repo/> mkdir src
/repo/> cd src
/repo/src/> touch hello.js hello.py
/repo/src/> ls
hello.js hello.py
/repo/src/> cd ..
/repo/> touch readme.md
/repo/> ls
src readme.md
/repo/> exit
```

Несложно добавить в эмулятор поддержку команд `cat` для вывода содержимого указанных файлов в stdout и `rm` для удаления файлов. Подготовим образ виртуальной файловой системы, соответствующий диаграмме, показанной на @fig:complexfs.

Обновим код нашего эмулятора:

```python
def cat(node, names):
    for name in names:
        if node.data[name].file_type == 'file':
            print(node.data[name].data)

def rm(node, names):
    for name in names:
        del node.data[name]

def repl(node):
    while True:
        match input(f'{pwd(node)}> ').split():
            case ('exit',):
                return
            case ('cat', *names):
                cat(node, names)
            case ('rm', *names):
                rm(node, names)
            # Реализация команд ls, mkdir, touch, cd, pwd, echo, date.

src = Node('dir', {
    'hello.py': Node('file', 'print("Hello, world!")'),
    'hello.js': Node('file', 'console.log("Hello, world!")'),
})
repo = Node('dir', {'readme.md': Node('file', ''), 'src': src})
root = Node('dir', {'repo': repo})

src.data['..'] = repo
repo.data['..'] = root
repl(root)
```

```{#fig:complexfs .pysvg caption="Структура файловой системы, включающей папки и файлы" width=95%}
dot('''
digraph {
ranksep=0.1
edge [arrowsize=0.5]
node [shape=none, fontsize=14]
rankdir=LR
5 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Node</b></td></tr>
<tr><td port="data" bgcolor="azure3">→</td></tr>
<tr><td>...</td></tr>
</table>>]
5:data -> 6:title
7 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Node</b></td></tr>
<tr><td port="data" bgcolor="azure3">→</td></tr>
<tr><td>...</td></tr>
</table>>]
7:data -> 8:title
9 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Node</b></td></tr>
<tr><td port="data" bgcolor="azure3">→</td></tr>
<tr><td>...</td></tr>
</table>>]
9:data -> 10:title
10 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Data</b></td></tr>
<tr><td> </td></tr>
</table>>]
8:9 -> 9:title
13 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Node</b></td></tr>
<tr><td port="data" bgcolor="azure3">→</td></tr>
<tr><td>...</td></tr>
</table>>]
13:data -> 14:title
15 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Node</b></td></tr>
<tr><td port="data" bgcolor="azure3">→</td></tr>
<tr><td>...</td></tr>
</table>>]
15:data -> 16:title
16 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Data</b></td></tr>
<tr><td>print("Hello, world!")</td></tr>
</table>>]
14:15 -> 15:title
19 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Node</b></td></tr>
<tr><td port="data" bgcolor="azure3">→</td></tr>
<tr><td>...</td></tr>
</table>>]
19:data -> 20:title
20 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>Data</b></td></tr>
<tr><td>console.log("Hello, world!")</td></tr>
</table>>]
14:19 -> 19:title
14 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>Data</b></td></tr>
<tr><td><b>Name</b></td><td><b>Node</b></td></tr>
<tr>
<td>hello.py</td>
<td port="15" bgcolor="azure3">→</td>
</tr>
<tr>
<td>hello.js</td>
<td port="19" bgcolor="azure3">→</td>
</tr>
</table>>]
8:13 -> 13:title
8 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>Data</b></td></tr>
<tr><td><b>Name</b></td><td><b>Node</b></td></tr>
<tr>
<td>readme.md</td>
<td port="9" bgcolor="azure3">→</td>
</tr>
<tr>
<td>src</td>
<td port="13" bgcolor="azure3">→</td>
</tr>
</table>>]
6:7 -> 7:title
6 [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>Data</b></td></tr>
<tr><td><b>Name</b></td><td><b>Node</b></td></tr>
<tr>
<td>repo</td>
<td port="7" bgcolor="azure3">→</td>
</tr>
</table>>]
rank=same { 8; 14 }
}
''')
```

Проверим, работают ли новые команды:

```
~$ python emu.py
/> cd repo
/repo/> cd src
/repo/src/> ls
hello.js hello.py
/repo/src/> cat hello.py hello.js
print("Hello, world!")
console.log("Hello, world!")
/repo/src/> cat hello.js hello.py
console.log("Hello, world!")
print("Hello, world!")
/repo/src/> rm hello.js
/repo/src/> ls
hello.py
/repo/src/> exit
```

### Упражнения

**Задача 1.** Добавьте в реализацию команд `cd`, `mkdir`, `touch`, `cat`, `rm` поддержку абсолютных путей.

**Задача 2.** Реализуйте функцию, которая по заданному пути в файловой системе Linux построит в памяти образ виртуальной файловой системы, совместимый с эмулятором.

**Задача 3.** Спроектируйте формат хранения данных виртуальной файловой системы и реализуйте инструменты для работы с этим форматом: сохранить файловую систему на диске и загрузить её в память с диска.

**Задача 4.** Реализуйте команду `mount` для подключения нескольких файловых систем.

**Задача 5.** Добавьте в эмулятор перенаправление ввода-вывода. Добавьте в эмулятор команду `curl`, совместимую с перенаправлением ввода-вывода.
