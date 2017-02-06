#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 2 ] || [ "$#" -gt 3 ]; then
  echo 'Usage: ./delete-stack.sh <stack_type> <stack_prefix> [config_path]'
  exit 1
fi

stack_type=$1
stack_prefix=$2
config_path=$3

run_id=${RUN_ID:-$(date +%Y-%m-%d:%H:%M:%S)}
log_path=logs/$stack_prefix/$run_id-create-$(echo "$stack_type" | sed 's/\//-/g').log

# Construct Ansible extra_vars flags.
# If CONFIG_PATH is set, all files under the directory will be added.
extra_vars=(--extra-vars "stack_prefix=$stack_prefix")
if [ ! -z "$config_path" ]; then
  for config_file in "$config_path"/*
  do
    extra_vars+=(--extra-vars "@$config_file")
  done
fi

mkdir -p "logs/$stack_prefix"
echo "Start deleting $stack_prefix $stack_type stack"
ANSIBLE_LOG_PATH=$log_path \
  ansible-playbook ansible/playbooks/"$stack_type".yaml \
  -i ansible/inventory/hosts \
  --module-path ansible/library/ \
  --tags delete \
  "${extra_vars[@]}"
echo "Finished deleting $stack_prefix $stack_type stack"
