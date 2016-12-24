validate:
	./shell/validate.sh

shellcheck:
	shellcheck shell/*.sh

create-shared-stack:
	./shell/create-stack.sh aem-${stack}-stack cloudformation/shared/${stack}.yaml

delete-shared-stack:
	./shell/delete-stack.sh aem-${stack}-stack cloudformation/shared/${stack}.yaml


create-shared-roles-stack:
	./shell/create-stack.sh aem-roles-stack cloudformation/specific/roles.yaml

delete-shared-roles-stack:
	./shell/delete-stack.sh aem-roles-stack cloudformation/specific/roles.yaml


create-stack:
	./shell/create-stack.sh ${moniker}-aem-${stack}-stack cloudformation/specific/${stack}.yaml

delete-stack:
	./shell/delete-stack.sh ${moniker}-aem-${stack}-stack cloudformation/specific/${stack}.yaml



ansible-create-stack:
	ansible-playbook -vvv ansible/${stack}.yaml -i ansible/${inventory} --tags create

ansible-delete-stack:
	ansible-playbook -vvv ansible/${stack}.yaml -i ansible/${inventory} --tags delete
