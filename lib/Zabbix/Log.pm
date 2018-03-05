#!/usr/bin/perl
#============================================================================
# Nom : Zabbix::Log.pm
# Date : 02/02/2018
# Auteur : William FEO
# Description : Cette classe  
# Version : 0.1
#============================================================================
package Zabbix::Log;
use Moo;
use POSIX qw(strftime);
use Cwd;
use feature 'say';

#_____VARIABLES_____
my $DIR = getcwd;
my $DIR_LOG="$DIR/log";

my $logFileName = "$DIR_LOG/zabbix_toolbox.log";
my $logFileMode = '>>';
my ($fileLog,$filetmp);
my $date = strftime "%Y-%m-%d %H:%M:%S", localtime;

#_____ATTRIBUTES_____
#has 'log' => ( is => 'ro', default => sub { File::Log->new(logFileName => $logFileName,logFileMode => $logFileMode) } );


# Constructeur
sub new {
	my $self = shift;
}	

sub init {
        my $self = shift;
        # Création du fichier
		if (! -f $logFileName) {
			open($filetmp, '>:encoding(UTF-8)', $logFileName) or die "Impossible de créer le fichier $logFileName";
			close($filetmp);
		}
        open($fileLog, '>>:encoding(UTF-8)', $logFileName) or die "Impossible d'ouvrir le fichier $logFileName";
}

sub close {
        my $self        = shift;
        close($fileLog);
}

#--- Fonctions logs LEVELS
sub log_DEBUG {
	my $self        = shift;
        my ($message)   = @_;

        print $fileLog "$date zabbix-toolbox [debug] $message\n"; 
}

sub log_INFO {
	my $self        = shift;
        my ($message)   = @_;

        print $fileLog "$date zabbix-toolbox [info]  $message\n"; 
}

sub log_WARN {
	my $self        = shift;
        my ($message)   = @_;

        print $fileLog "$date zabbix-toolbox [warn]  $message\n"; 
}

sub log_ERROR {
	my $self        = shift;
        my ($message)   = @_;

        print $fileLog "$date zabbix-toolbox [error] $message\n"; 
}

# Destructeur
sub DEMOLISH {
	my ($self, $in_global_destruction) = @_;
	my $log = $self->log;
	
}


# NE PAS MODIFIER AU DELA DE CETTE LIGNE
1;
__END__
