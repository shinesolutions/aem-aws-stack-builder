#!/bin/bash -eu

error() {
  cat <<< "$@" 1>&2;
  exit 1
}

if which jq > /dev/null; then
  have_jq=true
else
  have_jq=false
fi

echo "Stack prefix: ${STACK_PREFIX:?You must set the STACK_PREFIX environment variable}"
echo "Output S3 bucket name: ${OUTPUT_S3_BUCKET_NAME:=mb-aem-opencloud}"
echo "Output S3 key prefix: ${OUTPUT_S3_KEY_PREFIX:=${STACK_PREFIX}/run-command-output/}"

DISPATCHER_TYPE="${1:-publish-dispatcher}"
echo "Dispatcher type: ${DISPATCHER_TYPE}"

INSTANCE_IDS=( $(
  aws ec2 describe-instances \
    --filters \
      "Name=tag:StackPrefix,Values=${STACK_PREFIX}" \
      "Name=tag:Component,Values=${DISPATCHER_TYPE}" \
      "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text
) )
INSTANCE_COUNT=${#INSTANCE_IDS[@]}

if [[ ${INSTANCE_COUNT} -eq 0 ]]; then
  error "No intances found matching StackPrefix=${STACK_PREFIX} and Component=${DISPATCHER_TYPE}"
fi

PARAMETER_FILE=$(mktemp "XXXXXXXXXXXX")
OUTPUT_FILE=$(mktemp "XXXXXXXXXXXX")

cat > "${PARAMETER_FILE}" << PARAMETERS
{
  "commands": [
    "bash -l -c 'curl -sv \\\",
    "-H \"CQ-Action: DELETE\" \\\",
    "-H \"CQ-Handle: /\" \\\",
    "-H \"Content-Length: 0\" \\\",
    "-H \"Content-Type: application/octet-stream\" \\\",
    "http://127.0.0.1:80/dispatcher/invalidate.cache'"
  ]
}
PARAMETERS

aws ssm send-command \
  --document-name AWS-RunShellScript \
  --instance-ids "${INSTANCE_IDS[@]}" \
  --parameters file://"${PARAMETER_FILE}" \
  --output-s3-bucket-name "${OUTPUT_S3_BUCKET_NAME}" \
  --output-s3-key-prefix "${OUTPUT_S3_KEY_PREFIX}" \
  > "${OUTPUT_FILE}"

if ${have_jq}; then
  jq . < "${OUTPUT_FILE}"
  COMMAND_ID=$(< "${OUTPUT_FILE}" jq -r .Command.CommandId)
else
  python -m json.tool "${OUTPUT_FILE}"
  COMMAND_ID=$(< "${OUTPUT_FILE}" python -c 'import sys,json; print json.load(sys.stdin).get("Command", {}).get("CommandId", "")')
fi

rm "${OUTPUT_FILE}" "${PARAMETER_FILE}"

have_status() {
  STATUS_TO_CHECK="${1}"; shift
  STATUSES=( "${@}" )
  for STATUS in "${STATUSES[@]}"; do
    if [[ "${STATUS}" == "${STATUS_TO_CHECK}" ]]; then
      return 0
    fi
  done
  return 1
}

while true; do
  OUTPUT_FILE=$(mktemp "XXXXXXXXXXXX")
  aws ssm list-command-invocations \
    --command-id "${COMMAND_ID}" \
    > "${OUTPUT_FILE}"

  if ${have_jq}; then
    jq . < "${OUTPUT_FILE}"
    STATUSES=( $(< "${OUTPUT_FILE}" jq -r .CommandInvocations[].Status | sort -u) )
  else
    python -m json.tool "${OUTPUT_FILE}"
    STATUSES=( $(< "${OUTPUT_FILE}" python -c 'import sys,json; print "\n".join(map(lambda x: x.get("Status"), json.load(sys.stdin).get("CommandInvocations", [])))' | sort -u) )
  fi
  rm "${OUTPUT_FILE}"

  if ! ( have_status InProgress "${STATUSES[@]}" -o have_status Pending "${STATUSES[@]}" ); then
    echo "Commands completed on ${INSTANCE_COUNT} instances."
    if have_status Failed "${STATUSES[@]}"; then
      error "One or more commands failed."
    fi
    exit 0
  fi
  sleep 2
done
