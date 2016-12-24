#!/usr/bin/env bash

aws iam delete-server-certificate \
    --server-certificate-name aem-stack-certificate
