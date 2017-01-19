#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: ./delete-network-stacks.sh <stack_prefix> [config_path]'
  exit 1
fi

stack_prefix=$1
config_path=$2

delete_stack() {
  ./scripts/delete-stack.sh "$1" "$stack_prefix" "$config_path"
}

echo "Start deleting $stack_prefix network stacks..."

./scripts/delete-stack.sh network/nat-gateway
./scripts/delete-stack.sh network/network
./scripts/delete-stack.sh network/vpc

echo "Finished deleting $stack_prefix network stacks"
