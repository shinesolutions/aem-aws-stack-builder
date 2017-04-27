#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -lt 4 ]; then
  echo 'Usage: ./stack-init.sh <data_bucket_name> <stack_prefix> <component> <aem_aws_stack_provisioner_version> [local_yaml_file]'
  exit 1
fi

data_bucket_name=$1
stack_prefix=$2
component=$3
aem_aws_stack_provisioner_version=$4

PATH=$PATH:/opt/puppetlabs/bin

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

run_custom_stage() {
  stage=${1}
  custom_stack_provisioner_dir=/opt/shinesolutions/aem-custom-stack-provisioner
  script=${custom_stack_provisioner_dir}/${stage}.sh
  if [ -x "${script}" ]; then
    echo "Execute the ${stage} custom provisioning script..."
    cd ${custom_stack_provisioner_dir} && ${script} "${stack_prefix}" "${component}"
  fi
}

echo "Initialising AEM Stack Builder provisioning..."

aws --version
puppet --version
python --version
ruby --version

if aws s3api head-object --bucket "${data_bucket_name}" --key "${stack_prefix}/aem-custom-stack-provisioner.tar.gz"; then
  echo "Downloading AEM Stack Custom Provisioner..."
  download_provisioner /opt/shinesolutions/aem-custom-stack-provisioner aem-custom-stack-provisioner.tar.gz
fi

echo "Downloading AEM Stack Provisioner..."
download_provisioner /opt/shinesolutions/aem-aws-stack-provisioner "aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar.gz"

run_custom_stage pre-common

cd /opt/shinesolutions/aem-aws-stack-provisioner

if [ "$#" -eq 5 ]; then
  local_yaml_file=$5
  local_yaml_path="${PWD}/data/local.yaml"
  if [[ -e ${local_yaml_path} ]]; then
    echo "WARNING: ${local_yaml_path} exists and will be overwritten."
    echo "Previous contents:"
    cat "${local_yaml_path}"
    echo "New contents:"
    cat "${local_yaml_file}"
  fi
  cp "${local_yaml_file}" "${local_yaml_path}"
fi

export FACTER_data_bucket_name="${data_bucket_name}"
export FACTER_stack_prefix="${stack_prefix}"

echo "Applying common Puppet manifest for all components..."
puppet apply \
  --logdest /var/log/puppet-stack-init.log \
  --modulepath modules \
  --hiera_config conf/hiera.yaml \
  manifests/common.pp

echo "Checking orchestration tags for ${component} component..."
/opt/shinesolutions/aws-tools/wait_for_ec2tags.py "$component"

echo "Setting AWS resources as Facter facts..."
/opt/shinesolutions/aws-tools/set-facts.sh "${data_bucket_name}" "${stack_prefix}"

echo "Applying Puppet manifest for ${component} component..."
puppet apply \
  --logdest /var/log/puppet-stack-init.log \
  --modulepath modules \
  --hiera_config conf/hiera.yaml \
  "manifests/${component}.pp"

run_custom_stage post-common

cd /opt/shinesolutions/aem-aws-stack-provisioner/

echo "Testing ${component} component using Serverspec..."
cd test/serverspec && rake spec "SPEC=spec/${component}_spec.rb"

echo "Cleaning up provisioner temp directory..."
rm -rf /tmp/shinesolutions/aem-aws-stack-provisioner/*
