### Загрузка списка пакетов Debian

Менеджер пакетов apt используется для автоматического управления установкой и настройкой пакетов @sovietov2021scm в Debian и в различных дистрибутивах Linux, основанных на Debian, таких как Ubuntu, Kubuntu, Kali Linux @debianpm. Например, сеанс работы с командной строкой для установки пакета `jq` может иметь следующий вид:

```
~$ apt update
Сущ:1 http://ru.archive.ubuntu.com/ubuntu jammy InRelease
Пол:2 http://ru.archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
Пол:4 http://ru.archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
Сущ:6 http://security.ubuntu.com/ubuntu jammy-security InRelease
Получено 255 kB за 0с (515 kB/s)
Чтение списков пакетов… Готово
~$ apt install -y jq | tail -n 7
Подготовка к распаковке …/jq_1.6-2.1ubuntu3_amd64.deb
Распаковывается jq (1.6-2.1ubuntu3)
Настраивается пакет libonig5:amd64 (6.9.7.1-2build1)
Настраивается пакет libjq1:amd64 (1.6-2.1ubuntu3)
Настраивается пакет jq (1.6-2.1ubuntu3)
Обрабатываются триггеры для man-db (2.10.2-1)
Обрабатываются триггеры для libc-bin (2.35-0ubuntu3.8)
~$ apt depends jq
jq
  Зависит: libjq1 (= 1.6-2.1ubuntu3)
  Зависит: libc6 (>= 2.34)
```

Команда `update` пакетного менеджера apt позволяет получить сведения о доступных для установки пакетах из удалённых репозиториев, адреса которых указаны в файле `/etc/apt/sources.list`, а также в файлах, находящихся внутри папки `/etc/apt/sources.list.d`. Команда `install` устанавливает пакет с заданным именем, а опция `-y` отключает подтверждение установки в интерактивном режиме. При установке пакета из удалённого репозитория загружаются и распаковываются архивы с расширением `.deb` для устанавливаемого пакета и для всех его зависимостей, если нужные версии этих зависимостей уже не были установлены ранее @debianpm. Команда `depends` выводит в stdout список зависимостей пакета.

В этом разделе рассматривается процесс разработки средства построения графа зависимостей для заданного пакета Debian на основе анализа метаданных пакетов в формате `Packages.gz`.

Начнём с получения списка адресов удалённых репозиториев с пакетами Debian. Получить список адресов можно при помощи конвейера, состоящего из команды `cat` для чтения содержимого файла `/etc/apt/sources.list` и всех файлов из папки `/etc/apt/sources.list.d`, утилиты `grep` в режиме с поддержкой регулярных выражений для удаления комментариев, утилиты `uniq` для удаления дубликатов строк:

```bash
~$ cat /etc/apt/sources.list /etc/apt/sources.list.d/* |
grep -Eo 'deb.*http[^ ]+' | uniq
deb http://ru.archive.ubuntu.com/ubuntu/
deb http://security.ubuntu.com/ubuntu
```

Загрузим HTML-страницу по первой из полученных ссылок при помощи `curl`:

```bash
~$ curl -s http://ru.archive.ubuntu.com/ubuntu/ | tr -s ' '
<html>
<head><title>Index of /ubuntu/</title></head>
<body>
<h1>Index of /ubuntu/</h1><hr><pre><a href="../">../</a>
<a href="dists/">dists/</a> 17-Oct-2024 10:07 -
<a href="indices/">indices/</a> 21-Jan-2025 08:00 -
<a href="pool/">pool/</a> 27-Feb-2010 06:30 -
<a href="project/">project/</a> 24-Nov-2024 21:31 -
<a href="ubuntu/">ubuntu/</a> 21-Jan-2025 18:58 -
<a href="ls-lR.gz">ls-lR.gz</a> 21-Jan-2025 08:05 30M
</pre><hr></body>
</html>
```

Утилита `tr` с опцией `-s` позволяет избавиться от повторов переданного в качестве параметра опции символа.

Загруженная HTML-страница содержит ссылки на папки. Пакеты Debian находятся в подкаталогах папки `dists`, причём для разных дистрибутивов Ubuntu и разных архитектур удалённый репозиторий содержит разные файлы `Packages.gz`.

Папка `dists` содержит только папки, имена которых совпадают с кодовыми именами версий дистрибутивов Ubuntu, пакеты для которых предоставляет удалённый репозиторий. Узнать кодовое имя версии дистрибутива Ubuntu и архитектуру системы можно следующим образом:

```bash
~$ uname -m
x86_64
~$ cat /etc/os-release | head -n 5
PRETTY_NAME="Ubuntu 22.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
```

Переместимся в папку `jammy`:

```bash
~$ curl -s -L http://ru.archive.ubuntu.com/ubuntu/dists/jammy | tr -s ' '
<html>
<head><title>Index of /ubuntu/dists/jammy/</title></head>
<body>
<h1>Index of /ubuntu/dists/jammy/</h1><hr><pre><a href="../">../</a>
<a href="by-hash/">by-hash/</a> 15-Oct-2021 12:15 -
<a href="main/">main/</a> 10-Nov-2021 22:59 -
<a href="multiverse/">multiverse/</a> 11-Nov-2021 03:59 -
<a href="restricted/">restricted/</a> 10-Nov-2021 23:13 -
<a href="universe/">universe/</a> 11-Nov-2021 00:23 -
<a href="Contents-amd64.gz">Contents-amd64.gz</a> 21-Apr-2022 04:26 45M
<a href="Contents-i386.gz">Contents-i386.gz</a> 21-Apr-2022 05:56 35M
<a href="InRelease">InRelease</a> 21-Apr-2022 17:16 264K
<a href="Release">Release</a> 21-Apr-2022 17:16 263K
<a href="Release.gpg">Release.gpg</a> 21-Apr-2022 17:16 819
</pre><hr></body>
</html>
```

Папка `main` внутри папки `jammy` содержит пакеты компонентов Ubuntu, поддерживаемые издателем дистрибутива Ubuntu. В папке `universe` расположены сторонние пакеты, поддерживаемые сообществом разработчиков.

Переместимся в папку `main`, а затем – в папку `binary-amd64`, содержащую пакеты Debian, совместимые с архитектурой AMD64. В этой папке находится файл `Packages.gz`, содержащий метаданные всех пакетов Ubuntu 22.04 LTS `jammy`, поддерживаемых издателем и совместимых с архитектурой AMD64:

```bash
~$ curl -s http://ru.archive.ubuntu.com/ubuntu/dists/jammy/main/binary-amd64/ | tr -s ' '
<html>
<head><title>Index of /ubuntu/dists/jammy/main/binary-amd64/</title></head>
<body>
<h1>Index of /ubuntu/dists/jammy/main/binary-amd64/</h1><hr><pre><a href="../">../</a>
<a href="by-hash/">by-hash/</a> 15-Oct-2021 12:15 -
<a href="Packages.gz">Packages.gz</a> 21-Apr-2022 17:16 2M
<a href="Packages.xz">Packages.xz</a> 21-Apr-2022 17:16 1M
<a href="Release">Release</a> 21-Apr-2022 17:16 95
</pre><hr></body>
</html>
```

Файлы `Packages.gz` легко загрузить из удалённого репозитория:

```bash
~$ curl -s -o main.gz http://ru.archive.ubuntu.com/ubuntu/dists/jammy/main/binary-amd64/Packages.gz
~$ curl -s -o universe.gz http://ru.archive.ubuntu.com/ubuntu/dists/jammy/universe/binary-amd64/Packages.gz
~$ ls -la
-rw-rw-r-- 1 user user  1792213 янв 21 18:10 main.gz
-rw-rw-r-- 1 user user 17471387 янв 21 18:10 universe.gz
```

### Разбор формата Packages.gz

Распакуем загруженные файлы `main.gz` и `universe.gz` при помощи стандартной утилиты `gzip`:

```bash
~$ gzip -d main.gz universe.gz
~$ ls -la
-rw-rw-r-- 1 user user  6779186 янв 21 18:11 main
-rw-rw-r-- 1 user user 64332414 янв 21 18:11 universe
```

В результате распаковки были получены текстовые файлы `main` и `universe`. Файл `main` содержит метаданные пакетов, поддерживаемых издателем Ubuntu, а файл `universe` – метаданные пакетов от сторонних разработчиков. В этих файлах в начале блока с описанием каждого пакета приводится его название, указанное после подстроки `Package:`, а также его метаданные, такие как перечень зависимостей, версия, архитектура:

```
~$ cat main | head -n 3
Package: accountsservice
Architecture: amd64
Version: 22.07.5-2ubuntu1
~$ cat main | grep 'Package' | head -n 3
Package: accountsservice
Package: acct
Package: acl
~$ cat main | grep 'Depends' | head -n 3
Depends: dbus (>= 1.9.18), libaccountsservice0 (= 22.07.5-2ubuntu1), libc6 (>= 2.34), libglib2.0-0 (>= 2.63.5), libpolkit-gobject-1-0 (>= 0.99)
Pre-Depends: init-system-helpers (>= 1.54~)
Depends: libc6 (>= 2.34), lsb-base
```

Приступим к реализации средства построения графа зависимостей. Сначала попробуем проанализировать текстовые файлы `main` и `universe` и получить структуру данных, содержащую имя пакета и сведения о его зависимостях. Создадим файл `deb.py` со следующим содержимым:

```python
import re

def load_packages(path):
    with open(path, 'r', encoding='utf-8') as file:
        for line in file:
            if line.startswith('Package:'):
                name = line.split()[1]
            if re.match(r'(Pre-|)Depends:', line):
                yield name, line.strip()

print(*load_packages('main'),
      *load_packages('universe'), sep='\n')
```

В приведённом коде мы открываем на чтение файл по указанному пути и в цикле выполняем построчную обработку содержимого файла. Функция `load_packages` возвращает генератор @pep255. В случае, если встретилась строка, начинающаяся с подстроки `Package:`, мы извлекаем имя пакета и помещаем его в переменную `name`. В случае, если встретилась строка, начинающаяся с подстроки `Depends:` или `Pre-Depends:`, мы возвращаем имя пакета и строку со сведениями о его зависимостях, после чего продолжаем выполнение цикла.

Воспользуемся `deb.py` для вывода зависимостей пакетов `jq` и `cowsay`:

```bash
~$ ls
deb.py  main  universe
~$ python deb.py | grep -E "'jq'|'cowsay'"
('jq', 'Depends: libjq1 (= 1.6-2.1ubuntu3), libc6 (>= 2.34)')
('cowsay', 'Depends: libtext-charwidth-perl, perl:any')
```

Наш инструмент уже позволяет получать сведения о прямых зависимостях заданного пакета. Однако, на практике у прямой зависимости могут быть и свои собственные зависимости, которые необходимо установить как для её корректной работы, так и для корректной работы исходного пакета – такие зависимости называют **транзитивными**. Получение и вывод транзитивных зависимостей в нашем инструменте пока не поддерживается.

Попробуем доработать код и сформировать словарь, в котором ключами являются имена пакетов, а значениями – списки зависимостей пакетов:

```python
import re

def load_packages(path):
    packages = {}
    with open(path, 'r', encoding='utf-8') as file:
        for line in file:
            if line.startswith('Package:'):
                name = line.split()[1]
                packages[name] = set()
            elif re.match(r'(Pre-|)Depends:', line):
                deps = re.sub(r'(Pre-|)Depends:|:any|,|\||\([^,]+\)', ' ', line)
                packages[name] |= set(deps.split())
    return packages

packages = load_packages('main') | load_packages('universe')
print(packages)
```

Теперь в случае, если при построчной обработке содержимого файла в начале строки встречается подстрока `Package:`, в словарь `packages` добавляется новый ключ – имя пакета, а значением по этому ключу является пустое множество. В случае, если строка содержит перечень зависимостей, то подстроки `Pre-Depends:`, `Depends:`, `:any`, а также сведения о версиях зависимостей, указанные в круглых скобках, заменяются на пробел, после чего строка разделяется на части по символу пробела. Полученный результат добавляется в множество зависимостей пакета. Запись `a |= b` в Python эквивалентна записи `a = a | b`, где оператор `|` выполняет объединение множеств в том случае, если переменные `a` и `b` являются множествами – имеют тип `set`. На последней строке в примере кода выше оператор `|` используется для объединения словаря, содержащего сведения о пакетах и их зависимостях из файла `main`, со словарём, содержащим сведения о пакетах и их зависимостях из файла `universe`.

Проверим работу обновлённого инструмента:

```bash
~$ python deb.py | cut -c 1-275
{'accountsservice': {'libglib2.0-0', 'libaccountsservice0', 'dbus', 'libc6', 'libpolkit-gobject-1-0'}, 'acct': {'libc6', 'init-system-helpers', 'lsb-base'}, 'acl': {'libc6', 'libacl1'}, 'acpi-support': {'acpid'}, 'acpid': {'libc6', 'init-system-helpers', 'kmod', 'lsb-base'},
```

Утилита `cut` позволяет ограничить длину выводимой в stdout строки путём задания промежутка выводимых символов при помощи опции `-c`. В результате работы функции `load_packages` был построен граф зависимостей `packages`, представленный в виде словаря `dict[str, list[str]]`, ключ в котором – это имя пакета, а значение – множество смежных с пакетом вершин. Граф включает как пакеты, поддерживаемые издателем Ubuntu (файл `main`), так и пакеты, поддерживаемые сообществом разработчиков (файл `universe`).

### Визуализация графа в редакторе yEd

Для построения графа зависимостей пакета с заданным именем на основе графа зависимостей всех пакетов `packages`, полученного по результатам анализа файлов в формате `Packages.gz` из репозитория `ru.archive.ubuntu.com`, добавим функцию `make_graph` в файл `deb.py`. Кроме того, имя пакета Debian, граф зависимостей которого необходимо построить, будем передавать программе как аргумент командной строки – для получения аргумента командной строки воспользуемся модулем `sys`:

```python
import sys

def make_graph(root, packages):
    def dfs(name):
        graph[name] = set()
        for dep in packages.get(name, set()):
            if dep not in graph:
                dfs(dep)
            graph[name].add(dep)

    graph = {}
    dfs(root)
    return graph

packages = load_packages('main') | load_packages('universe')
root = sys.argv[1]
graph = make_graph(root, packages)
print(graph)
```

Функция `make_graph` принимает на вход имя пакета `root` и граф зависимостей всех пакетов `packages`. Вложенная функция `dfs` обходит граф зависимостей `packages` в глубину (Depth-First Search, DFS) и выполняет построение нового графа, содержащего только пакет с именем `name` и его зависимости.

Проверим работу `make_graph`, построив граф зависимостей для пакета `jq`:

```python
~$ python deb.py jq
{'jq': {'libc6', 'libjq1'}, 'libc6': {'libcrypt1', 'libgcc-s1'}, 'libcrypt1': {'libc6'}, 'libgcc-s1': {'libc6', 'gcc-12-base'}, 'gcc-12-base': set(), 'libjq1': {'libc6', 'libonig5'}, 'libonig5': {'libc6'}}
```

Для визуализации графа зависимостей воспользуемся библиотекой с открытым исходным кодом `yed.py` @yed_py. Библиотека состоит из единственного файла `yed.py` и позволяет при помощи языка Python генерировать описание графа в формате `graphml`, основанном на формате XML (eXtensible Markup Language) @sovietov2021scm. Формат `graphml` используется в редакторе диаграмм yEd @yed для описания графов.

Установим библиотеку `yed.py`:

```bash
~$ curl -s -o yed.py https://raw.githubusercontent.com/true-grue/yed_py/refs/heads/master/yed.py
~$ ls
deb.py  main  universe  yed.py
```

Добавим в файл `deb.py` функцию `viz` для преобразования графа зависимостей в формат `graphml` с целью его последующей визуализации в редакторе диаграмм и графов yEd:

```python
import yed

def viz(graph, path):
    y = yed.Graph()
    nodes = {}
    for name in graph:
        nodes[name] = y.node(text=name, font_family='Times New Roman',
                             shape='box', height=25)
    for name, deps in graph.items():
        for dep in deps:
            y.edge(nodes[name], nodes[dep])
    y.save(f'{path}.graphml')

packages = load_packages('main') | load_packages('universe')
root = sys.argv[1]
graph = make_graph(root, packages)
viz(graph, root)
```

Функция `viz` для ключей словаря `graph`, представленных именами пакетов, генерирует фрагменты `graphml` с описанием вершин графа. После этого при повторном обходе словаря `graph` генерируются связи между каждым пакетом и связанными с ним пакетами. Результат работы функции `viz` сохраняется в файл, расположенный по пути `path`.

Проверим работу обновлённого средства для визуализации зависимостей:

```bash
~$ python deb.py jq
~$ ls
deb.py  jq.graphml  main  universe  yed.py
~$ cat jq.graphml | head -n 10 | tail -n 3
<y:ShapeNode>
<y:Geometry x="0" y="0" width="50" height="50"/>
<y:Fill color="#ffffff"/>
```

Для того, чтобы визуализировать сгенерированный и сохранённый в файл `jq.graphml` граф зависимостей, файл `jq.graphml` необходимо открыть в редакторе yEd @yed и выбрать иерархическую компоновку вершин графа в меню `Layout`. Результат визуализации графа в редакторе yEd показан на @fig:jq-graph.

![Граф зависимостей пакета jq](jq-graph.svg){#fig:jq-graph}

Серым цветом на @fig:jq-graph показаны циклические зависимости:

- Пакет `libc6` зависит от `libgcc-s1`, причём `libgcc-s1` также зависит от `libc6`.
- Пакет `libc6` зависит от `libcrypt1`, причём `libcrypt1` также зависит от `libc6`.

Попробуем исключить из @fig:jq-graph стрелки, выделенные серым цветом, разрывая циклические зависимости при построении графа зависимостей пакета. Заменим в `deb.py` функцию `make_graph` на функцию `make_dag`, оставив без изменений остальной код:

```python
def make_dag(root, packages):
    def dfs(name):
        graph[name] = set()
        for dep in packages.get(name, set()):
            if dep not in graph:
                dfs(dep)
            if dep in seen:
                graph[name].add(dep)
        seen.add(name)

    seen = set()
    graph = {}
    dfs(root)
    return graph

packages = load_packages('main') | load_packages('universe')
root = sys.argv[1]
graph = make_dag(root, packages)
viz(graph, root)
```

Функция `make_dag` в процессе обхода исходного графа зависимостей в глубину сохраняет вершины графа в множестве `seen` после завершения их обработки, при этом связи между вершинами добавляются в граф-результат `graph` только в том случае, если вершина ещё не была обработана и отсутствует в множестве `seen` – таким образом удаётся разорвать циклы, которые могут присутствовать в исходном графе. Результатом работы функции `make_dag` является направленный ациклический граф (Directed Acyclic Graph, DAG).

Повторно сформируем граф зависимостей пакета `jq` для yEd:

```bash
~$ python deb.py jq
~$ ls
deb.py  jq.graphml  main  universe  yed.py
```

Обновлённый результат визуализации графа зависимостей пакета `jq`, сохранённого в файл `jq.graphml`, показан на @fig:jq-dag. По сравнению с @fig:jq-graph, в графе, показанном на @fig:jq-dag, отсутствуют циклы.

![Ациклический граф зависимостей пакета jq](jq-dag.svg){#fig:jq-dag}

Попробуем сформировать граф для пакета с большим числом зависимостей:

```bash
~$ python deb.py cowsay
~$ ls
cowsay.graphml  deb.py  jq.graphml  main  universe  yed.py
```

Результат визуализации `cowsay.graphml` в редакторе yEd показан на @fig:cowsay-dag.

![Ациклический граф зависимостей пакета cowsay](cowsay-dag.svg){#fig:cowsay-dag width=100%}

### Упражнения

**Задача 1.** Измените формат вывода графов зависимостей на язык `dot`, используемый в Graphviz @graphviz. Изобразите графы зависимостей для пакетов `jq` и `cowsay`.

**Задача 2.** Реализуйте инструмент командной строки для построения графа зависимостей для разных версий одного и того же пакета Debian, требуемая версия пакета указывается как параметр командной строки.

**Задача 3.** Реализуйте инструмент командной строки для построения графа зависимостей для одного из менеджеров пакетов, перечисленных в @tbl:pms, на Ваш выбор. Имя пакета, граф зависимостей которого необходимо построить, и его версия указываются как параметры командной строки.

Менеджер пакетов    Репозиторий                              Формат
------------------  ---------------------------------------  ---------------
pip                 pypi.org/pypi/{name}/json                JSON
npm                 registry.npmjs.org/{name}                JSON
crates              crates.io/api/v1/crates/{name}/{version} JSON
Maven               repo1.maven.org/maven2                   XML, pom-файл
NuGet               api.nuget.org/v3                         XML
apk                 dl-cdn.alpinelinux.org/alpine/           APKINDEX.tar.gz
apt                 archive.ubuntu.com/ubuntu/               Packages.gz

: Менеджеры пакетов {#tbl:pms}

**Задача 4.** Найдите прикладное ПО (это не должна быть ОС или язык программирования) со встроенным менеджером пакетов. Постройте визуализатор зависимостей между всеми пакетами этого ПО.

**Задача 5.** При визуализации зависимостей между всеми пакетами репозиториев Debian инструмент визуализации или не справится со своей работой, или же результат окажется совершенно неразборчивым. Придумайте и реализуйте способ производительной и наглядной визуализации графа зависимостей между тысячами пакетов.
