#!/usr/bin/env bash

STACK_NAME=$1

aws cloudformation delete-stack --stack-name "$STACK_NAME"

echo "Deleting Stack..."

aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"

echo "Stack Deleted"
