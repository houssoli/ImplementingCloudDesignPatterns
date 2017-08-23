#!/bin/bash
function get_tag {
  instance_id=$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)
  tag=$(aws ec2 describe-tags \
  --filters "Name=resource-type,Values=instance" \
  "Name=resource-id,Values=${instance_id}" \
  "Name=key,Values=$1" \
  | grep Value | awk '{print $2}' | sed 's/"\|,//g')
}

echo $'#!/bin/sh\nexport AWS_DEFAULT_REGION=us-east-1\n' > /etc/profile.d/aws.sh

. /etc/profile.d/aws.sh

get_tag 'Role'
ROLE=$tag
aws s3 cp s3://houssoli-1ce8b98d-8735-47ff-a9dc-7f4b57820a74/${ROLE}.sh /tmp/userdata.sh
sh /tmp/userdata.sh >/var/log/custom-userdata.sh 2>&1
