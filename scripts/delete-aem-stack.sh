#!/usr/bin/env bash
set -o nounset
set -o errexit

run_id=${run_id:-`date +%Y-%m-%d:%H:%M:%S`}
stack_prefix=${STACK_PREFIX:-default}

mkdir -p logs
delete_stack() {
  ANSIBLE_LOG_PATH=logs/$run_id-delete-$1.log ansible-playbook ansible/playbooks/apps/$1.yaml -i ansible/inventory/hosts --tags delete --extra-vars "stack_prefix=$stack_prefix"
}

echo "Deleting $stack_prefix AEM stack..."

delete_stack chaos-monkey &
delete_stack orchestrator &
delete_stack author-dispatcher &
delete_stack publish-dispatcher &
delete_stack publish &
delete_stack author &

wait

delete_stack messaging &
delete_stack security-groups &

wait

echo "Finished deleting $stack_prefix AEM stack"
