#!/usr/bin/env bash
set -o nounset
set -o errexit

INVENTORY=ansible/inventory/hosts

# TODO: should log the output for investigation and debugging if required.

echo "Deleting AEM stack..."

ansible-playbook -vvv ansible/playbooks/apps/chaos-monkey.yaml -i "$INVENTORY" --tags delete &
ansible-playbook -vvv ansible/playbooks/apps/orchestrator.yaml -i "$INVENTORY" --tags delete &
ansible-playbook -vvv ansible/playbooks/apps/author-dispatcher.yaml -i "$INVENTORY" --tags delete &
ansible-playbook -vvv ansible/playbooks/apps/author.yaml -i "$INVENTORY" --tags delete &
ansible-playbook -vvv ansible/playbooks/apps/publish.yaml -i "$INVENTORY" --tags delete &
ansible-playbook -vvv ansible/playbooks/apps/publish-dispatcher.yaml -i "$INVENTORY" --tags delete &

wait

ansible-playbook -vvv ansible/playbooks/apps/messaging.yaml -i "$INVENTORY" --tags delete &
ansible-playbook -vvv ansible/playbooks/apps/security-groups.yaml -i "$INVENTORY" --tags delete &

wait

echo "Finished deleting AEM stack"
