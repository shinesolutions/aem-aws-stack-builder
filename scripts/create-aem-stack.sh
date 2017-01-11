#!/usr/bin/env bash
set -o nounset
set -o errexit

mkdir -p logs
run_id=${run_id:-`date +%Y-%m-%d:%H:%M:%S`}
create_stack() {
  ANSIBLE_LOG_PATH=logs/$run_id-create-$1.log ansible-playbook ansible/playbooks/apps/$1.yaml -i ansible/inventory/hosts --tags create
}

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
