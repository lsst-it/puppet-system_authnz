#! /bin/bash

# CREATE RANDOM PASSWORD FOR CREATION OF HOSTKEY
#   WITH MINIMUM REQUIRED CHARACTER CLASSES 
RANDSTRING=`head -c 16 /dev/random  | base64 | grep -o . | sort -R | tr -d "\n" | head -c 14`
REQCLASS1=`date | base64 | tr -dc A-Z | grep -o . | sort -R | tr -d "\n" | head -c2`
REQCLASS2=`date | base64 | tr -dc a-z | grep -o . | sort -R | tr -d "\n" | head -c2`
REQCLASS3=`date | tr -dc 0-9 | grep -o . | sort -R | tr -d "\n" | head -c2`
REQCHARS=`echo $REQCLASS1$REQCLASS2$REQCLASS3`
TEMPPASS=`echo "$RANDSTRING$REQCHARS" | grep -o . | sort -R | tr -d "\n"`
FN_AUTH_KEYTAB=/root/auth.keytab


###
### WORK FUNCTIONS
###

mk_auth_keytab() {
    # SAVE CREATEHOST KEYTAB TEMPORARILY
    echo "$1" | base64 --decode > "$FN_AUTH_KEYTAB"
}

addprinc() {
    # ADD HOST PRINCIPAL TO KRB DB USING CREATEHOST KEYTAB
    local _domain="$1"
    local _usr="$2"
    local _user_princ="${_usr}/createhost@${_domain}"
    local _host_princ="host/$(hostname -f)@${_domain}"
    echo "Attempting addprinc ..."
    echo -e "$TEMPPASS\n$TEMPPASS" \
    | kadmin -kt "$FN_AUTH_KEYTAB" -p "$_user_princ" addprinc "${_host_princ}"
    rc=$?
    echo "  ... addprinc returned '$rc'"
    return $rc
}

ktadd() {
    # ADD NEW HOST PRINCIPAL TO LOCAL KEYTAB FILE
    local _domain="$1"
    local _host_princ="host/$(hostname -f)@${_domain}"
    echo "Attempting ktadd ..."
    echo -e "$TEMPPASS" | kadmin -p ${_host_princ} -q "ktadd ${_host_princ}"
    rc=$?
    echo "  ... ktadd returned '$?'"
    return $rc
}

cleanup() {
    # CLEAN UP LOCAL TEMP FILES
    rm -f "$FN_AUTH_KEYTAB"
}

###
### MAIN CODE LOGIC
###

if test "$#" -ne 3; then
    echo "wrong arg count, expected 3, got '$#'" >&2
    exit 1
fi
authorization_keytab=$1
createhostuser=$2
krb5_domain=$3

mk_auth_keytab "$authorization_keytab"

addprinc "$krb5_domain" "$createhostuser" \
&& ktadd "$krb5_domain"
rv=$?

cleanup

exit $rv
