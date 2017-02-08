#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -ne 3 ]; then
  echo 'Usage: ./stack-init.sh <data_bucket_name> <stack_prefix> <component>'
  exit 1
fi

data_bucket_name=$1
stack_prefix=$2
component=$3
PATH=$PATH:/opt/puppetlabs/bin

echo "Initialising AEM Stack Builder provisioning..."

aws --version
puppet --version
python --version
ruby --version

echo "Downloading AEM Stack Provisioner..."
mkdir -p /opt/shinesolutions/aem-aws-stack-provisioner/
aws s3 cp "s3://${data_bucket_name}/${stack_prefix}/aem-aws-stack-provisioner.tar.gz" /opt/shinesolutions/aem-aws-stack-provisioner/aem-aws-stack-provisioner.tar.gz
cd /opt/shinesolutions/aem-aws-stack-provisioner/
gunzip aem-aws-stack-provisioner.tar.gz
tar -xvf aem-aws-stack-provisioner.tar
rm aem-aws-stack-provisioner.tar

echo "Applying common Puppet manifest for all components..."
puppet apply --modulepath modules --hiera_config conf/hiera.yaml manifests/common.pp

echo "Checking orchestration tags for ${component} component..."
/opt/shinesolutions/aws-tools/wait_for_ec2tag.py "$component"

echo "Setting AWS resources as Facter facts..."
/opt/shinesolutions/aws-tools/set-facts.sh "${data_bucket_name}"

echo "Applying Puppet manifest for ${component} component..."
puppet apply --modulepath modules --hiera_config conf/hiera.yaml "manifests/${component}.pp"

echo "Testing ${component} component using Serverspec..."
cd test/serverspec && rake spec "SPEC=spec/${component}_spec.rb"
