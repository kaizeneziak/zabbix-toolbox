#!/usr/bin/perl
#============================================================================
# Nom : Auth.pm
# Date : 11/01/2018
# Auteur : William FEO
# Description : Cette classe permet de s'authentifier avec l'API de Zabbix
# Version : 0.1
#============================================================================

package Zabbix::Auth;                   # Nom du package, de la Classe

use FindBin;
use lib "$FindBin::Bin/../lib";

use Carp;                               # Utile pour émettre certains avertissements
use Moo;
use JSON;
use LWP;
use Data::Dumper;
use Config::IniFiles;
use Text::CSV;
use Cwd;

use v5.10;
#
# Définition des variables
#

# Version de la Classe
our $VERSION = '0.1';

my $DIR = getcwd;
my $DIR_CONF="$DIR/conf";
my $fileCredentials = "$DIR_CONF/credentials.ini";

#
# Définitions des attributs
#

has url => (is => 'rw');
has username => (is => 'ro');
has password => (is => 'ro');
has authid => (is => 'rw');

#
# Définitions des fonctions
#


# Méthode login()
sub login {
        my $self = shift;
        # Chargement des credentials
        my $cfg = Config::IniFiles->new( -file => "$fileCredentials" );
        #my $url = $cfg->val('zabbix','url');
        $self->url($cfg->val('zabbix','url'));
        my $username = $cfg->val('zabbix','user');
        my $password = $cfg->val('zabbix','password');

        # Création de la requête POST 
        my $ua = LWP::UserAgent->new;
        my $json_req = {
                jsonrpc => '2.0',
                method => 'user.login',
                params => {
                        user => $username,
                        password => $password
                },
                id => 1
        };
       
        # Création de la RESPONSE        
        my $json = encode_json( $json_req );
        #say "# DEBUG json=$json";

        $ua->ssl_opts( verify_hostnames => 1 );
        my $response = $ua->post( $self->url, 'Content-type' => 'application/json', Content => $json );

        #say "# DEBUG \$response=$response";

        if ( $response->is_success() ) {
			my $tmp = $response->decoded_content();
			#say "# DEBUG \$tmp=$tmp";
			my $content = decode_json( $tmp );
			#say "# DEBUG content=$content";
			$self->authid($content->{'result'});
			#say "Token d'authentification de l'utilisateur $username = $content->{'result'}";
	        return 1;
        } else {
			say "Erreur d'authentification !";
			say "Merci de vérifier les identifiants de connexion dans le fichier 'credentials.ini'";
			return 0;
        }
}

sub getUrl {
        my $self = shift;
	return $self->url;
}

sub getAuthId {
        my $self = shift;
	return $self->authid;
}

sub logout {
        my $this = shift;
        print "Déconnexion";
}
# NE PAS MODIFIER AU DELA DE CETTE LIGNE
1;
__END__
