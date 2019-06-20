#!/bin/bash

set -e

if [ -e /home/ec2-user/SageMaker/.gitconfig ]
then
    cp /home/ec2-user/SageMaker/{.gitconfig,.git-credentials} /home/ec2-user
    chown ec2-user.ec2-user /home/ec2-user/{.gitconfig,.git-credentials}
fi

if [ -e /home/ec2-user/SageMaker/.ssh ]
then
    cp -r /home/ec2-user/SageMaker/.ssh /home/ec2-user
    chown -R ec2-user.ec2-user /home/ec2-user/.ssh
fi
