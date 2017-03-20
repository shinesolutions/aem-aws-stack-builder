#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -ne 4 ]; then
  echo 'Usage: ./stack-init.sh <data_bucket_name> <stack_prefix> <component> <aem_aws_stack_provisioner_version>'
  exit 1
fi

data_bucket_name=$1
stack_prefix=$2
component=$3
aem_aws_stack_provisioner_version=$4
PATH=$PATH:/opt/puppetlabs/bin

echo "Initialising AEM Stack Builder provisioning..."

aws --version
puppet --version
python --version
ruby --version

if aws s3 ls "s3://${data_bucket_name}/${stack_prefix}/" | grep aem-custom-stack-provisioner.tar.gz
then

    echo "Downloading AEM Stack Custom Provisioner..."
    mkdir -p /opt/shinesolutions/aem-custom-stack-provisioner/
    aws s3 cp "s3://${data_bucket_name}/${stack_prefix}/aem-custom-stack-provisioner.tar.gz" /opt/shinesolutions/aem-custom-stack-provisioner/aem-custom-stack-provisioner.tar.gz
    cd /opt/shinesolutions/aem-custom-stack-provisioner/
    gunzip aem-custom-stack-provisioner.tar.gz
    tar -xvf aem-custom-stack-provisioner.tar
    rm aem-custom-stack-provisioner.tar
    chown -R root:root /opt/shinesolutions/aem-custom-stack-provisioner/

fi

echo "Downloading AEM Stack Provisioner..."
mkdir -p /opt/shinesolutions/aem-aws-stack-provisioner/
aws s3 cp "s3://${data_bucket_name}/${stack_prefix}/aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar.gz" "/opt/shinesolutions/aem-aws-stack-provisioner/aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar.gz"
cd /opt/shinesolutions/aem-aws-stack-provisioner/
gunzip "aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar.gz"
tar -xvf "aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar"
rm "aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar"
chown -R root:root /opt/shinesolutions/aem-aws-stack-provisioner/


if [ -d /opt/shinesolutions/aem-custom-stack-provisioner ] && [ -f /opt/shinesolutions/aem-custom-stack-provisioner/pre-common.sh ]; then

    echo "Execute the pre-common custom provisioning script..."
    cd /opt/shinesolutions/aem-custom-stack-provisioner && ./pre-common.sh "${stack_prefix}" "${component}"

fi

cd /opt/shinesolutions/aem-aws-stack-provisioner/

echo "Applying common Puppet manifest for all components..."
FACTER_data_bucket_name="${data_bucket_name}" \
  FACTER_stack_prefix="${stack_prefix}" \
  puppet apply \
  --modulepath modules \
  --hiera_config conf/hiera.yaml manifests/common.pp

echo "Checking orchestration tags for ${component} component..."
/opt/shinesolutions/aws-tools/wait_for_ec2tags.py "$component"

echo "Setting AWS resources as Facter facts..."
/opt/shinesolutions/aws-tools/set-facts.sh "${data_bucket_name}" "${stack_prefix}"

echo "Applying Puppet manifest for ${component} component..."
puppet apply --modulepath modules --hiera_config conf/hiera.yaml "manifests/${component}.pp"

if [ -d /opt/shinesolutions/aem-custom-stack-provisioner ] && [ -f /opt/shinesolutions/aem-custom-stack-provisioner/post-common.sh ]; then

    echo "Execute the post-common custom provisioning script..."
    cd /opt/shinesolutions/aem-custom-stack-provisioner && ./post-common.sh "${stack_prefix}" "${component}"

fi

cd /opt/shinesolutions/aem-aws-stack-provisioner/

echo "Testing ${component} component using Serverspec..."
cd test/serverspec && rake spec "SPEC=spec/${component}_spec.rb"

echo "Cleaning up provisioner temp directory..."
rm -rf /tmp/shinesolutions/aem-aws-stack-provisioner/*
