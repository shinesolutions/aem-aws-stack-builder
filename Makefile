version ?= 5.14.2
aem_stack_manager_messenger_version = 2.14.1
aem_test_suite_version = 2.0.0
aem_helloworld_custom_stack_provisioner_version = 0.15.0

ci: clean deps lint package

clean:
	rm -rf logs/ stage/ *.cert *.key provisioners/ansible/playbooks/apps/*.retry provisioners/ansible/playbooks/network/network-resources-generated.yaml

stage:
	mkdir -p stage/ stage/user-config/ stage/descriptors/

config:
	scripts/set-config.sh "${config_path}"

library: stage
	scripts/fetch-library.sh "${config_path}"

package:
	rm -rf stage
	mkdir -p stage
	tar \
	    --exclude='.git*' \
	    --exclude='.librarian*' \
	    --exclude='.tmp*' \
			--exclude='.yamllint' \
	    --exclude='stage*' \
	    --exclude='.idea*' \
	    --exclude='.DS_Store*' \
	    --exclude='logs*' \
	    --exclude='*.retry' \
	    --exclude='*.iml' \
	    -cvf \
	    stage/aem-aws-stack-builder-$(version).tar ./
	gzip stage/aem-aws-stack-builder-$(version).tar

release-major:
	rtk release --release-increment-type major

release-minor:
	rtk release --release-increment-type minor

release-patch:
	rtk release --release-increment-type patch

release: release-minor

publish:
	gh release create $(version) --title $(version) --notes "" || echo "Release $(version) has been created on GitHub"
	gh release upload $(version) stage/aem-aws-stack-builder-$(version).tar.gz

################################################################################
# Code styling check and validation targets:
# - lint Ansible inventory and playbook files
# - check shell scripts
################################################################################

lint:
	 yamllint \
	   conf/ansible/inventory/group_vars/*.yaml \
	   provisioners/ansible/playbooks/*.yaml \
	   provisioners/ansible/playbooks/*/*.yaml \
	   provisioners/ansible/playbooks/*/*/*.yaml \
	   templates/cloudformation/*/*.yaml \
	 	templates/cloudformation/*/*/*.yaml
	shellcheck scripts/*.sh test/integration/*.sh
	for playbook in provisioners/ansible/playbooks/*/*.yaml; do \
		ANSIBLE_LIBRARY=conf/ansible/library ansible-playbook -vvv $$playbook --syntax-check; \
	done
	# TODO: re-enable template validation after sorting out CI credential
	# for template in $$(find templates/cloudformation/ -type f -not -path "templates/cloudformation/apps/aem-stack-manager/ssm-commands/*" -name '*.yaml'); do \
	# 	echo "Checking template $$template ...."; \
	# 	AWS_DEFAULT_REGION=ap-southeast-2 aws cloudformation validate-template --template-body "file://$$template"; \
	# done

################################################################################
# Dependencies resolution targets.
# For deps-local and deps-test-local targets, the local dependencies must be
# available on the same directory level where aem-aws-stack-builder is at. The
# idea is that you can test AEM AWS Stack Builder while also developing those
# dependencies locally.
################################################################################

# resolve dependencies from remote artifact registries
deps: stage
	pip3 install -r requirements.txt

# resolve test dependencies from remote artifact registries
deps-test: stage
	# setup AEM Hello World Config from GitHub
	rm -rf stage/aem-helloworld-config/ stage/user-config/* stage/descriptors/*
	cd stage && git clone https://github.com/shinesolutions/aem-helloworld-config
	cp -R stage/aem-helloworld-config/aem-aws-stack-builder/* stage/user-config/
	cp -R stage/aem-helloworld-config/descriptors/* stage/descriptors/
	# setup AEM HelloWorld Custom Stack Provisioner from GitHub
	wget "https://github.com/shinesolutions/aem-helloworld-custom-stack-provisioner/releases/download/${aem_helloworld_custom_stack_provisioner_version}/aem-helloworld-custom-stack-provisioner-${aem_helloworld_custom_stack_provisioner_version}.tar.gz" \
	  -O stage/aem-custom-stack-provisioner.tar.gz
	# setup AEM Test Suite from GitHub
	rm -rf stage/aem-test-suite*/
	wget "https://github.com/shinesolutions/aem-test-suite/releases/download/${aem_test_suite_version}/aem-test-suite-${aem_test_suite_version}.tar.gz" --directory-prefix=stage
	mkdir -p stage/aem-test-suite
	tar -xvzf "stage/aem-test-suite-${aem_test_suite_version}.tar.gz" --directory stage/aem-test-suite/
	cd stage/aem-test-suite/ #& make deps
	# setup AEM Stack Manager Messenger from GitHub
	rm -rf stage/aem-stack-manager-messenger*/
	wget "https://github.com/shinesolutions/aem-stack-manager-messenger/releases/download/${aem_stack_manager_messenger_version}/aem-stack-manager-messenger-${aem_stack_manager_messenger_version}.tar.gz" --directory-prefix=stage
	mkdir -p stage/aem-stack-manager-messenger/
	tar -xvzf "stage/aem-stack-manager-messenger-${aem_stack_manager_messenger_version}.tar.gz" --directory stage/aem-stack-manager-messenger/
	cd stage/aem-stack-manager-messenger/ #& make deps

# resolve test dependencies from local directories
deps-test-local: stage
	# setup AEM AWS Stack Provisioner from local clone
	cd ../aem-aws-stack-provisioner && version=$(test_id) make deps-local package && aws s3 cp stage/aem-aws-stack-provisioner-$(test_id).tar.gz s3://aem-opencloud/library/
	# setup AEM Stack Manager from local clone
	cd ../aem-stack-manager-cloud && version=$(test_id) make deps package && aws s3 cp stage/aem-stack-manager-cloud-$(test_id).zip s3://aem-opencloud/library/
	# setup AEM Hello World Config from local clone
	rm -rf stage/aem-helloworld-config/ stage/user-config/* stage/descriptors/*
	cp -R ../aem-helloworld-config/aem-aws-stack-builder/* stage/user-config/
	cp -R ../aem-helloworld-config/descriptors/* stage/descriptors/
	# setup AEM Hello World Custom Stack Provisioner from local clone
	cd ../aem-helloworld-custom-stack-provisioner && make package
	rm -rf stage/aem-custom-stack-provisioner.tar.gz
	cp ../aem-helloworld-custom-stack-provisioner/stage/*.tar.gz stage/aem-custom-stack-provisioner.tar.gz
	# setup AEM Test Suite from local clone
	rm -rf stage/aem-test-suite/
	mkdir -p stage/aem-test-suite/
	cp -R ../aem-test-suite/* stage/aem-test-suite/
	# setup AEM Stack Manager Messenger from local clone
	rm -rf stage/aem-stack-manager-messenger/
	mkdir -p stage/aem-stack-manager-messenger/
	cp -R ../aem-stack-manager-messenger/* stage/aem-stack-manager-messenger/

################################################################################
# Network targets.
################################################################################

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

################################################################################
# AWS resources targets.
################################################################################

create-aws-resources:
	scripts/create-stack.sh apps/create-aws-resources "${config_path}" "${stack_prefix}"

delete-aws-resources:
	scripts/delete-stack.sh apps/delete-aws-resources "${config_path}" "${stack_prefix}"

################################################################################
# AEM Stack Data targets.
################################################################################

create-aem-stack-data:
	./scripts/create-stack.sh apps/aem/stack-data "$(config_path)" "$(stack_prefix)"

delete-aem-stack-data:
	./scripts/delete-stack.sh apps/aem/stack-data "$(config_path)" "$(stack_prefix)"

################################################################################
# AEM Consolidated architecture targets.
################################################################################

create-consolidated-prerequisites:
	./scripts/create-stack.sh apps/aem/consolidated/prerequisites "$(config_path)" "$(stack_prefix)"

delete-consolidated-prerequisites:
	./scripts/delete-stack.sh apps/aem/consolidated/prerequisites "$(config_path)" "$(stack_prefix)"

create-consolidated-main: create-aem-stack-data
	./scripts/create-stack.sh apps/aem/consolidated/main "$(config_path)" "$(stack_prefix)" "$(prerequisites_stack_prefix)"

delete-consolidated-main: delete-aem-stack-data
	./scripts/delete-stack.sh apps/aem/consolidated/main "$(config_path)" "$(stack_prefix)"

switch-dns-consolidated:
	./scripts/switch-dns-consolidated.sh apps/aem/consolidated/switch-dns "$(config_path)" "$(stack_prefix)" "$(author_publish_dispatcher_hosted_zone)" "$(author_publish_dispatcher_record_set)"

create-consolidated:
	make create-consolidated-prerequisites "config_path=$(config_path)" "stack_prefix=$(stack_prefix)"
	make create-consolidated-main "config_path=$(config_path)" "stack_prefix=$(stack_prefix)" "prerequisites_stack_prefix=$(stack_prefix)"

delete-consolidated: delete-consolidated-main delete-consolidated-prerequisites

################################################################################
# AEM Full Set architecture targets.
################################################################################

create-full-set-prerequisites:
	./scripts/create-stack.sh apps/aem/full-set/prerequisites "$(config_path)" "$(stack_prefix)"

delete-full-set-prerequisites:
	./scripts/delete-stack.sh apps/aem/full-set/prerequisites "$(config_path)" "$(stack_prefix)"

create-full-set-main: create-aem-stack-data
	./scripts/create-stack.sh apps/aem/full-set/main "$(config_path)" "$(stack_prefix)" "$(prerequisites_stack_prefix)"

delete-full-set-main: delete-aem-stack-data
	./scripts/delete-stack.sh apps/aem/full-set/main "$(config_path)" "$(stack_prefix)"

switch-dns-full-set:
	./scripts/switch-dns-full-set.sh apps/aem/full-set/switch-dns "$(config_path)" "$(stack_prefix)"  "$(publish_dispatcher_hosted_zone)" "$(publish_dispatcher_record_set)" "$(author_dispatcher_hosted_zone)" "$(author_dispatcher_record_set)"

create-full-set:
	make create-full-set-prerequisites "config_path=$(config_path)" "stack_prefix=$(stack_prefix)"
	make create-full-set-main "config_path=$(config_path)" "stack_prefix=$(stack_prefix)" "prerequisites_stack_prefix=$(stack_prefix)"

delete-full-set: delete-full-set-main delete-full-set-prerequisites

################################################################################
# AEM Stack Manager targets.
################################################################################

create-aem-stack-manager-stack-data:
	./scripts/create-stack.sh apps/aem-stack-manager/stack-data "$(config_path)" "$(stack_prefix)"

delete-aem-stack-manager-stack-data:
	./scripts/delete-stack.sh apps/aem-stack-manager/stack-data "$(config_path)" "$(stack_prefix)"

create-stack-manager: create-aem-stack-manager-stack-data
	./scripts/create-stack.sh apps/aem-stack-manager/main "$(config_path)" "$(stack_prefix)"

delete-stack-manager:
	./scripts/delete-stack.sh apps/aem-stack-manager/main "$(config_path)" "$(stack_prefix)"

################################################################################
# CloudFront CDN targets.
################################################################################

create-cdn:
	./scripts/create-stack.sh apps/cdn/main "$(config_path)" "$(stack_prefix)"

delete-cdn:
	./scripts/delete-stack.sh apps/cdn/main "$(config_path)" "$(stack_prefix)"

################################################################################
# Integration test targets.
# Provides convenient targets for testing against the supported permutation of
# AEM versions and OSes.
################################################################################

test-integration-aem62-rhel7: deps deps-test
	./test/integration/test-examples.sh $(test_id) aem62 rhel7

test-integration-aem62-amazon-linux2: deps deps-test
	./test/integration/test-examples.sh $(test_id) aem62 amazon-linux2

test-integration-aem63-rhel7: deps deps-test
	./test/integration/test-examples.sh $(test_id) aem63 rhel7

test-integration-aem63-amazon-linux2: deps deps-test
	./test/integration/test-examples.sh $(test_id) aem63 amazon-linux2

test-integration-aem64-rhel7: deps deps-test
	./test/integration/test-examples.sh $(test_id) aem64 rhel7

test-integration-aem64-amazon-linux2: deps deps-test
	./test/integration/test-examples.sh $(test_id) aem64 amazon-linux2

test-integration-aem65-rhel7: deps deps-test
	./test/integration/test-examples.sh $(test_id) aem65 rhel7

test-integration-aem65-amazon-linux2: deps deps-test
	./test/integration/test-examples.sh $(test_id) aem65 amazon-linux2

test-integration-local-aem62-rhel7: deps deps-test-local
	./test/integration/test-examples-local.sh $(test_id) aem62 rhel7

test-integration-local-aem62-amazon-linux2: deps deps-test-local
	./test/integration/test-examples-local.sh $(test_id) aem62 amazon-linux2

test-integration-local-aem63-rhel7: deps deps-test-local
	./test/integration/test-examples-local.sh $(test_id) aem63 rhel7

test-integration-local-aem64-rhel7: deps deps-test-local
	./test/integration/test-examples-local.sh $(test_id) aem64 rhel7

test-integration-local-aem64-amazon-linux2: deps deps-test-local
	./test/integration/test-examples-local.sh $(test_id) aem64 amazon-linux2

test-integration-local-aem65-rhel7: deps deps-test-local
	./test/integration/test-examples-local.sh $(test_id) aem65 rhel7

test-integration-local-aem65-amazon-linux2: deps deps-test-local
	./test/integration/test-examples-local.sh $(test_id) aem65 amazon-linux2

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

.PHONY: stage create-aem delete-aem create-network delete-network ci clean deps lint create-cert upload-cert delete-cert package git-archive generate-network-config release release-major release-minor release-patch publish
