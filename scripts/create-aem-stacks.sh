#!/usr/bin/env bash
set -o nounset
set -o errexit

stack_prefix=${STACK_PREFIX:-default}

echo "Start creating $stack_prefix AEM stacks..."

./scripts/create-stack.sh apps/security-groups &
./scripts/create-stack.sh apps/messaging &

wait

./scripts/create-stack.sh apps/author &
./scripts/create-stack.sh apps/publish &
./scripts/create-stack.sh apps/publish-dispatcher &
./scripts/create-stack.sh apps/author-dispatcher &
./scripts/create-stack.sh apps/orchestrator &
./scripts/create-stack.sh apps/chaos-monkey &

wait

echo "Finished creating $stack_prefix AEM stacks"
