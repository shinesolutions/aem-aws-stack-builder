lint:
	./scripts/lint.sh

create-shared-stack:
	./scripts/create-stack.sh aem-${stack}-stack cloudformation/shared/${stack}.yaml

delete-shared-stack:
	./scripts/delete-stack.sh aem-${stack}-stack cloudformation/shared/${stack}.yaml


create-shared-roles-stack:
	./scripts/create-stack.sh aem-roles-stack cloudformation/specific/roles.yaml

delete-shared-roles-stack:
	./scripts/delete-stack.sh aem-roles-stack cloudformation/specific/roles.yaml


create-stack:
	./scripts/create-stack.sh ${prefix}-aem-${stack}-stack cloudformation/specific/${stack}.yaml

delete-stack:
	./scripts/delete-stack.sh ${prefix}-aem-${stack}-stack cloudformation/specific/${stack}.yaml

create-aem-stack:
	./scripts/create-aem-stack.sh ${inventory}

delete-aem-stack:
	./scripts/delete-aem-stack.sh ${inventory}

ansible-create-stack:
	ansible-playbook -vvv ansible/${stack}.yaml -i ansible/${inventory} --tags create

ansible-delete-stack:
	ansible-playbook -vvv ansible/${stack}.yaml -i ansible/${inventory} --tags delete

.PHONY: lint
