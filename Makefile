version ?= 3.3.1
aem_stack_manager_messenger_version = 1.5.8
aem_test_suite_version = 0.9.10

ci: clean deps lint package

clean:
	rm -rf logs stage
	rm -f *.cert *.key
	rm -f ansible/playbooks/apps/*.retry

lint:
	# TODO: re-enable at a later release, post transition to aem-platform-buildenv
	# shellcheck scripts/*.sh
	shellcheck test/integration/*.sh
	for playbook in ansible/playbooks/*/*.yaml; do \
		ANSIBLE_LIBRARY=ansible/library ansible-playbook -vvv $$playbook --syntax-check; \
	done

validate:
	for template in $$(find cloudformation -type f -not -path "cloudformation/apps/aem-stack-manager/ssm-commands/*" -name '*.yaml'); do \
		echo "Checking template $$template ...."; \
		aws cloudformation validate-template --template-body "file://$$template"; \
	done

stage:
	mkdir -p stage/ stage/user-config/

config:
	scripts/set-config.sh "${config_path}"

library: stage
	scripts/fetch-library.sh "${config_path}"

################################################################################
# Dependencies resolution targets.
# For deps-local and deps-test-local targets, the local dependencies must be
# available on the same directory level where aem-aws-stack-builder is at. The
# idea is that you can test AEM AWS Stack Builder while also developing those
# dependencies locally.
################################################################################

# resolve dependencies from remote artifact registries
deps: stage
	pip install -r requirements.txt

# resolve test dependencies from remote artifact registries
deps-test: stage
	# setup AEM Hello World Config from GitHub
	rm -rf stage/aem-helloworld-config/ stage/user-config/*
	cd stage && git clone https://github.com/shinesolutions/aem-helloworld-config
	cp -R stage/aem-helloworld-config/aem-aws-stack-builder/* stage/user-config/
	# setup AEM Test Suite from GitHub
	rm -rf stage/aem-test-suite*/
	wget "https://github.com/shinesolutions/aem-test-suite/releases/download/${aem_test_suite_version}/aem-test-suite-${aem_test_suite_version}.tar.gz" --directory-prefix=stage
	mkdir -p stage/aem-test-suite
	tar -xvzf "stage/aem-test-suite-${aem_test_suite_version}.tar.gz" --directory stage/aem-test-suite/
	cd stage/aem-test-suite/ && make deps
	# setup AEM Stack Manager Messenger from GitHub
	rm -rf stage/aem-stack-manager-messenger*/
	wget "https://github.com/shinesolutions/aem-stack-manager-messenger/releases/download/${aem_stack_manager_messenger_version}/aem-stack-manager-messenger-${aem_stack_manager_messenger_version}.tar.gz" --directory-prefix=stage
	mkdir -p stage/aem-stack-manager-messenger/
	tar -xvzf "stage/aem-stack-manager-messenger-${aem_stack_manager_messenger_version}.tar.gz" --directory stage/aem-stack-manager-messenger/
	cd stage/aem-stack-manager-messenger/ && make deps

# resolve test dependencies from local directories
deps-test-local: stage
	# setup AEM AWS Stack Provisioner from local clone
	cd ../aem-aws-stack-provisioner && make deps-local package && aws s3 cp stage/aem-aws-stack-provisioner-*.tar.gz s3://aem-opencloud/library/
	# setup AEM Hello World Config from local clone
	rm -rf stage/aem-helloworld-config/ stage/user-config/*
	cp -R ../aem-helloworld-config/aem-aws-stack-builder/* stage/user-config/
	# setup AEM Test Suite from local clone
	rm -rf stage/aem-test-suite/
	mkdir -p stage/aem-test-suite/
	cp -R ../aem-test-suite/* stage/aem-test-suite/
	# setup AEM Stack Manager Messenger from local clone
	rm -rf stage/aem-stack-manager-messenger/
	mkdir -p stage/aem-stack-manager-messenger/
	cp -R ../aem-stack-manager-messenger/* stage/aem-stack-manager-messenger/

########################################
# Network stacks
########################################

generate-network-config:
	./scripts/generate-network-config.sh "$(config_path)"

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
# AEM Stack Data
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

# convenient targets for setting up configuration files

define config_examples
  rm -rf stage/user-config/$(1)-$(2)-$(3)/
	mkdir -p stage/user-config/$(1)-$(2)-$(3)/
	cp examples/user-config/common/*.yaml stage/user-config/$(1)-$(2)-$(3)/
	cp examples/user-config/apps/aem/$(1)-$(2).yaml stage/user-config/$(1)-$(2)-$(3)/
	cp examples/user-config/apps/aem/$(3).yaml stage/user-config/$(1)-$(2)-$(3)/
	cp examples/descriptors/$(3)/*.json stage/
endef

config-examples-all: config-examples-aem62-rhel7-full-set config-examples-aem62-rhel7-consolidated config-examples-aem63-rhel7-full-set config-examples-aem63-rhel7-consolidated config-examples-aem64-rhel7-full-set config-examples-aem64-rhel7-consolidated config-examples-aem-stack-manager

config-examples-aem62-rhel7-full-set: stage
	$(call config_examples,aem62,rhel7,full-set)

config-examples-aem62-rhel7-consolidated: stage
	$(call config_examples,aem62,rhel7,consolidated)

config-examples-aem62-amazon-linux2-consolidated: stage
	$(call config_examples,aem62,amazon-linux2,consolidated)

config-examples-aem63-rhel7-full-set: stage
	$(call config_examples,aem63,rhel7,full-set)

config-examples-aem63-rhel7-consolidated: stage
	$(call config_examples,aem63,rhel7,consolidated)

config-examples-aem64-rhel7-full-set: stage
	$(call config_examples,aem64,rhel7,full-set)

config-examples-aem64-rhel7-consolidated: stage
	$(call config_examples,aem64,rhel7,consolidated)

config-examples-aem64-amazon-linux2-full-set: stage
	$(call config_examples,aem64,amazon-linux2,full-set)

config-examples-aem64-amazon-linux2-consolidated: stage
	$(call config_examples,aem64,amazon-linux2,consolidated)

config-examples-aem-stack-manager:
	mkdir -p stage/user-config/aem-stack-manager/
	cp examples/user-config/apps/aem-stack-manager.yaml stage/user-config/aem-stack-manager/
	cp examples/user-config/common/*.yaml stage/user-config/aem-stack-manager/

test-integration-aem62-rhel7:
	./test/integration/test-examples.sh $(test_id) aem62 rhel7

test-integration-aem62-amazon-linux2:
	./test/integration/test-examples.sh $(test_id) aem62 amazon-linux2

test-integration-aem63-rhel7:
	./test/integration/test-examples.sh $(test_id) aem63 rhel7

test-integration-aem64-rhel7:
	./test/integration/test-examples.sh $(test_id) aem64 rhel7

test-integration-aem64-amazon-linux2:
	./test/integration/test-examples.sh $(test_id) aem64 amazon-linux2


test-integration-local-aem62-rhel7:
	./test/integration/test-examples-local.sh $(test_id) aem62 rhel7

test-integration-local-aem62-amazon-linux2:
	./test/integration/test-examples-local.sh $(test_id) aem62 amazon-linux2

test-integration-local-aem63-rhel7:
	./test/integration/test-examples-local.sh $(test_id) aem63 rhel7

test-integration-local-aem64-rhel7:
	./test/integration/test-examples-local.sh $(test_id) aem64 rhel7

test-integration-local-aem64-amazon-linux2:
	./test/integration/test-examples-local.sh $(test_id) aem64 amazon-linux2

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

.PHONY: stage create-aem delete-aem create-network delete-network ci clean deps lint validate create-cert upload-cert delete-cert package git-archive generate-network-config
