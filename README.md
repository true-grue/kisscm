# kisscm-docs

## Установка

Сборка проекта настроена для ОС Windows. Для редактирования используется [Visual Studio Code](https://code.visualstudio.com/download).

* Установить [pandoc](https://pandoc.org/).
* Установить плагин [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/).
* Установить [make для Windows](http://gnuwin32.sourceforge.net/packages/make.htm).
* Установить [Python 3](https://www.python.org/downloads/).
* Установить [rsvg-convert](http://sourceforge.net/projects/tumagcc/files/rsvg-convert-2.40.20.7z/download).
* Для PDF установить шрифты от [Paratype](http://rus.paratype.ru/pt-sans-pt-serif).

## Задачи

Присылать решения pull request'ом.

Рисунки

Переработать некоторые рисунки:

* Перевести надписи на русский язык.
* При необходимости, дополнить рисунок, сделать более наглядным.
* Подобрать наилучший формат и размеры.
* Рисунки с классификацией/историей желательно переделать с использованием поиска в интернете и применением средств в духе Graphviz.

| Файл рисунка | Кто взял |
|---|---|
|cli1.png|TMentosT|
|cli2.png|HaidesAidoseus|
|vcs6.png|HaidesAidoseus|
|make6.png|HaidesAidoseus|
|make5.png|TMentosT|
|make4.png|TMentosT|
|make3.png|TMentosT|
|make2.png|TMentosT|
|make1.png|TMentosT|
|pm1.png|HaidesAidoseus|

Формирование HMTL

1. Реализовать вывод в духе mdbook/bookdown с прикрепленным оглавлением.

Формирование PDF

1. ~~Исправить Contents на "Оглавление"~~.
1. ~~Подобрать красивый стиль страницы: шрифты, поля и так далее~~.

Формирование DOCX

1. ~~Реализовать корректный вывод с правильными шрифтами и так далее~~.

Автоматические тесты в makefile

1. Утилита проверки орфографии.
1. Утилита проверки корректности ссылок.

## Благодарности

* [TMentosT](https://github.com/TMentosT)
* [HaidesAidoseus](https://github.com/HaidesAidoseus)
  