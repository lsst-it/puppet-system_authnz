#! /bin/bash

LOCALKEYTAB="/etc/krb5.keytab"

# STOP PUPPET
systemctl stop puppet

## CURRENTLY THE HOST PRINCIPAL CANNOT DO get_principals AGAINST THE NCSA KDC
##   NEEDS list PRIVILEGES ADDED FOR HOST PRINCIPALS POLICY
##   IDEALLY YOU COULD ISSUE FOLLOWING TO FIND ALL SERVICE PRINCIPALS ASSOCIATED WITH THE HOST:
##   kadmin -kt $LOCALKEYTAB -p host/$(hostname -f)@NCSA.EDU  -q "get_principals */$(hostname -f)@NCSA.EDU" | grep -v 'host/'
## SO CURRENTLY LIMITED TO ONLY BE ABLE TO LOOK AT LOCAL KEYTAB FILES TO SEE LIST OF SERVICE PRINCIPALS WHICH MAY BE INCOMPLETE
##   e.g. HTTPD SERVICE PRINCIPALS ARE USUALLY NOT STORED IN DEFAULT krb5.keytab

# DELETE KNOWN SERVICE PRINCIPALS FROM KERBEROS SERVER
k5srvutil list | grep "$(hostname -f)" | awk '{ print $NF }' | grep -v 'host/' | xargs -I {} \
  kadmin -kt $LOCALKEYTAB -p host/$(hostname -f)@NCSA.EDU  -q "delprinc {}"

# DELETE KNOWN SERVICE PRINCIPALS FROM LOCAL KEYTAB
k5srvutil list | grep "$(hostname -f)" | awk '{ print $NF }' | grep -v 'host/' | xargs -I {} \
  kadmin -kt $LOCALKEYTAB -p host/$(hostname -f)@NCSA.EDU  -q "ktremove -k $LOCALKEYTAB {}"

