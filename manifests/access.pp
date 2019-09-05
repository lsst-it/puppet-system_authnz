# Configure security access.conf
#
# @summary Configure security access.conf
#
# @example
#   include lsst_system_authnz::access
class lsst_system_authnz::access (
    Array[ String[1] ] $required_pkgs,
    Hash $access_allow,
    Hash $access_deny,
    Hash $access_deny_before,
    Hash $pam_config,
) {

    ### Make sure pam is installed
    ensure_packages( $required_pkgs )

    ### Configure access.conf

    pam_access::entry { 'Default Allow':
        user       => 'root',
        origin     => 'LOCAL',
        permission => '+',
        position   => 'before',
    }

    pam_access::entry { 'Default Deny':
        user       => 'ALL',
        origin     => 'ALL',
        permission => '-',
        position   => 'after',
    }

    ensure_resources( 'pam_access::entry', $access_allow,
        { 'permission' => '+',
          'position'   => '-1',
        }
    )

    ensure_resources( 'pam_access::entry', $access_deny,
        { 'permission' => '-',
          'position'   => 'after',
        }
    )

    ensure_resources( 'pam_access::entry', $access_deny_before,
        { 'permission' => '-',
          'position'   => 'before',
        }
    )

    ### Configure pam
    ensure_resources( 'pam', $pam_config )

}

