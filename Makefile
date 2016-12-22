validate:
	./scripts/validate.sh

shellcheck:
	shellcheck scripts/*.sh

create-network-stack:
	./scripts/create-stack.sh aem-${stack}-stack templates/network/${stack}.yaml

delete-network-stack:
	./scripts/delete-stack.sh aem-${stack}-stack templates/network/${stack}.yaml

create-compute-stack:
	./scripts/create-stack.sh aem-${stack}-stack templates/compute/${stack}.yaml

delete-compute-stack:
	./scripts/delete-stack.sh aem-${stack}-stack templates/compute/${stack}.yaml



ansible-create-stack:
	ansible-playbook -vvv ansible/${stack}.yaml -i ansible/${inventory} --tags create

ansible-delete-stack:
	ansible-playbook -vvv ansible/${stack}.yaml -i ansible/${inventory} --tags delete
