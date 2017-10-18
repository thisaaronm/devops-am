#!/bin/bash

# -------------------------------- VARIABLES --------------------------------- #
## Temporarily set PATH to include the terraform directory, for running terraform
PATH="${PATH}:$(pwd)/terraform"

demo_path=$(pwd)
key_name="devops-am"
aws_region="us-east-2"
aws_profile="default"
s3_bucket="devops-am"

## Update ZIP URL here:
terraform_zip="https://releases.hashicorp.com/terraform/0.10.7/terraform_0.10.7_darwin_amd64.zip"
# -------------------------------- FUNCTIONS --------------------------------- #
## Checks for SSH key pair
f_keypair_check() {
  echo
  echo "Checking AWS for a $key_name key pair in $aws_region..."
  sleep 1
  keypaircheck=$(aws ec2 describe-key-pairs \
    --query "KeyPairs[*].KeyName" \
    --filters "Name=key-name,Values=$key_name" \
    --output text \
    --region "$aws_region" \
    --profile "$aws_profile")
  if [ -z "$keypaircheck" ]; then
    echo
    echo "The $key_name key pair was NOT FOUND in AWS region: $aws_region."
    sleep 1
    f_keypair_create
  else
    echo
    echo "The $key_name key pair was found in AWS region: $aws_region."
    echo
    echo "Checking for $demo_path/terraform/$key_name.pem..."
    sleep 1
    if [ ! -f "$demo_path/terraform/$key_name.pem" ]; then
      echo
      echo "$demo_path/terraform/$key_name.pem was NOT FOUND."
      echo
      echo "Please locate it and place it in $demo_path/terraform"
      sleep 3
      exit 10
    else
      echo
      echo "$demo_path/terraform/$key_name.pem was found."
      echo "Continuing on..."
      sleep 1
    fi
  fi
}


## Create SSH key pair if missing
f_keypair_create() {
  if [ -f "$demo_path/terraform/$key_name.pem" ]; then
    echo
    echo "$demo_path/terraform/$key_name.pem was found."
    var_date=$(date '+%Y-%m%d_%H%M%S')
    echo
    echo "Backing up $demo_path/terraform/$key_name.pem as"
    echo "$demo_path/terraform/$key_name.pem.bak_$var_date"
    sleep 3
    mv "$demo_path/terraform/$key_name.pem" \
      "$demo_path/terraform/$key_name.pem.bak_$var_date"
  fi
  echo
  echo "Creating $key_name key pair in $aws_region..."
  aws ec2 create-key-pair \
    --key-name "$key_name" \
    --query "KeyMaterial" \
    --output text \
    --region "$aws_region" \
    --profile "$aws_profile" > "$demo_path/terraform/$key_name.pem"
  echo
  echo
  chmod 400 "$demo_path/terraform/$key_name.pem"
}


## Copy s3_bucket contents to S3 bucket
f_copy_to_s3() {
  aws s3 cp s3_bucket s3://$s3_bucket --recursive
}


## Installs Terraform
f_install_terraform() {
  curl -s $terraform_zip -o terraform.zip
  unzip -o terraform.zip -d terraform
  rm -f terraform.zip
}


## Runs Terraform
f_run_terraform () {
  if [[ -d "$demo_path/terraform" ]]; then
    cd "$demo_path/terraform"
    terraform get
    terraform init
    terraform plan -out=main.tfplan
    terraform apply main.tfplan
  else
    echo
    echo "I can't find $demo_path/terraform"
    echo "Please try again when $demo_path/terraform is in place..."
    echo
    sleep 3
    exit 20
  fi
}

## Outputs ELB DNS Name
f_elbaddress() {
  echo
  aws elb describe-load-balancers \
    --query "LoadBalancerDescriptions[*].DNSName" \
    --region "$aws_region" \
    --output text
  echo
}


f_msg0() {
  echo "Please wait a few minutes for the initial ASG instance"
  echo "health checks to meet the 'healthy' threshold."
  echo
  echo "After that, the ELB DNS will load successfully."
  sleep 5
}
# --------------------------------- RUN IT! ---------------------------------- #
f_keypair_check
f_copy_to_s3
f_install_terraform
f_run_terraform
f_elbaddress
f_msg0

exit 0
