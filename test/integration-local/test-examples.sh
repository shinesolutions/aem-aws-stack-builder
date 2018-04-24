#!/usr/bin/env bash
set -o errexit

test_id=$1

# download dependencies and run lint checks
cd ../puppet-aem-resources
make clean deps lint
cd ../puppet-aem-curator
make clean deps lint
cd ../aem-aws-stack-provisioner
make clean deps lint
cd ../aem-aws-stack-builder
make clean deps lint
cd ../aem-stack-manager-messenger
make clean deps lint

# prepare AEM AWS Stack Provisioner
cd ../aem-aws-stack-provisioner
rm -rf modules/aem_resources/*
rm -rf modules/aem_curator/*
cp -R ../puppet-aem-resources/* modules/aem_resources/
cp -R ../puppet-aem-curator/* modules/aem_curator/
make package "version=${test_id}"
aws s3 cp "stage/aem-aws-stack-provisioner-${test_id}.tar.gz" s3://aem-stack-builder/library/

# create AEM environments
cd ../aem-aws-stack-builder
echo -e "library:\n  aem_aws_stack_provisioner_version: ${test_id}" > examples/user-config/common/zzz-test-integration-local.yaml
make create-stack-manager "stack_prefix=${test_id}-stack-manager" config_path=examples/user-config/aem-stack-manager/
make config-examples-aem62-rhel7-full-set
make create-full-set "stack_prefix=${test_id}-full-set" config_path=stage/user-config/aem62_sp1_cfp13-rhel7-full-set/
make config-examples-aem62-rhel7-consolidated
make create-consolidated "stack_prefix=${test_id}-consolidated" config_path=stage/user-config/aem62_sp1_cfp13-rhel7-consolidated/

# run integration tests on Stack Manager Messenger
cd ../aem-stack-manager-messenger
make test-full-set \
  "stack_prefix=${test_id}-stack-manager" \
  "target_aem_stack_prefix=${test_id}-full-set"
# make test-consolidated \
#   "stack_prefix=${test_id}-stack-manager" \
#   "target_aem_stack_prefix=${test_id}-consolidated"

# delete AEM environments
cd ../aem-aws-stack-builder
make config-examples-aem62-rhel7-full-set
make delete-full-set "stack_prefix=${test_id}-full-set" config_path=stage/user-config/aem62_sp1_cfp13-rhel7-full-set/
make config-examples-aem62-rhel7-consolidated
make delete-consolidated "stack_prefix=${test_id}-consolidated" config_path=stage/user-config/aem62_sp1_cfp13-rhel7-consolidated/
make delete-stack-manager "stack_prefix=${test_id}-stack-manager" config_path=examples/user-config/aem-stack-manager/
