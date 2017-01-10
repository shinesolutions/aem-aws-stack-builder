#!/usr/bin/env bash
set -o nounset
set -o errexit

openssl version

openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=AU/ST=Victoria/L=Melbourne/O=Shine Solutions/CN=aem-stack.shinesolutions.com" \
    -keyout aem-stack.shinesolutions.com.key \
    -out aem-stack.shinesolutions.com.cert
