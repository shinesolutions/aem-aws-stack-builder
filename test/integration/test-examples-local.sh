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
rm -rf modules/aem_curator/modules/aem_resources
cp -R modules/aem_resources modules/aem_curator/modules/aem_resources
make package "version=${test_id}"
aws s3 cp "stage/aem-aws-stack-provisioner-${test_id}.tar.gz" "s3://${s3_bucket}/library/"

#
# Create AEM Stack Managerfor integration test
#
echo "Create AEM Stack Manager"
cd "${workspace_dir}/aem-aws-stack-builder"
make config-examples-aem-stack-manager && make create-stack-manager "stack_prefix=${test_id}-stack-manager" config_path=stage/user-config/aem-stack-manager/

#
# Create AEM environments: an AEM Consolidated, and an AEM Full-Set
# with default configuration
#
echo "Create Stack for integration test with default configuration"
cd "${workspace_dir}/aem-aws-stack-builder"
rm -f "${integration_config_file}"
echo -e "library:\n  aem_aws_stack_provisioner_version: ${test_id}" > "${integration_config_file}"
echo -e "scheduled_jobs:\n  aem_orchestrator:\n    stack_manager_pair:\n        stack_prefix: ${test_id}-stack-manager" >> "${integration_config_file}"
make "config-examples-${aem_version}-${os_type}-full-set" && make create-full-set "stack_prefix=${test_id}-full-set" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/"
make "config-examples-${aem_version}-${os_type}-consolidated" && make create-consolidated "stack_prefix=${test_id}-consolidated" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/"

#
# Run Stack Manager Messenger integration tests
#
cd "${workspace_dir}/aem-stack-manager-messenger"
make test-consolidated \
  "stack_prefix=${test_id}-stack-manager" \
  "target_aem_stack_prefix=${test_id}-consolidated"
make test-full-set \
  "stack_prefix=${test_id}-stack-manager" \
  "target_aem_stack_prefix=${test_id}-full-set"

#
# Run AEM Test Suite integration tests
#
cd "${workspace_dir}/aem-test-suite"
make test-readiness-full-set "stack_prefix=${test_id}-full-set" config_path=conf/
make test-acceptance-full-set "stack_prefix=${test_id}-full-set" config_path=conf/
make test-recovery-full-set "stack_prefix=${test_id}-full-set" config_path=conf/
# placeholder security test for now, TODO: retrieve author, publish, and publish_dispatcher hosts
# make test-security config_path=conf/

#
# Delete all created AEM environments
#
cd "${workspace_dir}/aem-aws-stack-builder"
(make "config-examples-${aem_version}-${os_type}-full-set" && make delete-full-set "stack_prefix=${test_id}-full-set" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/") &
(make "config-examples-${aem_version}-${os_type}-consolidated" && make delete-consolidated "stack_prefix=${test_id}-consolidated" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/") &
wait

#
# Integration test for testing AEM Stack
# with enabled reconfiguration and
# enabled system users creation
#
echo "Create Stack for integration test with enabled reconfiguration and system users creation"
cd "${workspace_dir}/aem-aws-stack-builder"
rm -f "${integration_config_file}"
echo -e "reconfiguration:\n  enable_reconfiguration: true\n  enable_create_system_users: true\n  certs_base: s3://aem-opencloud/certs\n  keystore_password: changeit" >> "${integration_config_file}"
echo -e "library:\n  aem_aws_stack_provisioner_version: ${test_id}" >> "${integration_config_file}"
make "config-examples-${aem_version}-${os_type}-full-set" && make create-full-set "stack_prefix=${test_id}-reconf-user-created-full-set" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/"
make "config-examples-${aem_version}-${os_type}-consolidated" && make create-consolidated "stack_prefix=${test_id}-ruc-consolidated" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/"


# Run Stack Manager Messenger integration tests

cd "${workspace_dir}/aem-stack-manager-messenger"
make test-consolidated \
  "stack_prefix=${test_id}-stack-manager" \
  "target_aem_stack_prefix=${test_id}-ruc-consolidated"
make test-full-set \
  "stack_prefix=${test_id}-stack-manager" \
  "target_aem_stack_prefix=${test_id}-reconf-user-created-full-set"

#
# Run AEM Test Suite integration tests
#
cd "${workspace_dir}/aem-test-suite"
make test-readiness-full-set "stack_prefix=${test_id}-reconf-user-created-full-set" config_path=conf/
make test-acceptance-full-set "stack_prefix=${test_id}-reconf-user-created-full-set" config_path=conf/
# # placeholder security test for now, TODO: retrieve author, publish, and publish_dispatcher hosts
# # # make test-security config_path=conf/

#
# Delete all created AEM environments
# with enabled reconfiguration and
# enabled system users creation
#
echo "Create Stack for integration test with enabled reconfiguration and system users creation"
cd "${workspace_dir}/aem-aws-stack-builder"
(make "config-examples-${aem_version}-${os_type}-full-set" && make delete-full-set "stack_prefix=${test_id}-reconf-user-created-full-set" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/") &
(make "config-examples-${aem_version}-${os_type}-consolidated" && make delete-consolidated "stack_prefix=${test_id}-ruc-consolidated" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/") &
wait

#
# Integration test for testing AEM Stack
# with enabled reconfiguration and
# enabled system users password change
#
echo "Create Stack for integration test with enabled reconfiguration and system users password change"
cd "${workspace_dir}/aem-aws-stack-builder"
rm -f "${integration_config_file}"
echo -e "reconfiguration:\n  enable_reconfiguration: true\n  enable_create_system_users: false\n  certs_base: s3://aem-opencloud/certs\n  keystore_password: changeit" >> "${integration_config_file}"
echo -e "library:\n  aem_aws_stack_provisioner_version: ${test_id}" >> "${integration_config_file}"
make "config-examples-${aem_version}-${os_type}-full-set" && make create-full-set "stack_prefix=${test_id}-reconf-userpw-change-full-set" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/"
make "config-examples-${aem_version}-${os_type}-consolidated" && make create-consolidated "stack_prefix=${test_id}-ruch-con" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/"

#
# Run Stack Manager Messenger integration tests
#
cd "${workspace_dir}/aem-stack-manager-messenger"
make test-consolidated \
  "stack_prefix=${test_id}-stack-manager" \
  "target_aem_stack_prefix=${test_id}-ruch-con"
make test-full-set \
  "stack_prefix=${test_id}-stack-manager" \
  "target_aem_stack_prefix=${test_id}-reconf-userpw-change-full-set"

#
# Run AEM Test Suite integration tests
#
cd "${workspace_dir}/aem-test-suite"
make test-readiness-full-set "stack_prefix=${test_id}-reconf-userpw-change-full-set" config_path=conf/
make test-acceptance-full-set "stack_prefix=${test_id}-reconf-userpw-change-full-set" config_path=conf/
# placeholder security test for now, TODO: retrieve author, publish, and publish_dispatcher hosts
# # make test-security config_path=conf/

#
# Delete all created AEM environments
# with enabled reconfiguration and
# enabled system users password change
#
echo "Delete Stack for integration test with enabled reconfiguration and system users password change"
cd "${workspace_dir}/aem-aws-stack-builder"
(make "config-examples-${aem_version}-${os_type}-full-set" && make delete-full-set "stack_prefix=${test_id}-reconf-userpw-change-full-set" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/") &
(make "config-examples-${aem_version}-${os_type}-consolidated" && make delete-consolidated "stack_prefix=${test_id}-ruch-con" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/") &
wait

#
# Delete AEM Stack Manager
#
echo "Delete AEM Stack Manager"
cd "${workspace_dir}/aem-aws-stack-builder"
(make config-examples-aem-stack-manager && make delete-stack-manager "stack_prefix=${test_id}-stack-manager" config_path=stage/user-config/aem-stack-manager/) &
wait
