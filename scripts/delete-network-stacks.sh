#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -ne 1 ]; then
  echo 'Usage: ./delete-network-stacks.sh <stack_prefix>'
  exit 1
fi

stack_prefix=$1

delete_stack() {
  ./scripts/delete-stack.sh $1 "$stack_prefix"
}

echo "Start deleting $stack_prefix network stacks..."

./scripts/delete-stack.sh network/nat-gateway
./scripts/delete-stack.sh network/network
./scripts/delete-stack.sh network/vpc

echo "Finished deleting $stack_prefix network stacks"
