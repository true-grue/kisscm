## Разбор объектов git-репозитория

### Служебная папка .git

В этом разделе рассмотрим команду `git cat-file` @gitbook и её применение для получения сведений об объектах, хранящихся в контентно-адресуемой файловой системе git-репозитория.

Для хранения объектов типа `commit`, `tree` и `blob` в реализованной модели git использовался словарь `objects`, однако в «настоящем» git каждый объект хранится в отдельном файле. Попробуем проанализировать содержимое служебной папки `.git` созданного в предыдущем разделе репозитория `repo`. Начнём с визуализации текущего содержимого репозитория в виде дерева при помощи команды `tree`, а затем переместимся в папку `.git` и выведем список служебных файлов и папок git:

```bash
~$ cd repo
~/repo$ tree --noreport
.
├── license
├── readme.md
└── src
    └── hello.py
~$ cd .git
~/repo/.git$ ls
branches  COMMIT_EDITMSG  config  description  HEAD  hooks  index  info  logs  objects  ORIG_HEAD  refs
```

Для получения сведений об объектах типа `commit`, `tree` и `blob` репозитория `repo` необходимо выяснить, с каким коммитом связано текущее содержимое репозитория. Для этого при помощи команды `cat` выведем на экран содержимое файла `HEAD` – указателя на активную в настоящий момент ветку или на коммит @sovietov2021scm.

Сейчас `HEAD` указывает на файл `refs/heads/master`. В этом файле указано хэш-значение объекта типа `commit`, содержащего сведения о последнем коммите в ветке `master`:

```bash
~/repo/.git$ cat HEAD
ref: refs/heads/master
~/repo/.git$ cat refs/heads/master
12c5bb662c4d2f814ab614b6a393d0dc647d9632
```

Для хэширования объектов в git используется алгоритм SHA-1 (Secure Hash Algorithm 1), результатом работы которого является последовательность из 20 байт. Однако, выведенная на экран строка, содержащая хэш-значение коммита, состоит из 40 символов. Это обусловлено тем, что результатом преобразования одного байта в строку, содержащую число в шестнадцатеричной системе счисления, является последовательность из двух символов. Например, байт со значением 255 в десятичной системе будет представлен как `FF` в шестнадцатеричной системе.

Используя выведенное в stdout хэш-значение коммита, легко найти файл со сведениями об объекте типа `commit` в папке `objects`. Для этого необходимо разделить выведенную строку на 2 части – первая часть соответствует первому байту хэш-значения и содержит 2 шестнадцатеричных символа, а вторая часть соответствует оставшимся байтам и содержит 38 шестнадцатеричных символов.

Первая часть выведенного хэш-значения – это имя папки, а вторая часть – это имя файла в папке, содержащего данные объекта:

```bash
~/repo/.git$ ls objects/12
c5bb662c4d2f814ab614b6a393d0dc647d9632
~/repo/.git$ du -b objects/12/c5bb662c4d2f814ab614b6a393d0dc647d9632
184     objects/12/c5bb662c4d2f814ab614b6a393d0dc647d9632
```

Команда `du` с опцией `-b` позволяет оценить размер файла с указанным именем в байтах. Из вывода команд `ls` и `du` следует, что папка с именем `12`, находящаяся внутри папки `objects`, содержит единственный файл с именем `c5bb662c4d2f814ab614b6a393d0dc647d9632`, состоящий из 184 байт. Этот файл – сжатый, и прочитать его содержимое при помощи утилиты `cat` не получится.

### Утилита cat-file

Утилита `cat-file` позволяет получать сведения об объектах git по их хэш-значению. Попробуем при помощи команды `git cat-file` получить сведения о последнем коммите в ветке `master`, на которую указывает `HEAD`:

```bash
~/repo$ git cat-file -t 12c5bb662c4d2f814ab614b6a393d0dc647d9632
commit
~/repo$ git cat-file -p 12c5bb662c4d2f814ab614b6a393d0dc647d9632
tree 30271f5c2174f651b2258352a5ae65208bd61891
parent 1071c39bac0d67990aacd2c5916fd0d3068333d1
parent 7ce8f078ea430a24690786931bd7ab7aa646d845
author User <user@example.com> 1738851204 +0300
committer User <user@example.com> 1738851204 +0300

Merge
```

Выполнение команды `git cat-file` с опцией `-t` позволяет получить тип объекта, связанного с указанным хэш-значением. Выполнение той же команды с опцией `-p` позволяет вывести в stdout данные объекта. Как и в реализованной нами ранее модели git, объект типа `commit` содержит хэш-значения родительских коммитов в строках с префиксом `parent`, хэш-значение связанного с коммитом объекта папки в строке с префиксом `tree`, а также сведения об авторе коммита в строке с префиксом `author` и текст сообщения к коммиту в последующих строках.

Попробуем вывести содержимое связанного с коммитом объекта типа `tree`, а также содержимое объекта типа `blob` для одного из находящихся внутри папки файлов:

```bash
~/repo$ git cat-file -t 30271f5c2174f651b2258352a5ae65208bd61891
tree
~/repo$ git cat-file -p 30271f5c2174f651b2258352a5ae65208bd61891
100644 blob a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc    license
100644 blob b80f0bd60822d4fa4893de455958ef32f6c521bf    readme.md
040000 tree 11a1faff831b47b7268b7981726a177b36358639    src
~/repo$ git cat-file -t a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc
blob
~/repo$ git cat-file -p a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc
MIT
```

Объекты с содержимым файлов имеют тип `blob`, а объекты-папки имеют тип `tree`. Для объекта типа `tree` команда `git cat-file` построчно выводит в stdout список содержащихся внутри файлов и папок. Каждая строка в выводе содержит права доступа к файлу или папке @sovietov2021scm, тип объекта (`blob` для файла и `tree` для папки), хэш-значение связанного с именем объекта, а также имя объекта. Для объекта типа `blob` команда `git cat-file` выводит в stdout его содержимое.

### Реализация cat-file на Python

Теперь попробуем реализовать на языке Python утилиту командной строки, позволяющую выводить в stdout сведения об объектах из служебной папки `.git` по заданному хэш-значению. Начнём с реализации утилиты, имитирующей поведение команды `git cat-file` с опцией `-t`.

Создадим новый файл `cat-file.py` и поместим в него следующий код, содержащий 2 функции – `cat_file` и `cat_object`:

```python
import os, sys, zlib

def cat_object(obj):
    header, content = obj.split(b'\0', 1)
    header, size = header.split(b' ')
    print(header.decode())

def cat_file(repo, h):
  path = os.path.join(repo, '.git', 'objects', h[:2], h[2:])
  with open(path, 'rb') as f:
    cat_object(zlib.decompress(f.read()))

cat_file(sys.argv[1], sys.argv[2])
```

Функция `cat_file` принимает на вход путь к папке git-репозитория и хэш-значение объекта, тип которого необходимо вывести в stdout, и вычисляет путь к файлу с данными объекта `path`. В качестве имени папки используются первые 2 символа хэш-значения, а в качестве имени файла – остальные 38 символов. Файл по пути `path` открывается на чтение в двоичном режиме. Прочитанные байты подаются на вход функции `decompress` из стандартного модуля `zlib`, функция `decompress` выполняющей разжатие содержимого файла со сведениями об объекте git.

Затем сведения об объекте git подаются на вход функции `cat_object`, которая отделяет заголовок от данных, используя байт со значением 0 в качестве разделителя. Заголовок имеет формат `<тип> <размер>`, где `<тип>` может принимать значение `commit`, `tree` или `blob`, а `<размер>` – это число байт, которое занимают данные объекта `content`. Следовательно, для вывода в stdout типа объекта необходимо разделить заголовок по символу пробела.

Префикс `b`, указанный перед строками в функции `cat_object`, необходим, поскольку на вход функции `cat_object` поступают данные объекта в виде массива байт. Преобразование массива байт в строку выполняется перед выводом заголовка объекта `header` в консоль при помощи вызова метода `decode`.

Сравним вывод `cat-file.py` с выводом команды `git cat-file` с опцией `-t`:

```bash
~$ python cat-file.py repo 12c5bb662c4d2f814ab614b6a393d0dc647d9632
commit
~$ python cat-file.py repo 30271f5c2174f651b2258352a5ae65208bd61891
tree
~$ cd repo
~/repo$ git cat-file -t 12c5bb662c4d2f814ab614b6a393d0dc647d9632
commit
~/repo$ git cat-file -t 30271f5c2174f651b2258352a5ae65208bd61891
tree
```

Доработаем утилиту `cat-file.py` таким образом, чтобы можно было получать сведения об объекте git по его хэш-значению в формате, похожем на формат вывода команды `git cat-file` с опцией `-p`.

Обновим содержимое файла `cat-file.py`:

```python
import os, sys, zlib

def cat_tree(content):
    while content:
        mode, content = content.split(b' ', 1)
        name, content = content.split(b'\0', 1)
        h, content = content[:20], content[20:]
        print(f'{int(mode):06}', h.hex(), name.decode())

def cat_object(obj):
    header, content = obj.split(b'\0', 1)
    header, size = header.split(b' ')
    match header.decode():
        case 'commit' | 'blob':
            print(content.decode().rstrip())
        case 'tree':
            cat_tree(content)

def cat_file(repo, h):
  path = os.path.join(repo, '.git', 'objects', h[:2], h[2:])
  with open(path, 'rb') as f:
      cat_object(zlib.decompress(f.read()))

cat_file(sys.argv[1], sys.argv[2])
```

Мы добавили в файл `cat-file.py` новую функцию `cat_tree`, а также обновили содержимое функции `cat_object`. Теперь, если объект имеет тип `commit` или `blob`, то байты с данными объекта преобразуются в строку и выводятся в stdout. В случае, если объект имеет тип `tree`, управление передаётся в функцию `cat_tree`, которая осуществляет разбор байт `content` с данными об объектах, содержащихся в папке.

Функция `cat_tree` сначала разделяет набор байт по первому встреченному символу пробела. Прочитанное значение слева от пробела `mode` – это права доступа к файлу или папке. После этого оставшаяся часть набора байт разделяется по первому встреченному байту со значением 0. Прочитанное значение `name` слева от нулевого байта – это имя файла или папки. Следующие за нулевым байтом 20 символов содержат хэш-значение `h` объекта файла или папки с именем `name`.

Проверим работу обновлённой утилиты `cat-file.py`:

```bash
~$ python cat-file.py repo 12c5bb662c4d2f814ab614b6a393d0dc647d9632
tree 30271f5c2174f651b2258352a5ae65208bd61891
parent 1071c39bac0d67990aacd2c5916fd0d3068333d1
parent 7ce8f078ea430a24690786931bd7ab7aa646d845
author User <user@example.com> 1738851204 +0300
committer User <user@example.com> 1738851204 +0300

Merge
~$ python cat-file.py repo 30271f5c2174f651b2258352a5ae65208bd61891
100644 a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc license
100644 b80f0bd60822d4fa4893de455958ef32f6c521bf readme.md
040000 11a1faff831b47b7268b7981726a177b36358639 src
~$ python cat-file.py repo a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc
MIT
```

Реализованная в файле `cat-file.py` функция `cat_file`, позволяющая по хэш-значению объекта получить его данные, может использоваться и при построении графа объектов, сохранённых в служебной папке `.git`.

Граф объектов, построенный для анализируемого в данном разделе репозитория `repo`, показан на @fig:repograph.

```{#fig:repograph .pysvg caption="Содержимое репозитория `repo` в виде графа коммитов" width=90%}
dot('''
digraph {
ranksep=0.2
nodesep=0.1
edge [arrowsize=0.5]
node [shape=none, fontsize=12]
rankdir=LR
"12c5bb662c4d2f814ab614b6a393d0dc647d9632"->"30271f5c2174f651b2258352a5ae65208bd61891":"title"
"b376c9941fda362c8d2c5c8ddb35db3e0b003402" [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>b376c99</b><b> </b>blob</td></tr>
<tr><td>print('hello')</td></tr>
</table>>]
"7ce8f078ea430a24690786931bd7ab7aa646d845"->"668ba6deb6b497d0ee51fff1badfcde8a8be22c1":"title"
"b80f0bd60822d4fa4893de455958ef32f6c521bf" [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>b80f0bd</b><b> </b>blob</td></tr>
<tr><td>app</td></tr>
</table>>]
"f0e0c149280a45a1a91e80b81daf0a4913922f7e"->"2f4610130fcc78446e8428c71d05f5d78498332d":"title"
"2f4610130fcc78446e8428c71d05f5d78498332d" [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>2f46101</b><b> </b>tree</td></tr>
<tr>
<td>license</td>
<td port="a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc" bgcolor="azure3">→ </td>
</tr>
</table>>]
"a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc" [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title"><b>a22a2da</b><b> </b>blob</td></tr>
<tr><td>MIT</td></tr>
</table>>]
"30271f5c2174f651b2258352a5ae65208bd61891":"11a1faff831b47b7268b7981726a177b36358639"->"11a1faff831b47b7268b7981726a177b36358639":"title"
"12c5bb662c4d2f814ab614b6a393d0dc647d9632"->"7ce8f078ea430a24690786931bd7ab7aa646d845"
"12c5bb662c4d2f814ab614b6a393d0dc647d9632" [shape=doublecircle,
      fixedsize=true,
      width=0.7,
      label=<<b>12c5bb6</b><br/>Merge>,
      fillcolor="azure3"]
"668ba6deb6b497d0ee51fff1badfcde8a8be22c1":"a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc"->"a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc":"title"
"12c5bb662c4d2f814ab614b6a393d0dc647d9632"->"1071c39bac0d67990aacd2c5916fd0d3068333d1"
"1071c39bac0d67990aacd2c5916fd0d3068333d1" [shape=doublecircle,
      fixedsize=true,
      width=0.7,
      label=<<b>1071c39</b><br/>Code>,
      fillcolor="azure3"]
"bcdf66d768ef35a7831bc9502d027b8dde641414":"a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc"->"a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc":"title"
"f0e0c149280a45a1a91e80b81daf0a4913922f7e" [shape=doublecircle,
      fixedsize=true,
      width=0.7,
      label=<<b>f0e0c14</b><br/>Init>,
      fillcolor="azure3"]
"1071c39bac0d67990aacd2c5916fd0d3068333d1"->"f0e0c149280a45a1a91e80b81daf0a4913922f7e"
"bcdf66d768ef35a7831bc9502d027b8dde641414":"11a1faff831b47b7268b7981726a177b36358639"->"11a1faff831b47b7268b7981726a177b36358639":"title"
"11a1faff831b47b7268b7981726a177b36358639":"b376c9941fda362c8d2c5c8ddb35db3e0b003402"->"b376c9941fda362c8d2c5c8ddb35db3e0b003402":"title"
"1071c39bac0d67990aacd2c5916fd0d3068333d1"->"bcdf66d768ef35a7831bc9502d027b8dde641414":"title"
"7ce8f078ea430a24690786931bd7ab7aa646d845" [shape=doublecircle,
      fixedsize=true,
      width=0.7,
      label=<<b>7ce8f07</b><br/>Docs>,
      fillcolor="azure3"]
"30271f5c2174f651b2258352a5ae65208bd61891" [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>30271f5</b><b> </b>tree</td></tr>
<tr>
<td>license</td>
<td port="a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc" bgcolor="azure3">→ </td>
</tr>
<tr>
<td>readme.md</td>
<td port="b80f0bd60822d4fa4893de455958ef32f6c521bf" bgcolor="azure3">→ </td>
</tr>
<tr>
<td>src</td>
<td port="11a1faff831b47b7268b7981726a177b36358639" bgcolor="azure3">→ </td>
</tr>
</table>>]
"668ba6deb6b497d0ee51fff1badfcde8a8be22c1" [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>668ba6d</b><b> </b>tree</td></tr>
<tr>
<td>license</td>
<td port="a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc" bgcolor="azure3">→ </td>
</tr>
<tr>
<td>readme.md</td>
<td port="b80f0bd60822d4fa4893de455958ef32f6c521bf" bgcolor="azure3">→ </td>
</tr>
</table>>]
"bcdf66d768ef35a7831bc9502d027b8dde641414" [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>bcdf66d</b><b> </b>tree</td></tr>
<tr>
<td>license</td>
<td port="a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc" bgcolor="azure3">→ </td>
</tr>
<tr>
<td>src</td>
<td port="11a1faff831b47b7268b7981726a177b36358639" bgcolor="azure3">→ </td>
</tr>
</table>>]
"7ce8f078ea430a24690786931bd7ab7aa646d845"->"f0e0c149280a45a1a91e80b81daf0a4913922f7e"
"30271f5c2174f651b2258352a5ae65208bd61891":"a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc"->"a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc":"title"
"668ba6deb6b497d0ee51fff1badfcde8a8be22c1":"b80f0bd60822d4fa4893de455958ef32f6c521bf"->"b80f0bd60822d4fa4893de455958ef32f6c521bf":"title"
"2f4610130fcc78446e8428c71d05f5d78498332d":"a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc"->"a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc":"title"
"11a1faff831b47b7268b7981726a177b36358639" [label=<
<table border="0" cellborder="1" cellspacing="0">
<tr><td port="title" colspan="2"><b>11a1faf</b><b> </b>tree</td></tr>
<tr>
<td>hello.py</td>
<td port="b376c9941fda362c8d2c5c8ddb35db3e0b003402" bgcolor="azure3">→ </td>
</tr>
</table>>]
"30271f5c2174f651b2258352a5ae65208bd61891":"b80f0bd60822d4fa4893de455958ef32f6c521bf"->"b80f0bd60822d4fa4893de455958ef32f6c521bf":"title"
}
''')
```

Круглые вершины на @fig:repograph соответствуют коммитам, а прямоугольные — объектам типа `tree` или `blob`, как и в графе коммитов, построенном для модели git и показанном на @fig:gitgraph. Кроме того, в граф на @fig:repograph также включены первые 7 шестнадцатеричных символов хэш-значений каждого объекта.

Подграф показанного на @fig:repograph графа коммитов легко построить при помощи стандартных средств, воспользовавшись командой `git log` с опциями `--graph` и `--oneline`:

```
~$ cd repo
~/repo$ git log --graph --oneline
*   12c5bb6 (HEAD -> master) Merge
|\
| * 7ce8f07 (docs) Docs
* | 1071c39 Code
|/
* f0e0c14 Init
```

### Упражнения

**Задача 1.** Вывод реализованной утилиты `cat-file.py` почти совпадает с выводом команды `git cat-file` с опцией `-p`, однако в выводе содержимого объекта типа `tree` отсутствуют сведения о типах содержащихся в папке объектов – `blob` или `tree`. Исправьте утилиту `cat-file` так, чтобы её вывод совпадал с выводом `git cat-file`:

```bash
~$ python cat-file.py repo 30271f5c2174f651b2258352a5ae65208bd61891
100644 a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc license
100644 b80f0bd60822d4fa4893de455958ef32f6c521bf readme.md
040000 11a1faff831b47b7268b7981726a177b36358639 src
~$ cd repo
~/repo$ git cat-file -p 30271f5c2174f651b2258352a5ae65208bd61891
100644 blob a22a2da24d1ceeef3d0c2f1f4f68923f55b8d4cc    license
100644 blob b80f0bd60822d4fa4893de455958ef32f6c521bf    readme.md
040000 tree 11a1faff831b47b7268b7981726a177b36358639    src
```

**Задача 2.** Создайте визуализатор содержимого `.git/objects` с использованием инструмента Graphviz @graphviz, позволяющий получить изображение графа коммитов, показанного на @fig:gitgraph. Воспользуйтесь реализованной ранее функцией `cat_file`. Эту функцию потребуется доработать так, чтобы она возвращала сведения об объектах вместо вывода их содержимого в stdout.

**Задача 3.** Создайте инструмент `undo.py` для восстановления файла по имени, если файл более не присутствует в текущем дереве.

**Задача 4.** Создайте инструмент для извлечения всех сообщений коммитов из заданного репозитория.

**Задача 5.** Разберитесь, что собой представляют упакованные (packed) объекты репозитория. Доработайте свой вариант `cat-file.py` для поддержки упакованных объектов.