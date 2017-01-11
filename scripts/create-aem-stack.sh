#!/usr/bin/env bash
set -o nounset
set -o errexit

create_stack() {
  ansible-playbook ansible/playbooks/apps/$1.yaml -i "ansible/inventory/hosts" --tags create
}

# TODO: should log the output for investigation and debugging if required.

echo "Creating AEM stack..."

create_stack security-groups &
create_stack messaging &

wait

create_stack author &
create_stack publish &
create_stack publish-dispatcher &
create_stack author-dispatcher &
create_stack orchestrator &
create_stack chaos-monkey &

wait

echo "Finished creating AEM stack"
