# Puppet module for installing and configuring the system authnz using LSST IdM
#
# @summary Install and configure the the system authnz using LSST IdM
#
# @example
#   include lsst_system_authnz
class lsst_system_authnz {

  include ::lsst_system_authnz::access
  include ::lsst_system_authnz::kerberos
  include ::lsst_system_authnz::sshd
  include ::lsst_system_authnz::sssd
  include ::sudo   # saz::sudo

}
