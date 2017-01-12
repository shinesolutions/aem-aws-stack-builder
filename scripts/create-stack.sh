#!/usr/bin/env bash
set -o nounset
set -o errexit

run_id=${RUN_ID:-`date +%Y-%m-%d:%H:%M:%S`}
stack_prefix=${STACK_PREFIX:-default}
stack_type=$1
log_path=logs/$run_id-create-`echo $stack_type | sed 's/\//-/g'`.log

mkdir -p logs
echo "Start creating $stack_prefix $stack_type stack"
ANSIBLE_LOG_PATH=$log_path ansible-playbook ansible/playbooks/$stack_type.yaml -i ansible/inventory/hosts --tags create --extra-vars "stack_prefix=$stack_prefix"
echo "Finished creating $stack_prefix $stack_type stack"
