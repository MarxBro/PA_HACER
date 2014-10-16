#PA_HACER

Programita para administrar ideas, cosas para hacer y huevadas similares ("tareas"), desde la consola.

Permite agregar, agrupar en categorias, borrar (por categorias o por IDs), exportar y no mucho mas...

Todo va a un archivo de texto llamado "TODO.txt", el $HOME del usuario (quien obviamente usa Linux o algo
por el estilo).

## Forma de uso

Ver la documentacion con

```bash
./PA_HACER.pl -h
```

## Dependencias

Este programa necesita estos componentes de Perl:

* Term::ANSIColor
* File::Slurp

Para instalarlos con cpanplus:

```bash
cpanp i Term::ANSIColor File::Slurp
```

Ademas necesita:
* strict, autodie y "say" que pertence a features. [core]
* Getopt::Std [core]
* Pod::Usage [core]
* "strftime" de POSIX [core]

## Instalacion

Alcanza con copiar el archivo .pl en alguna carpeta del $PATH

Puede ser una buena idea agregar algunos alias a la configuracion de shell, para facil acceso.

```bash
alias T="PA_HACER.pl"
alias t="PA_HACER.pl -t"
```

Entonces despues alcanza con escrbir **T** en la terminal para ver la lista, y con algo asi:

```bash
t "Documentar en github" -c TODO_LIST_PROJECT -p 2
```

para agregar tareas.

Tambien es una buena idea agregarlo al startup del shell; en mi caso particualr esta despues de fortunes.

## Bugs conocidos

Como el unico que usa este "ekeko multitasking" soy yo, ninguno todavia.

## TODO

* Poner acentos en este archivo...
* Agregar _Forma de Uso_.
* Funcion para cambiar la prioridad de las tareas agregadas.
* Ordenar las tareas por Prioridad, en vez de usar el ID.
* Mejorar la salida, permitiendo descripciones mas largas.
* [TAL VEZ] Agregar fechas, a.k.a "deathlines". 
* [TAL VEZ] Un make que copie el script a /usr/local/bin y haga un manpage al path. (Es facil pero me da mucha ~~paja~~  pereza.)
* [EN UNA DE ESAS] Mejorar el css del HTML que exporta.
* [EN UNA DE ESAS && SI ME RE PINTA] agregar sincronizacion ftp.
* [SI HICE TODO LO ANTERIOR] Empezar a cobrar un servicio de ftp syncing... jaja, nah.

## Licencia.

WTFPL.

## Etc

Hay muchos programas como este, muy chetos y bien hechos; pero este es mio... 

Zaijian.

