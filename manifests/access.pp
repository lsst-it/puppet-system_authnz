# Configure security access.conf
#
# @summary Configure security access.conf
#
# @example
#   include lsst_system_authnz::access
class lsst_system_authnz::access (
    Array[ String[1] ] $required_pkgs,
    Hash $allow_users,
    Hash $deny_users,
    Hash $allow_services,
    Hash $deny_services,
    Hash $allow_root,
    Hash $deny_root,
    Hash $pam_config,
) {

    # Make sure pam is installed.
    ensure_packages( $required_pkgs )

    file { '/etc/security/access.conf':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => epp( 'lsst_system_authnz/access.conf.epp', {
            'allow_users'    => $allow_users,
            'deny_users'     => $deny_users,
            'allow_services' => $allow_services,
            'deny_services'  => $deny_services,
            'allow_root'     => $allow_root,
            'deny_root'      => $deny_root,
            }
        ),
    }

    #Configure pam
    each($pam_config) |String[1] $key, Hash $value| {
        pam { $key:
            * => $value,
        }
    }

}

