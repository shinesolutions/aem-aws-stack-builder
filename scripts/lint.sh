#!/usr/bin/env bash
set -o nounset
set -o errexit

#shellcheck "$PWD"/scripts/*.sh

CLOUDFORMATION_TEMPLATES="$PWD/cloudformation/*/*.yaml"
for template in $CLOUDFORMATION_TEMPLATES
do
	echo "Validating CloudFormation template - $template ..."
	aws cloudformation validate-template --template-body "file:///$template"
done

ANSIBLE_PLAYBOOKS="$PWD/ansible/playbooks/*/*.yaml"
for playbook in $ANSIBLE_PLAYBOOKS
do
	echo "Checking Ansible Playbook syntax - $playbook ..."
	ansible-playbook -vvv "$playbook" --syntax-check
done
