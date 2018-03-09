version ?= 2.1.0

ci: clean deps lint package

clean:
	rm -rf logs stage
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
		echo "Checking template $${template} ...."; \
		aws cloudformation validate-template --template-body "file://$$template"; \
	done
	for template in cloudformation/*/*/*.yaml; do \
		echo "Checking template $${template} ...."; \
		aws cloudformation validate-template --template-body "file://$$template"; \
	done
	for template in cloudformation/*/*/*/*.yaml; do \
		echo "Checking template $${template} ...."; \
		aws cloudformation validate-template --template-body "file://$$template"; \
	done

stage:
	mkdir -p stage/

config:
	scripts/set-config.sh "${config_path}"

secgrp:
	scripts/set-secgrp.sh "${config_path}"

library: stage
	scripts/fetch-library.sh "${config_path}"

########################################
# Shared stacks
########################################

create-vpc:
	./scripts/create-stack.sh network/vpc "$(config_path)" "$(stack_prefix)"

delete-vpc:
	./scripts/delete-stack.sh network/vpc "$(config_path)" "$(stack_prefix)"

create-network:
	./scripts/create-stack.sh network/network "$(config_path)" "$(stack_prefix)"

delete-network:
	./scripts/delete-stack.sh network/network "$(config_path)" "$(stack_prefix)"

create-network-exports:
	./scripts/create-stack.sh network/network-exports "$(config_path)" "$(stack_prefix)"

delete-network-exports:
	./scripts/delete-stack.sh network/network-exports "$(config_path)" "$(stack_prefix)"

create-nat-gateway:
	./scripts/create-stack.sh network/nat-gateway "$(config_path)" "$(stack_prefix)"

delete-nat-gateway:
	./scripts/delete-stack.sh network/nat-gateway "$(config_path)" "$(stack_prefix)"

create-bastion:
	./scripts/create-stack.sh network/bastion "$(config_path)" "$(stack_prefix)"

delete-bastion:
	./scripts/delete-stack.sh network/bastion "$(config_path)" "$(stack_prefix)"

########################################
# AEM
########################################

create-aem-stack-data:
	./scripts/create-stack.sh apps/aem/stack-data "$(config_path)" "$(stack_prefix)"

delete-aem-stack-data:
	./scripts/delete-stack.sh apps/aem/stack-data "$(config_path)" "$(stack_prefix)"

########################################
# AEM Consolidated architecture stacks
########################################

create-consolidated-prerequisites:
	./scripts/create-stack.sh apps/aem/consolidated/prerequisites "$(config_path)" "$(stack_prefix)"

delete-consolidated-prerequisites:
	./scripts/delete-stack.sh apps/aem/consolidated/prerequisites "$(config_path)" "$(stack_prefix)"

create-consolidated-main: create-aem-stack-data
	./scripts/create-stack.sh apps/aem/consolidated/main "$(config_path)" "$(stack_prefix)" "$(prerequisites_stack_prefix)"

delete-consolidated-main: delete-aem-stack-data
	./scripts/delete-stack.sh apps/aem/consolidated/main "$(config_path)" "$(stack_prefix)"

create-consolidated:
	make create-consolidated-prerequisites "config_path=$(config_path)" "stack_prefix=$(stack_prefix)"
	make create-consolidated-main "config_path=$(config_path)" "stack_prefix=$(stack_prefix)" "prerequisites_stack_prefix=$(stack_prefix)"

delete-consolidated: delete-consolidated-main delete-consolidated-prerequisites

########################################
# AEM Full Set architecture stacks
########################################

create-full-set-prerequisites:
	./scripts/create-stack.sh apps/aem/full-set/prerequisites "$(config_path)" "$(stack_prefix)"

delete-full-set-prerequisites:
	./scripts/delete-stack.sh apps/aem/full-set/prerequisites "$(config_path)" "$(stack_prefix)"

create-full-set-main: create-aem-stack-data
	./scripts/create-stack.sh apps/aem/full-set/main "$(config_path)" "$(stack_prefix)" "$(prerequisites_stack_prefix)"

delete-full-set-main: delete-aem-stack-data
	./scripts/delete-stack.sh apps/aem/full-set/main "$(config_path)" "$(stack_prefix)"

create-full-set:
	make create-full-set-prerequisites "config_path=$(config_path)" "stack_prefix=$(stack_prefix)"
	make create-full-set-main "config_path=$(config_path)" "stack_prefix=$(stack_prefix)" "prerequisites_stack_prefix=$(stack_prefix)"

delete-full-set: delete-full-set-main delete-full-set-prerequisites

########################################
# AEM Stack Manager
########################################

create-aem-stack-manager-stack-data:
	./scripts/create-stack.sh apps/aem-stack-manager/stack-data "$(config_path)" "$(stack_prefix)"

delete-aem-stack-manager-stack-data:
	./scripts/delete-stack.sh apps/aem-stack-manager/stack-data "$(config_path)" "$(stack_prefix)"

create-stack-manager: create-aem-stack-manager-stack-data
	 #create-ssm-documents
	./scripts/create-stack.sh apps/aem-stack-manager/main "$(config_path)" "$(stack_prefix)"

delete-stack-manager:
	 #delete-ssm-documents
	./scripts/delete-stack.sh apps/aem-stack-manager/main "$(config_path)" "$(stack_prefix)"

########################################
# Utility stacks
########################################

create-snapshots-purge:
	./scripts/create-stack.sh apps/utilities "$(config_path)" "$(stack_prefix)"

delete-snapshots-purge:
	./scripts/delete-stack.sh apps/utilities "$(config_path)" "$(stack_prefix)"

create-ssm-documents:
	./scripts/create-stack.sh apps/stack-manager/ssm-documents "$(config_path)" "$(stack_prefix)"

delete-ssm-documents:
	./scripts/delete-stack.sh apps/stack-manager/ssm-documents "$(config_path)" "$(stack_prefix)"

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
