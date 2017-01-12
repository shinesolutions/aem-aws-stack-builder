#!/usr/bin/env bash
set -o nounset
set -o errexit

run_id=${run_id:-`date +%Y-%m-%d:%H:%M:%S`}
stack_prefix=${STACK_PREFIX:-default}

echo "Start deleting $stack_prefix network stacks..."

./scripts/delete-stack.sh network/nat-gateway
./scripts/delete-stack.sh network/network
./scripts/delete-stack.sh network/vpc

echo "Finished deleting $stack_prefix network stacks"
