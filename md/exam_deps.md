## Разрешение зависимостей пакета

### Разбор задачи

Рассмотрим задачу разрешения зависимостей пакета, граф зависимостей которого показан на @fig:deps:

```{#fig:deps .pysvg caption="Граф зависимостей пакета"}
dot('''
digraph {
edge [minlen=1 arrowsize=0.7]
node [shape=none fontsize=14]
rankdir=LR
"app" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>app</b></td></tr>
<tr><td port="0">app 1.0.0</td></tr>
</table>>]
"monaco-editor" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>monaco-editor</b></td></tr>
<tr><td port="2">monaco-editor 2.3.0</td></tr>
<tr><td port="1">monaco-editor 2.2.0</td></tr>
</table>>]
"@replit/codemirror-css-color-picker" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>@replit/codemirror-css-color-picker</b></td></tr>
<tr><td port="5">@replit/codemirror-css-color-picker 3.5.0 </td></tr>
<tr><td port="4">@replit/codemirror-css-color-picker 3.4.0 </td></tr>
<tr><td port="3">@replit/codemirror-css-color-picker 3.3.0 </td></tr>
</table>>]
"lodash" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>lodash</b></td></tr>
<tr><td port="7">lodash 2.6.0</td></tr>
<tr><td port="6">lodash 2.5.0</td></tr>
</table>>]
"react" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>react</b></td></tr>
<tr><td port="9">react 3.2.0</td></tr>
<tr><td port="8">react 3.1.0</td></tr>
</table>>]
"app":0 -> "react":8
"app":0 -> "monaco-editor":1
"app":0 -> "monaco-editor":2
"monaco-editor":1 -> "@replit/codemirror-css-color-picker":4
"monaco-editor":1 -> "@replit/codemirror-css-color-picker":5
"monaco-editor":2 -> "@replit/codemirror-css-color-picker":3
"monaco-editor":2 -> "lodash":7
"@replit/codemirror-css-color-picker":4 -> "react":8
"@replit/codemirror-css-color-picker":3 -> "react":9
"@replit/codemirror-css-color-picker":3 -> "lodash":6
"@replit/codemirror-css-color-picker":5 -> "lodash":7
"@replit/codemirror-css-color-picker":5 -> "react":9
}
''')
```  

Зависимости разрешаются для пакета `app`, необходимо найти минимальное по числу пакетов решение.

В приведённом графе стрелки, соединяющие пакеты, обозначают факт наличия зависимости одного пакета от другого пакета. Например, из графа зависимостей следует, что для корректной работы пакета `app` версии 1.0.0 необходимо установить пакет `react` версии 3.1.0.

В том случае, если пакет заданной версии соединён несколькими стрелками с несколькими версиями другого пакета, то это значит, что тот пакет, из которого исходят стрелки, совместим с несколькими версиями другого пакета. Так, например, в приведённом выше графе зависимостей пакет `app` совместим с любой из версий пакета `monaco-editor` – как с `monaco-editor` 2.3.0, так и с `monaco-editor` 2.2.0. Поскольку речь идёт о минимальном по числу пакетов решении, необходимо выбрать одну из версий пакета `monaco-editor`, проверив транзитивные зависимости пакета `app` на наличие конфликтов версий.

При выборе пакета `monaco-editor` версии 2.3.0 возникает конфликт: `monaco-editor` одновременно требует установки пакета `lodash` 2.6.0 и пакета `@replit/codemirror-css-color-picker` 3.3.0, при этом пакет `@replit/codemirror-css-color-picker` 3.3.0 совместим только с `lodash` 2.5.0. Значит, разрешить зависимости для `monaco-editor` 2.3.0 не получится.

Аналогичным образом проверив другие подграфы легко найти решение, минимальное по числу пакетов:

* Установить `app` 1.0.0.
* Установить `monaco-editor` 2.2.0.
* Установить `@replit/codemirror-css-color-picker` 3.4.0.
* Установить `react` 3.1.0.
* Не устанавливать `lodash`.

Выделим на графе зависимостей @fig:deps выбранные версии пакетов символом «✓», а символом «✕» – один из конфликтов версий. Результат показан на @fig:depsln:

```{#fig:depsln .pysvg caption="Решение задачи выбора версий зависимостей"}
dot('''
digraph {
edge [minlen=1 arrowsize=0.7]
node [shape=none fontname="Times-Roman" fontsize=14]
rankdir=LR
"app" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>app</b></td></tr>
<tr><td port="0">app 1.0.0</td></tr>
</table>>]
"monaco-editor" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>monaco-editor</b></td></tr>
<tr><td port="2" color="red"><font color="red">✕ monaco-editor 2.3.0</font></td></tr>
<tr><td port="1" color="green"><font color="green">✓ monaco-editor 2.2.0</font></td></tr>
</table>>]
"@replit/codemirror-css-color-picker" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>@replit/codemirror-css-color-picker</b></td></tr>
<tr><td port="5">@replit/codemirror-css-color-picker 3.5.0</td></tr>
<tr><td port="4" color="green"><font color="green">✓ @replit/codemirror-css-color-picker 3.4.0</font></td></tr>
<tr><td port="3" color="red"><font color="red">✕ @replit/codemirror-css-color-picker 3.3.0</font></td></tr>
</table>>]
"lodash" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>lodash</b><br/><font color="red">Конфликт!</font></td></tr>
<tr><td port="7" color="red"><font color="red">✕ lodash 2.6.0</font></td></tr>
<tr><td port="6" color="red"><font color="red">✕ lodash 2.5.0</font></td></tr>
</table>>]
"react" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>react</b></td></tr>
<tr><td port="9">react 3.2.0</td></tr>
<tr><td port="8" color="green"><font color="green">✓ react 3.1.0</font></td></tr>
</table>>]
"app":0 -> "react":8 [color="green"]
"app":0 -> "monaco-editor":1 [color="green"]
"app":0 -> "monaco-editor":2 [color="red"]
"monaco-editor":1 -> "@replit/codemirror-css-color-picker":4 [color="green"]
"monaco-editor":1 -> "@replit/codemirror-css-color-picker":5
"monaco-editor":2 -> "@replit/codemirror-css-color-picker":3 [color="red"]
"monaco-editor":2 -> "lodash":7 [color="red"]
"@replit/codemirror-css-color-picker":4 -> "react":8 [color="green"]
"@replit/codemirror-css-color-picker":3 -> "react":9
"@replit/codemirror-css-color-picker":3 -> "lodash":6 [color="red"]
"@replit/codemirror-css-color-picker":5 -> "lodash":7
"@replit/codemirror-css-color-picker":5 -> "react":9
}
''')
```

Рассматриваемый граф зависимостей также может быть представлен в виде булевой формулы.

Введём следующие обозначения:

* Пакет `app` обозначим как $a$.
* Пакет `monaco-editor` – как $m$.
* Пакет `@replit/codemirror-css-color-picker` – как $c$.
* Пакет `lodash` – как $l$.
* Пакет `react` – как $r$.

Версию пакета будем указывать справа от его имени. Тогда формула с логическими переменными для графа, показанного на @fig:deps, будет иметь вид:

$$
\begin{align}
( a_{1.0.0} \implies m_{2.3.0} \lor m_{2.2.0} ) \land
( a_{1.0.0} \implies r_{3.1.0} ) \land
( m_{2.3.0} \implies c_{3.3.0} ) \land \\
( m_{2.3.0} \implies l_{2.6.0} ) \land
( m_{2.2.0} \implies c_{3.5.0} \lor c_{3.4.0} ) \land
( c_{3.5.0} \implies l_{2.6.0} ) \land \\
( c_{3.5.0} \implies r_{3.2.0} ) \land
( c_{3.4.0} \implies r_{3.1.0} ) \land
( c_{3.3.0} \implies l_{2.5.0} ) \land \\
( c_{3.3.0} \implies r_{3.2.0} ) \land
a_{1.0.0}.
\end{align}
$$ {#eq:examsat}

Легко убедиться, что при выбранных вручную версиях пакетов $a_{1.0.0}$, $m_{2.2.0}$, $c_{3.4.0}$ и $r_{3.1.0}$ формула выполняется, при этом найденное решение является минимальным по числу пакетов. На практике задачи выполнимости булевых формул, таких как формула @eq:examsat, решаются при помощи SAT-решателей.

### Упражнения

В приведенных задачах необходимо правильно выбрать версии пакетов, чтобы обеспечивалось минимальное по числу пакетов решение.

**Задача 1.** Решите задачу разрешения зависимостей для пакета `xcite`:

```{.pysvg caption=""}
dot('''
digraph {
edge [minlen=1 arrowsize=0.5]
node [shape=none, fontsize=14]
rankdir=LR
"0" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>xcite </b></td></tr>
<tr><td port="1.0.0">xcite 1.0.0 </td></tr>
</table>>]
"1" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>@libcallaudio/doc </b></td></tr>
<tr><td port="1.2.0">@libcallaudio/doc 1.2.0 </td></tr>
<tr><td port="1.1.0">@libcallaudio/doc 1.1.0 </td></tr>
</table>>]
"2" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>eperl </b></td></tr>
<tr><td port="3.4.0">eperl 3.4.0 </td></tr>
<tr><td port="3.3.0">eperl 3.3.0 </td></tr>
</table>>]
"3" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>@libkickpass/dev </b></td></tr>
<tr><td port="5.3.0">@libkickpass/dev 5.3.0 </td></tr>
<tr><td port="5.2.0">@libkickpass/dev 5.2.0 </td></tr>
</table>>]
"0":"1.0.0" -> "1":"1.1.0"
"0":"1.0.0" -> "1":"1.2.0"
"0":"1.0.0" -> "3":"5.3.0"
"1":"1.2.0" -> "3":"5.2.0"
"1":"1.2.0" -> "2":"3.3.0"
"1":"1.2.0" -> "2":"3.4.0"
"2":"3.4.0" -> "3":"5.2.0"
}
''')
```

**Задача 2.** Решите задачу разрешения зависимостей для пакета `ruby.erubis`:

```{.pysvg caption=""}
dot('''
digraph {
edge [minlen=1 arrowsize=0.5]
node [shape=none, fontsize=14]
rankdir=LR
"0" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>ruby.erubis </b></td></tr>
<tr><td port="1.0.0">ruby.erubis 1.0.0 </td></tr>
</table>>]
"1" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>dcap.tunnel.telnet </b></td></tr>
<tr><td port="5.2.0">dcap.tunnel.telnet 5.2.0 </td></tr>
<tr><td port="5.1.0">dcap.tunnel.telnet 5.1.0 </td></tr>
</table>>]
"2" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>rdmacm.utils </b></td></tr>
<tr><td port="2.5.0">rdmacm.utils 2.5.0 </td></tr>
<tr><td port="2.4.0">rdmacm.utils 2.4.0 </td></tr>
</table>>]
"3" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>libroslib.dev </b></td></tr>
<tr><td port="2.6.0">libroslib.dev 2.6.0 </td></tr>
<tr><td port="2.5.0">libroslib.dev 2.5.0 </td></tr>
<tr><td port="2.4.0">libroslib.dev 2.4.0 </td></tr>
</table>>]
"0":"1.0.0" -> "3":"2.4.0"
"0":"1.0.0" -> "1":"5.2.0"
"0":"1.0.0" -> "1":"5.1.0"
"1":"5.1.0" -> "2":"2.5.0"
"1":"5.1.0" -> "2":"2.4.0"
"1":"5.2.0" -> "3":"2.4.0"
"1":"5.2.0" -> "3":"2.5.0"
"1":"5.2.0" -> "2":"2.4.0"
"2":"2.4.0" -> "3":"2.5.0"
"2":"2.4.0" -> "3":"2.6.0"
}
''')
```

**Задача 3.** Решите задачу разрешения зависимостей для пакета `libcgicc.dev`:

```{.pysvg caption=""}
dot('''
digraph {
edge [minlen=1 arrowsize=0.5]
node [shape=none, fontsize=14]
rankdir=LR
"0" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>libcgicc.dev </b></td></tr>
<tr><td port="1.0.0">libcgicc.dev 1.0.0 </td></tr>
</table>>]
"1" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>php.symfony.mime </b></td></tr>
<tr><td port="4.3.0">php.symfony.mime 4.3.0 </td></tr>
<tr><td port="4.2.0">php.symfony.mime 4.2.0 </td></tr>
</table>>]
"2" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>yacpi </b></td></tr>
<tr><td port="3.5.0">yacpi 3.5.0 </td></tr>
<tr><td port="3.4.0">yacpi 3.4.0 </td></tr>
</table>>]
"3" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>debomatic </b></td></tr>
<tr><td port="5.7.0">debomatic 5.7.0 </td></tr>
<tr><td port="5.6.0">debomatic 5.6.0 </td></tr>
<tr><td port="5.5.0">debomatic 5.5.0 </td></tr>
</table>>]
"0":"1.0.0" -> "3":"5.7.0"
"0":"1.0.0" -> "1":"4.2.0"
"0":"1.0.0" -> "1":"4.3.0"
"1":"4.2.0" -> "3":"5.6.0"
"1":"4.3.0" -> "2":"3.5.0"
"1":"4.3.0" -> "2":"3.4.0"
"2":"3.5.0" -> "3":"5.5.0"
}
''')
```

**Задача 4.** Решите задачу разрешения зависимостей для пакета `Sysvinit`:

```{.pysvg caption=""}
dot('''
digraph {
edge [minlen=1 arrowsize=0.5]
node [shape=none, fontsize=14]
rankdir=LR
"0" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>Sysvinit </b></td></tr>
<tr><td port="1.0.0">Sysvinit 1.0.0 </td></tr>
</table>>]
"1" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>Libusb.Java </b></td></tr>
<tr><td port="5.2.0">Libusb.Java 5.2.0 </td></tr>
<tr><td port="5.1.0">Libusb.Java 5.1.0 </td></tr>
</table>>]
"2" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>Libvshadow.Utils </b></td></tr>
<tr><td port="4.5.0">Libvshadow.Utils 4.5.0 </td></tr>
<tr><td port="4.4.0">Libvshadow.Utils 4.4.0 </td></tr>
</table>>]
"3" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>Chiark.Rwbuffer </b></td></tr>
<tr><td port="1.3.0">Chiark.Rwbuffer 1.3.0 </td></tr>
<tr><td port="1.2.0">Chiark.Rwbuffer 1.2.0 </td></tr>
<tr><td port="1.1.0">Chiark.Rwbuffer 1.1.0 </td></tr>
</table>>]
"4" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>Yorick.Av </b></td></tr>
<tr><td port="5.3.0">Yorick.Av 5.3.0 </td></tr>
<tr><td port="5.2.0">Yorick.Av 5.2.0 </td></tr>
</table>>]
"0":"1.0.0" -> "1":"5.1.0"
"0":"1.0.0" -> "1":"5.2.0"
"1":"5.1.0" -> "3":"1.1.0"
"1":"5.1.0" -> "2":"4.5.0"
"1":"5.1.0" -> "2":"4.4.0"
"1":"5.2.0" -> "3":"1.2.0"
"1":"5.2.0" -> "4":"5.3.0"
"1":"5.2.0" -> "3":"1.1.0"
"2":"4.5.0" -> "3":"1.3.0"
"3":"1.3.0" -> "4":"5.2.0"
}
''')
```

**Задача 5.** Решите задачу разрешения зависимостей для пакета `scim-unikey`:

```{.pysvg caption=""}
dot('''
digraph {
edge [minlen=1 arrowsize=0.5]
node [shape=none, fontsize=14]
rankdir=LR
"0" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>scim-unikey </b></td></tr>
<tr><td port="1.0.0">scim-unikey 1.0.0 </td></tr>
</table>>]
"1" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>dictem </b></td></tr>
<tr><td port="1.4.0">dictem 1.4.0 </td></tr>
<tr><td port="1.3.0">dictem 1.3.0 </td></tr>
</table>>]
"2" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>codelite-plugins </b></td></tr>
<tr><td port="3.6.0">codelite-plugins 3.6.0 </td></tr>
<tr><td port="3.5.0">codelite-plugins 3.5.0 </td></tr>
<tr><td port="3.4.0">codelite-plugins 3.4.0 </td></tr>
</table>>]
"3" [label=<<table border="0" cellborder="1" cellspacing="0">
<tr><td><b>ghdl-mcode </b></td></tr>
<tr><td port="1.7.0">ghdl-mcode 1.7.0 </td></tr>
<tr><td port="1.6.0">ghdl-mcode 1.6.0 </td></tr>
<tr><td port="1.5.0">ghdl-mcode 1.5.0 </td></tr>
</table>>]
"0":"1.0.0" -> "3":"1.7.0"
"0":"1.0.0" -> "1":"1.4.0"
"0":"1.0.0" -> "1":"1.3.0"
"1":"1.3.0" -> "2":"3.5.0"
"1":"1.3.0" -> "2":"3.4.0"
"1":"1.3.0" -> "2":"3.6.0"
"1":"1.4.0" -> "2":"3.5.0"
"1":"1.4.0" -> "3":"1.5.0"
"2":"3.4.0" -> "3":"1.6.0"
"2":"3.6.0" -> "3":"1.6.0"
}
''')
```
