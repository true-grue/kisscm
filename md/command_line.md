# Работа в командной строке

Командная строка на экране монитора – имитация работы с телетайпом. Телетайп, в свою очередь, является электромеханической печатной машиной, которую можно подключить к компьютеру. Пользователь набирает текст, который печатается на рулоне бумаги. Компьютер печатает пользователю свои ответы.

Удивительно, но такой, казалось бы, устаревший способ общения с компьютером все еще активно используется, пусть и с более современными средствами ввода-вывода. Более того, многие задачи очень трудно решить без командной строки! Это касается, в частности, работы с системой контроля версий Git, с системой автоматизации сборки Make, с системой контейнеризации Docker и многими другими популярными сегодня программами. Командная строка в духе UNIX имеется в MacOS, Linux и Windows (WSL, Powershell). Стоит вспомнить и многочисленные фильмы о «хакерах» – если герой фильма решает за компьютером какие-то нетривиальные задачи, то, обычно, зрителю демонстрируется именно командная строка. 

Командная строка, как ни странно, хорошо знакома и любителям старых текстовых игр. В этих играх для совершения какого-либо действия необходимо набрать с клавиатуры соответствующую команду в духе `go north`, `read book` или `take apple`.

Вот как выглядит пример диалога с пользователем в игре Zork (1978 г.):

```default
West of House                                       Score: 0     Moves: 4      
ZORK

Welcome to ZORK.
Release 13 / Serial number 040826 / Inform v6.14 Library 6/7
West of House
This is an open field west of a white house, with a boarded front door.
There is a small mailbox here.
A rubber mat saying 'Welcome to Zork!' lies by the door.

>open mailbox
You open the mailbox, revealing a small leaflet.

>take leaflet
Taken.
```

Операционная система UNIX @unix была разработана в далеком 1969 году. UNIX изначально являлась операционной системой в первую очередь для разработчиков, которым удобнее всего автоматизировать свои действия с помощью командной строки. Сама по себе командная строка еще древнее UNIX. 

Основная суть решений, принятых при использовании командной строки, сводится к положениям «философии UNIX» (Дуг Макилрой), которые можно выразить следующими пунктами:

* Пусть каждая программа решает одну задачу и решает ее хорошо. Для новых задач создавайте новые программы, а не усложняйте старые новыми «возможностями».
* Предполагайте, что вывод каждой программы может стать входом другой, еще неизвестной программы. Не загромождайте вывод посторонней информацией. Избегайте строго выравненных столбчатых и двоичных входных форматов. Не настаивайте на интерактивном вводе.
* Проектируйте и разрабатывайте ПО, даже операционные системы, таким образом, чтобы его можно было опробовать уже на ранних этапах, в идеале в течение недель. Не бойтесь выбрасывать неудачно реализованные части и пересоздавать их.
* Вместо ручного труда используйте инструменты для облегчения задач разработки, даже если придется отвлечься на создание этих инструментов, а сами инструменты могут впоследствии больше не понадобиться.

Далее будет рассматриваться современный вариант UNIX, популярная ОС Linux, разработанная в 1991 году Линусом Торвальдсом (в то время – студентом финского университета).

При работе с командной строкой необходимо учитывать структуру файловой системы. В Linux она имеет следующий вид:

```default
localhost:~# tree -d -L 1 /
/
├── bin
├── dev
├── etc
├── home
├── lib
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
├── srv
├── sys
├── tmp
├── usr
└── var
```

Имя `/` является корнем (root) файловой системы. Внутри корня расположены следующие, наиболее значимые каталоги:

* bin. Исполняемые файлы системных утилит.
* dev. Устройства, к которым в Linux возможен доступ, как к файлам.
* etc. Системные конфигурационные файлы.
* home. Домашние каталоги пользователей.
* lib. Системные библиотеки.
* media. Подключаемые съемные диски: USB, CD-ROM и так далее.
* mnt. Подключаемые разделы.

## Командный интерпретатор

За поддержку работы в командной строке отвечает специальная программа – интерпретатор оболочки ОС (shell). В случае Linux таким интерпретатором обычно является Bash, архитектура которого приведена на @fig:cli1. Под Bash далее будем понимать целое семейство работающих схожим образом интерпретаторов. Интерпретатор выполняет следующие основные действия @ramey2011bourne:

1. Принимает строку от пользователя.
2. Разбирает эту строку и переводит во внутренний формат.
3. Осуществляет подстановку для различных специальных символов и имен.
4. Выполняет команду пользователя.
5. Выдает код выполнения.

![Архитектура интерпретатора Bash](cli1.svg){#fig:cli1}

Ниже показан пример сеанса работы в Bash:

```default
localhost:~# pwd
/root
localhost:~# ls -l
total 16
-rw-r--r--    1 root     root           114 Jul  5  2020 bench.py
-rw-r--r--    1 root     root            76 Jul  3  2020 hello.c
-rw-r--r--    1 root     root            22 Jun 26  2020 hello.js
-rw-r--r--    1 root     root           151 Jul  5  2020 readme.txt
localhost:~# echo 'new file' > new_file.txt
localhost:~# cat new_file.txt
new file
localhost:~# mkdir new_dir
localhost:~# cp new_file.txt new_dir/
localhost:~# rm new_file.txt
localhost:~# ls -l
total 20
-rw-r--r--    1 root     root           114 Jul  5  2020 bench.py
-rw-r--r--    1 root     root            76 Jul  3  2020 hello.c
-rw-r--r--    1 root     root            22 Jun 26  2020 hello.js
drwxr-xr-x    2 root     root            66 Nov  4 17:16 new_dir
-rw-r--r--    1 root     root           151 Jul  5  2020 readme.txt
localhost:~# ls -l new_dir/
total 4
-rw-r--r--    1 root     root             9 Nov  4 17:16 new_file.txt
```

Обратите внимание на использование в приведенном сеансе команд, упрощенное описание которых дано ниже:

* `pwd` (print working directory). Вывести имя текущего каталога.
* `ls` (list). Вывести содержимое каталога.
* `echo` Вывести свой аргумент.
* `cat` (concatenate). Вывести содержимое файла.
* `mkdir` (make directory). Создать каталог.
* `cp` (copy). Скопировать файл.
* `rm` (remove). Удалить файл.

Многие команды имеют ряд аргументов, это, в частности, касается `ls`, которая выше была вызвана с аргументом `-l`. Аргументы разделяются пробелами и имеют префикс `-`.

Узнать об аргументах, которые принимает команда, можно с помощью аргумента `--help`:

```default
localhost:~# ls --help
BusyBox v1.31.1 () multi-call binary.
 
Usage: ls [-1AaCxdLHRFplinshrSXvctu] [-w WIDTH] [FILE]...
 
List directory contents
 
        -1      One column output
        -a      Include entries which start with .
        -A      Like -a, but exclude . and ..
        -x      List by lines
        -d      List directory entries instead of contents
        -L      Follow symlinks
        -H      Follow symlinks on command line
        -R      Recurse
        -p      Append / to dir entries
        -F      Append indicator (one of */=@|) to entries
        -l      Long listing format
        -i      List inode numbers
        -n      List numeric UIDs and GIDs instead of names
        -s      List allocated blocks
        -lc     List ctime
        -lu     List atime
        --full-time     List full date and time
        -h      Human readable sizes (1K 243M 2G)
        --group-directories-first
        -S      Sort by size
        -X      Sort by extension
        -v      Sort by version
        -t      Sort by mtime
        -tc     Sort by ctime
        -tu     Sort by atime
        -r      Reverse sort order
        -w N    Format N columns wide
        --color[={always,never,auto}]   Control coloring
```

Еще одним способом получить подробные сведения о конкретной команде является вызов вида `man <команда>`.

Без объяснений осталась строка `echo 'new file' > new_file.txt` в примере сеанса работы в командной строке выше. Здесь используется механизм перенаправления данных с помощью символов `<` (перенаправление ввода) и `>` (перенаправление вывода). В Linux имеется источник стандартного ввода stdin (код 0), а также два приемника стандартного вывода: stdout (код 1) и stderr (код 2, для ошибок). Организация ввода/вывода показана на @fig:cli2.

![Организация ввода/вывода](cli2.svg){#fig:cli2}

В примере ниже используется stdout и stderr:

```default
localhost:~# pwd
/root
localhost:~# pwd > pwd.txt
localhost:~# pwd --foo
sh: pwd: illegal option --
localhost:~# pwd --foo 2> err.txt
localhost:~# cat err.txt
sh: pwd: illegal option --
```

Обратите внимание на явное указание кода 2 при сохранении сообщения об ошибке в файл.

Перенаправление ввода/вывода превращается в очень мощную конструкцию при использовании такой организации команд, при которой вывод одной команды попадает на вход другой команды. Эта конструкция представляет собой конвейер и реализуется с помощью символа `|`, как показано в примере далее:

```default
localhost:~# pwd > pwd.txt
localhost:~# rev --help
Usage: rev [options] [file ...]
 
Reverse lines characterwise.
 
Options:
 -h, --help     display this help
 -V, --version  display version
 
For more details see rev(1).
localhost:~# rev pwd.txt
toor/
localhost:~# pwd | rev
toor/
```

В Bash имеется удобный синтаксис для развертывания файловых путей (globbing). С помощью символов `*` (произвольная последовательность) и `?` (произвольный символ) реализуется подстановка имен файлов в духе регулярных выражений, как в примере ниже:

```default
localhost:~# echo *
bench.py err.txt hello.c hello.js new_dir pwd.txt readme.txt rev
localhost:~# echo *.c
hello.c
localhost:~# echo p*
pwd.txt
localhost:~# echo *.??
bench.py hello.js
```

В Bash есть возможность задать переменные и, кроме того, имеется ряд уже определенных переменных. Обратите внимание на особенности создания переменных:

```default
localhost:~# A = 42
sh: A: not found
localhost:~# A=42
localhost:~# A
sh: A: not found
localhost:~# echo $A
42
```

С помощью команды `set` можно, помимо прочего, узнать, какие переменные сейчас заданы для текущего пользователя:

```default
localhost:~# set
A='42'
HISTFILE='/root/.ash_history'
HOME='/root'
HOSTNAME='localhost'
IFS='
'
LINENO=''
OLDPWD='/'
OPTIND='1'
PAGER='less'
PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
PPID='1'
PS1='\h:\w\$ '
PS2='> '
PS4='+ '
PWD='/root'
SHLVL='3'
TERM='linux'
TZ='UTC-03:00'
_='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
script='/etc/profile.d/*.sh'
```

Особенно важна здесь переменная PATH, которая определяет те пути (разделенные с помощью `:`), где будет осуществляться поиск команд интерпретатором.

Linux является многопользовательской ОС и информация о зарегистрированных пользователях находится в конфигурационном файле `/etc/passwd`:

```default
localhost:~# whoami
root
localhost:~# cat /etc/passwd
root:x:0:0:root:/root:/bin/ash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/mail:/sbin/nologin
news:x:9:13:news:/usr/lib/news:/sbin/nologin
uucp:x:10:14:uucp:/var/spool/uucppublic:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
man:x:13:15:man:/usr/man:/sbin/nologin
postmaster:x:14:12:postmaster:/var/mail:/sbin/nologin
cron:x:16:16:cron:/var/spool/cron:/sbin/nologin
ftp:x:21:21::/var/lib/ftp:/sbin/nologin
sshd:x:22:22:sshd:/dev/null:/sbin/nologin
at:x:25:25:at:/var/spool/cron/atjobs:/sbin/nologin
squid:x:31:31:Squid:/var/cache/squid:/sbin/nologin
xfs:x:33:33:X Font Server:/etc/X11/fs:/sbin/nologin
games:x:35:35:games:/usr/games:/sbin/nologin
cyrus:x:85:12::/usr/cyrus:/sbin/nologin
vpopmail:x:89:89::/var/vpopmail:/sbin/nologin
ntp:x:123:123:NTP:/var/empty:/sbin/nologin
smmsp:x:209:209:smmsp:/var/spool/mqueue:/sbin/nologin
guest:x:405:100:guest:/dev/null:/sbin/nologin
nobody:x:65534:65534:nobody:/:/sbin/nologin
dhcp:x:100:101:dhcp:/var/lib/dhcp:/sbin/nologin
svn:x:101:102:svn:/var/svn:/sbin/nologin
```

Информация о каждом из пользователей занимает отдельную строку. Строка разделяется символом `:` на поля. Первое поле означает имя пользователя. В нашем случае это root. Последнее поле указывает путь к интерпретатору оболочки ОС. В нашем случае это компактный Bash-подобный интерпретатор ash.

Вспомним, как выглядит вывод команды `ls` в long-формате:

```default
localhost:~# ls -l
total 20
-rw-r--r--    1 root     root           114 Jul  5  2020 bench.py
drwxr-xr-x    2 root     root            37 Nov  4 18:01 foo
-rw-r--r--    1 root     root            76 Jul  3  2020 hello.c
-rw-r--r--    1 root     root            22 Jun 26  2020 hello.js
-rw-r--r--    1 root     root           151 Jul  5  2020 readme.txt
```

Первый столбец определяет права доступа и информацию о файле (`-`) или каталоге (`d`, как в случае с foo), закодированную в первом символе. Флаги доступа бывают следующих основных видов:

* `-` Доступ запрещен.
* `r` (read). Имеется доступ на чтение.
* `w` (write). Имеется доступ на запись.
* `x` (execute). Имеется доступ на исполнение (на вход в случае каталога).

Рассмотрим детали на примере с файлом bench.py, который имеет следующие права доступа:

```default
-rw-r--r--  1 root    root             114 Jul  5  2020 bench.py
|[-][-][-]   [----]  [----]
| |  |  |      |       |
| |  |  |      |       +-------------> 6. Группа
| |  |  |      +---------------------> 5. Владелец
| |  |  | 
| |  |  +----------------------------> 4. Права всех остальных
| |  +-------------------------------> 3. Права группы
| +----------------------------------> 2. Права владельца
+------------------------------------> 1. Тип файла
```

При создании пользовательских команд необходимо указать права на исполнение, как показано в примере ниже:

```default
localhost:~# echo "ls -l" > lsl
localhost:~# lsl
sh: lsl: not found
localhost:~# ./lsl
sh: ./lsl: Permission denied
localhost:~# chmod +x lsl
localhost:~# ./lsl
total 24
-rw-r--r--    1 root     root           114 Jul  5  2020 bench.py
drwxr-xr-x    2 root     root            37 Nov  4 18:01 foo
-rw-r--r--    1 root     root            76 Jul  3  2020 hello.c
-rw-r--r--    1 root     root            22 Jun 26  2020 hello.js
-rwxr-xr-x    1 root     root             6 Nov  4 18:44 lsl
-rw-r--r--    1 root     root           151 Jul  5  2020 readme.txt
```

В Bash существует ряд специальных переменных, в частности:

* `$0`. Путь к запущенной программе.
* `$1, $2, ...`. Аргументы программы.
* `$#`. Количество аргументов программы.
* `$@`. Список аргументов программы.
* `$?`. Значение результата выполнения программы (0 означает успешное выполнение).

Рассмотрим в качестве примера следующую программу tests.sh:

```default
echo $0
echo $1 $2
echo $#
echo $@
```

Результат ее выполнения показан далее:

```default
localhost:~# ./test.sh 1 2 3 4 5
./test.sh
1 2
5
1 2 3 4 5
localhost:~# echo $?
0
localhost:~# foo
sh: foo: not found
localhost:~# echo $?
127
```

Рассмотрим теперь более сложный пример пользовательской команды. Далее приведен код на языке Bash вычисления факториала:

```default
#!/bin/sh
seq "$1" | xargs echo | tr " " "*" | bc
```

В первой строке указан интерпретатор, который будет использоваться для исполнения программы. По соглашению, такую строку необходимо всегда указывать первой в пользовательских скриптах. Далее используется ряд новых команд.

Команда `seq` (sequence) генерирует последовательность чисел:

```default
localhost:~# seq 5
1
2
3
4
5
```

Команда `xargs` (extended arguments) форматирует список из стандартного ввода:

```default
localhost:~# seq 5 | xargs
1 2 3 4 5
```

Команда `tr` (translate) осуществляет замену текстовых фрагментов:

```default
localhost:~# seq 5 | xargs | tr " " "*"
1*2*3*4*5
```

Команда `bc` (basic calculator) представляет собой калькулятор:

```default
localhost:~# echo "2+2" | bc
4
```
Для вычислений в Bash можно также использовать скобки специального вида:

```default
localhost:~# echo $((2 + 2))
4
```
Для получения результата команды в виде аргумента другой команды можно также использовать скобки специального вида:

```default
localhost:~# echo "My folder is $(pwd)"
My folder is /root
```

В Bash имеются возможности полноценного языка программирования. Ниже приведен пример реализации факториала с использованием ветвлений и рекурсии:

```default
#!/bin/sh
if [ "$1" -le 1 ] ; then
        echo 1
        return
fi
echo $(( $1 * $( ./fact.sh $(( $1 - 1 )) ) ))
```

Реализация факториала с использованием цикла:

```default
#!/bin/sh
res=1
for i in $(seq 1 "$1"); do
        res=$((res * i))
done
echo $res
```

Существует веб-инструмент ShellCheck @shellcheck, которым можно пользоваться для проверки корректности Bash-скриптов.

## Инструменты командной строки

Команда `grep` (globally search for a regular expression and print matching lines) осуществляет поиск по образцу, определяемому регулярным выражением. Команда `sed` (stream editor) является строчным редактором, но главное ее использование состоит в замене по шаблону, как и в случае grep, заданному регулярным выражением.

В @tbl:cli1 показаны примеры некоторых базовых элементов регулярного выражения.

: Некоторые базовые регулярные выражения {#tbl:cli1}

| Символ | Действие |
| --- | --- |
| `Буквы, числа, некоторые знаки` | Обозначают сами себя |
| `.` | Любой символ |
| `[множество символов]` | Любой символ из множества |
| `[^множество символов]` | Любой символ не из множества |
| `^` | Начало строки |
| `$` | Конец строки |
| `^` | Начало строки |
| `выражение*` | Повторение выражения 0 или более раз |
| `выражение` `выражение` | Последовательность из выражений |

Веб-инструмент regex101 @regex101 может помочь в поэлементном разборе сложных регулярных выражений.

С использованием `grep` и `sed` можно создать достаточно сложные схемы обработки данных. В частности, следующий код осуществляет проверку правописания для файла README.md на основе словаря из файла unix-words:

```default
cat README.md | tr A-Z a-z | tr -cs A-Za-z '\n' | sort | uniq | grep -vx -f unix-words >out ; cat out | wc -l | sed 's/$/ mispelled words!/'
```

Еще более изощренной, чем `grep` и `sed`, является команда `awk`. AWK (по именам авторов – Aho, Weinberger, Kernighan) представляет собой язык программирования для обработки текстовых данных.

Ниже показан пример вывода колонки №5 из данных, предоставленных вызовом `ls -l`:

```default
localhost:~# ls -l
total 36
-rw-r--r--    1 root     root           114 Jul  5  2020 bench.py
-rwxr-xr-x    1 root     root            51 Nov  4 18:56 fact.sh
-rwxr-xr-x    1 root     root            76 Nov  4 19:45 fact2.sh
drwxr-xr-x    2 root     root            37 Nov  4 18:01 foo
-rw-r--r--    1 root     root            76 Jul  3  2020 hello.c
-rw-r--r--    1 root     root            22 Jun 26  2020 hello.js
-rwxr-xr-x    1 root     root             6 Nov  4 18:44 lsl
-rw-r--r--    1 root     root           151 Jul  5  2020 readme.txt
-rwxr-xr-x    1 root     root            36 Nov  4 18:50 test.sh
localhost:~# ls -l | awk '{ print $5 }'
 
114
51
76
37
76
22
6
151
36
```

Средствами `awk` легко подсчитать общий размер файлов:

```default
localhost:~# ls -l | awk '{ s += $5 } END { print s }'
569
```

В заключение рассмотрим пример вывода на экран самой свежей новости с ресурса Hacker News:

```default
#!/bin/sh
N=$(curl -s https://hacker-news.firebaseio.com/v0/topstories.json | jq '.[0]')
curl -s "https://hacker-news.firebaseio.com/v0/item/$N.json" | jq '.["title"]' | cowsay
```

Вот как выглядит вывод этой программы:

```default
root@Server584432:~# ./hn.sh
 ________________________________________
/ "Finishing my first game while working \
\ full-time"                             /
 ----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

На тему анализа данных в командной строке существует целая книга @janssens2021data.
