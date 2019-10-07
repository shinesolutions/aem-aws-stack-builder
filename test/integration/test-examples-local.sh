#!/usr/bin/env bash
set -o errexit

# This script is used for integration testing AEM environments using local
# repos, which allows the user to decide whether to use master or a feature
# branch that's being worked on for each of the repos.
# The repositories must be located at the same directory level.
# The AEM environments are created using examples user configurations.
# This script configures AEM AWS Stack Provisioner and AEM Stack Manager
# version dependencies to use the one that's genreated by deps-test-local.

if [[ "$#" -lt 1 ]] || [[ "$#" -gt 3 ]]; then
  echo "Usage: ${0} <test_id> [aem_version] [os_type]"
  exit 1
fi

test_id=$1
aem_version=${2:-aem64}
os_type=${3:-amazon-linux2}
integration_test_config_file=stage/user-config/zzz-test.yaml

echo "Running AEM AWS Stack Builder integration test with test_id: ${test_id}, aem_version: ${aem_version}, os_type: ${os_type}"

# Create integration test configuration for CDN testing
echo "Creating integration test configuration file..."
rm -f "${integration_test_config_file}"
echo -e "aws:\n  resources:\n    s3_bucket: ${test_id}-res" > "${integration_test_config_file}"

# Create CDN
cp "${integration_test_config_file}" "stage/user-config/cdn-sandpit/"
echo "Creating CDN..."
make create-cdn "stack_prefix=${test_id}-cdn" config_path=stage/user-config/cdn-sandpit/

# Delete CDN
echo "Deleting CDN..."
make delete-cdn "stack_prefix=${test_id}-cdn" config_path=stage/user-config/cdn-sandpit/

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
echo -e "library:\n  aem_aws_stack_provisioner_version: ${test_id}\n  aem_stack_manager_version: ${test_id}" > "${integration_test_config_file}"
echo -e "scheduled_jobs:\n  aem_orchestrator:\n    stack_manager_pair:\n        stack_prefix: ${test_id}-sm" >> "${integration_test_config_file}"

# Create AEM Stack Manager environment
echo "Creating AEM Stack Manager environment..."
make create-stack-manager "stack_prefix=${test_id}-sm" config_path=stage/user-config/aem-stack-manager-sandpit/

# Create, test, and delete AEM Consolidated environment
cp "${integration_test_config_file}" "stage/user-config/aem-consolidated-${os_type}-${aem_version}/"
echo "Configuring AEM Consolidated environment..."
make config "config_path=stage/user-config/aem-consolidated-${os_type}-${aem_version}/"
echo "Creating AEM Consolidated environment..."
cp -R stage/descriptors/consolidated/* stage/
make create-consolidated "stack_prefix=${test_id}-con" "config_path=stage/user-config/aem-consolidated-${os_type}-${aem_version}/"
echo "Testing AEM Consolidated environment with AEM Stack Manager Messenger events..."
cd stage/aem-stack-manager-messenger/ && make test-consolidated "stack_prefix=${test_id}-sm" "target_aem_stack_prefix=${test_id}-con" && cd ../../
echo "Deleting AEM Consolidated environment..."
make delete-consolidated "stack_prefix=${test_id}-con" "config_path=stage/user-config/aem-consolidated-${os_type}-${aem_version}/"

# Create, test, and delete AEM Full-Set environment
cp "${integration_test_config_file}" "stage/user-config/aem-full-set-${os_type}-${aem_version}/"
echo "Configuring AEM Full-Set environment..."
make config "config_path=stage/user-config/aem-full-set-${os_type}-${aem_version}/"
echo "Creating AEM Full-Set environment..."
cp -R stage/descriptors/full-set/* stage/
make create-full-set "stack_prefix=${test_id}-fs" "config_path=stage/user-config/aem-full-set-${os_type}-${aem_version}/"
echo "Testing AEM Full-Set environment with AEM Stack Manager Messenger events..."
cd stage/aem-stack-manager-messenger/ && make test-full-set "stack_prefix=${test_id}-sm" "target_aem_stack_prefix=${test_id}-fs" && cd ../../
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
