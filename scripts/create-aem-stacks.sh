#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -le 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: ./create-aem-stacks.sh <stack_prefix> [config_path]'
  exit 1
fi

stack_prefix=$1
config_path=$2

create_single_stack() {
  ./scripts/create-stack.sh "$1" "$stack_prefix" "$config_path"
}

create_multi_stacks() {
  export -f create_single_stack
  # intentional word split for passing multiple stack types
  # shellcheck disable=2086
  parallel create_single_stack ::: $1
}

echo "Start creating $stack_prefix AEM stacks..."
create_single_stack "apps/stack-data"
create_multi_stacks "apps/security-groups apps/messaging"
create_multi_stacks "apps/author apps/publish apps/publish-dispatcher apps/author-dispatcher apps/orchestrator apps/chaos-monkey"
create_single_stack "apps/dns-records"
echo "Finished creating $stack_prefix AEM stacks"
