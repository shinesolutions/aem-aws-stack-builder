#!/usr/bin/env bash
set -o nounset
set -o errexit

if [ "$#" -ne 2 ]; then
  echo 'Usage: ./stack-init.sh <bucket_name> <stack_prefix>'
  exit 1
fi

bucket_name=$1
stack_prefix=$2
PATH=$PATH:/opt/puppetlabs/bin

echo "Initialising AEM Stack Builder provisioning..."

aws --version
puppet --version
python --version
ruby --version

echo "Downloading AEM Stack Provisioner..."
mkdir -p /tmp/aem-aws-stack-provisioner/
aws s3 cp s3://${bucket_name}/${stack_prefix}/aem-aws-stack-provisioner.tar.gz /tmp/aem-aws-stack-provisioner/aem-aws-stack-provisioner.tar.gz
cd /tmp/aem-aws-stack-provisioner/
gunzip aem-aws-stack-provisioner.tar.gz
tar -xvf aem-aws-stack-provisioner.tar
rm aem-aws-stack-provisioner.tar

echo "Applying common Puppet manifest for all components..."
puppet apply --modulepath modules --hiera_config conf/hiera.yaml manifests/common.pp

echo "Setting EC2 tags as Facter facts..."
/opt/aws-tools/ec2tags-facts.sh
component=`facter component`

echo "Applying Puppet manifest for ${component} component..."
puppet apply --modulepath modules --hiera_config conf/hiera.yaml "manifests/${component}.pp"
