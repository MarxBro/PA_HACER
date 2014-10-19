#PA_HACER

Programita para administrar ideas, cosas para hacer y huevadas similares ("tareas"), desde la consola.
Permite agregar, asignar y re-asignar prioridades, agrupar en categorias, borrar (por categorias o por IDs), exportar y no mucho mas...

Todas las tareas van a parar al $HOME del usuario (quien obviamente usa Linux o algo
por el estilo) dentro de un archivo llamado -no muy originalmente- *TODO.txt*.

## Forma de uso

No tiene mucho misterio y esta documentado -mas o menos- en una manpage y en el script mismo:

```bash
man T || PA_HACER.pl -h
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

La forma mas feliz es utilizando el _make_ :

```bash
make
```

que se encarga de todo.

Sin embargo, alcanza con copiar el archivo PA_HACER.pl en alguna carpeta del $PATH.

Pare desinstalar, es similar:

```bash
make
```

## Customizar la cosa

Puede ser una buena idea agregar algunos alias a la configuracion de shell, para facil acceso.

```bash
alias T="PA_HACER.pl"
alias t="PA_HACER.pl -t"
```

Entonces despues alcanza con escrbir **T** en la terminal para ver la lista, y con algo asi:

```bash
t "Documentar en github" -c TODO_LIST -p 2
```

para agregar tareas (ver el ejemplo abajo).

![](ejemplo.jpg?raw=true)

Tambien es una buena idea agregarlo al startup del shell; en mi caso particular esta despues de fortune.

## Bugs conocidos

Como el unico que usa este "ekeko multitasking" soy yo, ninguno todavia.

## TODO

- Poner acentos en este archivo...
- Agregar _Forma de Uso_.
- Ordenar las tareas por Prioridad, en vez de usar el ID.
- Mejorar la salida, permitiendo descripciones mas largas.
- [TAL VEZ] Agregar fechas, a.k.a "deathlines". 
- [EN UNA DE ESAS] Mejorar el css del HTML que exporta.
- [EN UNA DE ESAS && SI ME RE PINTA] agregar sincronizacion ftp.
- [SI HICE TODO LO ANTERIOR] Empezar a cobrar un servicio de ftp syncing... jaja, nah.
~~Funcion para cambiar la prioridad de las tareas agregadas.~~

## Licencia.

WTFPL.

## Etc

Hay muchos programas como este, muy chetos y bien hechos; pero este es mio... 

Zaijian.

