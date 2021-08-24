#!/usr/bin/env bash

set -e

SSL_FILES_DIR="/etc/private/ssl"
KEYSTORE_FILENAME="server.keystore.jks"
TRUSTSTORE_FILENAME="server.truststore.jks"

mkdir -p $SSL_FILES_DIR && cd $SSL_FILES_DIR
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/C=JP/ST=Tokyo"

keytool -noprompt -storepass changeit -keystore $TRUSTSTORE_FILENAME -alias CARoot -import -file server.crt
keytool -noprompt -storepass changeit -keystore $KEYSTORE_FILENAME -alias localhost -validity 1000 -genkey -keyalg RSA -dname "CN=, OU=, O=, L=, S=, C="
keytool -noprompt -storepass changeit -keystore $KEYSTORE_FILENAME -alias CARoot -import -file server.crt
