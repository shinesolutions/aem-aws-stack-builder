#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: ./delete-aem-stacks.sh <stack_prefix> [config_path]'
  exit 1
fi

stack_prefix=$1
config_path=$2

delete_single_stack() {
  ./scripts/delete-stack.sh "$1" "$stack_prefix" "$config_path"
}

delete_multi_stacks() {
  export -f delete_single_stack
  # intentional word split for passing multiple stack types
  # shellcheck disable=2086
  parallel delete_single_stack ::: $1
}

echo "Deleting $stack_prefix AEM stacks..."
delete_single_stack "apps/dns-records"
delete_multi_stacks "apps/chaos-monkey apps/orchestrator apps/author-dispatcher apps/publish-dispatcher apps/publish apps/author"
delete_multi_stacks "apps/messaging apps/security-groups"
delete_single_stack "apps/stack-data"
echo "Finished deleting $stack_prefix AEM stacks"
