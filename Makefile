validate:
	./scripts/validate.sh

shellcheck:
	shellcheck scripts/validate.sh scripts/create-stack.sh scripts/delete-stack.sh

create-network-stack:
	./scripts/create-stack.sh aem-${stack}-stack templates/network/${stack}.yaml

delete-network-stack:
	./scripts/delete-stack.sh aem-${stack}-stack templates/network/${stack}.yaml

create-compute-stack:
	./scripts/create-stack.sh aem-${stack}-stack templates/compute/${stack}.yaml

delete-compute-stack:
	./scripts/delete-stack.sh aem-${stack}-stack templates/compute/${stack}.yaml



ansible-create-vpc-stack:
	ansible-playbook -vvv ansible/network-stack.yaml -i ansible/${inventory} --tags create-vpc

ansible-delete-vpc-stack:
	ansible-playbook -vvv ansible/network-stack.yaml -i ansible/${inventory} --tags delete-vpc

ansible-create-network-stack:
	ansible-playbook -vvv ansible/network-stack.yaml -i ansible/${inventory} --tags create-network

ansible-detele-network-stack:
	ansible-playbook -vvv ansible/network-stack.yaml -i ansible/${inventory} --tags delete-network

