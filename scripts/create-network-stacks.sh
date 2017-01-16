#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 -o "$#" -gt 2 ]; then
  echo 'Usage: ./create-network-stacks.sh <stack_prefix> [config_path]'
  exit 1
fi

stack_prefix=$1
config_path=$2

create_stack() {
  ./scripts/create-stack.sh $1 "$stack_prefix" "$config_path"
}

echo "Start creating $stack_prefix network stacks..."

create_stack network/vpc
create_stack network/network
create_stack network/nat-gateway

echo "Finished creating $stack_prefix network stacks"
