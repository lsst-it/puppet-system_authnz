
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

  * kerberos configuration
  * kerberos host keytab
  * SSSD configuration
  * sshd configuration
  * firewall restrictions for sshd
  * PAM security access.conf configuration
  * sudoers configuration

### Setup Requirements

The following parameters must be defined:

  * `lsst_system_authnz::...` - ...

This module requires the following puppet modules to be installed:

  * https://forge.puppet.com/herculesteam/augeasproviders
  * https://forge.puppet.com/herculesteam/augeasproviders_pam
  * https://forge.puppet.com/herculesteam/augeasproviders_ssh
  * https://forge.puppet.com/puppetlabs/firewall
  * https://forge.puppet.com/puppetlabs/inifile
  * https://forge.puppet.com/puppetlabs/stdlib

### Beginning with lsst_system_authnz

## Usage

To use load the lsst_system_authnz puppet module, declare this class in your manifest with `include lsst_system_authnz`.

## Reference

The following parameters let you extend lsst_system_authnz options beyond the default:

  * `lsst_system_authnz::...::...` - String of CIDR address notation for ... firewall rules

## Limitations

This lsst_system_authnz module only supports RHEL/CentOS servers that are configured to use `iptables`.

