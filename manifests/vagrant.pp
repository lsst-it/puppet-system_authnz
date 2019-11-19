# @summary Retain vagrant access on virtualbox deployments
#
# Assume virtualbox is only deployed on local systems, by vagrant, for testing
# Production systems should never run in a virtualbox
#
# @example
#   include system_authnz::vagrant
class system_authnz::vagrant {

    sudo::conf { 'vagrant':
        priority => 10,
        content  => '%vagrant ALL=(ALL) NOPASSWD: ALL',
    }

    # Add vagrant user to access conf
    pam_access::entry { 'allow sudo access by vagrant':
        user   => 'vagrant',
        origin => 'LOCAL',
    }

}
