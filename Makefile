validate:
	./scripts/validate.sh

shellcheck:
	shellcheck scripts/validate.sh

create-stack:
	./scripts/create-stack.sh michaeld-aem-${stack}-stack templates/${stack}.yaml

delete-stack:
	./scripts/delete-stack.sh michaeld-aem-${stack}-stack templates/${stack}.yaml

