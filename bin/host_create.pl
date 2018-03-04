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

#_____VARIABLES_____
#my $file = "/opt/Zabbix-Toolbox/csv/csvHostCreate.csv";
my $file = $ARGV[0];

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
	$zabbixLog->log_INFO("Chargement du fichier $file");

	my $csv = Text::CSV->new({
		binary   => 1,
		eol      => "\N{LF}",
		sep_char => ';',
	});

	open (my $data ,'<:encoding(UTF-8)',$file) or die "Impossible d'ouvrir le fichier '$file' !\n";
	
	# Parcours du fichier
	while (my $line = <$data>) {
		chomp $line;
		if ($csv->parse($line)) {
			my @fields 		= $csv->fields();
			my $csvHost 		= $fields[0];
			my $csvInterface 	= $fields[1];
			my $csvUseIP 		= $fields[2];
			my $csvIPorDNS 		= $fields[3];
			my $csvDescription 	= $fields[4];
			my $csvHostGroups 	= $fields[5];
			
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
						say "[ ok ] : L'hote $csvHost a été ajouté correctement.";
						$zabbixLog->log_INFO("================================================================================");
						$zabbixLog->log_INFO("# Création l'hôte \"$csvHost\" réussie !");
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
						say "[ Erreur ] : Une erreur est survenue lors de la création de l'hôte";
						$zabbixLog->log_ERROR("Une erreur est survenue lors de la création de l'hôte !");
					}
			} else {
				say "[ Erreur ] : L'hôte $csvHost existe";
				$zabbixLog->log_ERROR("L'hôte $csvHost existe !");
			}
		} else {
			say "Impossible de parser le fichier CSV";
            $zabbixLog->log_ERROR("Impossible de parser le fichier CSV !");
		}
	}
	
	$zabbixLog->close;
} else {
        $zabbixLog->close;
        exit;
}
