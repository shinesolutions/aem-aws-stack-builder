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
aem_version=${2:-aem63}
os_type=${3:-rhel7}
integration_config_file=examples/user-config/common/zzz-test.yaml
aem_stack_manager_messenger_version=1.5.6
# aem_test_suite_version=0.9.8
workspace_dir=$(pwd)

# Create AEM environments: a Stack Manager, an AEM Consolidated, and an AEM Full-Set
rm -f "${integration_config_file}"
echo -e "scheduled_jobs:\n  aem_orchestrator:\n    stack_manager_pair:\n        stack_prefix: ${test_id}-sm" > "${integration_config_file}"
make config-examples-aem-stack-manager && make create-stack-manager "stack_prefix=${test_id}-sm" config_path=stage/user-config/aem-stack-manager/
make "config-examples-${aem_version}-${os_type}-full-set" && make create-full-set "stack_prefix=${test_id}-fs" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/"
make "config-examples-${aem_version}-${os_type}-consolidated" && make create-consolidated "stack_prefix=${test_id}-con" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/"

# Download Stack Manager Messenger and resolve dependencies
cd "${workspace_dir}"
wget "https://github.com/shinesolutions/aem-stack-manager-messenger/releases/download/${aem_stack_manager_messenger_version}/aem-stack-manager-messenger-${aem_stack_manager_messenger_version}.tar.gz" --directory-prefix=stage
mkdir -p "stage/aem-stack-manager-messenger-${aem_stack_manager_messenger_version}"
tar -xvzf "stage/aem-stack-manager-messenger-${aem_stack_manager_messenger_version}.tar.gz" --directory "stage/aem-stack-manager-messenger-${aem_stack_manager_messenger_version}"
cd "${workspace_dir}/stage/aem-stack-manager-messenger-${aem_stack_manager_messenger_version}"
make deps

# Run integration tests via Stack Manager Messenger
make test-consolidated \
  "stack_prefix=${test_id}-sm" \
  "target_aem_stack_prefix=${test_id}-con"
make test-full-set \
  "stack_prefix=${test_id}-sm" \
  "target_aem_stack_prefix=${test_id}-fs"

# TODO: temporarily disable aem-test-suite testing to allow CodeBuild to pass
#       will re-enable when we've improved buildspec for CodeBuild, and this script
#       can return to be used by developers only, or aws-sdk is upgraded to 3.x.x
# # Download AEM Test Suite and resolve dependencies
# cd "${workspace_dir}"
# wget "https://github.com/shinesolutions/aem-test-suite/releases/download/${aem_test_suite_version}/aem-test-suite-${aem_test_suite_version}.tar.gz" --directory-prefix=stage
# mkdir -p "stage/aem-test-suite-${aem_test_suite_version}"
# tar -xvzf "stage/aem-test-suite-${aem_test_suite_version}.tar.gz" --directory "stage/aem-test-suite-${aem_test_suite_version}"
# cd "${workspace_dir}/stage/aem-test-suite-${aem_test_suite_version}"
# make deps
#
# # Run AEM Test Suite integration tests
# cd "${workspace_dir}/stage/aem-test-suite-${aem_test_suite_version}"
# make test-readiness-full-set "stack_prefix=${test_id}-fs" config_path=conf/
# make test-acceptance-full-set "stack_prefix=${test_id}-fs" config_path=conf/
# make test-recovery-full-set "stack_prefix=${test_id}-fs" config_path=conf/

# placeholder security test for now, TODO: retrieve author, publish, and publish_dispatcher hosts
# make test-security config_path=conf/

# Delete all created AEM environments
cd "${workspace_dir}"
make deps
(make "config-examples-${aem_version}-${os_type}-full-set" && make delete-full-set "stack_prefix=${test_id}-fs" "config_path=stage/user-config/${aem_version}-${os_type}-full-set/") &
(make "config-examples-${aem_version}-${os_type}-consolidated" && make delete-consolidated "stack_prefix=${test_id}-con" "config_path=stage/user-config/${aem_version}-${os_type}-consolidated/") &
(make config-examples-aem-stack-manager && make delete-stack-manager "stack_prefix=${test_id}-sm" config_path=stage/user-config/aem-stack-manager/) &
wait
