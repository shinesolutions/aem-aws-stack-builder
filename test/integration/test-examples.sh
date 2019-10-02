#!/usr/bin/env bash
set -o errexit

# This script is used for integration testing AEM environments using
# the configured libraries versions.
# The AEM environments are created using examples user configurations.

if [[ "$#" -lt 1 ]] || [[ "$#" -gt 3 ]]; then
  echo "Usage: ${0} <test_id> [aem_version] [os_type]"
  exit 1
fi

test_id=$1
aem_version=${2:-aem64}
os_type=${3:-amazon-linux2}
integration_test_config_file=stage/user-config/zzz-test.yaml

echo "Running AEM AWS Stack Builder integration test with test_id: ${test_id}, aem_version: ${aem_version}, os_type: ${os_type}"

# Create integration test configuration for AWS resources testing
# Note that the AWS resources testing is specifically for testing the AWS resources creation
# they are not yet used by the AEM environments creation testing further below.
echo "Creating integration test configuration file..."
rm -f "${integration_test_config_file}"
echo -e "aws:\n  resources:\n    s3_bucket: ${test_id}-res" > "${integration_test_config_file}"

# Create AWS resources
cp "${integration_test_config_file}" "stage/user-config/aws-resources-sandpit/"
echo "Creating AWS resources..."
make create-aws-resources "stack_prefix=${test_id}-res" config_path=stage/user-config/aws-resources-sandpit/

# Delete AWS resources
echo "Deleting AWS resources..."
make delete-aws-resources "stack_prefix=${test_id}-res" config_path=stage/user-config/aws-resources-sandpit/

# Create integration test configuration for AEM environments testing
echo "Creating integration test configuration file..."
rm -f "${integration_test_config_file}"
echo -e "scheduled_jobs:\n  aem_orchestrator:\n    stack_manager_pair:\n        stack_prefix: ${test_id}-sm" > "${integration_test_config_file}"

# Create AEM Stack Manager environment
echo "Creating AEM Stack Manager environment..."
make create-stack-manager "stack_prefix=${test_id}-sm" config_path=stage/user-config/aem-stack-manager-sandpit/

# Provision test DNS records, needed for switch-dns testing against AEM Consolidated and AEM Full-Set environments
./test/integration/fixtures/provision-test-dns-batch.sh "${test_id}"

# Create, test, and delete AEM Consolidated environment
cp "${integration_test_config_file}" "stage/user-config/aem-consolidated-${os_type}-${aem_version}/"
echo "Creating AEM Consolidated environment..."
cp -R stage/descriptors/consolidated/* stage/
make create-consolidated "stack_prefix=${test_id}-con" "config_path=stage/user-config/aem-consolidated-${os_type}-${aem_version}/"
echo "Testing AEM Consolidated environment with AEM Stack Manager Messenger events..."
cd stage/aem-stack-manager-messenger/ && make test-consolidated "stack_prefix=${test_id}-sm" "target_aem_stack_prefix=${test_id}-con" && cd ../../
echo "Testing DNS switching to point to AEM Consolidated environment..."
make switch-dns-consolidated config_path=stage/user-config/aws-resources-sandpit/ "stack_prefix=${test_id}-con" author_publish_dispatcher_hosted_zone=aemopencloud.cms "author_publish_dispatcher_record_set=${test_id}-apd-con"
echo "Deleting AEM Consolidated environment..."
make delete-consolidated "stack_prefix=${test_id}-con" "config_path=stage/user-config/aem-consolidated-${os_type}-${aem_version}/"

# Create, test, and delete AEM Full-Set environment
cp "${integration_test_config_file}" "stage/user-config/aem-full-set-${os_type}-${aem_version}/"
echo "Creating AEM Full-Set environment..."
cp -R stage/descriptors/full-set/* stage/
make create-full-set "stack_prefix=${test_id}-fs" "config_path=stage/user-config/aem-full-set-${os_type}-${aem_version}/"
echo "Testing AEM Full-Set environment with AEM Stack Manager Messenger events..."
cd stage/aem-stack-manager-messenger/ && make test-full-set "stack_prefix=${test_id}-sm" "target_aem_stack_prefix=${test_id}-fs" && cd ../../
echo "Testing DNS switching to point to AEM Full-Set environment..."
make switch-dns-full-set config_path=stage/user-config/aws-resources-sandpit/ "stack_prefix=${test_id}-con" publish_dispatcher_hosted_zone=aemopencloud.space "publish_dispatcher_record_set=${test_id}-pd-fs" author_dispatcher_hosted_zone=aemopencloud.cms "author_dispatcher_record_set=${test_id}-ad-fs"
# TODO: temporarily disable aem-test-suite testing to allow CodeBuild to pass
#       will re-enable when InSpec already upgrades aws-sdk sub dependency to version 3.x
# echo "Testing AEM Full-Set environment readiness with AEM Test Suite..."
# cd /stage/aem-test-suite/ && make test-readiness-full-set "stack_prefix=${test_id}-fs" config_path=conf/ && cd ../../
# echo "Testing AEM Full-Set environment acceptance with AEM Test Suite..."
# cd /stage/aem-test-suite/ && make test-acceptance-full-set "stack_prefix=${test_id}-fs" config_path=conf/ && cd ../../
# echo "Testing AEM Full-Set environment recovery with AEM Test Suite..."
# cd /stage/aem-test-suite/ && make test-recovery-full-set "stack_prefix=${test_id}-fs" config_path=conf/ && cd ../../
echo "Deleting AEM Full-Set environment..."
make delete-full-set "stack_prefix=${test_id}-fs" "config_path=stage/user-config/aem-full-set-${os_type}-${aem_version}/"

# Delete AEM Stack Manager
echo "Deleting AEM Stack Manager environment..."
make delete-stack-manager "stack_prefix=${test_id}-sm" config_path=stage/user-config/aem-stack-manager-sandpit/
