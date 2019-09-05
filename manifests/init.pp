# Puppet module for installing and configuring the system authnz using LSST IdM
#
# @summary Install and configure the the system authnz using LSST IdM
#
# @example
#   include lsst_system_authnz
class lsst_system_authnz {

  include ::lsst_system_authnz::access
  #include ::lsst_system_authnz::kerberos
  #include ::lsst_system_authnz::sssd

  # Retain vagrant access on virtualbox deployments
  # Assume virtualbox is only deployed on local systems, by vagrant, for testing
  # Production systems should never run virtualbox
  if ( $::virtual == "virtualbox" ) {
    sudo::conf { 'vagrant':
      priority => 10,
      content  => '%vagrant ALL=(ALL) NOPASSWD: ALL',
    }
  }
}
