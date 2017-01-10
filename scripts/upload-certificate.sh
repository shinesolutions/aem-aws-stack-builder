#!/usr/bin/env bash
set -o nounset
set -o errexit

aws iam upload-server-certificate \
    --server-certificate-name aem-stack-certificate \
    --certificate-body "file:///$PWD//aem-stack.shinesolutions.com.cert" \
    --private-key "file:///$PWD//aem-stack.shinesolutions.com.key"
