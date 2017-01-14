#!/usr/bin/env bash
set -o nounset
set -o errexit

stack_prefix=${STACK_PREFIX:-default}

echo "Deleting $stack_prefix AEM stacks..."

./scripts/delete-stack.sh apps/chaos-monkey &
./scripts/delete-stack.sh apps/orchestrator &
./scripts/delete-stack.sh apps/author-dispatcher &
./scripts/delete-stack.sh apps/publish-dispatcher &
./scripts/delete-stack.sh apps/publish &
./scripts/delete-stack.sh apps/author &

wait

./scripts/delete-stack.sh apps/messaging &
./scripts/delete-stack.sh apps/security-groups &

wait

echo "Finished deleting $stack_prefix AEM stacks"
