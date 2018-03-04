#!/usr/bin/perl
#====================================================
#        NAME : init.pl
#        DATE : 02/02/2018
#      AUTHOR : William FEO
# DESCRIPTION : Ce script permet d'initialiser le programme Zabbix-Toolbox avec
#				l'adresse du serveur Zabbix, le nom d'utilisateur et son mot de passe.
#     VERSION : 1.0
#====================================================

BEGIN { push @INC, '/opt/Zabbix-Toolbox/lib'};

#_____PACKAGES_____
use Moo;
use feature 'say';

use Zabbix::Auth;
use Zabbix::Host;
use Zabbix::HostGroup;
use Zabbix::Log;
use Text::CSV;
use IO:Prompt;

#_____VARIABLES_____
my ($server,$user,$pass);

#_____FUNCTIONS_____
sub testCredentials {
	my $url = shift;
	my $user = shift;
	my $pass = shift;
	
	my $zabbixAuth  = Zabbix::Auth->test;
}	

sub getUrl {
	my $server = shift;
	
	# Test http://$server/zabbix/api_jsonrpc.php
	my $test1 = `curl -s http://$server/zabbix/api_jsonrpc.php`;
	if 
	# Test http://$server/api_jsonrpc.php
	my $test2 = `curl -s http://$server/api_jsonrpc.php`;
	# Test https://$server/zabbix/api_jsonrpc.php
	my $test3 = `curl -s https://$server/zabbix/api_jsonrpc.php`;
	# Test https://$server/api_jsonrpc.php
	my $test4 = `curl -s https://$server/api_jsonrpc.php`;
	
}

#_____PROGRAMME_____

# Affichage des questions
#--Quel est l'adresse du serveur Zabbix ? (Exemple : zabbix.domain.tld) : "
print "Quel est l'adresse du serveur Zabbix ? (Exemple : zabbix.domain.tld) : ";
$server = <STDIN>;
#--Nom d'utilisateur disposant des droits d'administration ? : "
print "Nom d'utilisateur disposant des droits d'administration ? : ";
$user = <STDIN>;
# Chiffrage du mot de passe en MD5
#--Mot de passe : "
$pass = prompt('Mot de passe : ', -e => '*');


# Test de l'url et vérification http ou https
# Test du couple login/mot de passe

# Enregistrement dans le fichier.








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
                        my $hostExist = $zabbixHost->checkIfHostExist($csvHost);
                        #say "##### DEBUG HostExist ? : $hostExist";
		        if ( $hostExist eq 0 ) {
                        #if ($zabbixHost->checkIfHostExist($csvHost)) {
		                # Vérif le type d'interface
		                my ($interface,$port) = $zabbixHost->checkInterface($csvInterface);
               
                                #say "##### DEBUG \$interfaceCSV=$csvInterface"; 
                                #say "##### DEBUG \$interface=$interface"; 
                                #say "##### DEBUG \$port=$port";

		                # Vérif Adresse IP ou DNS
                                if ($csvUseIP eq 1) {
                                        $IPorDNS="IP";
                                } else {
                                        $IPorDNS="DNS";
                                }
		                my ($ipfield,$dnsfield) = $zabbixHost->checkIfIpOrDns($csvUseIP,$csvIPorDNS);
                                
                                #say "##### DEBUG \$ipfield=$ipfield";
                                #say "##### DEBUG \$dnsfield=$dnsfield";
	
		                # Vérif les hostGroups
		                my @hostGroupIds = $zabbixHostGroup->getHostGroupId($csvHostGroups);

		                # Création du host
		                # createHost($id,$host,$interface,$port,$useip,$ipfield,$dnsfield,@hostGroups);
                                #say "##### DEBUG FCT createHost : \$csvHost=$csvHost";
                                #say "##### DEBUG FCT createHost : \$interface=$interface";
                                #say "##### DEBUG FCT createHost : \$port=$port";
                                #say "##### DEBUG FCT createHost : \$csvUseIP=$csvUseIP";
                                #say "##### DEBUG FCT createHost : \$ipfield=$ipfield";
                                #say "##### DEBUG FCT createHost : \$dnsfield=$dnsfield";
                                #say "##### DEBUG FCT createHost : \$csvDescription=$csvDescription";
		                my $zabbixHostCreated = $zabbixHost->createHost(1,$csvHost,$interface,$port,$csvUseIP,$ipfield,$dnsfield,$csvDescription,@hostGroupIds);

                                if ($zabbixHostCreated) {
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

        # Création du host
#        my @hostGroups = qw(test test1234 test12345);
#        $zabbixHost->createHost(1, "host_01","agent",0,"1.1.1.1",@hostGroups );

#        my $result = $zabbixHostGroup->getHostGroupId("test1234567");

#        say "# DEBUG \$groupid=$result";
        $zabbixLog->close;
} else {
        $zabbixLog->close;
        exit;
}
