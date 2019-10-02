#!/bin/bash
set -o errexit

if [[ "$#" -lt 3 ]] || [[ "$#" -gt 7 ]]; then
  echo "Usage: ${0} <stack_type> <config_path> <stack_prefix> <publish_dispatcher_hosted_zone> <publish_dispatcher_record> <author_dispatcher_hosted_zone> <author_dispatcher_record>"
  exit 1
fi

tag=switch
action_verb=switching

stack_type="${1}"
stack_prefix="${3}"
publish_dispatcher_hosted_zone="${4}"
publish_dispatcher_record_set="${5}"
author_dispatcher_hosted_zone="${6}"
author_dispatcher_record_set="${7}"

config_paths=()
IFS=':' read -ra temp_config_paths <<< "${2}"
for p in "${temp_config_paths[@]}"; do
  if [[ -n "${p}" ]]; then
    config_paths+=( "${p}" )
  fi
done

run_id=${RUN_ID:-$(date +%Y-%m-%d:%H:%M:%S)}
# shellcheck disable=SC2001
log_path=logs/$stack_prefix/$run_id-${tag}-$(echo "$stack_type" | sed 's/\//-/g').log

# Construct Ansible extra_vars flags. If `config_path` is set, all files
# directly under the directory with extension `.yaml` or `.yml` will be added.
# The search for config files _will not_ descend into subdirectories.
extra_vars=(--extra-vars "stack_prefix=$stack_prefix publish_dispatcher_hosted_zone=$publish_dispatcher_hosted_zone publish_dispatcher_record_set=$publish_dispatcher_record_set author_dispatcher_hosted_zone=$author_dispatcher_hosted_zone  author_dispatcher_record_set=$author_dispatcher_record_set " )
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
ANSIBLE_CONFIG=conf/ansible/ansible.cfg \
  ansible-playbook -v provisioners/ansible/playbooks/"$stack_type".yaml \
  -i conf/ansible/inventory/hosts \
  --module-path provisioners/ansible/library/ \
  --tags "${tag}" \
  "${extra_vars[@]}"
echo "Finished ${action_verb} $stack_prefix $stack_type stack"
