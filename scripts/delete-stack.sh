#!/usr/bin/env bash
set -o nounset
set -o errexit

run_id=${RUN_ID:-`date +%Y-%m-%d:%H:%M:%S`}
stack_prefix=${STACK_PREFIX:-default}
stack_type=$1

mkdir -p logs
echo "Start deleting $stack_prefix $stack_type stack"
ANSIBLE_LOG_PATH=logs/$run_id-create-$stack_type.log ansible-playbook ansible/playbooks/apps/$stack_type.yaml -i ansible/inventory/hosts --tags delete --extra-vars "stack_prefix=$stack_prefix"
echo "Finished deleting $stack_prefix $stack_type stack"
