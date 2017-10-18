#!/bin/bash

# -------------------------------- VARIABLES --------------------------------- #
PATH="${PATH}:$(pwd)/terraform"

demo_path=$(pwd)
key_name="devops-am"
aws_region="us-east-2"
aws_profile="default"
s3_bucket="devops-am"


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
    echo "Checking for $demo_path/terraform/$key_name.pem"
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
  if [ -f "$demo_path/terraform/$key_name.pem" ]; then
    echo
    echo "$demo_path/terraform/$key_name.pem was found."
    sleep 1
    f_keypair_confirm_delete_local
  else
    echo
    echo "$demo_path/terraform/$key_name.pem was not found."
    sleep 1
  fi
}


## Confirm local key pair deletion
function f_keypair_confirm_delete_local() {
	choices=("Yes" "No")
  echo
	echo "DELETE $demo_path/terraform/$key_name.pem?"
	select choice in "${choices[@]}";
	do
		case $choice in
			Yes)
        echo
				echo "DELETING $demo_path/terraform/$key_name.pem..."
        sleep 3
				rm -f "$demo_path/terraform/$key_name.pem"
        break
				;;
			No)
        echo
				echo "DELETION OF $demo_path/terraform/$key_name.pem CANCELLED."
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


## Remove s3_bucket contents from S3
f_s3_directory_confirm_delete() {
  choices=("Yes" "No")
  echo
  echo "DELETE s3://$s3_bucket/ansible?"
  echo
  echo "This directory was automatically created when deploy.sh was run."
  echo "If you've made any customizations to the files within this bucket"
  echo "since deployment, please make sure they are backed up before deleting."
  echo
  select choice in "${choices[@]}";
  do
    case $choice in
      Yes)
        echo
        echo "DELETING the ansible directory from s3://$s3_bucket..."
        sleep 3
        aws s3 rm s3://$s3_bucket/ansible --recursive
        break
        ;;
      No)
        echo
        echo "DELETION of the ansible directory from s3://$s3_bucket CANCELLED."
        sleep 3
        break
        ;;
    esac
  done
}


## Run terraform destroy -force
f_terraform_destroy () {
  if [[ -d "$demo_path/terraform" ]]; then
    cd "$demo_path/terraform"
    echo
    echo "Running terraform destroy -force..."
    sleep 3
    terraform destroy -force
  else
    echo
    echo "I can't find $demo_path/terraform"
    echo "Please try again when $demo_path/terraform is in place..."
    echo
    sleep 3
    exit 10
  fi
}


## Remove s3_bucket contents from S3
f_terraform_binary_confirm_delete() {
  choices=("Yes" "No")
  echo
  echo "DELETE terraform binary from $demo_path/terraform?"
  echo
  echo "Terraform was automatically installed when deploy.sh was run."
  echo "If you plan to rerun Terraform from this directory again, do not delete."
  echo "Otherwise, you can rerun deploy.sh to reinstall Terraform."
  echo
  select choice in "${choices[@]}";
  do
    case $choice in
      Yes)
        echo
        echo "DELETING the terraform binary from $demo_path/terraform..."
        sleep 3
        rm -f $demo_path/terraform/terraform
        break
        ;;
      No)
        echo
        echo "DELETION of the terraform binary from $demo_path/terraform CANCELLED."
        sleep 3
        break
        ;;
    esac
  done
}
# --------------------------------- RUN IT! ---------------------------------- #
f_terraform_destroy
f_terraform_binary_confirm_delete
f_s3_directory_confirm_delete
f_keypair_check_aws
