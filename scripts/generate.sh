#!/bin/bash

declare -a arg_flags
jq_filters=.

# make sure the script works no matter where it is being invoked
# shellcheck disable=SC2086
pushd "$(dirname ${0})" > /dev/null
SCRIPTPATH="$(pwd)"
CFTMPLPATH="$SCRIPTPATH/../cloudformation"
popd > /dev/null

for cmd in $(python "$SCRIPTPATH"/yaml2json.py "$CFTMPLPATH"/ssm-commands-cloudformation.yaml | jq -r '.Resources | keys | .[]'); do
    json="$(python "$SCRIPTPATH"/yaml2json.py "$CFTMPLPATH"/ssm-commands/AEM-"${cmd}".yaml | jq -c .)"
    arg_flags+=( "--argjson" "$cmd" "${json}" )
    jq_filters="${jq_filters} | del(.Parameters.${cmd}IncludeFile) | .Resources.${cmd}.Properties.Content = \$${cmd}"
done

python "$SCRIPTPATH"/yaml2json.py "$CFTMPLPATH"/ssm-commands-cloudformation.yaml | jq "${arg_flags[@]}" "${jq_filters[@]}"
