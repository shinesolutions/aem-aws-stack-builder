#!/usr/bin/env bash
set -o errexit
set -o nounset

if [ "$#" -ne 1 ]; then
  echo 'Usage: ./set-secgrp.sh <config_path>'
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

echo "Extra vars:"
echo "  ${extra_vars[*]}"

PYTHONPATH=../python-modules ansible-playbook ansible/playbooks/set-secgrp.yaml \
  -i "localhost," \
  --module-path ansible/library/ \
  "${extra_vars[@]}"
