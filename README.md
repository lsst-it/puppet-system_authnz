
# system_authnz

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with system_authnz](#setup)
    * [What system_authnz affects](#what-system_authnz-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with system_authnz](#beginning-with-system_authnz)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

Puppet module for configuring system authentication and authorization using LSST IdM (Identity Management). It allows users to log into servers using their LSST IdM credentials.

For more information about LSST IdM (Identity Managment), see:

  * https://confluence.lsstcorp.org/x/l5B9Ag

## Setup

### What system_authnz affects

The `system_authnz` module affects the following services on a given server:

  * kerberos configuration & host keytab
  * SSSD configuration
  * PAM security access.conf configuration
  * sudoers configuration

### Setup Requirements

The following parameters must (or should) be defined:

  * `system_authnz::kerberos::createhostkeytab` - String of BASE64 encoded keytab file used for creating kerberos host keys
  * `system_authnz::kerberos::createhostuser` - String of kerberos user used for creating kerberos host keys
  * `system_authnz::sssd::simple_allow_groups` - Array of group names that are allowed access through SSSD

The `createhostuser` and cooresponding `createhostkeytab` parameters are unique for each LSST site and datacenter. Datacenter admins should contact <kerberos@ncsa.illinois.edu> to inquire about these values for their site.

The sudo fuctionality requires hiera to specify something like the following:
```
# Set custom content for sudoers file
sudo::content: 'system_authnz/sudoers.erb'

# Additional sudoers config settings to be included from sudoers.d
sudo::configs:
  defaults:
    priority: 0
    content:
      - 'Defaults   !visiblepw'
      - 'Defaults    always_set_home'
      - 'Defaults    env_reset'
      - 'Defaults    env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS"'
      - 'Defaults    env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"'
      - 'Defaults    env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"'
      - 'Defaults    env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"'
      - 'Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"'
      - 'Defaults    match_group_by_gid'
      - 'Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin'
      - 'root ALL=(ALL)   ALL'
      - '%wheel   ALL=(ALL)   ALL'
  common_lsst_admins:
    priority: 10
    content:
      - '%lsst_sysadm ALL=(ALL) NOPASSWD: ALL'
  common_disabled_users:
    priority: 99
    content:
      - '#deny former NCSA users'
      - '%all_disabled_usr ALL=(ALL) !ALL'
      - '#deny users in lsst_disabled LDAP group'                                                                          
      - '%lsst_disabled ALL=(ALL) !ALL'                                                                                    
```

This module requires the following puppet modules to be installed:

  * https://forge.puppet.com/herculesteam/augeasproviders
  * https://forge.puppet.com/herculesteam/augeasproviders_pam
  * https://forge.puppet.com/herculesteam/augeasproviders_ssh
  * https://forge.puppet.com/puppetlabs/firewall
  * https://forge.puppet.com/puppetlabs/inifile
  * https://forge.puppet.com/puppetlabs/stdlib
  * https://forge.puppet.com/saz/sudo
  * https://forge.puppet.com/walkamongus/sssd

### Beginning with system_authnz

## Usage

To use load the system_authnz puppet module, declare this class in your manifest with `include system_authnz`.

## Reference

The following parameters let you extend system_authnz options beyond the default:

  * `system_authnz::access::allow_root` - Hash of allowed root user/group names and their respective permissions
  * `system_authnz::access::allow_services` - Hash of allowed service user/group names and their respective permissions
  * `system_authnz::access::allow_users` - Hash of allowed user/group names and their respective permissions
  * `system_authnz::access::deny_root` - Hash of denied root user/group names and their respective permissions
  * `system_authnz::access::deny_services` - Hash of denied service user/group names and their respective permissions
  * `system_authnz::access::deny_users` - Hash of denied user/group names and their respective permissions
  * `system_authnz::access::pam_config` - Hash of pam configuration
  * `system_authnz::kerberos::cfg_file_settings` - Hash of kerberos file settings
  * `system_authnz::kerberos::required_pkgs` - Array of packages needed for kerberos configuration
  * `system_authnz::sssd::allowed_shells` - Array of shell binaries with full path
  * `system_authnz::sssd::debug_level_domain` - Integer of debug level for domain in SSSD
  * `system_authnz::sssd::debug_level_nss` - Integer of debug level for nss in SSSD
  * `system_authnz::sssd::debug_level_pam` - Integer of debug level for pam in SSSD
  * `system_authnz::sssd::debug_level_sssd` - Integer of debug level for SSSD
  * `system_authnz::sssd::enablemkhomedir` - Boolean of whether or not to enable mkhomedir
  * `system_authnz::sssd::enumerate` - String of enumerate setting in SSSD
  * `system_authnz::sssd::filter_groups` - Array of group names to not come from LDAP
  * `system_authnz::sssd::filter_users` - Array of user names to not come from LDAP (e.g. local users)
  * `system_authnz::sssd::krb5_realm` - String for kerberos realm
  * `system_authnz::sssd::ldap_domain` - String for ldap domain name
  * `system_authnz::sssd::ldap_group_search_base` - String of LDAP group search base
  * `system_authnz::sssd::ldap_search_base` - String of ldap search base
  * `system_authnz::sssd::ldap_tls_cacert` - String of content of LDAP TLS CA certificate
  * `system_authnz::sssd::ldap_user_search_base` - String of ldap user search base
  * `system_authnz::sssd::ldap_uri` - Array of ldap server URIs
  * `system_authnz::sssd::ldap_backup_uri` - Array of backup ldap server URIs
  * `system_authnz::sssd::override_homedir` - String of override path for user home directories
  * `system_authnz::sssd::shell_fallback` - String of fallback shell binary with full path
  * `system_authnz::sssd::simple_deny_groups` - Array of group names that are denied access through SSSD
  * `system_authnz::sssd::simple_allow_users` - Array of user names are allowed access through SSSD
  * `system_authnz::sssd::timeout` - Integer of timeout setting in SSSD
  * `system_authnz::sssd::vetoed_shells` - Array of unallowed shell binaries with full path

## Rebuilding, Deleting, or Renaming a Server

Note that if you change, rebuild, or shutdown a server, the HOST principal for the old host remains in the Kerberos database. Besides cluttering up the Kerberos database, these old HOST principal entries will prevent a rebuilt server with the same hostname for setting up a fresh HOST principal that is necessary for system authentication.

You should clean up the existing HOST principal **before** the server is rebuilt or deleted:

1. Optional: If the hostname is not intended to be reused, first clean up any service principals associated with the hostname: `/root/deleteserviceprincipals.sh`
2. Then clean up the host principal: `/root/deletehostprincipal.sh`

If you forget to clean up the existing HOST principal and can't run the above scripts, send email to <kerberos@ncsa.illinois.edu> requesting the principal(s) to be deleted from the Kerberos database. Be sure to mention the hostname(s) that need to be cleaned up.

## Limitations

This system_authnz module only supports RHEL/CentOS servers that are configured to use `iptables`.

