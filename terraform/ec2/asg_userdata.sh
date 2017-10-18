#!/bin/bash

sleep 60

## Update OS and install Ansible
yum update -y
pip install --upgrade pip
pip install ansible

## Copy Ansible assests from S3
cd
aws s3 cp s3://${s3_bucket}/ansible . --recursive

## Run Ansible Playbook
/usr/local/bin/ansible-playbook ansible/devops-am.yml
