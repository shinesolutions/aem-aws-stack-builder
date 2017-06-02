#!/bin/bash
set -o nounset
set -o errexit

if [[ "$#" -lt 2 ]] || [[ "$#" -gt 3 ]]; then
  echo "Usage: ${0} <stack_type> <stack_prefix> [config_path]"
  exit 1
fi

if [[ ${0} =~ create-stack ]]; then
  tag=create
  action_verb=creating
elif [[ ${0} =~ delete-stack ]]; then
  tag=delete
  action_verb=deleting
else
  echo "This script must be called as 'create-stack' or 'delete-stack'"
  exit 1
fi

stack_type="${1}"
stack_prefix="${2}"

config_paths=()
if [[ "$#" -eq 3 ]]; then
  IFS=':' read -ra temp_config_paths <<< "${3}"
  for p in "${temp_config_paths[@]}"; do
    if [[ -n "${p}" ]]; then
      config_paths+=( "${p}" )
    fi
  done
fi

run_id=${RUN_ID:-$(date +%Y-%m-%d:%H:%M:%S)}
log_path=logs/$stack_prefix/$run_id-${tag}-$(echo "$stack_type" | sed 's/\//-/g').log

# Construct Ansible extra_vars flags. If `config_path` is set, all files
# directly under the directory with extension `.yaml` or `.yml` will be added.
# The search for config files _will not_ descend into subdirectories.
extra_vars=(--extra-vars "stack_prefix=$stack_prefix")
if [[ ${#config_paths[@]} -gt 0 ]]; then
  OIFS="${IFS}"
  IFS=$'\n'
  for d in "${config_paths[@]}"; do
    for config_file in $( find -L "${d}" -maxdepth 1 -type f -a \( -name '*.yaml' -o -name '*.yml' \) | sort ); do
      echo "  Adding extra vars from file: ${config_file}"
      extra_vars+=(--extra-vars "@$config_file")
    done
  done
  IFS="${OIFS}"
fi

echo "Extra vars:"
echo "  ${extra_vars[*]}"

mkdir -p "logs/$stack_prefix"
echo "Start ${action_verb} $stack_prefix $stack_type stack"
ANSIBLE_LOG_PATH=$log_path \
  ansible-playbook -v ansible/playbooks/"$stack_type".yaml \
  -i ansible/inventory/hosts \
  --module-path ansible/library/ \
  --tags "${tag}" \
  "${extra_vars[@]}"
echo "Finished ${action_verb} $stack_prefix $stack_type stack"
