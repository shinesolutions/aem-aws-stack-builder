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


multi_stack_simple() {
  stats_file="/tmp/$(date +%Y%m%d%H%M%S)"
  touch "$stats_file"

  for stack in $1
  do
    create_single_stack "$stack" || echo 1 >> "$stats_file" &
  done
  wait

  RC=0
  while read -r line; do
    RC=$((RC+line))
  done < "$stats_file"
  rm -f $stats_file

  return $RC
}


multi_stack_parallel() {
  export -f create_single_stack
  parallel --joblog logs/"create-aem-stacks-$(date +%Y%m%d%H%M%S)" create_single_stack ::: $1
}

create_multi_stacks() {

  hash parallel 2>/dev/null

  if [ $? -eq 0 ]; then
    multi_stack_parallel "$1"
  else
    multi_stack_simple "$1"
  fi

}

echo "Start creating $stack_prefix AEM stacks..."
create_single_stack "apps/stack-data"
create_multi_stacks "apps/security-groups apps/messaging"
create_multi_stacks "apps/author apps/publish apps/publish-dispatcher apps/author-dispatcher apps/orchestrator apps/chaos-monkey"
create_single_stack "apps/dns-records"
echo "Finished creating $stack_prefix AEM stacks"
