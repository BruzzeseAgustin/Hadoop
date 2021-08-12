#!/bin/bash

if [ ! -f /etc/krb5.conf ]; then
    echo "/etc/krb5.conf not found, please map your volume to make it available to this container"
    exit 1
fi

while getopts u:a:f: flag
do
    case "${flag}" in
        u) principal=${OPTARG};;
        a) password=${OPTARG};;
        f) keytab=${OPTARG};;
    esac
done

echo "principal: $principal";
echo "password: $password";
echo "keytab: $keytab";

if [[ -z "${principal// }" ]]; then echo "PRINCIPAL hasn't been provided"; exit 1; fi;
# prompt user for password
if [[ -z "${password// }" ]]; then IFS= read -s  -p "Enter $principal password:" password; exit 1; fi;
echo ""

# if [[ -z "${password// }" ]]; then echo "PASSWORD hasn't been provided, exit"; exit 1; fi;

if [[ -z "${keytab// }" ]]; then echo "KEYTAB output hasn't been provided, using default"; keytab=$KEYTAB_DIR; fi;

echo $KEYTAB_DIR
KEYTAB_SECURITY=${KEYTAB_SECURITY:-"rc4-hmac"}

# Creating kerberos ticket 
kadmin.local -q "addprinc -pw ${password} ${principal}"

# password verifications
echo "========== Verifying password... =========="
echo $password | kinit -V $principal
ret_code=$?
if [ $ret_code != 0 ]; then
  echo "Error : Wrong username/password combination"
  exit $ret_code
fi

# generate keytab
echo "========== Generating Keytab... =========="
KEYTAB=$(echo $principal | cut -d@ -f1 | cut -d/ -f1 | tr '[:upper:]' '[:lower:]').keytab
ktutil < <(echo -e "addent -password -p $principal -k 1 -e $KEYTAB_SECURITY\n$password\nwkt $KEYTAB\nquit")

# test keytab
echo "========== Testing Keytab =========="
kinit -V -kt $KEYTAB $principal
ret_code=$?
if [ $ret_code != 0 ]; then
  echo "Error : The keytab that was generated does not appear to work"
  exit $ret_code
fi

# copy output
echo "========== Writing keytab to $keytab/$KEYTAB ========== "
echo "Make sure you have mapped your volume to the $keytab volume"
cp $KEYTAB ${keytab}/$KEYTAB
echo "Successfully completed!"

