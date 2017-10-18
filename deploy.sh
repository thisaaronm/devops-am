#!/bin/bash

# -------------------------------- VARIABLES --------------------------------- #
demo_path="devops-am"
key_name="devops-am"
aws_region="us-east-2"
aws_profile="default"


# -------------------------------- FUNCTIONS --------------------------------- #
## Create ssh key pair for ansible
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
    echo "Checking for $HOME/$demo_path/ansible/$key_name.pem..."
    sleep 1
    if [ ! -f "$HOME/$demo_path/ansible/$key_name.pem" ]; then
      echo
      echo "$HOME/$demo_path/ansible/$key_name.pem was NOT FOUND."
      echo
      echo "Please locate it and place it in $HOME/$demo_path/ansible"
      sleep 3
      exit 10
    else
      echo
      echo "$HOME/$demo_path/ansible/$key_name.pem was found."
      echo "Continuing on..."
      sleep 3
    fi
  fi
}


## Create key pair
f_keypair_create() {
  if [ -f "$HOME/$demo_path/ansible/$key_name.pem" ]; then
    echo
    echo "$HOME/$demo_path/ansible/$key_name.pem was found."
    var_date=$(date '+%Y-%m%d_%H%M%S')
    echo
    echo "Backing up $HOME/$demo_path/ansible/$key_name.pem as"
    echo "$HOME/$demo_path/ansible/$key_name.pem.bak_$var_date"
    sleep 3
    mv "$HOME/$demo_path/ansible/$key_name.pem" \
    "$HOME/$demo_path/ansible/$key_name.pem.bak_$var_date"
  fi
  echo
  echo "Creating $key_name key pair in $aws_region..."
  aws ec2 create-key-pair \
    --key-name "$key_name" \
    --query "KeyMaterial" \
    --output text \
    --region "$aws_region" \
    --profile "$aws_profile" > "$HOME/$demo_path/ansible/$key_name.pem"
  echo
  echo
  chmod 400 "$HOME/$demo_path/ansible/$key_name.pem"
}


## Run Terraform
f_terraform () {
  if [[ -d "$HOME/$demo_path/terraform" ]]; then
    cd "$HOME/$demo_path/terraform"
    terraform get
    terraform init
    terraform plan -out=main.tfplan
    terraform apply main.tfplan
  else
    echo
    echo "I can't find $HOME/$demo_path/terraform"
    echo "Please try again when $HOME/$demo_path/terraform is in place..."
    echo
    sleep 3
    exit 20
  fi
}


# --------------------------------- RUN IT! ---------------------------------- #
f_keypair_check
f_terraform

echo "If this is the first time deploy.sh has been run,"
echo "please wait approximately 60 seconds for the initial"
echo "ASG instances health checks to meet the 'healthy' threshold."
echo
echo "After that, the ELB address will load successfully."
sleep 5
