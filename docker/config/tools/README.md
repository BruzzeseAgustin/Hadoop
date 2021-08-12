# Kerberos Keytab Generator

This script allows you to automate the creation of a keytab file using only your username and password

## Environment variables

- `PRINCIPAL`: Your username, should be of the form `user@EXAMPLE.COM`

## Running

[need to be done]

## Providing your own krb5.conf

If you wish, you can provide your own krb5.conf to find the login servers
Locations could be
- /etc/krb5.conf (Linux)
Then in your `docker run` command, add the following: `-v /location/of/krb5.conf:/etc/krb5:ro`

