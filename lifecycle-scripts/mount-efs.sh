#!/bin/bash

set -e

sudo yum install -y amazon-efs-utils
sudo mount -t efs -o tls fs-xxx:/ /home/ec2-user/SageMaker/efs
chmod 755 /home/ec2-user

users="
xxx
"

for user in $users
do
    id=$(echo $user | sed 's/:.*//')
    name=$(echo $user | sed 's/.*://')
    echo "Creating UNIX account for $name"

    sudo groupadd -g $id $name
    sudo useradd -g $id -u $id -M -d /home/ec2-user/SageMaker/efs/$name $name
    sudo usermod -a -G $name ec2-user
done

pushd anaconda3/envs/
tar zxf /home/ec2-user/SageMaker/efs/R.tar.gz
popd
