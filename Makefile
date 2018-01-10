version ?= 1.1.1

# development targets

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

create-security-groups:
	./scripts/create-stack.sh apps/security-groups "$(stack_prefix)" "$(config_path)"

delete-security-groups:
	./scripts/delete-stack.sh apps/security-groups "$(stack_prefix)" "$(config_path)"

########################################
# Consolidated architecture stacks
########################################

create-consolidated: create-stack-data
	./scripts/create-stack.sh apps/consolidated/compute-stacks "$(stack_prefix)" "$(config_path)"

delete-consolidated: delete-stack-data
	./scripts/delete-stack.sh apps/consolidated/compute-stacks "$(stack_prefix)" "$(config_path)"

########################################
# Full Set architecture stacks
########################################

create-full-set-prerequisites:
	./scripts/create-stack.sh apps/full-set/prerequisites "$(stack_prefix)" "$(config_path)"

delete-full-set-prerequisites:
	./scripts/delete-stack.sh apps/full-set/prerequisites "$(stack_prefix)" "$(config_path)"

create-full-set-compute: create-stack-data
	./scripts/create-stack.sh apps/full-set/compute-stacks  "$(stack_prefix)" "$(config_path)"

delete-full-set-compute: delete-stack-data
	./scripts/delete-stack.sh apps/full-set/compute-stacks "$(stack_prefix)" "$(config_path)"

create-full-set: create-full-set-prerequisites create-full-set-compute

delete-full-set: delete-full-set-compute delete-full-set-prerequisites

########################################
# Utility stacks
########################################

create-stack-data:
	./scripts/create-stack.sh apps/stack-data "$(stack_prefix)" "$(config_path)"

delete-stack-data:
	./scripts/delete-stack.sh apps/stack-data "$(stack_prefix)" "$(config_path)"







# stacks set management targets

create-set-aem:
	./scripts/create-aem-stacks.sh "$(stack_prefix)" "$(config_path)"

delete-set-aem:
	./scripts/delete-aem-stacks.sh "$(stack_prefix)" "$(config_path)"

create-set-network:
	./scripts/create-network-stacks.sh "$(stack_prefix)" "$(config_path)"

delete-set-network:
	./scripts/delete-network-stacks.sh "$(stack_prefix)" "$(config_path)"



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

create-dns-records:
	./scripts/create-stack.sh apps/dns-records "$(stack_prefix)" "$(config_path)"

delete-dns-records:
	./scripts/delete-stack.sh apps/dns-records "$(stack_prefix)" "$(config_path)"

create-stack-prerequisites:
	./scripts/create-stack.sh apps/prerequisites "$(stack_prefix)" "$(config_path)"

delete-stack-prerequisites:
	./scripts/delete-stack.sh apps/prerequisites "$(stack_prefix)" "$(config_path)"

create-compute-stacks: create-stack-data
	./scripts/create-stack.sh apps/compute-stacks  "$(stack_prefix)" "$(config_path)"

delete-compute-stacks: delete-stack-data
	./scripts/delete-stack.sh apps/compute-stacks "$(stack_prefix)" "$(config_path)"


create-private-cert:
	./scripts/create-stack.sh apps/cert-private  "$(stack_prefix)" "$(config_path)"

delete-private-cert:
	./scripts/delete-stack.sh apps/cert-private  "$(stack_prefix)" "$(config_path)"

create-public-cert:
	./scripts/create-stack.sh apps/cert-public  "$(stack_prefix)" "$(config_path)"

delete-public-cert:
	./scripts/delete-stack.sh apps/cert-public  "$(stack_prefix)" "$(config_path)"

library-upload:
	./scripts/create-stack.sh apps/library-upload "$(stack_prefix)" "$(config_path)"

# utility targets

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
