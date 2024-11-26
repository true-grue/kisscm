---
theme : white
highlightTheme: white
transition: none
slideNumber: true
enableMenu: false
---

<!-- .slide: data-background="black" style="color:#00ff00" -->

## <span style="color:#00ff00">Конфигурационное управление</span>

Лекция №6. Виртуальные машины

Лектор: *Советов Пётр Николаевич*

---

## Виртуальные машины

* Программные реализации реальных процессоров.
* Языковые виртуальные машины (ВМ).

---

## Байткод CPython

* Стековая ВМ.
* Модуль [dis](https://docs.python.org/3/library/dis.html).
* Пример с дискриминантом.
* Реализация ассемблера.
* Реализация интерпретатора.

---

## RISC-V

* Регистровая архитектура.
* Оптимизированный код дискриминанта ([godbolt](https://godbolt.org/), gcc).
* Реализация ассемблера и интерпретатора.

---

## Виртуальные игровые ретро-приставки

* [CHIP-8](https://taniarascia.github.io/chip8/).
* [PICO-8](https://nerdyteachers.com/PICO-8/Games/Top200/).

---

## ByteByteJump

* [Архитектура](https://esolangs.org/wiki/ByteByteJump) память-память.
* ВМ с одной командой.
* Как реализовать умножение?

---

## Виртуальная приставка [BytePusher](https://esolangs.org/wiki/BytePusher)

* Карта памяти.
* Поддержка графики.
* Тестирование "картриджей".

---

## Эмулятор QEMU

* QNX на одной дискете.
* Программы и [игры](https://gist.github.com/XlogicX/8204cf17c432cc2b968d138eb639494e) в загрузочном секторе.

---

## WebAssembly

Демонстрация компилятора подмножества Питона в WASM, по мотивам [доклада](https://github.com/true-grue/python-dsls).

