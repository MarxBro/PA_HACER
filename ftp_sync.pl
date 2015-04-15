#!/usr/bin/perl
######################################################################
# Simple ftp sync (por el momento solo un complemento de  PA_HACER.pl)
######################################################################
use strict;
use Getopt::Std;
use autodie;
use Data::Dumper;
use Net::FTP;
use Config::Simple;
use feature "say";

my ( %Configs, %opts ) = ();
getopts( 'Ssbdf:', \%opts );
my $debug = $opts{d} || 0;

die "Error! Falta el archivo de configuracion FTP!" unless defined $opts{f};
Config::Simple->import_from( $opts{f}, \%Configs );
if ($debug) {
    foreach my $key ( keys %Configs ) {
        say $key, "   ", $Configs{$key};
    }
}

# este es el archivo TODO.txt.
my $todo_archivo_pathy           = $ENV{'HOME'};
my $todo_archivo                 = 'TODO.txt';
my $nombre_completo_todo_archivo = $todo_archivo_pathy . '/' . $todo_archivo;

my $host   = $Configs{'FTP.HOST'};
my $puerto = $Configs{'FTP.PORT'};
my $user   = $Configs{'FTP.USER'};
my $pass   = $Configs{'FTP.PASSWORD'};
my $archivo_remoto;
if ( defined $Configs{'FTP.PATH'} ) {
    $archivo_remoto = $Configs{'FTP.PATH'} . $todo_archivo;
}
else {
    $archivo_remoto = '/' . $todo_archivo;
}

say ($user,$pass,$host,$puerto,$archivo_remoto) if $debug;

# Conectarse.
my $ftp_conex = Net::FTP->new($host);
$ftp_conex->login( $user, $pass );

######################################################################
# MAIN
######################################################################

if ( $opts{g} and $opts{p} ) {
    say
'OJO! las opciones -b(bajar) y -s(subir) son excluyentes Error, intente de nuevo cuando decida que carajo quiere hacer.'
      and die;
}
elsif ( $opts{s} ) {
    $ftp_conex->put($nombre_completo_todo_archivo,$archivo_remoto);
    $ftp_conex->quit;
}
elsif ( $opts{b} ) {
    $nombre_completo_todo_archivo .= "_Sync" unless $opts{S};
    $ftp_conex->get( $archivo_remoto, $nombre_completo_todo_archivo );
    $ftp_conex->quit;
}
else {
    say "Modo de uso: stuffs";
}

__DATA__

[FTP]
HOST="example.org"
USER="anonymous"
PASSWORD="-anonymous@"
PORT="21"
PATH="/todo_lists_backups/"
