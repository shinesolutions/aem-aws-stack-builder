#!/usr/bin/env bash
set -o nounset
set -o errexit

STACK_NAME=$1
TEMPLATE=$2

aws cloudformation create-stack \
    --stack-name "$STACK_NAME" \
    --template-body "file:///$PWD//$TEMPLATE" \
    --capabilities CAPABILITY_NAMED_IAM

echo "Creating Stack..."

aws cloudformation wait stack-create-complete \
    --stack-name "$STACK_NAME"

echo "Stack Created"
