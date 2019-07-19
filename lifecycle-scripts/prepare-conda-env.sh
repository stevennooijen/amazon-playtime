#!/usr/bin/env bash

set -e

source activate python3

while read requirement; do
    pip install $requirement;
done < /home/ec2-user/SageMaker/sagemaker_toy_project_steven/requirements.txt

source /home/ec2-user/SageMaker/sagemaker_toy_project_steven/.env
