# development targets

ci: clean deps lint

clean:
	rm -rf logs
	rm -f *.cert *.key
	rm -f ansible/playbooks/apps/*.retry

deps:
	pip install -r requirements.txt

lint:
	shellcheck scripts/*.sh
	for playbook in ansible/playbooks/*/*.yaml; do \
		ANSIBLE_LIBRARY=ansible/library ansible-playbook -vvv $$playbook --syntax-check; \
	done

validate:
	for template in cloudformation/*/*.yaml; do \
		aws cloudformation validate-template --template-body "file://$$template"; \
	done

# stacks set management targets

create-set-aem:
	./scripts/create-aem-stacks.sh "$(stack_prefix)" "$(config_path)"

delete-set-aem:
	./scripts/delete-aem-stacks.sh "$(stack_prefix)" "$(config_path)"

create-set-network:
	./scripts/create-network-stacks.sh "$(stack_prefix)" "$(config_path)"

delete-set-network:
	./scripts/delete-network-stacks.sh "$(stack_prefix)" "$(config_path)"


# single network stack management targets

create-vpc:
	./scripts/create-stack.sh network/vpc "$(stack_prefix)" "$(config_path)"

delete-vpc:
	./scripts/delete-stack.sh network/vpc "$(stack_prefix)" "$(config_path)"

create-network:
	./scripts/create-stack.sh network/network "$(stack_prefix)" "$(config_path)"

delete-network:
	./scripts/delete-stack.sh network/network "$(stack_prefix)" "$(config_path)"

create-nat-gateway:
	./scripts/create-stack.sh network/nat-gateway "$(stack_prefix)" "$(config_path)"

delete-nat-gateway:
	./scripts/delete-stack.sh network/nat-gateway "$(stack_prefix)" "$(config_path)"

create-bastion:
	./scripts/create-stack.sh network/bastion "$(stack_prefix)" "$(config_path)"

delete-bastion:
	./scripts/delete-stack.sh network/bastion "$(stack_prefix)" "$(config_path)"


# single apps stack management targets

create-author-dispatcher:
	./scripts/create-stack.sh apps/author-dispatcher "$(stack_prefix)" "$(config_path)"

delete-author-dispatcher:
	./scripts/delete-stack.sh apps/author-dispatcher "$(stack_prefix)" "$(config_path)"

create-author:
	./scripts/create-stack.sh apps/author "$(stack_prefix)" "$(config_path)"

delete-author:
	./scripts/delete-stack.sh apps/author "$(stack_prefix)" "$(config_path)"

create-chaos-monkey:
	./scripts/create-stack.sh apps/chaos-monkey "$(stack_prefix)" "$(config_path)"

delete-chaos-monkey:
	./scripts/delete-stack.sh apps/chaos-monkey "$(stack_prefix)" "$(config_path)"

create-messaging:
	./scripts/create-stack.sh apps/messaging "$(stack_prefix)" "$(config_path)"

delete-messaging:
	./scripts/delete-stack.sh apps/messaging "$(stack_prefix)" "$(config_path)"

create-orchestrator:
	./scripts/create-stack.sh apps/orchestrator "$(stack_prefix)" "$(config_path)"

delete-orchestrator:
	./scripts/delete-stack.sh apps/orchestrator "$(stack_prefix)" "$(config_path)"

create-publish-dispatcher:
	./scripts/create-stack.sh apps/publish-dispatcher "$(stack_prefix)" "$(config_path)"

delete-publish-dispatcher:
	./scripts/delete-stack.sh apps/publish-dispatcher "$(stack_prefix)" "$(config_path)"

create-publish:
	./scripts/create-stack.sh apps/publish "$(stack_prefix)" "$(config_path)"

delete-publish:
	./scripts/delete-stack.sh apps/publish "$(stack_prefix)" "$(config_path)"

create-roles:
	./scripts/create-stack.sh apps/roles "$(stack_prefix)" "$(config_path)"

delete-roles:
	./scripts/delete-stack.sh apps/roles "$(stack_prefix)" "$(config_path)"

create-security-groups:
	./scripts/create-stack.sh apps/security-groups "$(stack_prefix)" "$(config_path)"

delete-security-groups:
	./scripts/delete-stack.sh apps/security-groups "$(stack_prefix)" "$(config_path)"

create-dns-records:
	./scripts/create-stack.sh apps/dns-records "$(stack_prefix)" "$(config_path)"

delete-dns-records:
	./scripts/delete-stack.sh apps/dns-records "$(stack_prefix)" "$(config_path)"

create-stack-data:
	./scripts/create-stack.sh apps/stack-data "$(stack_prefix)" "$(config_path)"

delete-stack-data:
	./scripts/delete-stack.sh apps/stack-data "$(stack_prefix)" "$(config_path)"

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

# download public release of AEM AWS Stack Provisioner
# to be uploaded to S3 as part of stack-data playbook
download-stack-provisioner:
	mkdir -p stage
	curl \
    -L \
	  --output stage/aem-aws-stack-provisioner.tar.gz \
          https://github.com/shinesolutions/aem-aws-stack-provisioner/tarball/$(aem_aws_stack_provisioner_version)/

.PHONY: create-aem delete-aem create-network delete-network ci clean deps lint validate create-cert upload-cert delete-cert
