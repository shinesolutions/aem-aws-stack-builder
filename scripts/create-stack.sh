#!/usr/bin/env bash
set -o nounset
set -o errexit

if [[ "$#" -le 2 ]]; then
  echo 'Usage: ./create-stack.sh <stack_type> <stack_prefix> [config_path]'
  exit 1
fi

stack_type=$1; shift;
stack_prefix=$1; shift;
config_paths=( ${@} )

run_id=${RUN_ID:-$(date +%Y-%m-%d:%H:%M:%S)}
log_path=logs/$stack_prefix/$run_id-create-$(echo "$stack_type" | sed 's/\//-/g').log

# Construct Ansible extra_vars flags.
# If CONFIG_PATH is set, all files under the directory will be added.
extra_vars=(--extra-vars "stack_prefix=$stack_prefix")
if [[ ${#config_paths[@]} -gt 0 ]]; then
  for config_path in "${config_paths[@]}"; do
    if [[ ! -d ${config_path} ]]; then
      echo "Configuration path does not exist: ${config_path}/"
    else
      echo "Reading configuration path: ${config_path}/"
      for config_file in "${config_path}"/*; do
        echo "  Adding extra vars file: ${config_file}"
        extra_vars+=(--extra-vars "@$config_file")
      done
    fi
  done
fi

echo "Extra vars:"
echo "  ${extra_vars[@]}"

mkdir -p "logs/$stack_prefix"
echo "Start creating $stack_prefix $stack_type stack"
ANSIBLE_LOG_PATH=$log_path \
  ansible-playbook -v ansible/playbooks/"$stack_type".yaml \
  -i ansible/inventory/hosts \
  --module-path ansible/library/ \
  --tags create \
  "${extra_vars[@]}"
echo "Finished creating $stack_prefix $stack_type stack"
