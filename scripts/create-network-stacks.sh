#!/usr/bin/env bash
set -o nounset
set -o errexit

stack_prefix=${STACK_PREFIX:-default}

echo "Start creating $stack_prefix network stacks..."

./scripts/create-stack.sh network/vpc
./scripts/create-stack.sh network/network
./scripts/create-stack.sh network/nat-gateway

echo "Finished creating $stack_prefix network stacks"
