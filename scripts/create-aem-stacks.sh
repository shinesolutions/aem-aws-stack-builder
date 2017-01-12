#!/usr/bin/env bash
set -o nounset
set -o errexit

run_id=${run_id:-`date +%Y-%m-%d:%H:%M:%S`}
stack_prefix=${STACK_PREFIX:-default}

echo "Start creating $stack_prefix AEM stacks..."

./scripts/create-stack.sh security-groups &
./scripts/create-stack.sh messaging &

wait

./scripts/create-stack.sh author &
./scripts/create-stack.sh publish &
./scripts/create-stack.sh publish-dispatcher &
./scripts/create-stack.sh author-dispatcher &
./scripts/create-stack.sh orchestrator &
./scripts/create-stack.sh chaos-monkey &

wait

echo "Finished creating $stack_prefix AEM stacks"
