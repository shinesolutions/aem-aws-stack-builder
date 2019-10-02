#!/usr/bin/env bash
set -o errexit

# This script ensures that the following DNS records would be created if they don't already exist:
# - an Author-Publish-Dispatcher record having the format test_id-sm
# - a Publish-Dispatcher record having the format test_id-publish-dispatcher-fs
# - an Author-Dispatcher having the format test_id-author-dispatcher-fs
# Note: the existence of the DNS records is a pre-condition of running switch DNS

if [[ "$#" -lt 1 ]] || [[ "$#" -gt 1 ]]; then
  echo "Usage: ${0} <test_id>"
  exit 1
fi

test_id=$1

author_publish_dispatcher_hosted_zone=aemopencloud.cms.
publish_dispatcher_hosted_zone=aemopencloud.space.
author_dispatcher_hosted_zone=aemopencloud.cms.

ensure_dns_exist()
{
  test_id=$1
  component=$2
  hosted_zone=$3
  record_set_suffix=$4
  hosted_zone_id=$(aws route53 list-hosted-zones-by-name --output text --query "HostedZones[?Name == '${hosted_zone}'].[Id][0][0]" | sed 's/\/hostedzone\///g')
  echo "Using ${component} hosted zone id: ${hosted_zone_id}"
  cat ./test/integration/fixtures/switch-dns.json.template | sed "s/record_set_name/${test_id}-${record_set_suffix}.${hosted_zone}/g" > "stage/switch-dns-${record_set_suffix}.json"
  aws route53 change-resource-record-sets --hosted-zone-id "${hosted_zone_id}" --change-batch "file://stage/switch-dns-${record_set_suffix}.json"
}

ensure_dns_exist "${test_id}" "Author-Publish-Dispatcher" "${author_publish_dispatcher_hosted_zone}" "apd-con"
ensure_dns_exist "${test_id}" "Publish-Dispatcher" "${publish_dispatcher_hosted_zone}" "pd-fs"
ensure_dns_exist "${test_id}" "Author-Dispatcher" "${author_dispatcher_hosted_zone}" "ad-fs"
