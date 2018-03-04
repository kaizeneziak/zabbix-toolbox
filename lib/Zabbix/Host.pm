#!/usr/bin/perl
#============================================================================
# Nom : Host.pm
# Date : 11/01/2018
# Auteur : William FEO
# Description : Cette classe  
# Version : 0.1
#============================================================================
package Zabbix::Host;             # Nom du package, de la Classe

use FindBin;
use lib "$FindBin::Bin/../lib";

use Moo;
use Carp;
use feature 'say';

use LWP;
use JSON;
use Data::Dumper;
        
#_____VARIABLES_____
my @inventoryFields = qw(
	host
	type
	type_full
	name
	alias
	os
	os_full
	os_short
	serialno_a
	serialno_b
	tag
	asset_tag
	macaddress_a
	macaddress_b
	hardware
	hardware_full
	software
	software_full
	software_app_a
	software_app_b
	software_app_c
	software_app_d
	software_app_e
	contact
	location
	location_lat
	location_lon
	notes
	chassis
	model
	hw_arch
	vendor
	contract_number
	installer_name
	deployment_status
	url_a
	url_b
	url_c
	host_networks
	host_netmask
	host_router
	oob_ip
	oob_netmask
	oob_router
	date_hw_purchase
	date_hw_install
	date_hw_expiry
	date_hw_decomm
	site_address_a
	site_address_b
	site_address_c
	site_city
	site_state
	site_country
	site_zip
	site_rack
	site_notes
	poc_1_name
	poc_1_email
	poc_1_phone_a
	poc_1_phone_b
	poc_1_cell
	poc_1_screen
	poc_1_notes
	poc_2_name
	poc_2_email
	poc_2_phone_a
	poc_2_phone_b
	poc_2_cell
	poc_2_screen
	poc_2_notes
);
#_____ATTRIBUTES_____

#--- Host object
has 'host_hostid' 		        => ( is => 'rw' );
has 'host_name'                 => ( is => 'rw' );
has 'host_available'		    => ( is => 'rw' );
has 'host_description'	        => ( is => 'rw' );
has 'host_disable_until'		=> ( is => 'rw' );
has 'host_error' 				=> ( is => 'rw' );
has 'host_errors_from' 			=> ( is => 'rw' );
has 'host_flags' 				=> ( is => 'rw' );
has 'host_inventory_mode'	    => ( is => 'rw' );
 
has 'host_ipmi_authtype'	    => ( is => 'rw' );
has 'host_ipmi_available'       => ( is => 'rw' );
has 'host_ipmi_disable_until' 	=> ( is => 'rw' );
has 'host_ipmi_error' 			=> ( is => 'rw' );
has 'host_ipmi_errors_from' 	=> ( is => 'rw' );
has 'host_ipmi_password'	    => ( is => 'rw' );
has 'host_ipmi_privilege'	    => ( is => 'rw' );
has 'host_ipmi_username'        => ( is => 'rw' );

has 'host_jmx_available'        => ( is => 'rw' );
has 'host_jmx_disable_until' 	=> ( is => 'rw' );
has 'host_jmx_error' 			=> ( is => 'rw' );
has 'host_jmx_errors_from' 		=> ( is => 'rw' );
has 'host_maintenance_from'     => ( is => 'rw' );
has 'host_maintenance_status'   => ( is => 'rw' );
has 'host_maintenance_type'     => ( is => 'rw' );
has 'host_maintenance_id'       => ( is => 'rw' );
has 'host_proxy_hostid'	        => ( is => 'rw' );

has 'host_snmp_available'       => ( is => 'rw' );
has 'host_snmp_disable_until' 	=> ( is => 'rw' );
has 'host_snmp_error' 			=> ( is => 'rw' );
has 'host_snmp_errors_from' 	=> ( is => 'rw' );
has 'host_status'               => ( is => 'rw' );

has 'host_tls_connect' 			=> ( is => 'rw' );
has 'host_tls_accept' 			=> ( is => 'rw' );
has 'host_tls_issuer' 			=> ( is => 'rw' );
has 'host_tls_subject' 			=> ( is => 'rw' );
has 'host_tls_psk_identity' 	=> ( is => 'rw' );
has 'host_tls_psk' 				=> ( is => 'rw' );

#--- Host inventory
has 'hostinv_alias'             => ( is => 'rw' );
has 'hostinv_asset_tag'         => ( is => 'rw' );
has 'hostinv_chassis'           => ( is => 'rw' );
has 'hostinv_contact'           => ( is => 'rw' );
has 'hostinv_contract_number'   => ( is => 'rw' );
has 'hostinv_date_hw_decomm'    => ( is => 'rw' );
has 'hostinv_date_hw_expiry'    => ( is => 'rw' );
has 'hostinv_date_hw_install'   => ( is => 'rw' );
has 'hostinv_date_hw_purchase'  => ( is => 'rw' );
has 'hostinv_deployment_status' => ( is => 'rw' );
has 'hostinv_hardware'          => ( is => 'rw' );
has 'hostinv_hardware_full'     => ( is => 'rw' );
has 'hostinv_host_netmask'      => ( is => 'rw' );
has 'hostinv_host_networks'     => ( is => 'rw' );
has 'hostinv_host_router'       => ( is => 'rw' );
has 'hostinv_hw_arch'           => ( is => 'rw' );
has 'hostinv_installer_name'    => ( is => 'rw' );
has 'hostinv_location'          => ( is => 'rw' );
has 'hostinv_location_lat'      => ( is => 'rw' );
has 'hostinv_location_lon'      => ( is => 'rw' );
has 'hostinv_macaddress_a'      => ( is => 'rw' );
has 'hostinv_macaddress_b'      => ( is => 'rw' );
has 'hostinv_model'             => ( is => 'rw' );
has 'hostinv_visible_name'      => ( is => 'rw' );
has 'hostinv_notes'             => ( is => 'rw' );
has 'hostinv_oob_ip'            => ( is => 'rw' );
has 'hostinv_oob_netmask'       => ( is => 'rw' );
has 'hostinv_oob_router'        => ( is => 'rw' );
has 'hostinv_os'                => ( is => 'rw' );
has 'hostinv_os_full'           => ( is => 'rw' );
has 'hostinv_os_short'          => ( is => 'rw' );
has 'hostinv_poc_1_cell'        => ( is => 'rw' );
has 'hostinv_poc_1_email'       => ( is => 'rw' );
has 'hostinv_poc_1_name'        => ( is => 'rw' );
has 'hostinv_poc_1_notes'       => ( is => 'rw' );
has 'hostinv_poc_1_phone_a'     => ( is => 'rw' );
has 'hostinv_poc_1_phone_b'     => ( is => 'rw' );
has 'hostinv_poc_1_screen'      => ( is => 'rw' );
has 'hostinv_poc_2_cell'        => ( is => 'rw' );
has 'hostinv_poc_2_email'       => ( is => 'rw' );
has 'hostinv_poc_2_name'        => ( is => 'rw' );
has 'hostinv_poc_2_notes'       => ( is => 'rw' );
has 'hostinv_poc_2_phone_a'     => ( is => 'rw' );
has 'hostinv_poc_2_phone_b'     => ( is => 'rw' );
has 'hostinv_poc_2_screen'      => ( is => 'rw' );
has 'hostinv_serialno_a'        => ( is => 'rw' );
has 'hostinv_serialno_b'        => ( is => 'rw' );
has 'hostinv_site_address_a'    => ( is => 'rw' );
has 'hostinv_site_address_b'    => ( is => 'rw' );
has 'hostinv_site_address_c'    => ( is => 'rw' );
has 'hostinv_site_city'         => ( is => 'rw' );
has 'hostinv_site_country'      => ( is => 'rw' );
has 'hostinv_site_notes'        => ( is => 'rw' );
has 'hostinv_site_rack'         => ( is => 'rw' );
has 'hostinv_site_state'        => ( is => 'rw' );
has 'hostinv_site_zip'          => ( is => 'rw' );
has 'hostinv_software'          => ( is => 'rw' );
has 'hostinv_software_app_a'    => ( is => 'rw' );
has 'hostinv_software_app_b'    => ( is => 'rw' );
has 'hostinv_software_app_c'    => ( is => 'rw' );
has 'hostinv_software_app_d'    => ( is => 'rw' );
has 'hostinv_software_app_e'    => ( is => 'rw' );
has 'hostinv_software_full'     => ( is => 'rw' );
has 'hostinv_tag'               => ( is => 'rw' );
has 'hostinv_type'              => ( is => 'rw' );
has 'hostinv_type_full'         => ( is => 'rw' );
has 'hostinv_url_a'             => ( is => 'rw' );
has 'hostinv_url_b'             => ( is => 'rw' );
has 'hostinv_url_c'             => ( is => 'rw' );
has 'hostinv_vendor'            => ( is => 'rw' );

#--- Attributs systèmes
has 'ua'                        => ( is => 'ro', lazy => 1, default => sub { LWP::UserAgent->new } );
has 'url'		        		=> ( is => 'rw', required => 1 );
has 'authid'		        	=> ( is => 'rw', required => 1 );
has 'zabbixLog'                 => ( is => 'ro', default => sub { Zabbix::Log->new } );


# The BUILD method is called after an object is created. 
# There are several reasons to use a BUILD method. 
# One of the most common is to check that the object state is valid. 
# While we can validate individual attributes through the use of types,
# we can't validate the state of a whole object that way. 
sub BUILD {
	my $self        = shift;
        my $url         = $self->url;
        my $authid      = $self->authid;

        my $zabbixLog   = $self->zabbixLog;
}

sub hostCreate {
	# Récupération des paramètres
	my $self                = shift;
	my ($idHostCreate,$host,$interface,$port,$useip,$ipfield,$dnsfield,$desc,@hostGroups) = @_;
	
	my $ua                  = $self->ua;
	my $authid              = $self->authid;
	
	my $zabbixLog           = $self->zabbixLog;

	(my $description = $desc) =~ s#\\\\#\n#g;

	# Construction JSON
	my $json_data = {
		jsonrpc => '2.0',
		method	=> 'host.create',
		params	=> {
			host	=> $host,
			interfaces	=> {
				type	=> $interface,
				main	=> 1,
				useip	=> $useip,
				ip	=> $ipfield,
				dns	=> $dnsfield,
				port	=> $port,
			},
			groups => \@hostGroups,
			description => $description,
        },
		auth => $authid,
		id	=> $idHostCreate
	};

	#say "______________ REQUEST ___________";
	#print Dumper $json_data;

	my $json = encode_json($json_data);

	my $response = $ua->post( $self->url, 'Content-type' => 'application/json', Content => $json );

	#say "\n\n__________ HTTP RESPONSE __________";
	#print Dumper $response;

	if ( $response->{_rc} !~ /2\d\d/ ) {
                my $error_message = "HTTP error ";
                $error_message   .= "(code $response->{_rc}) ";
                $error_message   .= $response->{_msg} // q{};
                croak($error_message);
        }

	my $content = decode_json( $response->{_content} );

	#say "\n\n__________ CONTENT __________";
	#print Dumper $content;

	if ( $content->{error} ) {
		my $error_data = $content->{error}->{data};
		my $error_msg  = $content->{error}->{message};
		my $error_code = $content->{error}->{code};
		my $error = "Error from Zabbix (code $error_code): $error_msg  $error_data";
		say $error;
		return 0;
	} else {
		return 1;
	}
}

sub checkIfHostExist {
	my $self        = shift;
	my ($host)      = @_;

	my $ua          = $self->ua;
	my $url         = $self->url;
	my $authid      = $self->authid;

	my $json_data = {
		jsonrpc => '2.0',
		method  => 'host.get',
		params  => {
				filter => {
						host => [ $host ]
				},
		},
		auth    => $authid,
		id      => 1
	};
  
	#say "\n\n____________________ JSON_DATA ____________________";
	#print Dumper $json_data;

	my $json = encode_json($json_data);
	my $response = $ua->post($url,'Content-type' => 'application/json',Content => $json);

	#say "\n\n____________________ HTTP_RESPONSE ____________________";
	#print Dumper $response;

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
		#say "\n\n____________________ JSON_RESULT ____________________";
		#print Dumper $content;
		
		my $tmp = $content->{result}[0];
		my $result = $tmp->{hostid};
		
		
		#say "\n\n____________________ \$RESULT HOSTID ____________________";
		#say "##### DEBUG \$result=$result";
		
		if (defined $result) {
				return (1,$result);
		} else {
				return (0,'');
		}
	}
}

sub checkInterface {
        my $self        = shift;
        my ($param)     = @_;

        my ($interface,$port);

	if ( $param eq 'agent' ) {
		$interface = 1;
		$port = 10050;
	} elsif ( $param eq 'snmp' ) {
		$interface = 2;
		$port = 161;
	} elsif ( $param eq 'ipmi' ) {
		$interface = 3;
		$port = 12345;
	} elsif ( $param eq 'jmx' ) {
		$interface = 4;
		$port = 623;
	}
        
        return ($interface,$port);
}

sub checkIfIpOrDns {
        my $self                        = shift;
        my ($paramUseIP,$paramIpOrDns)  = @_;

        my ($ipfield,$dnsfield);
        
	if ( $paramUseIP eq 1 && _checkIP($paramIpOrDns)){
		$ipfield = $paramIpOrDns;
		$dnsfield = '';
	} elsif ( $paramUseIP eq 0 ) {
		$ipfield = '';
		$dnsfield = $paramIpOrDns;
	} else {
                say "[ Erreur ] : Une erreur est présente dans le fichier de configuration";
                exit;
        }

        return ($ipfield,$dnsfield);
}

sub hostGetInventory {
	my $self 					= shift;
	$self->{host_hostid}		= shift;
	
	my $ua         				= $self->ua;
	my $url         			= $self->url;
	my $authid      			= $self->authid;
	my %inventory;
	
	my $json_data = {
		jsonrpc => '2.0',
		method  => 'host.get',
		params  => {
			filter => {
				hostid	=> $self->host_hostid,
			},
			selectInventory => \@inventoryFields,
			searchInventory	=> \@inventoryFields,
			output => [],
		},
		auth    => $authid,
		id      => 1
	};
  
	#say "\n\n____________________ JSON_DATA ____________________";
	#print Dumper $json_data;

	my $json = encode_json($json_data);
	my $response = $ua->post($url,'Content-type' => 'application/json',Content => $json);

	#say "\n\n____________________ HTTP_RESPONSE ____________________";
	#print Dumper $response;

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
		if (@{$content->{result}}) {
			return $content->{result}->[0]{inventory};
		}
	}
}

sub hostUpdateInventory {
	my $self                           = shift;
	$self->{host_hostid}               = shift;
	my $hostInventoryFields            = shift;
	my %inventory;
	
	$self->{host_name}                 = $hostInventoryFields->[0];
	$self->{hostinv_notes}             = $hostInventoryFields->[1];
	
	# test si $self->{key} = valeur et $result->{key} = vide : UPDATE
	$inventory{notes}            	   = $self->hostinv_notes             if ( defined $self->hostinv_notes );

	
	my $ua                             = $self->ua;
	my $url                            = $self->url;
	my $authid                         = $self->authid;
	
	my $json_data = {
		jsonrpc => '2.0',
		method  => 'host.update',
		params  => {
				hostid	=> $self->host_hostid,
				inventory_mode	=> 1,
				inventory	=> \%inventory,
		},
		auth    => $authid,
		id      => 1
	};
  
	#say "\n\n____________________ JSON_DATA ____________________";
	#print Dumper $json_data;

	my $json = encode_json($json_data);
	my $response = $ua->post($url,'Content-type' => 'application/json',Content => $json);

	#say "\n\n____________________ HTTP_RESPONSE ____________________";
	#print Dumper $response;

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
		#say "\n\n____________________ JSON_RESULT ____________________";
		#print Dumper $content;
		
		my $tmp = $content->{result};
		my $result = $tmp->{hostids};
		
		
		#say "\n\n____________________ \$RESULT HOSTID ____________________";
		#say "##### DEBUG \$result->[0]=$result->[0]";
		
		if (defined $result->[0]) {
				return 1;
		} else {
				return 0;
		}
	}
}

sub hostForceUpdateInventory {
	my $self                           = shift;
	$self->{host_hostid}               = shift;
	my $hostInventoryFields            = shift;
	my $hostGetInventoryFields	 	   = shift;
	my %inventory;
	
	$self->{host_name}                 = $hostInventoryFields->[0];
	$self->{hostinv_notes}             = $hostInventoryFields->[1];
	
	my $hostGetInventoryFields_notes   = $hostGetInventoryFields->{notes};
	
	# test si $self->{key} = valeur et $result->{key} = valeur : FORCE UPDATE
	$inventory{notes} 				   = $self->hostinv_notes if ( defined $self->hostinv_notes && defined $hostGetInventoryFields_notes );
	
	my $ua                             = $self->ua;
	my $url                            = $self->url;
	my $authid                         = $self->authid;
	
	my $json_data = {
		jsonrpc => '2.0',
		method  => 'host.update',
		params  => {
				hostid	=> $self->host_hostid,
				inventory_mode	=> 0,
				inventory	=> \%inventory,
		},
		auth    => $authid,
		id      => 1
	};
  
	#say "\n\n____________________ JSON_DATA ____________________";
	#print Dumper $json_data;

	my $json = encode_json($json_data);
	my $response = $ua->post($url,'Content-type' => 'application/json',Content => $json);

	#say "\n\n____________________ HTTP_RESPONSE ____________________";
	#print Dumper $response;

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
		#say "\n\n____________________ JSON_RESULT ____________________";
		#print Dumper $content;
		
		my $tmp = $content->{result};
		my $result = $tmp->{hostids};
		
		
		#say "\n\n____________________ \$RESULT HOSTID ____________________";
		#say "##### DEBUG \$result->[0]=$result->[0]";
		
		if (defined $result->[0]) {
				return 1;
		} else {
				return 0;
		}
	}
}


#_____PRIVATE FUNTIONS_____
sub _checkIP {
	my $ip_rgx = "\\d+\\.\\d+\\.\\d+\\.\\d+";
	my ($ipaddress) = $_[0] =~ /($ip_rgx)/o;
	
	return undef unless $ipaddress;

	for (split /\./, $ipaddress ) {
		return undef if $_ < 0 or $_ > 255;
	}

	return $ipaddress;
}

# Destructeur
sub DEMOLISH {
	my ($self, $in_global_destruction) = @_;

}

# NE PAS MODIFIER AU DELA DE CETTE LIGNE
1;
__END__