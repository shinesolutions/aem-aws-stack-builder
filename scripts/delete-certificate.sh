#!/usr/bin/env bash
set -o nounset
set -o errexit

aws iam delete-server-certificate \
    --server-certificate-name aem-stack-certificate
