## Работа с git из командной строки

### Разбор задачи

Рассмотрим пример работы с git из командной строки Linux. Пусть дан лог git-репозитория в виде графа:

```
*   (dev) Merge branch 'master' into dev
|\  
* | Add unit tests
| | M   readme.md
| | A   tests.py
| | * (HEAD -> master) Add features
| |/  
| |   M app.py
| |   M compute.c
| |   D readme.md
| * Accelerate computations
|/  
|   A   compute.c
|   M   readme.md
* Initial commit
  A     app.py
  A     readme.md
```

Как показано в приведённом логе, git-репозиторий содержит ветку `master`, включающую в себя 3 коммита, и ветку `dev`, также включающую в себя 3 коммита. Последний коммит в ветке `dev` выполняет слияние веток, а первый коммит в ветке `master` также является первым коммитом в ветке `dev`.

Попробуем привести пустой git-репозиторий к состоянию, показанному выше. Создадим директорию в текущем каталоге и инициализируем в ней новый git-репозиторий:

```bash
~$ mkdir repo
~$ cd repo
~/repo$ git init
Initialized empty Git repository in /home/user/repo/.git/
```

Создадим в директории файлы `README.md` и `app.py`, добавим текущую директорию целиком в область индексирования командой `git add .` и выведем содержимое области индексирования в консоль при помощи команды `git diff --cached`:

```bash
~/repo$ echo "Sample app" > README.md
~/repo$ echo "print('Hello world')" > app.py
~/repo$ git add .
~/repo$ git diff --cached
diff --git a/app.py b/app.py
new file mode 100644
index 0000000..f7d1785
--- /dev/null
+++ b/app.py
@@ -0,0 +1 @@
+print('Hello world')
diff --git a/README.md b/README.md
new file mode 100644
index 0000000..827457e
--- /dev/null
+++ b/README.md
@@ -0,0 +1 @@
+Sample app
```

Из вывода команды `git diff --cached` следует, что системе контроля версий теперь известно о добавлении в репозиторий 2 новых файлов. Зафиксируем внесённые изменения:

```
~/repo$ git commit -m "Initial commit"
[master (root-commit) 902fffb] Initial commit
 2 files changed, 2 insertions(+)
 create mode 100644 app.py
 create mode 100644 README.md
```

Создадим ещё один коммит в ветке `master`, добавив в репозиторий файл `compute.c` и изменив `README.md`:

```
~/repo$ echo "int main(void) { printf(\"hello, world\n\"); }" > compute.c
~/repo$ echo "Sample app with C code" > README.md
~/repo$ git add .
~/repo$ git diff --cached --stat
 README.md | 2 +-
 compute.c | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)
~/repo$ git commit -m "Accelerate computations"
[master fa6960d] Accelerate computations
 2 files changed, 2 insertions(+), 1 deletion(-)
 create mode 100644 compute.c
```

Команда `git diff` с опцией `--stat` позволяет получить краткие сведения об изменившихся файлах из области индексирования, в которую файлы репозитория были ранее добавлены командой `git add`. Выведем историю коммитов в виде графа:

```
~/repo$ git log --graph --name-status --pretty=oneline
* fa6960d552a199adea9151189d267f62e69d96cc (HEAD -> master) Accelerate computations
| A     compute.c
| M     README.md
* 902fffb0f20c66f37366681722465e4e4edd7e2c Initial commit
  A     app.py
  A     README.md
```

Команда `git log` выдаёт информацию о коммитах в хронологическом порядке, а опция `--graph` позволяет визуализировать историю коммитов в виде графа, где коммиты обозначены символом `*`, за которым следует хэш коммита и сообщение к коммиту. С опцией `--pretty=oneline` сведения о коммитах выводятся в компактном виде, без подробных сведений об авторе. Опция `--name-status` позволяет обогатить вывод команды `git log` именами и статусами файлов, связанных с коммитом.

Статус файла может принимать одно из следующих значений:
* `M` (modified) – файл изменён;
* `A` (added) – файл добавлен в репозиторий;
* `D` (deleted) – файл удалён из репозитория;
* `R` (renamed) – файл переименован.

Граф выше содержит 2 связанных коммита. Добавим заключительный коммит в ветку `master`:

```
~/repo$ rm README.md
~/repo$ echo "int main() { printf("Hello, world\n"); }" > compute.c
~/repo$ echo "print('Hello, world')" > app.py
~/repo$ git add .
~/repo$ git diff --cached --stat
 app.py    | 2 +-
 compute.c | 2 +-
 README.md | 1 -
 3 files changed, 2 insertions(+), 3 deletions(-)
~/repo$ git commit -m "Add features"
[master d2062c3] Add features
 3 files changed, 2 insertions(+), 3 deletions(-)
 delete mode 100644 README.md
~/repo$ git log --graph --name-status --pretty=oneline
* d2062c36a8bcf56edc46a6bc69b254b371c40b22 (HEAD -> master) Add features
| M     app.py
| M     compute.c
| D     README.md
* fa6960d552a199adea9151189d267f62e69d96cc Accelerate computations
| A     compute.c
| M     README.md
* 902fffb0f20c66f37366681722465e4e4edd7e2c Initial commit
  A     app.py
  A     README.md
```

Связанных коммитов в графе стало 3.

Теперь мы хотим создать новую ветку `dev` на основе самого первого коммита в ветке `master`. Сначала переместим указатель на текущую ветку `HEAD` на первый коммит в ветке `master`. Для этого нам понадобится команда `git checkout`, с помощью которой можно переключиться на нужную ветку по её имени или на нужный коммит по его хэшу:

```
~/repo$ git checkout 902fffb0f20c66f37366681722465e4e4edd7e2c
HEAD is now at 902fffb Initial commit
~/repo$ git log --graph --name-status --pretty=oneline --all
* d2062c36a8bcf56edc46a6bc69b254b371c40b22 (master) Add features
| M     app.py
| M     compute.c
| D     README.md
* fa6960d552a199adea9151189d267f62e69d96cc Accelerate computations
| A     compute.c
| M     README.md
* 902fffb0f20c66f37366681722465e4e4edd7e2c (HEAD) Initial commit
  A     app.py
  A     README.md
```

Обратите внимание, при пересоздании репозитория хэши коммитов будут отличаться. Команда `git log` теперь используется с дополнительной опцией `--all`, позволяющей включить в вывод в консоль все ветки в репозитории.

Как видно из графа коммитов, указатель `HEAD` переместился на первый коммит в ветке `master`. Создадим новую ветку `dev` на основе этого коммита, и добавим в ветку `dev` новый коммит:

```
~/repo$ git checkout -b dev
Switched to a new branch 'dev'
~/repo$ echo "Sample app with tests" > README.md
~/repo$ echo "def test(): assert True" > tests.py
~/repo$ git add .
~/repo$ git diff --cached --stat
 README.md | 2 +-
 tests.py  | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)
~/repo$ git commit -m "Add unit tests"
[dev 4c19b34] Add unit tests
 2 files changed, 2 insertions(+), 1 deletion(-)
 create mode 100644 tests.py
~/repo$ git log --graph --name-status --pretty=oneline --all
* 4c19b344abd9dede5a028bb29357e98d49943622 (HEAD -> dev) Add unit tests
| M     README.md
| A     tests.py
| * d2062c36a8bcf56edc46a6bc69b254b371c40b22 (master) Add features
| | M   app.py
| | M   compute.c
| | D   README.md
| * fa6960d552a199adea9151189d267f62e69d96cc Accelerate computations
|/  
|   A   compute.c
|   M   README.md
* 902fffb0f20c66f37366681722465e4e4edd7e2c Initial commit
  A     app.py
  A     README.md
```

В графе коммитов теперь видны 2 ветки и 4 коммита.

Выполним слияние ветки `master` без последнего коммита с веткой `dev`. Для этого воспользуемся командой `git merge`, указав в качестве аргумента хэш коммита, слияние с которым хотим выполнить:

```bash
~/repo$ git merge fa6960d552a199adea9151189d267f62e69d96cc
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.
~/repo$ cat README.md
<<<<<<< HEAD
Sample app with tests
=======
Sample app with C code
>>>>>>> fa6960d552a199adea9151189d267f62e69d96cc
```

В процессе слияния веток возникли конфликты, которые git предлагает исправить вручную.

При командной разработке программного обеспечения нередко возникают конфликты слияния. Их наличие связано с тем, что работа над одним и тем же файлом с исходным кодом может вестись одновременно и независимо в разных ветках git-репозитория. Рано или поздно изменения из разных веток придётся объединять – принимать решение, какие фрагменты кода оставить в новой версии файла после слияния, а какие – удалить или заменить новыми. В случае, если git не может разрешить конфликты автоматически, разные версии изменившегося фрагмента файла помещаются в его новую версию с разделителями из символов `<`, `=` и `>`.

Разрешим конфликты вручную, сохранив в новой версии файла `README.md` его содержимое как из текущей ветки `HEAD`, так и из ветки `master`, с коммитом `fa6960d552a199adea9151189d267f62e69d96cc` из которой сейчас производится слияние. Для этого обновим содержимое файла `README.md`, добавим файл в область индексирования и сделаем новый коммит:

```bash
~/repo$ echo "Sample app with tests and C code" > README.md
~/repo$ git add .
~/repo$ git commit -m "Merge branch 'master' into dev"
[dev 0c8489d] Merge branch 'master' into dev
```

Переключим указатель `HEAD` на ветку `master` и визуализируем граф коммитов:

```
~/repo$ git checkout master
Switched to branch 'master'
~/repo$ git log --graph --name-status --pretty=oneline --all
*   0c8489d26761a0ed6968ebc9e453749264e278ad (dev) Merge branch 'master' into dev
|\  
* | 4c19b344abd9dede5a028bb29357e98d49943622 Add unit tests
| | M   readme.md
| | A   tests.py
| | * d2062c36a8bcf56edc46a6bc69b254b371c40b22 (HEAD -> master) Add features
| |/  
| |   M app.py
| |   M compute.c
| |   D readme.md
| * fa6960d552a199adea9151189d267f62e69d96cc Accelerate computations
|/  
|   A   compute.c
|   M   readme.md
* 902fffb0f20c66f37366681722465e4e4edd7e2c Initial commit
  A     app.py
  A     readme.md
```

### Упражнения

В приведённых задачах необходимо создать в командной строке git-репозиторий, соответствующий указанному логу. Для проверки используйте команду: `git log --graph --name-status --pretty=oneline --all --decorate`

**Задача 1.**

```
* (HEAD -> master) Rundown deface deodorize?
| R100 linoleum.py spider.c
* Merge branch 'carnation'
|\
| * (carnation) fiftieth anatomist country
| | M landlord.txt
| * Dating dangle liability.
| | A drench
| | A spirited.h
| * (spearman) Jailbreak humility unworthy!
| | M handiwork.ini
| | M landlord.txt
* | Deception boundless!
|/
| M handiwork.ini
| A linoleum.py
* Lecturer entering?
 A handiwork.ini
 A landlord.txt
```

**Задача 2.**

```
* (HEAD -> overpay) tiny decimeter
| M doormat.py
* (master) Merge branch 'booth'
|\
| * (booth) Chatroom radiation unrobed?
| | A feminize.yaml
| * animosity
| | R100 doormat.py stress.h
* | trout
|/
| M doormat.py
| M revolt.ini
* Kooky unhook?
| A doormat.py
| A revolt.ini
| D wound.c
* Chip projector?
 A wound.c
```

**Задача 3.**

```
* (HEAD -> master) Merge branch 'mumble'
|\
| * (mumble) Anyhow anemic?
| | R100 expedited.c coconut.c
* | Splotchy!
|/
| A confused.h
* coveting skinhead
| M crook.yaml
| M expedited.c
* tutu
| M crook.yaml
| A expedited.c
* Sullen jury.
 A crook.yaml
```

**Задача 4.**

```
* (HEAD -> master) Merge branch 'dusk'
|\
| * (dusk) Traverse?
| | R100 operator.ini compactor.h
| | R100 stargazer.yaml reshape.h
* | Stained send curfew?
| | M chariot.c
| | M expire
* | Grandkid favorably octagon.
|/
| R100 afflicted.c expire
* parchment
| A afflicted.c
* Covenant agency convene.
 A chariot.c
 A operator.ini
 A stargazer.yaml
```

**Задача 5.**

```
* (HEAD -> backtrack) Magnetic hatbox baguette.
| M unrigged.json
* Whacky craftily.
| A strive.c
* unlocked bush
| A neatness.ini
| M unrigged.json
* (superior) Merge branch 'master' into superior
|\
| * (master) devious recent bust
| | A neatness.ini
* | Subsonic sweep!
| | D strive.c
* | Class negligent zipfile?
|/
| M unrigged.json
* twelve trinity halt
 A strive.c
 A unrigged.json
```
