#!/usr/bin/env bash
set -o nounset
set -o errexit

run_id=${run_id:-`date +%Y-%m-%d:%H:%M:%S`}
stack_prefix=${STACK_PREFIX:-default}

echo "Start creating $stack_prefix network stacks..."

./scripts/create-stack.sh vpc
./scripts/create-stack.sh network
./scripts/create-stack.sh nat-gateway

echo "Finished creating $stack_prefix network stacks"
