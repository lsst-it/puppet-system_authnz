# Puppet module for installing and configuring the system authnz using LSST IdM
#
# @summary Install and configure the the system authnz using LSST IdM
#
# @example
#   include system_authnz
class system_authnz {

    # ALL HOSTS GET THESE MODULES
    include ::system_authnz::access
    include ::system_authnz::kerberos
    include ::system_authnz::sssd

#    # MODULES DEPENDING ON CONTAINER/VIRTUAL TYPE
#    $additional_modules = [
#        '::system_authnz::kerberos',
#    ]
#
#    # Exclude additional modules based on virtual type
#    $exclude_modules = $::virtual ? {
##        'docker'     => [ '::system_authnz::kerberos' ],
#        default      => [],
#    }
#    #include only relevant modules
#    $selected_modules = $additional_modules - $exclude_modules
#    include $selected_modules

    if ( $::virtual == 'virtualbox' ) {
        include ::system_authnz::vagrant
    }
}
