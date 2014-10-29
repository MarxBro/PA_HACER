#!/usr/bin/perl
######################################################################
# PA_HACER.pl v2.
######################################################################

use strict;
use Getopt::Std;
use Pod::Usage;
use autodie;
use File::Slurp;
use feature "say";
use Term::ANSIColor;
use POSIX q/strftime/;
use Data::Dumper;

my $debug = 0;
my ( %opts, %QQ ) = ();

=pod

=encoding utf8

=head1 SYNOPSIS

Script para llevar una lista de cosas para hacer.

Permite agregar tareas, agruparlas en categorias, asignar y re-asignar prioridades, 
borrar por ID o categorias completas y exportar todo a HTML.

Sin opciones despliega una lista simple de cosas para hacer. 

=head2 Forma de uso:

PA_HACER -t Hola -c Prueba -p 1

PA_HACER 

PA_HACER -X

PA_HACER -B Prueba

PA_HACER -p 9 -i 1

=head2 Opciones

=over

=item B<-t>    Tarea - Descripcion o titulo de la tarea en si.

=item B<-c>    Categoria - Las categorias agrupan tareas. [ prescindible ]

=item B<-p>    Prioridad - La prioridad debe ser numerica y entre 1-10. [ prescindible ]

=item B<-B>    Borrar tarea/s - Permite eliminar tareas de la lista, por ID o CATEGORIA. [ excluyente ]

=item B<-X>    Exportar la lista de tareas a HTML. [ excluyente ]

=item B<-p>    Priorizar : Toma un numero que sera asignado como nueva prioridad para la tarea con ID -i. [ Necesita -i]

=item B<-i>    ID de la tarea a priorizar. [ Necesita -p]

=item B<-n>    NUEVO archivo TODO.txt: Borra el viejo, cuidadito... [excluyente]

=item B<-a>    ARCHIVAR - Backup del archivo TODO.txt actual. [excluyente]

=item B<-r>    RESTAURAR - Permite restaurar algun backup y convertirlo en acutal. [excluyente] 

=item B<-d>    DEBUGGING FLAG!

=item B<-h>    (Esta) Ayuda. [excluyente]

=back

Los parametros presindibles toman valores por defecto ante su ausencia.

Las opciones I<excluyentes> B<NO> se pueden combinar con otras.

Las opciones B<-p> y B<-i> van siempre juntas.

La prioridad por defecto es de B<6>.

La categoria por defecto es B<Etc.>.

=cut

getopts( 'p:i:t:c:p:B:Xnhdar', \%opts );
if ( $opts{d} ) { $debug++ }

# Variables necesarias
my $home          = $ENV{"HOME"};
my $archivo_input = $home . '/' . "TODO.txt";
my $existia       = 1;
my $carpeta_pa_backup = $home . q|/.PA_HACER_backups|;
Existencia();
my $msg_archivo_recien_creado = "El archivo TODO.txt fue recreado.... 
        No hay tareas pendientes. FIN.";
my $msg_archivo_vacio = "No hay tareas pendientes. 
    FIN.";
my @lns_todo_file = read_file("$archivo_input");

my $CATEGORIA_defaut  = 'Etc.';
my $PRIORIDAD_default = 6;

my $separador_campos_tareas = ' ||| ';
my $separador               = $separador_campos_tareas;
my $t_banana = strftime( "%d_%B_%Y_%H_%M_%S", localtime( time() ) );

######################################################################
# Cod. ppal.
######################################################################

if ( $opts{h} ) {
    ayudas();
}
elsif ( $opts{n} ) {
    Nuevo_archivo_input();
}
elsif ( $opts{t} ) {
    agregar_tarea();

    # Mostrar la lista después de insertar la tarea.
    LISTAR_LARGO();
}
elsif ( $opts{B} ) {
    Borrar_tarea();
}
elsif ( $opts{X} ) {
    Exportartar();
}
elsif ( $opts{p} ) {
    cambiar_prioridad( $opts{i}, $opts{p} );

    # Mostrar la lista después de modificar la tarea.
    LISTAR_LARGO();
}
elsif ( $opts{i} ) {
    cambiar_prioridad( $opts{i}, $opts{p} );

    # Mostrar la lista después de modificar la tarea.
    LISTAR_LARGO();
}
elsif ( $opts{a}){
    Backup();
    # Mostrar la lista después de copiar la lista de tareas. 
    LISTAR_LARGO();
}
elsif ($opts{r}){
    Restore();
    # Mostrar la lista después de restaurarla. 
    #LISTAR_LARGO();
}
else {
    if ($existia) {
        if ( -z $archivo_input ) {
            say $msg_archivo_vacio;
        }
        else {
            LISTAR_LARGO();
        }
    }
    else {
        say $msg_archivo_recien_creado;
    }
}
exit;

######################################################################
# SUBs
######################################################################
sub ayudas {
    pod2usage( -verbose => 2 );
    exit;
}

sub Existencia {

    # chequea que el arhcivo input exista, sino lo crea.
    unless ( -e $archivo_input ) {
        $existia--;
        `touch $archivo_input`;
        chmod 755, $archivo_input;
    }
}

sub last_line {
    my $last_line_l = $lns_todo_file[-1];
    say $last_line_l if $debug;
    my @campos_last_line = split( /$separador_campos_tareas/, $last_line_l );
    my $gh = $campos_last_line[0];
    say $gh if $debug;
    return $gh;
}

sub agregar_tarea {
    my $ln_tarea_apnd;
    my $ultimo_ID_escrito = last_line();
    say $ultimo_ID_escrito if $debug;
    my $ID_a_Escribir = $ultimo_ID_escrito + 1;
    say "IIIII _ _ $ID_a_Escribir" if $debug;
    my $TAREA_a_escribit = $opts{t};    # Tiene que haber algo ahi!

    # chequear si se pasaron categoria y prioridad al script;
    # sino, usar defaults.
    my ( $CATEGORIA_a_escribir, $PRIORIDAD_a_escribir );

    if ( $opts{c} ) {
        $CATEGORIA_a_escribir = $opts{c};
    }
    else {
        $CATEGORIA_a_escribir = $CATEGORIA_defaut;
    }
    if ( $opts{p} ) {
        $PRIORIDAD_a_escribir = $opts{p};
    }
    else {
        $PRIORIDAD_a_escribir = $PRIORIDAD_default;
    }

    say $CATEGORIA_a_escribir, $PRIORIDAD_a_escribir if $debug;

    $ln_tarea_apnd .=
        $ID_a_Escribir
      . $separador_campos_tareas
      . $CATEGORIA_a_escribir
      . $separador_campos_tareas
      . $PRIORIDAD_a_escribir
      . $separador_campos_tareas
      . $TAREA_a_escribit . "\n";
    say " -- $ln_tarea_apnd --" if $debug;

    push( @lns_todo_file, $ln_tarea_apnd );
    # Guardar archivo.
    Guardar_archivo($archivo_input);
}

sub LISTAR_LARGO {
    Jerarquia();
    print "\n", "-" x 84, "\n";
    print sprintf( "\| %-4s ", "Pr." ), sprintf( "\| %-15s ", "Categoria" ),
      sprintf( "\| %-45s ",  "TAREAS - Descripcion" ),
      sprintf( "\| %-7s \|", "IDs" );
    print "\n", "-" x 84, "\n";
    foreach my $id_pr ( sort { $a <=> $b } keys %QQ ) {
        for my $el ( 0 .. $#{ $QQ{$id_pr} } ) {
            if ( $el == 0 ) {
                #Prioridad
                my $prior         = $QQ{$id_pr}[$el];
                my $prior_colorin = '';
                if ( $prior >= 8 ) {
                    $prior_colorin = "bright_red on_black";
                }
                elsif ( $prior >= 5 ) {
                    $prior_colorin = "bright_yellow on_black";
                }
                elsif ( $prior >= 3 ) {
                    $prior_colorin = "bold on_black";
                }
                else {
                    $prior_colorin = "on_black";
                }
                print '|',
                  colored(
                    sprintf( " %-4d ", "$QQ{$id_pr}[$el]" ),
                    $prior_colorin
                  ),
                  '|';
            }
            elsif ( $el == 1 ) {
                #Categoria
                print colored( sprintf( " %-15s ", "$QQ{$id_pr}[$el]" ),
                    'bright_green  on_black' ),
                  '|';
            }
            elsif ( $el == 2 ) {
                #TAREA
                print colored( sprintf( " %-45s ", "$QQ{$id_pr}[$el]" ),
                    'bold  on_black' ),
                  '|';
            }
            elsif ( $el == 3 ) {
                print colored( sprintf( " %-7d ", "$QQ{$id_pr}[$el]" ),
                    'bright_green on_black' ),
                  '|';
            }
            else {
                say "error!";
            }
        }
        print "\n", "-" x 84, "\n";
    }
}

sub Jerarquia {
    foreach my $ln (@lns_todo_file) {
        my ( $ID_a, $CAT_a, $PRIO_a, $TAREA_a ) = split( / [\|]{3} /, $ln );
        chomp($TAREA_a);    # IMPORTANTE!
        say $ID_a, $CAT_a, $PRIO_a, $TAREA_a if $debug;
        $QQ{$ID_a} = [ "$PRIO_a", "$CAT_a", "$TAREA_a", "$ID_a" ];
        say "$QQ{$ID_a}" if $debug;
    }
}

sub Guardar_archivo {
    my $archivo_out = shift;
    write_file( "$archivo_out", @lns_todo_file );
}

sub Borrar_tarea {
    my $target  = $opts{B};
    my @lns_NEO = ();
    my $tipo;

    if ( $target =~ m/\d+/ ) {
        $tipo = 'ID';
        @lns_NEO = grep ( !/^$target/, @lns_todo_file );
    }
    elsif ( $target =~ m/\w+/ ) {
        $tipo = 'CATEGORIA';
        @lns_NEO = grep ( !/[\|]{3} $target [\|]{3}/, @lns_todo_file );
    }
    else {
        Erro(
"El argumento utilizado no es numerico ni un string valido. ERROR Y FINAL."
        );
    }
    #CORREGIR IDs -> super-paranoicamente!
    my $nnn = 1;
    foreach my $ln_txt_original (@lns_NEO) {
        $ln_txt_original =~ s/^\d+/$nnn/;
        $nnn++;
    }

    #Guardar archivo!
    write_file( "$archivo_input", @lns_NEO );
}

sub Erro {
    my $td = shift;
    die "$td";
}

sub Exportartar {
    my $HTML_header =
'<!DOCTYPE html><html><body><table border=1 style="width:80%;padding: 6px">'
      . "\n";
    my $HTML_pie = '<pre>Exportado : ' . $t_banana . '</pre>';
    my $HTML_fin = '</table>' . $HTML_pie . '</body></html>';
    my $HTML_header_tabla =
'<tr> <th>ID</th> <th>CATEGORIA</th> <th>PRIORIDAD</th> <th>TAREA</th> </tr> ';
    my $HTMLIN = $HTML_header . $HTML_header_tabla;

    foreach my $lns_pa_exp (@lns_todo_file) {
        $HTMLIN .= '<tr>' . "\n";
        my @campos = split( / [\|]{3} /, $lns_pa_exp );
        foreach my $campo_exp (@campos) {
            $HTMLIN .= q|<td>| . $campo_exp . q|</td>| . "\n";
            say $campo_exp if $debug;
        }
        $HTMLIN .= '<tr>' . "\n";
    }

    $HTMLIN .= $HTML_fin;
    my $nombre_archivo_a_exportar = 'TODO_export_' . $t_banana . '.html';
    say $nombre_archivo_a_exportar if $debug;
    write_file( "$nombre_archivo_a_exportar", $HTMLIN );
}

sub Nuevo_archivo_input {
    say "Borrando viejo archivo $archivo_input ...";
    write_file( $archivo_input, '' );    # Ja!
    say "Listo, creando uno nuevo...";
    Existencia();
    say "---";
}

# Funcion para cambiar la prioridad de una tarea preexistente.
sub cambiar_prioridad {
    my $id_pra_cambiar  = shift;
    my $prior_final_pre = shift;
    Erro("No se especifico el ID de la tarea a modificar. ERROR.")
      unless $id_pra_cambiar;
    Erro("No se especifico una PRIORIDAD nueva. ERROR.")
      unless $prior_final_pre;
    say $id_pra_cambiar, $prior_final_pre if $debug;
    my $prior_final = $prior_final_pre;

    my @lns_NEOnn = grep ( /^$id_pra_cambiar \|{3}/, @lns_todo_file );
    my $ln_pre = $lns_NEOnn[0];
    say $ln_pre if $debug;
    Erro(
"El ID de la tarea especificada para cambiar la prioridad, no existe. ERROR"
    ) unless $ln_pre;

    my @cps                    = split( / \|{3} /, $ln_pre );
    my $prior_buscado          = $cps[2];
    my $id_buscado             = $cps[0];
    my ($id_buscado_pra_index) = $id_buscado;
    say "ID PRA IN: $id_buscado_pra_index" if $debug;
    my $ln_final = $ln_pre;
    $ln_final =~ s/\|{3} $prior_buscado/\|\|\| $prior_final/g;

    $lns_todo_file[ $id_buscado_pra_index - 1 ] = $ln_final;
    write_file( "$archivo_input", @lns_todo_file );
}

sub Backup {
    check_dir_backup();
    # Escribir el backup y guardarlo.
    my $nombre_backup = $carpeta_pa_backup .'/' . "TODO_backup_" . $t_banana . '.txt';
    say $nombre_backup if $debug;
    write_file("$nombre_backup",@lns_todo_file);
}

sub check_dir_backup {
    # Chequear si existe la carpeta destino, si no existe crearla como un loco.
    unless (-d $carpeta_pa_backup ){
        #chdir $home; 
        `mkdir -p $carpeta_pa_backup`;
        say "Creado $carpeta_pa_backup" if $debug;
        return 1;
    }
    return 0;
}

sub Restore {
    my $st = check_dir_backup();
    Erro("No hay archivos para Restaurar: la carpeta $carpeta_pa_backup no existia o estaba vacia. ERROR!") if $st;

    opendir my $dir_bk, $carpeta_pa_backup;
    my @backs_anteriores = grep (!/^[.]/, readdir($dir_bk));
    closedir $dir_bk;

    my $nro_bak_pra_menu = $#backs_anteriores + 1;
    my $index_dummy = 0;
    my %BBB =  map { $index_dummy++ => $_ } @backs_anteriores;
    print Dumper (\%BBB) if $debug;

    say "Elegir que archivo restaurar (Notar las fechas en los nombres):";
# Mejorar este menu chiotto.
    for my $kk_restaurar (sort { $a <=> $b }keys %BBB){
        say "$kk_restaurar )- $BBB{$kk_restaurar}";
    }
    
    my $in_us = <STDIN>;
    say $in_us if $debug;
    #exit;

    say "Restaurando $BBB{$in_us}";
# CHequear que exista la opcion y que este bien escrito.
# Reemplazar todo.txt por el todo.txt real.
    `cp $carpeta_pa_backup/$BBB{$in_us} $archivo_input;`
}



=pod

=head3 Ejemplos: 

Para insertar una tarea, alcanza con utilizar solamente la opcion B<-t>.

PA_HACER -t Hola -c Prueba -p 1

La opciones B<-c> y B<-p> no son obligatorias y asignan prioridad y categoria.

La tarea es -en si misma- una descripcion, y conviene agruparlas en categorias para borrarlas mas facilmente.

Las prioridades, a su vez, se pueden reasignar.

=head3 TXT

Todo lo que este programita hace esta en un archivo de texto plano (el viejo y querido I<txt>).

=head2 Bugs y epilepsia.

Utiliza como separador de campos al string ' ||| ', asi que evitarlo en la descripcion de las tareas...
Nadie es tan extravagante, no? Ja!

=head1 Autor y Licencia.

Programado por B<Marxbro> aka B<Gstv>, un lluvioso dia de Octubre del 2014.
La pagina esta hecha por la gracia de github y algunos retoques a priori.

Distribuir solo bajo la licencia
WTFPL: I<Do What the Fuck You Want To Public License>.

Zaijian.

=cut

#######################################################################
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE              #
#                    Version 2, December 2004                         #
#                                                                     #
# Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>                    #
#                                                                     #
# Everyone is permitted to copy and distribute verbatim or modified   #
# copies of this license document, and changing it is allowed as long #
# as the name is changed.                                             #
#                                                                     #
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE              #
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION   #
#                                                                     #
#  0. You just DO WHAT THE FUCK YOU WANT TO.                          #
#                                                                     #
#######################################################################
