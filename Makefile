validate:
	./scripts/validate.sh

shellcheck:
	shellcheck scripts/validate.sh

create-vpc-stack:
	./scripts/create-stack.sh michaeld-aem-vpc-stack templates/vpc.yaml

delete-vpc-stack:
	./scripts/delete-stack.sh michaeld-aem-vpc-stack templates/vpc.yaml

create-network-stack:
	./scripts/create-stack.sh michaeld-aem-network-stack templates/network.yaml

delete-network-stack:
	./scripts/delete-stack.sh michaeld-aem-network-stack templates/network.yaml
