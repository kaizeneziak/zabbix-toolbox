#!/usr/bin/perl
#====================================================
#        NAME : hostupdateInventory.pl
#        DATE : 02/02/2018
#      AUTHOR : William FEO
# DESCRIPTION : 
#     VERSION : 1.0
#====================================================

#_____PACKAGES_____
use FindBin;
use lib "$FindBin::Bin/../lib";

use Moo;
use feature 'say';

use Zabbix::Auth;
use Zabbix::Host;
use Zabbix::HostGroup;
use Zabbix::Log;
use Text::CSV;

#_____VARIABLES_____
my $force_update 	= $ARGV[0];
my $file 			= $ARGV[1];

#_____FUNCTIONS_____

#_____PROGRAMME_____

my $zabbixLog   = Zabbix::Log->new;
$zabbixLog->init;

my $zabbixAuth  = Zabbix::Auth->new;

if ( $zabbixAuth->login() ) {
	my $zabbixHost = Zabbix::Host->new( 
		url     => $zabbixAuth->url,
		authid  => $zabbixAuth->authid 
	);

	# Lecture du Fichier CSV ligne par ligne
	# Chargement du fichier
	$zabbixLog->log_INFO("Chargement du fichier $file");

	my $csv = Text::CSV->new({
		binary   	=> 1,
		auto_diag 	=> 1,
		sep_char 	=> ';',
		eol			=> "\r\n",
	});

	open (my $data ,'<:encoding(utf-8)',$file) or die "Impossible d'ouvrir le fichier '$file' !\n";
	
	# Ignore header
	$csv->getline($data);
	
	# Parcours du fichier
	while ( my $hostInventoryFields = $csv->getline($data) ) {
		my $i = 0;
		my $csv_host = $hostInventoryFields->[0];;
		if ( defined $hostInventoryFields->[0] ) {			
	
			# Vérifications
			my ($hostExist,$hostid) = $zabbixHost->checkIfHostExist($csv_host);
			if ( $hostExist eq 1 ) {
				my $hostGetInventoryFields = $zabbixHost->hostGetInventory($hostid);
				my $statusHostUpdateInventory;
				if ( $force_update == 0 ) {
					$statusHostUpdateInventory = $zabbixHost->hostUpdateInventory($hostid,$hostInventoryFields);
				} elsif ( $force_update == 1 ) {
					#--- Get Inventory values from host
					$statusHostUpdateInventory = $zabbixHost->hostForceUpdateInventory($hostid,$hostInventoryFields,$hostGetInventoryFields);
				}
				
				if ( $statusHostUpdateInventory == 1 ) {
					say "[ ok ] : Mise à jour des données d'inventaire de l'hôte \"$csv_host\" réussi";
					$zabbixLog->log_ERROR("Mise à jour des données d'inventaire de l'hôte \"$csv_host\" réussi");
				} else {
					say "[ Erreur ] : Une erreur est survenue lors de la mise à jour des données d'inventaire de l'hôte \"$csv_host\" ! ";
					$zabbixLog->log_ERROR("Une erreur est survenue lors de la mise à jour des données d'inventaire de l'hôte \"$csv_host\" !");
				}
			} else {
				say "[ Erreur ] : L'hôte $csv_host n'existe pas !";
				$zabbixLog->log_ERROR("L'hôte $csv_host n'existe pas !");
			}
		}
	}
	
	if (not $csv->eof) {
		$csv->error_diag();
	}
	
	close $data;
    $zabbixLog->close;
} else {
	$zabbixLog->close;
	exit;
}
