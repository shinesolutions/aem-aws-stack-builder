#!/usr/bin/env bash
set -o errexit

# This script is used for integration testing AEM environments using local
# repos, which allows the user to decide whether to use master or a feature
# branch that's being worked on for each of the repos.
# The AEM environments are created using examples user configurations.

test_id=$1
aem_version=aem63
os_type=rhel7
s3_bucket=aem-stack-builder
integration_config_file=examples/user-config/common/zzz-test-integration-local.yaml

# Download dependencies and run lint checks
cd ../puppet-aem-resources && make clean deps lint
cd ../puppet-aem-curator && make clean deps lint
cd ../puppet-aem-orchestrator && make clean deps lint
cd ../aem-aws-stack-provisioner && make clean deps lint
cd ../aem-aws-stack-builder && make clean deps lint
cd ../aem-stack-manager-messenger && make clean deps lint

# Build AEM AWS Stack Provisioner and upload it to S3
cd ../aem-aws-stack-provisioner
rm -rf modules/aem_resources/*
rm -rf modules/aem_curator/*
cp -R ../puppet-aem-resources/* modules/aem_resources/
cp -R ../puppet-aem-curator/* modules/aem_curator/
cp -R ../puppet-aem-orchestrator/* modules/aem_orchestrator/
make package "version=${test_id}"
aws s3 cp "stage/aem-aws-stack-provisioner-${test_id}.tar.gz" "s3://${s3_bucket}/library/"

# Create AEM environments: a Stack Manager, an AEM Consolidated, and an AEM Full-Set
cd ../aem-aws-stack-builder
rm -f "${integration_config_file}"
echo -e "library:\n  aem_aws_stack_provisioner_version: ${test_id}" > "${integration_config_file}"
echo -e "scheduled_jobs:\n  aem_orchestrator:\n    stack_manager_pair:\n        stack_prefix: ${test_id}-stack-manager" >> "${integration_config_file}"
make config-examples-aem-stack-manager && make create-stack-manager "stack_prefix=${test_id}-stack-manager" config_path=stage/user-config/aem-stack-manager/
make "config-examples-${aem_version}-${os_type}-full-set" && make create-full-set "stack_prefix=${test_id}-full-set" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/"
make "config-examples-${aem_version}-${os_type}-consolidated" && make create-consolidated "stack_prefix=${test_id}-consolidated" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/"

# Run integration tests via Stack Manager Messenger
cd ../aem-stack-manager-messenger
make test-consolidated \
  "stack_prefix=${test_id}-stack-manager" \
  "target_aem_stack_prefix=${test_id}-consolidated"
make test-full-set \
  "stack_prefix=${test_id}-stack-manager" \
  "target_aem_stack_prefix=${test_id}-full-set"

# Delete all created AEM environments
cd ../aem-aws-stack-builder
(make "config-examples-${aem_version}-${os_type}-full-set" && make delete-full-set "stack_prefix=${test_id}-full-set" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/") &
(make "config-examples-${aem_version}-${os_type}-consolidated" && make delete-consolidated "stack_prefix=${test_id}-consolidated" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/") &
(make config-examples-aem-stack-manager && make delete-stack-manager "stack_prefix=${test_id}-stack-manager" config_path=stage/user-config/aem-stack-manager/) &
wait
