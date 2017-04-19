#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: ./delete-aem-stacks.sh <stack_prefix> [config_path]'
  exit 1
fi

stack_prefix=$1
config_path=$2

echo "Deleting $stack_prefix AEM stacks..."
./scripts/delete-stack.sh "apps/all-in-one" "$stack_prefix" "$config_path"
./scripts/delete-stack.sh "apps/stack-data" "$stack_prefix" "$config_path"
echo "Finished deleting $stack_prefix AEM stacks"
