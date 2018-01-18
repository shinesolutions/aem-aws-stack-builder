version ?= 2.1.0

ci: clean deps lint package

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
		echo "checking template $${template} ...."; \
		aws cloudformation validate-template --template-body "file://$$template"; \
	done

########################################
# Shared stacks
########################################

create-network:
	./scripts/create-stack.sh network/network "$(stack_prefix)" "$(config_path)"

delete-network:
	./scripts/delete-stack.sh network/network "$(stack_prefix)" "$(config_path)"

create-network-exports:
	./scripts/create-stack.sh network/network-exports "$(stack_prefix)" "$(config_path)"

delete-network-exports:
	./scripts/delete-stack.sh network/network-exports "$(stack_prefix)" "$(config_path)"

create-vpc:
	./scripts/create-stack.sh network/vpc "$(stack_prefix)" "$(config_path)"

delete-vpc:
	./scripts/delete-stack.sh network/vpc "$(stack_prefix)" "$(config_path)"

create-nat-gateway:
	./scripts/create-stack.sh network/nat-gateway "$(stack_prefix)" "$(config_path)"

delete-nat-gateway:
	./scripts/delete-stack.sh network/nat-gateway "$(stack_prefix)" "$(config_path)"

create-bastion:
	./scripts/create-stack.sh network/bastion "$(stack_prefix)" "$(config_path)"

delete-bastion:
	./scripts/delete-stack.sh network/bastion "$(stack_prefix)" "$(config_path)"

create-instance-profiles:
	./scripts/create-stack.sh apps/instance-profiles "$(stack_prefix)" "$(config_path)"

delete-instance-profiles:
	./scripts/delete-stack.sh apps/instance-profiles "$(stack_prefix)" "$(config_path)"

create-stack-manager-instance-profiles:
	./scripts/create-stack.sh apps/stack-manager/instance-profiles "$(stack_prefix)" "$(config_path)"

delete-stack-manager-instance-profiles:
	./scripts/delete-stack.sh apps/stack-manager/instance-profiles "$(stack_prefix)" "$(config_path)"

create-security-groups:
	./scripts/create-stack.sh apps/security-groups "$(stack_prefix)" "$(config_path)"

delete-security-groups:
	./scripts/delete-stack.sh apps/security-groups "$(stack_prefix)" "$(config_path)"

########################################
# Consolidated architecture stacks
########################################

create-consolidated-prerequisites:
	./scripts/create-stack.sh apps/consolidated/prerequisites "$(stack_prefix)" "$(config_path)"

delete-consolidated-prerequisites:
	./scripts/delete-stack.sh apps/consolidated/prerequisites "$(stack_prefix)" "$(config_path)"

create-consolidated-main: create-stack-data
	./scripts/create-stack.sh apps/consolidated/main "$(stack_prefix)" "$(config_path)"

delete-consolidated-main: delete-stack-data
	./scripts/delete-stack.sh apps/consolidated/main "$(stack_prefix)" "$(config_path)"

create-consolidated: create-consolidated-prerequisites create-consolidated-main

delete-consolidated: delete-consolidated-main delete-consolidated-prerequisites

########################################
# Full Set architecture stacks
########################################

create-full-set-prerequisites:
	./scripts/create-stack.sh apps/full-set/prerequisites "$(stack_prefix)" "$(config_path)"

delete-full-set-prerequisites:
	./scripts/delete-stack.sh apps/full-set/prerequisites "$(stack_prefix)" "$(config_path)"

create-full-set-main: create-stack-data
	./scripts/create-stack.sh apps/full-set/main  "$(stack_prefix)" "$(config_path)"

delete-full-set-main: delete-stack-data
	./scripts/delete-stack.sh apps/full-set/main "$(stack_prefix)" "$(config_path)"

create-full-set: create-full-set-prerequisites create-full-set-main

delete-full-set: delete-full-set-main delete-full-set-prerequisites

########################################
# Utility stacks
########################################

create-stack-data:
	./scripts/create-stack.sh apps/stack-data "$(stack_prefix)" "$(config_path)"

delete-stack-data:
	./scripts/delete-stack.sh apps/stack-data "$(stack_prefix)" "$(config_path)"

create-snapshots-purge:
	./scripts/create-stack.sh apps/utilities "$(stack_prefix)" "$(config_path)"

delete-snapshots-purge:
	./scripts/delete-stack.sh apps/utilities "$(stack_prefix)" "$(config_path)"

create-ssm-documents:
	./scripts/create-stack.sh apps/stack-manager/ssm-documents "$(stack_prefix)" "$(config_path)"

delete-ssm-documents:
	./scripts/delete-stack.sh apps/stack-manager/ssm-documents "$(stack_prefix)" "$(config_path)"

########################################
# Stack Manager
########################################

create-stack-manager: create-stack-data create-stack-manager-instance-profiles create-ssm-documents
	./scripts/create-stack.sh apps/stack-manager/main "$(stack_prefix)" "$(config_path)"

delete-stack-manager: delete-ssm-documents
	./scripts/delete-stack.sh apps/stack-manager/main "$(stack_prefix)" "$(config_path)"
	./scripts/delete-stack.sh apps/stack-manager/instance-profiles "$(stack_prefix)" "$(config_path)"

# utility targets

library-upload:
	./scripts/create-stack.sh apps/library-upload "$(stack_prefix)" "$(config_path)"

# convenient targets for creating certificate using OpenSSL, upload to and remove from AWS IAM
CERT_NAME=aem-stack-builder

create-cert:
	openssl req \
	    -new \
	    -newkey rsa:4096 \
			-nodes \
	    -days 365 \
	    -x509 \
	    -subj "/C=AU/ST=Victoria/L=Melbourne/O=Sample Organisation/CN=*.*.*.amazonaws.com" \
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

package:
	rm -rf stage
	mkdir -p stage
	tar \
	    --exclude='.git*' \
	    --exclude='.librarian*' \
	    --exclude='.tmp*' \
	    --exclude='stage*' \
	    --exclude='.idea*' \
	    --exclude='.DS_Store*' \
	    --exclude='logs*' \
	    --exclude='*.retry' \
	    --exclude='*.iml' \
	    -cvf \
	    stage/aem-aws-stack-builder-$(version).tar ./
	gzip stage/aem-aws-stack-builder-$(version).tar

git-archive:
	rm -rf stage
	mkdir -p stage
	git archive --format=tar.gz --prefix=aaem-aws-stack-builder-$(version)/ HEAD -o stage/aem-aws-stack-builder-$(version).tar.gz

.PHONY: create-aem delete-aem create-network delete-network ci clean deps lint validate create-cert upload-cert delete-cert package git-archive
