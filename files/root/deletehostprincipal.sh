#! /bin/bash

LOCALKEYTAB="/etc/krb5.keytab"
COPYKEYTAB="/root/copy.krb5.keytab"

# STOP PUPPET
systemctl stop puppet

# TEMPORARILY COPY KEYTAB
cp -p $LOCALKEYTAB $COPYKEYTAB

# DELETE THE HOST FROM LOCAL KEYTAB
kadmin -kt $COPYKEYTAB -p host/$(hostname -f)@NCSA.EDU  -q "ktremove -k $LOCALKEYTAB host/$(hostname -f)@NCSA.EDU"

# DELETE THE HOST FROM KERBEROS SERVER
kadmin -kt $COPYKEYTAB -p host/$(hostname -f)@NCSA.EDU  -q "delprinc host/$(hostname -f)@NCSA.EDU"

# CLEAN UP LOCAL TEMP FILES
rm -f $COPYKEYTAB

