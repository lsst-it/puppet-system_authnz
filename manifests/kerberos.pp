# Basic kerberos client setup
#
# @summary Basic kerberos client setup
#
# @example
#   include lsst_system_authnz::kerberos
class lsst_system_authnz::kerberos (
  Hash               $cfg_file_settings, # cfg files and their contents
  String             $createhostkeytab,  # BASE64 ENCODING OF krb5 createhost keytab FILE
  String             $createhostuser,
  String             $krb5_domain,
  Array[ String[1] ] $required_pkgs,     # DEFAULT SET VIA MODULE DATA
) {

    ensure_packages( $required_pkgs )

    $file_defaults = {
        owner  => root,
        group  => root,
        ensure => file,
        mode   => '0644',
    }

    # Ensure directory for include files
    file {
        '/etc/krb5.conf.d':
            ensure => directory,
            mode   => '0755',
        ;
        default: * => $file_defaults
        ;
    }

    # Create all the files listed in the cfg_file_settings hash
    $cfg_file_settings.each | $fn, $content | {
        file {
            $fn: content => $content,
            ;
            default:   * => $file_defaults
            ;
        }
    }

    file { '/root/createhostkeytab.sh':
        ensure => present,
        mode   => '0700',
        source => 'puppet:///modules/lsst_system_authnz/root/createhostkeytab.sh',
    }
    file { '/root/deleteserviceprincipals.sh':
        ensure => present,
        mode   => '0700',
        source => 'puppet:///modules/lsst_system_authnz/root/deleteserviceprincipals.sh',
    }
    file { '/root/deletehostprincipal.sh':
        ensure => present,
        mode   => '0700',
        source => 'puppet:///modules/lsst_system_authnz/root/deletehostprincipal.sh',
    }

    ## THIS MIGHT NEED TO BE SMARTER TO ALLOW FOR MULTIPLE HOSTNAMES ON ONE SERVER
    #unless  => 'klist -kt /etc/krb5.keytab 2>&1 | grep "host/`hostname -f`@NCSA.EDU"',
    $host_key_exists = join( 
        [ 'klist -kt /etc/krb5.keytab 2>&1 ',
          '| grep "host/$(hostname -f)', '@', $krb5_domain, '"',
        ]
    )
    exec { 'create_host_keytab':
        path    => [ '/usr/bin', '/usr/sbin'],
        command => "/root/createhostkeytab.sh ${createhostkeytab} ${createhostuser}",
        unless  => $host_key_exists,
        require => [
            File[ '/etc/krb5.conf' ],
            File[ '/etc/krb5.conf.d/kdc.conf' ],
            File[ '/root/createhostkeytab.sh' ],
        ]
    }

}
