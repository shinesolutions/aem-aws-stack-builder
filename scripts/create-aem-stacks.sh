#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: ./create-aem-stacks.sh <stack_prefix> [config_path]'
  exit 1
fi

stack_prefix=$1
config_path=$2

create_stack() {
  ./scripts/create-stack.sh "$1" "$stack_prefix" "$config_path"
}

echo "Start creating $stack_prefix AEM stacks..."

create_stack apps/security-groups &
create_stack apps/messaging &

wait

create_stack apps/author &
create_stack apps/publish &
create_stack apps/publish-dispatcher &
create_stack apps/author-dispatcher &
create_stack apps/orchestrator &
create_stack apps/chaos-monkey &

wait

echo "Finished creating $stack_prefix AEM stacks"
