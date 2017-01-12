#!/usr/bin/env bash
set -o nounset
set -o errexit

run_id=${run_id:-`date +%Y-%m-%d:%H:%M:%S`}
stack_prefix=${STACK_PREFIX:-default}

echo "Deleting $stack_prefix AEM stacks..."

./scripts/delete-stack.sh chaos-monkey &
./scripts/delete-stack.sh orchestrator &
./scripts/delete-stack.sh author-dispatcher &
./scripts/delete-stack.sh publish-dispatcher &
./scripts/delete-stack.sh publish &
./scripts/delete-stack.sh author &

wait

./scripts/delete-stack.sh messaging &
./scripts/delete-stack.sh security-groups &

wait

echo "Finished deleting $stack_prefix AEM stacks"
