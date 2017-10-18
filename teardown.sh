#!/bin/bash

# -------------------------------- VARIABLES --------------------------------- #
demo_path="devops-am"
key_name="devops-am"
aws_region="us-east-2"
aws_profile="default"


# -------------------------------- FUNCTIONS --------------------------------- #
## Check for AWS key pair
f_keypair_check_aws() {
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
    echo
    echo "Checking for $HOME/$demo_path/ansible/$key_name.pem"
    f_keypair_check_local
  else
    echo
    echo "The $key_name key pair was found in AWS region: $aws_region."
    sleep 1
    f_keypair_confirm_delete_aws
    f_keypair_check_local
  fi
}


## Check for local key pair
f_keypair_check_local() {
  if [ -f "$HOME/$demo_path/ansible/$key_name.pem" ]; then
    echo
    echo "$HOME/$demo_path/ansible/$key_name.pem was found."
    sleep 1
    f_keypair_confirm_delete_local
  else
    echo
    echo "$HOME/$demo_path/ansible/$key_name.pem was not found."
    sleep 1
  fi
}


## Confirm local key pair deletion
function f_keypair_confirm_delete_local() {
	choices=("Yes" "No")
  echo
	echo "DELETE $HOME/$demo_path/ansible/$key_name.pem?"
	select choice in "${choices[@]}";
	do
		case $choice in
			Yes)
        echo
				echo "DELETING $HOME/$demo_path/ansible/$key_name.pem..."
        sleep 3
				rm -f "$HOME/$demo_path/ansible/$key_name.pem"
        break
				;;
			No)
        echo
				echo "DELETION OF $HOME/$demo_path/ansible/$key_name.pem CANCELLED."
				sleep 3
        break
				;;
		esac
	done
}


## Confirm AWS key pair deletion
function f_keypair_confirm_delete_aws() {
	choices=("Yes" "No")
  echo
	echo "DELETE the $key_name key pair from AWS region: $aws_region?"
	select choice in "${choices[@]}";
	do
		case $choice in
			Yes)
        echo
				echo "DELETING the $key_name key pair from AWS region: $aws_region..."
        sleep 3
        aws ec2 delete-key-pair \
          --key-name "$key_name" \
          --region "$aws_region" \
          --profile "$aws_profile"
        break
				;;
			No)
        echo
				echo "DELETION of the $key_name key pair in AWS region: $aws_region CANCELLED."
				sleep 3
        break
				;;
		esac
	done
}


## Run terraform destroy -force
f_terraform_destroy () {
  if [[ -d "$HOME/$demo_path/terraform" ]]; then
    cd "$HOME/$demo_path/terraform"
    echo
    echo "Running terraform destroy -force..."
    sleep 3
    terraform destroy -force
  else
    echo
    echo "I can't find $HOME/$demo_path/terraform"
    echo "Please try again when $HOME/$demo_path/terraform is in place..."
    echo
    sleep 3
    exit 10
  fi
}



# --------------------------------- RUN IT! ---------------------------------- #
f_terraform_destroy
f_keypair_check_aws
