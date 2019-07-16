
# lsst_system_authnz

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with lsst_system_authnz](#setup)
    * [What lsst_system_authnz affects](#what-lsst_system_authnz-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with lsst_system_authnz](#beginning-with-lsst_system_authnz)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Puppet module for configuring system authentication and authorization using LSST IdM (Identity Management). It allows users to log into servers using their LSST IdM credentials.

For more information about LSST IdM (Identity Managment), see:

  * https://confluence.lsstcorp.org/x/l5B9Ag

## Setup

### What lsst_system_authnz affects

The `lsst_system_authnz` module affects the following services on a given server:

  * kerberos configuration & host keytab
  * SSSD configuration
  * sshd configuration
  * PAM security access.conf configuration
  * sudoers configuration

### Setup Requirements

The following parameters must be defined:

  * `lsst_system_authnz::...` - ...

The sudo fuctionality requires hiera to specify something like the following:
```
# Set custom content for sudoers file
sudo::content: 'lsst_system_authnz/sudoers.erb'

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

### Beginning with lsst_system_authnz

## Usage

To use load the lsst_system_authnz puppet module, declare this class in your manifest with `include lsst_system_authnz`.

## Reference

The following parameters let you extend lsst_system_authnz options beyond the default:

  * `lsst_system_authnz::...::...` - String of CIDR address notation for ... firewall rules

## Limitations

This lsst_system_authnz module only supports RHEL/CentOS servers that are configured to use `iptables`.

