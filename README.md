# devops-am

# Prerequisites:
- macOS (this has only been tested on 10.12.6)
- Have AWS credentials (~/.aws/credentials) that grants full administrative privileges
- **MUST have S3 bucket created in advance, with the contents of the s3_bucket directory included in this project as shown below in the tree below**
  - NOTE: I intentionally nested the ansible.cfg and ansible directory inside of another ansible directory. My reasoning is that it was done for organizational reasons. This may change later, but it needs to be this way for now.

After cloning this branch, your directory structure should look like this:
```
.
├── README.md
├── deploy.sh
├── s3_bucket
│   └── ansible
│       ├── ansible
│       │   ├── devops-am.yml
│       │   ├── hosts
│       │   ├── roles
│       │   │   ├── common-yum
│       │   │   │   └── tasks
│       │   │   │       └── main.yml
│       │   │   └── devops-am
│       │   │       └── tasks
│       │   │           └── main.yml
│       └── ansible.cfg
├── teardown.sh
└── terraform
    ├── ec2
    │   ├── asg.tf
    │   ├── asg_userdata.sh
    │   ├── elb.tf
    │   └── variables.tf
    ├── main.tf
    ├── main.tfplan
    ├── variables.tf
    └── vpc
        ├── sg.tf
        ├── variables.tf
        └── vpc.tf
```


# Overview
If the above prerequisites are met, then you should be able to deploy this by simply doing:
  - git clone https://github.com/thisaaronm/devops-am.git
  - cd ~/devops-am
  - git checkout priv-v2
  - ./deploy.sh

A (very) high level overview of what happens when you run __deploy.sh__ is:
- check is made to see if there is a __devops-am__ key pair in AWS. If not, it will be created, and the __devops-am.pem__ private key being placed in __devops-am/ansible/__. There's also other logic built in to handle:
  - if the key pair __is__ in AWS, __and__ in the previously mentioned path
  - if the key pair __is__ in AWS, __but not__ in the previously mentioned path
  - if the key pair __is not__ in AWS, __but is__ in the mentioned path
- after the key pair section is complete, Terraform is downloaded, initialized, planned, and applied.
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
    - creates EC2 role and policy, which will be assigned to the ASG instances, allowing them to copy the necessary Ansible assets from S3. This ensures that the S3 bucket can remain private.
    - creates and assigns Launch Configuration to ASG with user data that:
      - updates OS
      - updates pip
      - installs Ansible
      - copies required Ansible assets from S3
      - runs Ansible Playbook
      This ensures that when new instances are spun up due to scaling, they are automatically configured at launch.
    - creates ASG in the private subnets with Scaling Policy, CloudWatch Alarm, as well as registers them to ELB
    - creates ELB and associates it with the public subnets
- once done, the __deploy.sh__ script will output the ELB DNS Name, so that you don't need to log into the AWS Console to get that information.
- you can run Terraform from your local workstation like normal.

Once you're done, to tear everything down in the AWS environment, including the key pairs created by this project, just run __teardown.sh__. It will run ```terraform destroy -force``` to tear down the AWS resources created by this project. Once that is complete, it will check AWS for the specified key pair public key, the local key pair private key, and prompt the user to confirm deletion. It will not delete the Terraform binary, but even if it did, re-running __deploy.sh__ would automatically reinstall it.

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

- Last but not least, and I've mentioned it before. You MUST include the name of your own S3 bucket, and again, the assets in the devops-am/s3_bucket must be copied over mirroring that structure. You need to set the S3 bucket name in:
  - devops-am/terraform/ec2/variables (s3_bucket // line 18)
---
### For any questions or comments, please contact me. Thanks!
