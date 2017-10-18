# devops-am (priv)

# Prerequisites:
- macOS (this has only been tested on 10.12.6)
- Ensure that Terraform is installed and in your __```$PATH```__
- Have AWS credentials (~/.aws/credentials) that grants full administrative privileges
- Clone this project to ~ so that your directory structure looks like this:

```
~
└── devops-am
    ├── README.md
    ├── ansible
    │   ├── ansible.cfg
    │   ├── playbooks
    │   │   └── devops-am.yml
    │   └── roles
    │       ├── common-yum
    │       │   └── tasks
    │       │       └── main.yml
    │       └── devops-am
    │           └── tasks
    │               └── main.yml
    ├── deploy.sh
    ├── teardown.sh
    └── terraform
        ├── ansible.cfg
        ├── ec2
        │   ├── asg.tf
        │   ├── elb.tf
        │   └── variables.tf
        ├── main.tf
        ├── variables.tf
        └── vpc
            ├── sg.tf
            ├── variables.tf
            └── vpc.tf
```


# Overview
If the above prerequisites are met, then you should be able to deploy this by simply doing:
  - git clone https://github.com/thisaaronm/devops-am.git ~/
  - cd ~/devops-am
  - git checkout priv
  - ./deploy.sh

A (very) high level overview of what happens when you run __deploy.sh__ is:
- check is made to see if there is a __devops-am__ key pair in AWS. If not, it will be created, and the __devops-am.pem__ private key being placed in __devops-am/ansible/__. There's also other logic built in to handle:
  - if the key pair __is__ in AWS, __and__ in the previously mentioned path
  - if the key pair __is__ in AWS, __but not__ in the previously mentioned path
  - if the key pair __is not__ in AWS, __but is__ in the mentioned path
- after the key pair section is complete, Terraform is initialized, planned, and applied.
  - What Terraform does is (not in this specifc order):
    - creates VPC in a specified region (in this demo, it is us-east-2)
    - creates three public and three private subnets
    - creates Internet Gateway for the public subnets
    - creates NAT Gateway for the private subnets
    - creates and attaches an EIP to the NAT Gateway
    - creates public and private route tables for their respective subnets
    - associates the public/private subnets to their respective subnets
    - creates three security groups
      - sg_public00 (assigned to the ELB)
        - allows port 80 from 0.0.0.0/0 to the ELB
      - sg_internal00 (assigned to the ASG Instances)
        - allows port 80 from the ELB
        - allows ICMP and SSH from members of sg_secure00
      - sg_secure00
        - allows ICMP and SSH from authorized IPs (for management purposes)
        - ___***Make sure to update "cidr_secure" in devops-am/terraform/vpc/variables.tf with your own IP(s)! It is currently open to 0.0.0.0/0.***___
    - creates and assigns Launch Configuration to ASG
    - creates ASG in the private subnets with Scaling Policy, CloudWatch Alarm, as well as registers them to ELB
    - creates ELB and associates it with the public subnets
    - creates EC2 role and policy, which will be assigned to the bastion host, allowing it to query for the private IP address of the ASG instances, as well as the DNS A record for the ELB.
    - creates bastion host in the public subnet, which will be used to run Ansible Playbooks against the ASG instances.
    - updates the bastion OS, installs Ansible, then copies the project ansible directory to ~ on the bastion host.
    - has the bastion host run the Ansible playbook for configuring the ASG instances with (among other things) a __Hello World__ page, along with the AWS hostname from http://169.254.169.254/latest/meta-data/local-hostname and the __```$HOSTNAME```__ .
    - adds a cron job that runs every 5 minutes to run the Ansible Playbook. One task of the playbook is to update the Ansible inventory file, so if the ASG scales out or back in, this cron job will catch them and configure them.
- the last thing that Ansible does before exiting, is output the ELB DNS A record, this way, instead of grabbing it from AWS yourself, Ansible does it for you. So in theory, you should be able to run without ever needing to be logged into the AWS Console.
- once done, you can run Terraform from your local workstation, and/or SSH into the bastion host to run Ansible.

Once you're done, to tear everything down in the AWS environment, including the key pairs created by this project, just run __teardown.sh__. It will run ```terraform destroy -force``` to tear down the AWS resources created by this project. Once that is complete, it will check AWS for the specified key pair public key, the local key pair private key, and prompt the user to confirm deletion.

# Customizing the Project
- As mentioned above, you must have valid AWS credentials at ~/.aws/credentials. My assumption is that your credentials file only has the default profile in it. If so, then you don't need to make any changes. However, if your AWS credentials file DOES contain multiple credential profiles, and you want to use a profile other than __```[default]```__, you'll need to specify it in:
  - devops-am/deploy.sh (aws_profile // line 7)
  - devops-am/terraform/variables.tf (aws_profile // line 14)

- This project is configured to use us-east-2 (Ohio), but if another region is desired, you can change it in the same files mentioned above, but at the following lines:
  - devops-am/deploy.sh (aws_region // line 6)
  - devops-am/terraform/variables.tf (aws_region // line 5)

- The devops-am/deploy.sh script will also create the necessary key pair configured in other files. However, if you would like to use your own key pair:
  - ensure it resides in the same region you are going to deploy to
  - in devops-am/deploy.sh, comment out the __```f_keypair_check```__ function at line 122
  - then you can update the key pair in the following files:
    - devops-am/deploy.sh (key_name // line 5)
    - devops-am/ansible/ansible.cfg (private_key_file // line 8)
    - devops-am/terraform/ec2/variables.tf (key_name // line 13)
---
### For any questions or comments, please contact me. Thanks!
