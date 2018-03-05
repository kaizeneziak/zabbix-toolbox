#!/usr/bin/perl
#====================================================
#        NAME : zabbixCreateHosts.pl
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
use Text::Iconv;

#_____VARIABLES_____
my $fileInput = $ARGV[0];

my $IPorDNS;

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

	my $zabbixHostGroup = Zabbix::HostGroup->new(
		url     => $zabbixAuth->url,
		authid  => $zabbixAuth->authid
	);

	# Lecture du Fichier CSV ligne par ligne
	# Chargement du fichier
	$zabbixLog->log_INFO("Chargement du fichier $fileInput");

	my $csv = Text::CSV->new({
		binary   	=> 1,
		auto_diag 	=> 1,
		sep_char 	=> ';',
	});

	# Conversion du fichier
	my $encodage = Text::Iconv->new("cp1252","utf-8");
	my $file = $encodage->convert($fileInput);
	
	open (my $data ,'<',$file) or die "Impossible d'ouvrir le fichier '$file' !\n";
	
	# Ignore header
	$csv->getline($data);
	
	# Parcours du fichier
	while ( my $hostCreateFields = $csv->getline($data) ) {
		my $csvHost 		= $hostCreateFields->[0];
		if ( defined $hostCreateFields->[0] ) {
			my $csvInterface 	= $hostCreateFields->[1];
			my $csvUseIP 		= $hostCreateFields->[2];
			my $csvIPorDNS 		= $hostCreateFields->[3];
			my $csvDescription 	= $hostCreateFields->[4];
			my $csvHostGroups 	= $hostCreateFields->[5];
			
			# Vérifications
			# Vérif si host existe
			my ($hostExist,$hostid) = $zabbixHost->checkIfHostExist($csvHost);
			# say "##### DEBUG \$csvHost=$csvHost";
			# say "##### DEBUG \$hostExist=$hostExist";
			# say "##### DEBUG \$hostid=$hostid";

			if ( $hostExist eq 0 ) {
					#if ($zabbixHost->checkIfHostExist($csvHost)) {
					# Vérif le type d'interface
					my ($interface,$port) = $zabbixHost->checkInterface($csvInterface);

					# Vérif Adresse IP ou DNS
					if ($csvUseIP eq 1) {
							$IPorDNS="IP";
					} else {
							$IPorDNS="DNS";
					}
					my ($ipfield,$dnsfield) = $zabbixHost->checkIfIpOrDns($csvUseIP,$csvIPorDNS);

					# Vérif les hostGroups
					my @hostGroupIds = $zabbixHostGroup->getHostGroupId($csvHostGroups);

					# Création du host
					# createHost($id,$host,$interface,$port,$useip,$ipfield,$dnsfield,@hostGroups);
					my $zabbixHostCreated = $zabbixHost->hostCreate(1,$csvHost,$interface,$port,$csvUseIP,$ipfield,$dnsfield,$csvDescription,@hostGroupIds);

					if ($zabbixHostCreated eq 1) {
						say "[ ok ] : L'hote $csvHost a ete ajoute correctement.";
						$zabbixLog->log_INFO("================================================================================");
						$zabbixLog->log_INFO("# Création l'hote \"$csvHost\" reussie !");
						$zabbixLog->log_INFO("================================================================================");
						$zabbixLog->log_INFO("|               Host : $csvHost");
						$zabbixLog->log_INFO("|          Interface : $csvInterface");
						$zabbixLog->log_INFO("|               Port : $port");
						$zabbixLog->log_INFO("|  Adresse IP ou DNS : $IPorDNS");
						$zabbixLog->log_INFO("|         Adresse IP : $ipfield");
						$zabbixLog->log_INFO("|            Nom DNS : $dnsfield");
						$zabbixLog->log_INFO("| Membre des groupes : $csvHostGroups");
						$zabbixLog->log_INFO("|        Description : $csvDescription");
					} else {
						say "[ Erreur ] : Une erreur est survenue lors de la création de l'hote";
						$zabbixLog->log_ERROR("Une erreur est survenue lors de la création de l'hote !");
					}
			} else {
				say "[ Erreur ] : L'hote $csvHost existe";
				$zabbixLog->log_ERROR("L'hote $csvHost existe !");
			}
		}
	}
	
	$zabbixLog->close;
} else {
        $zabbixLog->close;
        exit;
}
