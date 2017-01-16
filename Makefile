# development targets

clean:
	rm -rf logs
	rm -f *.cert *.key
	rm -f ansible/playbooks/apps/*.retry

deps:
	pip install -r requirements.txt

lint:
	shellcheck scripts/*.sh
	for playbook in ansible/playbooks/*/*.yaml; do \
		ansible-playbook -vvv $$playbook --syntax-check; \
	done

validate:
	for template in cloudformation/*/*.yaml; do \
		aws cloudformation validate-template --template-body "file://$$template"; \
	done

# stack group management targets

create-aem-stacks:
	./scripts/create-aem-stacks.sh

delete-aem-stacks:
	./scripts/delete-aem-stacks.sh

create-network-stacks:
	./scripts/create-network-stacks.sh

delete-network-stacks:
	./scripts/delete-network-stacks.sh

# single network stack management targets

create-vpc:
	./scripts/create-stack.sh network/vpc

delete-vpc:
	./scripts/delete-stack.sh network/vpc

create-network:
	./scripts/create-stack.sh network/network

delete-network:
	./scripts/delete-stack.sh network/network

create-nat-gateway:
	./scripts/create-stack.sh network/nat-gateway

delete-nat-gateway:
	./scripts/delete-stack.sh network/nat-gateway

# single apps stack management targets

create-author-dispatcher:
	./scripts/create-stack.sh apps/author-dispatcher

delete-author-dispatcher:
	./scripts/delete-stack.sh apps/author-dispatcher

create-author:
	./scripts/create-stack.sh apps/author

delete-author:
	./scripts/delete-stack.sh apps/author

create-chaos-monkey:
	./scripts/create-stack.sh apps/chaos-monkey

delete-chaos-monkey:
	./scripts/delete-stack.sh apps/chaos-monkey

create-messaging:
	./scripts/create-stack.sh apps/messaging

delete-messaging:
	./scripts/delete-stack.sh apps/messaging

create-orchestrator:
	./scripts/create-stack.sh apps/orchestrator

delete-orchestrator:
	./scripts/delete-stack.sh apps/orchestrator

create-publish-dispatcher:
	./scripts/create-stack.sh apps/publish-dispatcher

delete-publish-dispatcher:
	./scripts/delete-stack.sh apps/publish-dispatcher

create-publish:
	./scripts/create-stack.sh apps/publish

delete-publish:
	./scripts/delete-stack.sh apps/publish

create-roles:
	./scripts/create-stack.sh apps/roles

delete-roles:
	./scripts/delete-stack.sh apps/roles

create-security-groups:
	./scripts/create-stack.sh apps/security-groups

delete-security-groups:
	./scripts/delete-stack.sh apps/security-groups

# utility targets
# convenient targets for creating certificate using OpenSSL, upload to and remove from AWS IAM
CERT_NAME = "aem-stack-certificate"

create-cert:
	openssl req \
	    -new \
	    -newkey rsa:4096 \
	    -days 365 \
	    -nodes \
	    -x509 \
	    -subj "/C=AU/ST=Victoria/L=Melbourne/O=Sample Organisation/CN=$(CERT_NAME)" \
	    -keyout $(CERT_NAME).key \
	    -out $(CERT_NAME).cert

upload-cert:
	aws iam upload-server-certificate \
	    --server-certificate-name $(CERT_NAME) \
	    --certificate-body "file://$(CERT_NAME).cert" \
	    --private-key "file://$(CERT_NAME).key"

delete-cert:
	aws iam delete-server-certificate \
	    --server-certificate-name $(CERT_NAME)

.PHONY: create-aem delete-aem create-network delete-network clean deps lint validate create-cert upload-cert delete-cert
