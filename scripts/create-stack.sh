#!/usr/bin/env bash
set -o nounset
set -o errexit

config_path=${CONFIG_PATH:-}
run_id=${RUN_ID:-`date +%Y-%m-%d:%H:%M:%S`}
stack_prefix=${STACK_PREFIX:-default}
stack_type=$1
log_path=logs/$run_id-create-`echo $stack_type | sed 's/\//-/g'`.log

# Construct Ansible extra_vars flags.
# If CONFIG_PATH is set, all files under the directory will be added.
extra_vars="--extra-vars ""stack_prefix=$stack_prefix"""
if [ ! -z "$config_path" ]; then
  for config_file in `find "$config_path"/*`
  do
    extra_vars="$extra_vars --extra-vars ""@$config_file"""
  done
fi
echo $extra_vars

mkdir -p logs
echo "Start creating $stack_prefix $stack_type stack"
ANSIBLE_LOG_PATH=$log_path \
  ansible-playbook ansible/playbooks/$stack_type.yaml \
  -i ansible/inventory/hosts \
  --tags create \
  $extra_vars
echo "Finished creating $stack_prefix $stack_type stack"
