#!/usr/bin/env bash
set -o errexit
set -o nounset

# Full path required here
if [ "$#" -ne 1 ]; then
  echo 'Usage: ./generate-network-config.sh <config_path>'
  exit 1
fi

config_path=${1}

# Construct Ansible extra_vars flags. If `config_path` is set, all files
# directly under the directory with extension `.yaml` or `.yml` will be added.
# The search for config files _will not_ descend into subdirectories.
extra_vars=()
for config_file in $( find -L "${config_path}" -maxdepth 1 -type f -a \( -name '*.yaml' -o -name '*.yml' \) | sort ); do
  extra_vars+=( --extra-vars "@${config_file}")
done

extra_vars+=( --extra-vars "config_path=${config_path}" )

echo "Extra vars:"
echo "  ${extra_vars[*]}"

PYTHONPATH=../python-modules \
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook ansible/playbooks/generate-network-config.yaml \
  -i "localhost," \
  --module-path ansible/library/ \
  "${extra_vars[@]}"
