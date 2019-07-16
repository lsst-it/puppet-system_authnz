# Configure SSSD for use with LDAP and Kerberos
#
# @summary Configure SSSD for use with LDAP and Kerberos
# Requires walkamongus/sssd.
#
# @example
#   include lsst_system_authnz::sssd
class lsst_system_authnz::sssd (
    # PARAMETERS: general
    Boolean $enablemkhomedir,

    # PARAMETERS: [domain/...]
    Integer       $debug_level_domain,
    String        $enumerate,
    Array[String] $ldap_backup_uri,
    String        $ldap_group_search_base,
    String        $ldap_search_base,
    Array[String] $ldap_uri,
    String        $ldap_tls_cacert,
    String        $ldap_user_search_base,
    Array[String] $simple_allow_groups,
    Array[String] $simple_allow_users,
    Array[String] $simple_deny_groups,
    Integer       $timeout,

    # PARAMETERS: [nss]
    Array[String] $allowed_shells,
    Integer       $debug_level_nss,
    Array[String] $filter_groups,
    Array[String] $filter_users,
    String        $krb5_realm,
    String        $override_homedir,
    String        $shell_fallback,
    Array[String] $vetoed_shells,

    # PARAMETERS: [pam]
    Integer $debug_level_pam,

    # PARAMETERS: [ssd]
    Integer $debug_level_sssd,
    String  $ldap_domain,
) {

    # CONFIGURE NSS AND PAM TO USE SSSD, AND IF APPROPRIATE CONFIGURE
    # AUTHCONFIG WITH ENABLEMKHOMEDIR
    # walkamongus-sssd handles this but added supportd for enablemkhomedir
    # recently and it looks suspect if you tell it that mkhomedir should
    # be disabled (probably should be on machines with network home dirs?):
    # https://github.com/walkamongus/sssd/issues/22
    # rolling our own for now

    # define parameters for authconfig
    if $enablemkhomedir {
        $authconfig_args = ['--enablemkhomedir', '--enablesssd', '--enablesssdauth']
    }
    else {
        $authconfig_args = ['--disablemkhomedir', '--enablesssd', '--enablesssdauth']
    }
    $authconfig_args_f = join($authconfig_args, ' ')

    # INSTALL INCOMMON ROOT CA
    $cacert = '/etc/pki/ca-trust/source/anchors/incommon-ca.pem'
    file { $cacert :
        source => "puppet:///modules/lsst_system_authnz${cacert}",
        mode   => '0444',
        before => Service['sssd'],
    }

    # ENABLE MKHOMEDIR (create homedir on first login)
    # ::sssd has support for this, but don't trust it to do the right thing
    # so doing it directly from here
    # Note: require ::sssd, which ensures the "authconfig" package is installed
    exec { 'enablesssdauth':
        path    => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
        onlyif  => 'test `grep -i "SSSD" /etc/sysconfig/authconfig | grep "=yes" | wc -l` -lt 2',
        command => "authconfig ${authconfig_args_f} --updateall", # should we just be using '--update'?
        require => Class[ ::sssd ],
    }

    # CONFIGURE SSSD
    class {'::sssd':
        config => {
            "domain/${ldap_domain}" => {
                'access_provider'         => 'simple',
                'auth_provider'           => 'krb5',
                'chpass_provider'         => 'krb5',
                'cache_credentials'       => false,
                'debug_level'             => $debug_level_domain,
                'enumerate'               => $enumerate,
                'id_provider'             => 'ldap',
                'krb5_auth_timeout'       => 3,
                'krb5_lifetime'           => '25h',
                'krb5_realm'              => $krb5_realm,
                'krb5_renew_interval'     => 3600,
                'krb5_renewable_lifetime' => '7d',
                'krb5_use_kdcinfo'        => false,
                'krb5_validate'           => true,
                'ldap_backup_uri'         => $ldap_backup_uri,
                'ldap_group_member'       => 'uniqueMember',
                'ldap_group_search_base'  => $ldap_group_search_base,
                'ldap_schema'             => 'rfc2307bis',
                'ldap_search_base'        => $ldap_search_base,
                'ldap_tls_cacert'         => $ldap_tls_cacert,
                'ldap_tls_reqcert'        => 'demand',
                'ldap_uri'                => $ldap_uri,
                'ldap_user_search_base'   => $ldap_user_search_base,
                'simple_allow_groups'     => $simple_allow_groups,
                'simple_allow_users'      => $simple_allow_users,
                'simple_deny_groups'      => $simple_deny_groups,
                'timeout'                 => $timeout,
            },
            'nss'                   => {
                'allowed_shells'   => $allowed_shells,
                'debug_level'      => $debug_level_nss,
                'filter_groups'    => $filter_groups,
                'filter_users'     => $filter_users,
                'override_homedir' => $override_homedir,
                'shell_fallback'   => $shell_fallback,
                'vetoed_shells'    => $vetoed_shells,
            },
            'pam'                   => {
                'debug_level' => $debug_level_pam,
            },
            'sssd'                  => {
                'config_file_version' => 2,
                'debug_level'         => $debug_level_sssd,
                'domains'             => $ldap_domain,
                'services'            => ['nss', 'pam'],
            },
        }
    }

    # ENSURE SSSD SERVICE IS RESTARTED IF/WHEN ANY KRB5 CFG FILES CHANGE
    $krb_cfgfile_data = lookup( 'lsst_system_authnz::kerberos::cfg_file_settings',
                                Hash,
                                'hash' )
    # setup a "notify" relationship from filename to service
    $krb_cfgfile_data.each() | $filename, $junk | {
        File[ $filename ] ~> Class[ '::sssd::service' ]
    }

}

