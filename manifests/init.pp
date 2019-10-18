# Puppet module for installing and configuring the system authnz using LSST IdM
#
# @summary Install and configure the the system authnz using LSST IdM
#
# @example
#   include lsst_system_authnz
class lsst_system_authnz {

    # ALL HOSTS GET THESE MODULES
    include ::lsst_system_authnz::access
    #include ::lsst_system_authnz::sssd

    # MODULES DEPENDING ON CONTAINER/VIRTUAL TYPE
    $additional_modules = [
        '::lsst_system_authnz::kerberos',
    ]

    # Exclude additional modules based on virtual type
    $exclude_modules = $::virtual ? {
#        'docker'     => [ '::lsst_system_authnz::kerberos' ],
        default      => [],
    }
    #include only relevant modules
    $selected_modules = $additional_modules - $exclude_modules
    include $selected_modules

    elsif ( $::virtual == 'virtualbox' ) {
        # Retain vagrant access on virtualbox deployments
        # Assume virtualbox is only deployed on local systems, by vagrant, for testing
        # Production systems should never run in a virtualbox
        sudo::conf { 'vagrant':
            priority => 10,
            content  => '%vagrant ALL=(ALL) NOPASSWD: ALL',
        }
    }
}
