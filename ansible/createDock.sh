#!/bin/bash
# $1 = type
# $2 = org
# $3 = env (prod/stage/beta)
# $4 = tags for host tags
set -e
if [[ $1 = '' ]]; then
  echo 'requires EC2 server type (m1.micro)'
  exit 1
fi
TYPE=$1
if [[ $2 = '' ]]; then
  echo 'requires org name (runnable-run)'
  exit 1
fi
ORG=$2
if [[ $3 = '' ]]; then
  echo 'requires env (prod/stage/beta)'
  exit 1
fi
ENV=$3
if [[ $ENV = 'prod' ]] || [[ $ENV = 'stage' ]]; then
  PLACE=alpha
  AMI=ami-d16a8b95
  SG_GROUPS=sg-cb8e7dae
  SUBNET=subnet-bfb646da
  KEY=Test-runnable
  REGION=us-west-1
elif [[ $ENV = 'beta' ]]; then
  PLACE=beta
  AMI=ami-5189a661
  SG_GROUPS="sg-6bc8060f sg-87ca04e3"
  SUBNET=subnet-bea0d3db
  KEY=oregon
  REGION=us-west-2
fi
echo "configs"
echo "PLACE = $PLACE"
echo "AMI = $AMI"
echo "SG_GROUPS = $SG_GROUPS"
echo "SUBNET = $SUBNET"
echo "KEY = $KEY"
echo "REGION = $REGION"

if [[ $4 = '' ]]; then
  echo 'requires tags to be added to the dock'
  exit 1
fi
TAGS=$4


#
# test out
# {
#     "OwnerId": "437258487404",
#     "ReservationId": "r-34f708ff",
#     "Groups": [],
#     "Instances": [
#         {
#             "Monitoring": {
#                 "State": "disabled"
#             },
#             "PublicDnsName": null,
#             "KernelId": "aki-880531cd",
#             "State": {
#                 "Code": 0,
#                 "Name": "pending"
#             },
#             "EbsOptimized": false,
#             "LaunchTime": "2015-07-16T01:10:17.000Z",
#             "PrivateIpAddress": "10.0.1.19",
#             "ProductCodes": [],
#             "VpcId": "vpc-b22ccfd7",
#             "StateTransitionReason": null,
#             "InstanceId": "i-c494e80f",
#             "ImageId": "ami-d16a8b95",
#             "PrivateDnsName": "ip-10-0-1-19.us-west-1.compute.internal",
#             "KeyName": "Test-runnable",
#             "SecurityGroups": [
#                 {
#                     "GroupName": "alpha-dock-sg",
#                     "GroupId": "sg-cb8e7dae"
#                 }
#             ],
#             "ClientToken": null,
#             "SubnetId": "subnet-bfb646da",
#             "InstanceType": "t1.micro",
#             "NetworkInterfaces": [
#                 {
#                     "Status": "in-use",
#                     "MacAddress": "02:75:07:b5:5e:17",
#                     "SourceDestCheck": true,
#                     "VpcId": "vpc-b22ccfd7",
#                     "Description": null,
#                     "NetworkInterfaceId": "eni-a012a4c4",
#                     "PrivateIpAddresses": [
#                         {
#                             "PrivateDnsName": "ip-10-0-1-19.us-west-1.compute.internal",
#                             "Primary": true,
#                             "PrivateIpAddress": "10.0.1.19"
#                         }
#                     ],
#                     "PrivateDnsName": "ip-10-0-1-19.us-west-1.compute.internal",
#                     "Attachment": {
#                         "Status": "attaching",
#                         "DeviceIndex": 0,
#                         "DeleteOnTermination": true,
#                         "AttachmentId": "eni-attach-b3ed77ee",
#                         "AttachTime": "2015-07-16T01:10:17.000Z"
#                     },
#                     "Groups": [
#                         {
#                             "GroupName": "alpha-dock-sg",
#                             "GroupId": "sg-cb8e7dae"
#                         }
#                     ],
#                     "SubnetId": "subnet-bfb646da",
#                     "OwnerId": "437258487404",
#                     "PrivateIpAddress": "10.0.1.19"
#                 }
#             ],
#             "SourceDestCheck": true,
#             "Placement": {
#                 "Tenancy": "default",
#                 "GroupName": null,
#                 "AvailabilityZone": "us-west-1a"
#             },
#             "Hypervisor": "xen",
#             "BlockDeviceMappings": [],
#             "Architecture": "x86_64",
#             "StateReason": {
#                 "Message": "pending",
#                 "Code": "pending"
#             },
#             "RootDeviceName": "/dev/sda1",
#             "VirtualizationType": "paravirtual",
#             "RootDeviceType": "ebs",
#             "AmiLaunchIndex": 0
#         }
#     ]
# }
#
# INSTANCE_INFO="{ OwnerId: 437258487404, ReservationId: r-c6f6090d, Groups: [], Instances: [ { Monitoring: { State: disabled }, PublicDnsName: null, KernelId: aki-880531cd, State: { Code: 0, Name: pending }, EbsOptimized: false, LaunchTime: 2015-07-16T01:14:17.000Z, PrivateIpAddress: 10.0.1.103, ProductCodes: [], VpcId: vpc-b22ccfd7, StateTransitionReason: null, InstanceId: i-eb94e820, ImageId: ami-d16a8b95, PrivateDnsName: ip-10-0-1-103.us-west-1.compute.internal, KeyName: Test-runnable, SecurityGroups: [ { GroupName: alpha-dock-sg, GroupId: sg-cb8e7dae } ], ClientToken: null, SubnetId: subnet-bfb646da, InstanceType: t1.micro, NetworkInterfaces: [ { Status: in-use, MacAddress: 02:0c:b1:1b:30:eb, SourceDestCheck: true, VpcId: vpc-b22ccfd7, Description: null, NetworkInterfaceId: eni-a413a5c0, PrivateIpAddresses: [ { PrivateDnsName: ip-10-0-1-103.us-west-1.compute.internal, Primary: true, PrivateIpAddress: 10.0.1.103 } ], PrivateDnsName: ip-10-0-1-103.us-west-1.compute.internal, Attachment: { Status: attaching, DeviceIndex: 0, DeleteOnTermination: true, AttachmentId: eni-attach-e2e278bf, AttachTime: 2015-07-16T01:14:17.000Z }, Groups: [ { GroupName: alpha-dock-sg, GroupId: sg-cb8e7dae } ], SubnetId: subnet-bfb646da, OwnerId: 437258487404, PrivateIpAddress: 10.0.1.103 } ], SourceDestCheck: true, Placement: { Tenancy: default, GroupName: null, AvailabilityZone: us-west-1a }, Hypervisor: xen, BlockDeviceMappings: [], Architecture: x86_64, StateReason: { Message: pending, Code: pending }, RootDeviceName: /dev/sda1, VirtualizationType: paravirtual, RootDeviceType: ebs, AmiLaunchIndex: 0 } ] }"
INSTANCE_INFO=`aws --region $REGION ec2 run-instances \
  --image-id $AMI \
  --count 1 \
  --instance-type $TYPE \
  --key-name $KEY \
  --security-group-ids $SG_GROUPS \
  --subnet-id $SUBNET \
  --block-device-mappings \
    "[{\"DeviceName\":\"/dev/sdb\",\"Ebs\":{\"VolumeSize\":1000,\"DeleteOnTermination\":true}}, \
    {\"DeviceName\":\"/dev/sdc\",\"Ebs\":{\"VolumeSize\":50,\"DeleteOnTermination\":true}}, \
    {\"DeviceName\":\"/dev/sdd\",\"Ebs\":{\"VolumeSize\":50,\"DeleteOnTermination\":true}}]" | sed s/\"//g`


echo instance info $INSTANCE_INFO
INSTANCE_ID=`echo $INSTANCE_INFO | grep -o ' i-[0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z]'`
PRIVATE_IP=`echo $INSTANCE_INFO | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1`
echo "created $INSTANCE_ID with ip $PRIVATE_IP waiting till its running"
aws --region $REGION ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "instance up, adding tags"
# tag instance
# name
aws --region $REGION ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$PLACE-$ORG
# org
aws --region $REGION ec2 create-tags --resources $INSTANCE_ID --tags Key=org,Value=$ORG
# type
aws --region $REGION ec2 create-tags --resources $INSTANCE_ID --tags Key=type,Value=dock
# env
aws --region $REGION ec2 create-tags --resources $INSTANCE_ID --tags Key=env,Value=$ENV

## install docker, and our stuff
echo "tags done, adding entry to config file"

echo "Host $PLACE-$ORG" >> ~/.ssh/config
echo "  ProxyCommand ssh -q ubuntu@$PLACE-bastion nc $PRIVATE_IP 22" >> ~/.ssh/config

ansible-playbook -i ./$ENV-hosts -e restart=true -e host_tags=$TAGS -e host_ip=$PRIVATE_IP -e host_name=$PLACE-$ORG createDock.yml
