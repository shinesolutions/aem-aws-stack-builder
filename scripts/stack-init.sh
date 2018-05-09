#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -lt 4 ]; then
  echo 'Usage: ./stack-init.sh <data_bucket_name> <stack_prefix> <component> <aem_aws_stack_provisioner_version> [extra_local_yaml_path]'
  exit 1
fi

data_bucket_name=$1
stack_prefix=$2
component=$3
aem_aws_stack_provisioner_version=$4

aws_provisioner_dir=/opt/shinesolutions/aem-aws-stack-provisioner
custom_provisioner_dir=/opt/shinesolutions/aem-custom-stack-provisioner
tmp_dir=/tmp/shinesolutions/aem-aws-stack-provisioner

PATH=/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:$PATH

# Download stack provisioner artifacts from S3.
download_provisioner() {
  dest_dir=$1
  s3_object_name=$2
  mkdir -p "${dest_dir}"
  pushd "${dest_dir}"
  aws s3 cp "s3://${data_bucket_name}/${stack_prefix}/${s3_object_name}" .
  tar -xzvf "${s3_object_name}"
  rm "${s3_object_name}"
  chown -R root:root .
  popd
}

# Execute a stage (e.g. pre-common, post-common) on custom stack provisioner.
# The two stages are available to allow users to execute their provisioning
# before and after AEM provisioning.
run_custom_stage() {
  stage=${1}
  script=${custom_provisioner_dir}/${stage}.sh
  if [ -x "${script}" ]; then
    echo "Executing the ${stage} script of Custom Stack Provisioner..."
    cd ${custom_provisioner_dir} && ${script} "${stack_prefix}" "${component}"
  else
    echo "${stage} script of Custom Stack Provisioner is either not provided or not executable..."
  fi
}

# Translate puppet detailed exit codes to basic convention 0 to indicate success.
# More info on Puppet --detailed-exitcodes https://puppet.com/docs/puppet/5.3/man/agent.html
translate_puppet_exit_code() {

  exit_code="$1"

  # 0 (success) and 2 (success with changes) are considered as success.
  # Everything else is considered to be a failure.
  if [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 2 ]; then
    exit_code=0
  else
    exit "$exit_code"
  fi

  return "$exit_code"
}

echo "Initialising AEM Stack Builder provisioning..."

# List down version numbers of utility tools
echo "AWS CLI version: $(aws --version)"
echo "Facter version: $(facter --version)"
echo "Hiera version: $(hiera --version)"
echo "Puppet version: $(puppet --version)"
echo "Python version: $(python --version)"
echo "Ruby version: $(ruby --version)"

if aws s3api head-object --bucket "${data_bucket_name}" --key "${stack_prefix}/aem-custom-stack-provisioner.tar.gz"; then
  echo "Downloading Custom Stack Provisioner..."
  download_provisioner "${custom_provisioner_dir}" aem-custom-stack-provisioner.tar.gz
else
  echo "No Custom Stack Provisioner provided..."
fi

echo "Downloading AEM Stack Provisioner..."
download_provisioner "${aws_provisioner_dir}" "aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar.gz"

run_custom_stage pre-common

cd "${aws_provisioner_dir}"

if [[ -d data ]]; then
  echo "Downloading custom configuration..."
  aws s3 sync "s3://${data_bucket_name}/${stack_prefix}/data/" data/
  aws s3 sync "s3://${data_bucket_name}/${stack_prefix}/conf/" conf/
fi

# When extra_local.yaml file is provided, the configuration in that file will
# be appended to the configured local.yaml provisioned using stack-provisioner-hieradata.j2 template
if [ "$#" -eq 5 ]; then
  extra_local_yaml_path=$5
  local_yaml_path="${PWD}/data/local.yaml"
  echo "Adding extra configuration at ${extra_local_yaml_path} to local AEM Stack Provisioner configuration at ${local_yaml_path}..."
  sed -e 's/^[[:space:]]*//' < "${extra_local_yaml_path}" >> "${local_yaml_path}"
fi

echo "Downloading custom Facter facts..."
mkdir -p /opt/puppetlabs/facts/facts.d
aws s3 cp "s3://${data_bucket_name}/${stack_prefix}/stack-facts.txt" /opt/puppetlabs/facter/facts.d/stack-facts.txt

export FACTER_data_bucket_name="${data_bucket_name}"
export FACTER_stack_prefix="${stack_prefix}"

set +o errexit

echo "Applying pre-common Puppet manifest for all components..."
puppet apply \
  --detailed-exitcodes \
  --logdest /var/log/puppet-stack-init.log \
  --modulepath modules \
  --hiera_config conf/hiera.yaml \
  manifests/pre-common.pp

translate_puppet_exit_code "$?"

set -o errexit

echo "Checking orchestration tags for ${component} component..."
/opt/shinesolutions/aws-tools/wait_for_ec2tags.py "$component"

echo "Setting AWS resources as Facter facts..."
/opt/shinesolutions/aws-tools/set-facts.sh "${data_bucket_name}" "${stack_prefix}"

set +o errexit

echo "Applying Puppet manifest for ${component} component..."
puppet apply \
  --detailed-exitcodes \
  --logdest /var/log/puppet-stack-init.log \
  --modulepath modules \
  --hiera_config conf/hiera.yaml \
  "manifests/${component}.pp"

translate_puppet_exit_code "$?"

set -o errexit

set +o errexit

echo "Applying action_scheduled_jobs Puppet manifest for all components..."
puppet apply \
  --detailed-exitcodes \
  --logdest /var/log/puppet-stack-init.log \
  --modulepath modules \
  --hiera_config conf/hiera.yaml \
  manifests/action-scheduled-jobs.pp

translate_puppet_exit_code "$?"

set -o errexit

run_custom_stage post-common

echo "Testing ${component} component using InSpec..."
cd "${aws_provisioner_dir}/test/inspec"
HOME=/root inspec exec "${component}_spec.rb"

echo "Cleaning up provisioner temp directory..."
rm -rf "${tmp_dir:?}/*"
