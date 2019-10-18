# Configure SSSD for use with LDAP and Kerberos
#
# @summary Configure SSSD for use with LDAP and Kerberos
# Requires bodgit/sssd.
#
# @example
#   include lsst_system_authnz::sssd
class lsst_system_authnz::sssd (
    # PARAMETERS: general
    Boolean       $enablemkhomedir,
    Array[String] $authconfig_pkgs,

) {

    # INSTALL INCOMMON ROOT CA
    # TODO - make this a paramter, then use a hiera interpolation lookup in hiera
    $cacert = '/etc/pki/ca-trust/source/anchors/incommon-ca.pem'
    file { $cacert :
        source => "puppet:///modules/lsst_system_authnz${cacert}",
        mode   => '0444',
        before => Service['sssd'],
    }

    # ENABLE MKHOMEDIR (create homedir on first login)
    ensure_packages( $authconfig_pkgs )
    # create appropriate args
    if $enablemkhomedir {
        $authconfig_args = ['--enablemkhomedir', '--enablesssd', '--enablesssdauth']
    }
    else {
        $authconfig_args = ['--disablemkhomedir', '--enablesssd', '--enablesssdauth']
    }
    $authconfig_args_f = join($authconfig_args, ' ')
    # run authconfig
    exec { 'enablesssdauth':
        path    => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
        onlyif  => 'test `grep -i "SSSD" /etc/sysconfig/authconfig | grep "=yes" | wc -l` -lt 2',
        command => "authconfig ${authconfig_args_f} --updateall", # should we just be using '--update'?
    }

    # ENSURE SSSD SERVICE IS RESTARTED IF/WHEN ANY KRB5 CFG FILES CHANGE
#    $krb_cfgfile_data = lookup( 'lsst_system_authnz::kerberos::cfg_file_settings',
#                                Hash,
#                                'hash' )
#    # setup a "notify" relationship from filename to service
#    $krb_cfgfile_data.each() | $filename, $junk | {
#        File[ $filename ] ~> Class[ '::sssd::service' ]
#    }

}
