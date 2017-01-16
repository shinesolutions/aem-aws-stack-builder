#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -ne 2 ]; then
  echo 'Usage: ./delete-stack.sh <stack_type> <stack_prefix>'
  exit 1
fi

stack_type=$1
stack_prefix=$2

run_id=${RUN_ID:-$(date +%Y-%m-%d:%H:%M:%S)}
log_path=logs/$run_id-create-$(echo "$stack_type" | sed 's/\//-/g').log

mkdir -p logs
echo "Start deleting $stack_prefix $stack_type stack"
ANSIBLE_LOG_PATH=$log_path \
  ansible-playbook ansible/playbooks/"$stack_type".yaml \
  -i ansible/inventory/hosts \
  --tags delete \
  --extra-vars "stack_prefix=$stack_prefix"
echo "Finished deleting $stack_prefix $stack_type stack"
