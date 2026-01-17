## Конвейер на разных языках программирования

Поскольку при использовании конвейера коммуникация между разными процессами осуществляется через stdout и stdin, эти процессы могут быть представлены запущенными программами, написанными на разных языках программирования. Язык реализации при этом может быть как высокоуровневым, таким как, например, Python, так и низкоуровневым, таким как C.

Рассмотрим процесс разработки инструмента для поиска короткого фрагмента текста в больших текстовых файлах. Компоненты инструмента реализуем на разных языках программирования, а коммуникация между компонентами будет осуществляться сопрограммным образом, при помощи конвейера `|`.

Доступную в bash утилиту `cat` используем для получения в stdout содержимого заданного текстового файла. Содержимое файла будет передано по конвейеру утилите `scan`, разные версии которой мы реализуем на языках Python и С. Эта утилита будет выполнять поиск по короткой подстроке и возвращать результат в виде строки в формате JSON (JavaScript Object Notation) @json. Утилита `stats`, в свою очередь, будет реализована на языке Python и использована для преобразования результата работы утилиты `scan` в понятное для человека табличное представление.

Организация ввода-вывода в нашем инструменте будет иметь вид, показанный на @fig:datepipe:

```{#fig:datepipe .pysvg caption="Организация ввода-вывода в средстве поиска по подстроке" width=100%}  
dot('''
digraph {
    edge [arrowsize=0.7]
    node [shape=box]
    ranksep=0.3
    rankdir=LR
    1 [label="cat", shape=circle, style=filled, fixedsize=shape]
    2 [label="stdout" shape=rarrow]
    3 [label="stdin" shape=rarrow]
    4 [label="scan", shape=box, style="filled,rounded"]
    5 [label="stdout" shape=rarrow]
    6 [label="stdin" shape=rarrow]
    7 [label="stats", shape=box, style="filled,rounded"]
    8 [label="stdout" shape=rarrow]
    9 [label="Экран" shape=none]
    subgraph cluster_0 {
        graph [style=dashed];
        1 -> 2 [arrowhead=none] 
    }
    subgraph cluster_1 {
        graph [style=dashed];        
        2 -> 3 [arrowhead=none]    
        3 -> 4 [arrowhead=none] 
        4 -> 5 [arrowhead=none] 
    }
    subgraph cluster_2 {
        graph [style=dashed];
        5 -> 6 [arrowhead=none] 
        6 -> 7 [arrowhead=none] 
        7 -> 8 [arrowhead=none] 
    }
    8 -> 9 [arrowhead=none] 
}
''')
```

Серым цветом на @fig:datepipe выделены утилиты, задействованные в конвейере. 

Сначала воспользуемся утилитой командной строки Linux `cat` для получения в stdout строк из файла `/var/log/syslog`, содержащего сообщения о происходящих в системе событиях @unix. Также подсчитаем число строк в журнале событий:

```bash
~$ cat /var/log/syslog | tail -n 3
Jan 18 00:00:26 user-NBD-WXX9 systemd[1]: Started Make remote CUPS printers available locally.
Jan 18 00:00:26 user-NBD-WXX9 systemd[1]: dpkg-db-backup.service: Deactivated successfully.
Jan 18 00:00:26 user-NBD-WXX9 systemd[1]: Finished Daily dpkg database backup service.
~$ cat /var/log/syslog | wc -l
34031
```

Утилита `tail` используется для получения последних 3 строк из вывода `cat`.

### Поиск по подстроке на языке Python

Теперь реализуем на Python утилиту `scan.py` для поиска по подстроке:

```python
import sys
import json

pat = sys.argv[1]
for i, line in enumerate(sys.stdin):
  if pat in line:
      o = dict(line=i, content=line[:-1])
      print(json.dumps(o))
```

Эта утилита построчно читает стандартный поток ввода stdin, а функция `enumerate` используется для получения номера прочитанной строки. В том случае, если переданный в качестве параметра командной строки короткий шаблон содержится в прочитанной строке, утилита `scan` отправляет в stdout строковое представление JSON-объекта, содержащего ключи `line` и `content`. Значением для ключа `line` является номер найденной строки в анализируемом файле. Значением для ключа `content` является содержимое строки, из которого удалён символ переноса строки на новую `\n`.

Для проверки работы `scan.py` попробуем найти подстроку `root` в файле `/var/log/syslog`:

```bash
~$ cat /var/log/syslog | python scan.py root | tail -n 3
{"line": 33903, "content": "Jan 17 22:30:01 user-NBD-WXX9 CRON[35710]: (root) CMD ([ -x /etc/init.d/anacron ] && if [ ! -d /run/systemd/system ]; then /usr/sbin/invoke-rc.d anacron start >/dev/null; fi)"}
{"line": 33955, "content": "Jan 17 23:17:01 user-NBD-WXX9 CRON[35863]: (root) CMD (   cd / && run-parts --report /etc/cron.hourly)"}
{"line": 33972, "content": "Jan 17 23:30:01 user-NBD-WXX9 CRON[35890]: (root) CMD ([ -x /etc/init.d/anacron ] && if [ ! -d /run/systemd/system ]; then /usr/sbin/invoke-rc.d anacron start >/dev/null; fi)"}
```

При помощи стандартной утилиты `time` @unix легко выполнить замеры времени выполнения реализованной утилиты по результатам 100 тестовых запусков поиска подстроки `root` в текстовом файле `/var/log/syslog`:

```
~$ time (for i in $(seq 1 100); do (cat /var/log/syslog | python scan.py root > /dev/null); done)

real    0m2,236s
user    0m1,897s
sys     0m0,583s
```

Команда `seq 1 100` генерирует последовательность из 100 целых чисел. Оператор `>` позволяет перенаправить stdout в специальный файл `/dev/null`, который удаляет все записанные в него данные. 

Попробуем ускорить поиск подстроки в текстовом файле, формируя JSON без создания временного словаря и без использования функции `dumps` из модуля `json` стандартной библиотеки языка Python. Обновим содержимое файла `scan.py`:

```python
import sys

pat = sys.argv[1] 
for i, line in enumerate(sys.stdin):
  if pat in line:
      print(f'{{"line": {i}, "content": "{line[:-1]}"}}')
```

Убедимся, что поведение утилиты не изменилось, и повторно измерим время её работы:

```bash
~$ cat /var/log/syslog | python scan.py root | tail -n 3
{"line": 33903, "content": "Jan 17 22:30:01 user-NBD-WXX9 CRON[35710]: (root) CMD ([ -x /etc/init.d/anacron ] && if [ ! -d /run/systemd/system ]; then /usr/sbin/invoke-rc.d anacron start >/dev/null; fi)"}
{"line": 33955, "content": "Jan 17 23:17:01 user-NBD-WXX9 CRON[35863]: (root) CMD (   cd / && run-parts --report /etc/cron.hourly)"}
{"line": 33972, "content": "Jan 17 23:30:01 user-NBD-WXX9 CRON[35890]: (root) CMD ([ -x /etc/init.d/anacron ] && if [ ! -d /run/systemd/system ]; then /usr/sbin/invoke-rc.d anacron start >/dev/null; fi)"}
```

```
~$ time (for i in $(seq 1 100); do (cat /var/log/syslog | python scan.py root > /dev/null); done)

real    0m1,668s
user    0m1,393s
sys     0m0,510s
```

Время выполнения утилиты `scan.py` снизилось, а результат выполнения не изменился. 

### Поиск по подстроке на языке C

Попробуем ускорить утилиту, реализовав на языке C сравнение строк как 64-битных целых чисел – в этом случае длина подстроки для поиска будет ограничена 8 символами, но процесс поиска должен ускориться. Создадим файл `scan.c` со следующим содержимым:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>

#define MAX_LINE 65536

int found(char *line, uint64_t pat, uint64_t mask) {
    for (char *p = line; *p; p++) {
        if ((*((uint64_t *) p) & mask) == pat) {
            return 1;
        }
    }
    return 0;
}

int main(int argc, char **argv) {
    char line[MAX_LINE + sizeof(uint64_t)];
    assert(argc == 2);
    unsigned pat_size = strlen(argv[1]);
    assert(pat_size <= sizeof(uint64_t));
    uint64_t mask = (-1llu) >> (sizeof(uint64_t) - pat_size) * 8;
    uint64_t pat = *((uint64_t *) argv[1]) & mask;
    for (int i = 0; fgets(line, MAX_LINE, stdin) != NULL; i++) {
        if (found(line, pat, mask)) {
            line[strcspn(line, "\n")] = 0;
            printf("{\"line\": %d, \"content\": \"%s\"}\n", i, line);
        }
    }
    return 0;
}
```

В функции `main` сначала выделяется память для `MAX_LINE + 8` символов и вычисляется размер шаблона для поиска – конструкция `assert(pat_size <= 8)` позволяет убедиться, что указанный пользователем шаблон занимает не более 8 байт, то есть включает в себя не более 8 ASCII-символов. После этого указатель на первый символ строкового шаблона, имеющий тип `char*`, преобразуется в указатель на беззнаковое целое, занимающее 8 байт – этот указатель имеет тип `uint64_t*`. На значение, полученное по указателю с типом `uint64_t*`, при помощи оператора побитового «и» `&` накладывается маска `mask` для того, чтобы установить равными 0 те биты, которые не относятся к указанному пользователем шаблону в том случае, если шаблон занимает меньше 8 байт.

Затем запускается цикл обработки строк, получаемых из stdin – чтение строк из стандартного ввода осуществляется при помощи стандартной функции `fgets`, определённой в заголовочном файле `stdio.h`. Функция `found` выполняет быстрый поиск шаблона `pat` в строке `line` по методу скользящего окна. Подстроки `p`, состоящие из 8 символов, сравниваются с шаблоном `pat` как 64-битные целые числа. В случае совпадения в stdout печатается JSON-строка, содержащая номер найденной строки и её содержимое, как и в версии утилиты, реализованной на языке Python.

Скомпилируем новую утилиту `scan.c` и проверим её работу:

```bash
~$ clang -O3 -o scan scan.c
~$ ls
scan  scan.c  scan.py
~$ cat /var/log/syslog | ./scan root | tail -n 3
{"line": 33903, "content": "Jan 17 22:30:01 user-NBD-WXX9 CRON[35710]: (root) CMD ([ -x /etc/init.d/anacron ] && if [ ! -d /run/systemd/system ]; then /usr/sbin/invoke-rc.d anacron start >/dev/null; fi)"}
{"line": 33955, "content": "Jan 17 23:17:01 user-NBD-WXX9 CRON[35863]: (root) CMD (   cd / && run-parts --report /etc/cron.hourly)"}
{"line": 33972, "content": "Jan 17 23:30:01 user-NBD-WXX9 CRON[35890]: (root) CMD ([ -x /etc/init.d/anacron ] && if [ ! -d /run/systemd/system ]; then /usr/sbin/invoke-rc.d anacron start >/dev/null; fi)"}
```

```
$ time (for i in $(seq 1 100); do (cat /var/log/syslog | ./scan root > /dev/null); done)

real    0m0,543s
user    0m0,452s
sys     0m0,321s
```

Время выполнения утилиты `scan.c`, реализованной на языке C, в 4 раза ниже, чем время выполнения первой реализации `scan.py` на языке Python, и в 3 раза ниже, чем время выполнения ускоренной реализации `scan.py` на языке Python.


### Вывод статистики на языке Python

Полученную последовательность найденных строк в формате JSON легко преобразовать в понятное человеку представление при помощи стороннего модуля для Python `tabulate`, перед использованием модуль `tabulate` необходимо установить из реестра пакетов PyPI (Python Package Index) @tabulate.

Реализуем утилиту `stats.py` следующим образом:

```python
import sys
import json
from tabulate import tabulate

print(tabulate([json.loads(line).values() for line in sys.stdin],
               headers=['Строка', 'Содержимое'],
               maxcolwidths=[None, 50]))
```

Утилита `stats.py` читает все строки в формате JSON из stdin, извлекает из JSON-объектов значения, и передаёт на вход функции `tabulate` сформированный список, содержащий вложенные списки значений. После этого сформированная модулем `tabulate` @tabulate таблица выводится в stdout:

```
~$ cat /var/log/syslog | ./scan root | tail -n 3 | python stats.py
  Строка  Содержимое
--------  -------------------------------------------------
   33903  Jan 17 22:30:01 user-NBD-WXX9 CRON[35710]: (root)
          CMD ([ -x /etc/init.d/anacron ] && if [ ! -d
          /run/systemd/system ]; then /usr/sbin/invoke-rc.d
          anacron start >/dev/null; fi)
   33955  Jan 17 23:17:01 user-NBD-WXX9 CRON[35863]: (root)
          CMD (   cd / && run-parts --report
          /etc/cron.hourly)
   33972  Jan 17 23:30:01 user-NBD-WXX9 CRON[35890]: (root)
          CMD ([ -x /etc/init.d/anacron ] && if [ ! -d
          /run/systemd/system ]; then /usr/sbin/invoke-rc.d
          anacron start >/dev/null; fi)
```

### Упражнения

**Задача 1.** Что будет, если в обрабатываемой с помощью `scan` строке появится символ двойной кавычки? Исправьте соответствующим образом код.

**Задача 2.** Замените в конвейере формат JSON на CSV (Comma-Separated Values). Заголовки колонок должны передаваться программе как параметры командной строки.

**Задача 3.** Сравните производительность `scan` с вариантом реализации, использующим стандартную функцию `strstr`.

**Задача 4.** Почему `grep` оказывается быстрее `scan`? Улучшите код `scan` с использованием POSIX-функции `read`, чтобы приблизиться к показателям `grep`.

**Задача 5.** Реализуйте `scan` на языке, отличном от Python и C. Составьте таблицу с оценками производительности всех полученных вариантов `scan`.
