#!/usr/bin/perl
#============================================================================
# Nom : HostGroup.pm
# Date : 11/01/2018
# Auteur : William FEO
# Description : Cette classe  
# Version : 0.1
#============================================================================

package Zabbix::HostGroup;             # Nom du package, de la Classe

use FindBin;
use lib "$FindBin::Bin/../lib";

use Moo;
use feature 'say';
use Carp;

use LWP;
use JSON;
use Data::Dumper;
        
#_____VARIABLES_____

#_____ATTRIBUTES_____
has 'groupid' 		=> ( is => 'rw' );
has 'idHostGroupCreate'	=> ( is => 'rw' );
has 'name'		=> ( is => 'rw' );
has 'flags'		=> ( is => 'ro' );
has 'internal'		=> ( is => 'ro' );

has 'ua'		=> ( is => 'ro', lazy => 1, default => sub { LWP::UserAgent->new } );
has 'url'	        => ( is => 'rw', required => 1 );
has 'authid'		=> ( is => 'rw', required => 1 );

# The BUILD method is called after an object is created. 
# There are several reasons to use a BUILD method. 
# One of the most common is to check that the object state is valid. 
# While we can validate individual attributes through the use of types,
# we can't validate the state of a whole object that way. 
sub BUILD {
	my $self 	= shift;
	my $url		= $self->url;
	my $authid  = $self->authid;
}

sub createHostGroup {
	my $self                        = shift;
	my ($idHostGroupCreate,$name)   = @_;

	my $ua = $self->ua;
        
	# Construction JSON
	my $json_data = {
		jsonrpc => '2.0',
		method	=> 'hostgroup.create',
		params	=> {
			name	=> $name
		},
		auth	=> $self->authid,
		id	=> $idHostGroupCreate
	};
	
        my $json = encode_json($json_data);
        my $response = $ua->post( $self->url, 'Content-type' => 'application/json', Content => $json );
        
	if ( $response->{_rc} !~ /2\d\d/ ) {
                my $error_message = "HTTP error ";
                $error_message   .= "(code $response->{_rc}) ";
                $error_message   .= $response->{_msg} // q{};
                croak($error_message);
        }

        my $content = decode_json( $response->{_content} );

        if ( $content->{error} ) {
                my $error_data = $content->{error}->{data};
                my $error_msg  = $content->{error}->{message};
                my $error_code = $content->{error}->{code};
                my $error = "Error from Zabbix (code $error_code): $error_msg  $error_data";
                say $error;
        } else { 
                say "[ ok ] : Création du HostGroup $name";
                $self->groupid($content->{'groupids'});
       }
}

sub getHostGroupId {
	my $self                = shift;
	my ($csvHostGroups)     = @_;

        my $ua                  = $self->ua;
	my $authid              = $self->authid;
	
        my (@hostGroupIds);

        #Split
        my @hostGroups = split /,/, $csvHostGroups;

        foreach my $hg (@hostGroups) {
                # Construction JSON
        	my $json_data = {
        		jsonrpc => '2.0',
        		method	=> 'hostgroup.get',
        		params	=> {
        			output	=> 'extend',
        			filter	=> {
        				name	=> [ $hg ]
        			}
        		},      
        		auth	=> $authid,
        		id	=> 1
        	};
        
                #say "______________ REQUEST ___________"; 
                #print Dumper $json_data;

                my $json = encode_json($json_data);

                my $response = $ua->post( $self->url, 'Content-type' => 'application/json', Content => $json );

        	if ( $response->{_rc} !~ /2\d\d/ ) {
                        my $error_message = "HTTP error ";
                        $error_message   .= "(code $response->{_rc}) ";
                        $error_message   .= $response->{_msg} // q{};
                        croak($error_message);
                }

                my $content = decode_json( $response->{_content} );

                if ( $content->{error} ) {
                        my $error_data = $content->{error}->{data};
                        my $error_msg  = $content->{error}->{message};
                        my $error_code = $content->{error}->{code};
                        my $error = "Error from Zabbix (code $error_code): $error_msg  $error_data";
                        say $error;
                } else {
                        for my $result (@{ $content->{'result'} }) {
                                #say "##### DEBUG FCT getHostGroupId : \$result->{'groupid'}=$result->{'groupid'}";
                                if ($result->{'groupid'}) {
                                        push @hostGroupIds, { groupid => $result->{'groupid'} };
                                }
                        }
                }
        }

        if (!@hostGroupIds) {
                say "[ Erreur ] : Aucun des hostGroup existe.";
                exit;
        } else {
                return @hostGroupIds;
        }
}

# NE PAS MODIFIER AU DELA DE CETTE LIGNE
1;
__END__
