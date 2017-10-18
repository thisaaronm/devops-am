#!/bin/bash

# -------------------------------- VARIABLES --------------------------------- #
demo_path="Desktop/devops-am"
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
  chmod 600 "$HOME/$demo_path/ansible/$key_name.pem"
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


## Run Ansible
f_ansible () {
  if [ -d "$HOME/$demo_path/ansible" ]; then
    cd "$HOME/$demo_path/ansible"
    rm -f hosts
    rm -f playbooks/devops-am.retry
    echo '[devops-am]' > hosts
    aws ec2 describe-instances \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --filters "Name=instance-state-name,Values=running" \
    --region "$aws_region" \
    --profile "$aws_profile" \
    --output text >> hosts
    ansible-playbook playbooks/devops-am.yml -v
  else
    echo
    echo "I can't find $HOME/$demo_path/ansible"
    echo "Please try again when $HOME/$demo_path/ansible is in place..."
    echo
    sleep 3
    exit 30
  fi
}


# --------------------------------- RUN IT! ---------------------------------- #
f_keypair_check
f_terraform
f_ansible
