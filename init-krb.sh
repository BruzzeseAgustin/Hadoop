#!/bin/bash

# Link of interest: https://help.qlik.com/en-US/nprinting/May2021/Content/NPrinting/Troubleshooting/Configure-Firefox-for-Kerberos.htm

# Link of interest; https://docs.fedoraproject.org/en-US/Fedora/16/html/Security_Guide/sect-Security_Guide-Single_Sign_on_SSO-Configuring_Firefox_to_use_Kerberos_for_SSO.html

KERBEROS_ADMIN_PASSWORD=test
KDC_ADDRES=localhost
KRB_REALM=EXAMPLE.COM

echo ${KERBEROS_ADMIN_PASSWORD}| kinit user@${KRB_REALM}

