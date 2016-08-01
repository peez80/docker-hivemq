#!/bin/bash
# File is not called during docker build, it's just for sake of comleteness to show how the certificates were created.

CERT_FILENAME=hivemqcert

# Specify where we will install
# the xip.io certificate
SSL_DIR="."

# Set the wildcarded domain
# we want to use
DOMAIN="*"

# A blank passphrase
PASSPHRASE=""

# Set our CSR variables
SUBJ="
C=DE
ST=
O=
localityName=Munich
commonName=$DOMAIN
organizationalUnitName=
emailAddress=
"

# Create our SSL directory
# in case it doesn't exist
mkdir -p "$SSL_DIR"

# Generate our Private Key, CSR and Certificate
openssl genrsa -out "$SSL_DIR/$CERT_FILENAME.key" 2048
openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/$CERT_FILENAME.key" -out "$SSL_DIR/$CERT_FILENAME.csr" -passin pass:$PASSPHRASE
openssl x509 -req -days 6000 -in "$SSL_DIR/$CERT_FILENAME.csr" -signkey "$SSL_DIR/$CERT_FILENAME.key" -out "$SSL_DIR/$CERT_FILENAME.crt"