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

=pod

=encoding UTF-8

=head1 NAME

Zabbix::Log.pm - Module permettant de tracer dans un fichier de logs toutes les actions réalisées

=head1 SYNOPSIS

use Zabbix::Log;

my $log = Zabbix::Log->new();

# Set DEBUG log
$log->log_DEBUG("Message en mode debug");

# Set INFO log
$log->log_INFO("Message en mode INFO");

# Set WARNING log
$log->log_WARNING("Message en mode WARNING");

# Set ERROR log
$log->log_ERROR("Message en mode ERROR");

# Set FATAL log
$log->log_FATAL("Messsage en mode FATAL");

=head1 DESCRIPTION

=head1 SEE ALSO

Zabbix API Documentation: L<https://www.zabbix.com/documentation/3.4/manual/api>

=head1 COPYRIGHT

Zabbix::Log is Copyright (C) 2018, William FEO.

=head1 License Information

This module is free software; you can redistribute it and/or modify it under the same terms as Perl 5.
This program is distributed in the hope that it will be useful, but it is provided 'as is' and without any express or implied warranties.

=head1 AUTHOR

William FEO


=head2 Exports
