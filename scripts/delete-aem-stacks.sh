#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -ne 1 ]; then
  echo 'Usage: ./delete-aem-stacks.sh <stack_prefix>'
  exit 1
fi

stack_prefix=$1

delete_stack() {
  ./scripts/delete-stack.sh "$1" "$stack_prefix"
}

echo "Deleting $stack_prefix AEM stacks..."

delete_stack apps/chaos-monkey &
delete_stack apps/orchestrator &
delete_stack apps/author-dispatcher &
delete_stack apps/publish-dispatcher &
delete_stack apps/publish &
delete_stack apps/author &

wait

delete_stack apps/messaging &
delete_stack apps/security-groups &

wait

echo "Finished deleting $stack_prefix AEM stacks"
