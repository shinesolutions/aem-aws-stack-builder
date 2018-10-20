#!/usr/bin/env bash
set -o errexit

# This script is used for integration testing AEM environments using local
# repos, which allows the user to decide whether to use master or a feature
# branch that's being worked on for each of the repos.
# The repositories must be located at the same directory level.
# The AEM environments are created using examples user configurations.

if [[ "$#" -lt 1 ]] || [[ "$#" -gt 3 ]]; then
  echo "Usage: ${0} <test_id> [aem_version] [os_type]"
  exit 1
fi

test_id=$1
aem_version=${2:-aem64}
os_type=${3:-rhel7}
s3_bucket=aem-opencloud
integration_config_file=examples/user-config/common/zzz-test.yaml
workspace_dir=..

# Download dependencies and run lint checks
cd "${workspace_dir}/puppet-aem-resources" && make clean deps lint
cd "${workspace_dir}/puppet-aem-curator" && make clean deps lint
cd "${workspace_dir}/puppet-aem-orchestrator" && make clean deps lint
cd "${workspace_dir}/aem-aws-stack-provisioner" && make clean deps lint
cd "${workspace_dir}/aem-aws-stack-builder" && make clean deps lint
cd "${workspace_dir}/aem-stack-manager-cloud" && make clean deps lint
cd "${workspace_dir}/aem-stack-manager-messenger" && make clean deps lint
cd "${workspace_dir}/aem-test-suite" && make clean deps lint

# Build AEM AWS Stack Provisioner and upload it to S3
cd "${workspace_dir}/aem-aws-stack-provisioner"
rm -rf modules/aem_resources/*
rm -rf modules/aem_curator/*
rm -rf modules/aem_orchestrator/*
cp -R ${workspace_dir}/puppet-aem-resources/* modules/aem_resources/
cp -R ${workspace_dir}/puppet-aem-curator/* modules/aem_curator/
cp -R ${workspace_dir}/puppet-aem-orchestrator/* modules/aem_orchestrator/
make package "version=${test_id}"
aws s3 cp "stage/aem-aws-stack-provisioner-${test_id}.tar.gz" "s3://${s3_bucket}/library/"

# Build AEM Stack Manager Cloud and upload it to S3
cd "${workspace_dir}/aem-stack-manager-cloud"
make package "version=${test_id}"
aws s3 cp "stage/aem-stack-manager-cloud-${test_id}.zip" "s3://${s3_bucket}/library/"

# Create AEM environments: a Stack Manager, an AEM Consolidated, and an AEM Full-Set
cd "${workspace_dir}/aem-aws-stack-builder"
rm -f "${integration_config_file}"
echo -e "library:\n  aem_aws_stack_provisioner_version: ${test_id}\n  aem_stack_manager_version: ${test_id}" > "${integration_config_file}"
echo -e "scheduled_jobs:\n  aem_orchestrator:\n    stack_manager_pair:\n        stack_prefix: ${test_id}-sm" >> "${integration_config_file}"
make config-examples-aem-stack-manager && make create-stack-manager "stack_prefix=${test_id}-sm" config_path=stage/user-config/aem-stack-manager/
make "config-examples-${aem_version}-${os_type}-full-set" && make create-full-set "stack_prefix=${test_id}-fs" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/"
make "config-examples-${aem_version}-${os_type}-consolidated" && make create-consolidated "stack_prefix=${test_id}-con" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/"

# Run Stack Manager Messenger integration tests
cd "${workspace_dir}/aem-stack-manager-messenger"
make test-consolidated \
  "stack_prefix=${test_id}-sm" \
  "target_aem_stack_prefix=${test_id}-con"
make test-full-set \
  "stack_prefix=${test_id}-sm" \
  "target_aem_stack_prefix=${test_id}-fs"

# Run AEM Test Suite integration tests
cd "${workspace_dir}/aem-test-suite"
make test-readiness-full-set "stack_prefix=${test_id}-fs" config_path=conf/
make test-acceptance-full-set "stack_prefix=${test_id}-fs" config_path=conf/
make test-recovery-full-set "stack_prefix=${test_id}-fs" config_path=conf/
# placeholder security test for now, TODO: retrieve author, publish, and publish_dispatcher hosts
# make test-security config_path=conf/

# Delete all created AEM environments
cd "${workspace_dir}/aem-aws-stack-builder"
(make "config-examples-${aem_version}-${os_type}-full-set" && make delete-full-set "stack_prefix=${test_id}-fs" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/") &
(make "config-examples-${aem_version}-${os_type}-consolidated" && make delete-consolidated "stack_prefix=${test_id}-con" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/") &
(make config-examples-aem-stack-manager && make delete-stack-manager "stack_prefix=${test_id}-sm" config_path=stage/user-config/aem-stack-manager/) &
wait
