#! /bin/bash

# CREATE RANDOM PASSWORD FOR CREATION OF HOSTKEY
#   WITH MINIMUM REQUIRED CHARACTER CLASSES 
RANDSTRING=`head -c 16 /dev/random  | base64 | grep -o . | sort -R | tr -d "\n" | head -c 14`
REQCLASS1=`date | base64 | tr -dc A-Z | grep -o . | sort -R | tr -d "\n" | head -c2`
REQCLASS2=`date | base64 | tr -dc a-z | grep -o . | sort -R | tr -d "\n" | head -c2`
REQCLASS3=`date | tr -dc 0-9 | grep -o . | sort -R | tr -d "\n" | head -c2`
REQCHARS=`echo $REQCLASS1$REQCLASS2$REQCLASS3`
TEMPPASS=`echo "$RANDSTRING$REQCHARS" | grep -o . | sort -R | tr -d "\n"`

#DEBUG
#echo "($0) Keytab: $1, User: $2" > /root/createhost.txt

# SAVE CREATEHOST KEYTAB TEMPORARILY
echo "$1" | base64 --decode > /root/createhost.keytab

# ADD HOST PRINCIPAL TO KRB DB USING CREATEHOST KEYTAB
echo -e "$TEMPPASS\n$TEMPPASS" | kadmin -kt /root/createhost.keytab -p $2/createhost@NCSA.EDU -q "addprinc host/$(hostname -f)@NCSA.EDU"
# ADD NEW HOST PRINCIPAL TO LOCAL KEYTAB FILE
echo -e "$TEMPPASS" | kadmin -p host/$(hostname -f)@NCSA.EDU -q "ktadd host/$(hostname -f)@NCSA.EDU"

# CLEAN UP LOCAL TEMP FILES
rm -f /root/createhost.keytab
