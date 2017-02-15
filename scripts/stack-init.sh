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

if aws s3 ls "s3://${data_bucket_name}/${stack_prefix}/" | grep aem-stack-custom-provisioner.tar.gz
then

    echo "Downloading AEM Stack Custom Provisioner..."
    mkdir -p /opt/shinesolutions/aem-stack-custom-provisioner/
    aws s3 cp "s3://${data_bucket_name}/${stack_prefix}/aem-stack-custom-provisioner.tar.gz" /opt/shinesolutions/aem-stack-custom-provisioner/aem-stack-custom-provisioner.tar.gz
    cd /opt/shinesolutions/aem-stack-custom-provisioner/
    gunzip aem-stack-custom-provisioner.tar.gz
    tar -xvf aem-stack-custom-provisioner.tar
    rm aem-stack-custom-provisioner.tar

fi

echo "Downloading AEM Stack Provisioner..."
mkdir -p /opt/shinesolutions/aem-aws-stack-provisioner/
aws s3 cp "s3://${data_bucket_name}/${stack_prefix}/aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar.gz" "/opt/shinesolutions/aem-aws-stack-provisioner/aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar.gz"
cd /opt/shinesolutions/aem-aws-stack-provisioner/
gunzip "aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar.gz"
tar -xvf "aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar"
rm "aem-aws-stack-provisioner-${aem_aws_stack_provisioner_version}.tar"

if [ -d /opt/shinesolutions/aem-stack-custom-provisioner ] && [ -f /opt/shinesolutions/aem-stack-custom-provisioner/custom-common.sh ]; then

    echo "Execute the custom provisioning script..."
    cd /opt/shinesolutions/aem-stack-custom-provisioner && ./custom-common.sh "${stack_prefix}" "${component}"

fi


cd /opt/shinesolutions/aem-aws-stack-provisioner/

echo "Applying common Puppet manifest for all components..."
puppet apply --modulepath modules --hiera_config conf/hiera.yaml manifests/common.pp

echo "Checking orchestration tags for ${component} component..."
/opt/shinesolutions/aws-tools/wait_for_ec2tags.py "$component"

echo "Setting AWS resources as Facter facts..."
/opt/shinesolutions/aws-tools/set-facts.sh "${data_bucket_name}" "${stack_prefix}"

echo "Applying Puppet manifest for ${component} component..."
puppet apply --modulepath modules --hiera_config conf/hiera.yaml "manifests/${component}.pp"

echo "Testing ${component} component using Serverspec..."
cd test/serverspec && rake spec "SPEC=spec/${component}_spec.rb"
