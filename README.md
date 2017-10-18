# devops-am
---
# Prerequisites:
- macOS (this has only been tested on 10.12.6)
- Ensure that Terraform and Ansible are installed and in your __```$PATH```__
- Have AWS credentials (~/.aws/credentials) that grants full administrative privileges
- Clone this project to ~/Desktop so that your directory structure looks like this:

```
~
└── Desktop
    └── devops-am
        ├── README.md
        ├── ansible
        │   ├── ansible.cfg
        │   ├── playbooks
        │   │   └── devops-am.yml
        │   └── roles
        │       ├── common-yum
        │       │   └── tasks
        │       │       └── main.yml
        │       └── devops-am
        │           └── tasks
        │               └── main.yml
        ├── deploy.sh
        ├── teardown.sh
        └── terraform
            ├── ansible.cfg
            ├── ec2
            │   ├── asg.tf
            │   ├── elb.tf
            │   └── variables.tf
            ├── main.tf
            ├── variables.tf
            └── vpc
                ├── sg.tf
                ├── variables.tf
                └── vpc.tf
```


# Overview
If all the prerequisites above are met, then you should be able to "one shot" this by:
  - cloning to ~/Desktop
  - cd to devops-am
  - then executing deploy.sh

A (very) high level overview of what happens when you run __deploy.sh__ is:
- check is made to see if there is a __devops-am__ key pair in AWS. If not, it will be created, and the __devops-am.pem__ private key being placed in __devops-am/ansible/__. There's also other logic built in to handle:
  - if the key pair __is__ in AWS, __and__ in the previously mentioned path
  - if the key pair __is__ in AWS, __but not__ in the previously mentioned path
  - if the key pair __is not__ in AWS, __but is__ in the mentioned path
- after the key pair section is complete, Terraform is initialized, planned, and applied. Terraform will also kick off Ansible as part of its final process.
- after Terraform has run, even though it just ran Ansible, __deploy.sh__ will have Ansible run the __devops-am.yml__ playbook. This was left in just to ensure that Ansible was able to run all by itself, independent of Terraform.
- the last thing that Ansible does before exiting, is output the ELB DNS A record, this way, instead of grabbing it from AWS yourself, Ansible does it for you. So in theory, you should be able to run without ever needing to be logged into the AWS Console.
- three AutoScaling Group instances are launched, so when you navigate to the ELB, with each refresh, along with the good ol' __Hello World__, you should up to three different hostnames. (six, if you count that for each instance, the AWS hostname from http://169.254.169.254/latest/meta-data/local-hostname AND the __```$HOSTNAME```__ are included)
- once done, you can run Terraform and Ansible independently of each other. in other words, you only need to run __deploy.sh__ once. afterwards, if you want to make changes to Terraform or Ansible, you can do so without requiring __deploy.sh__, since __deploy.sh__ is really just an initial bootstrap.

Once you're done, to tear everything down in the AWS environment, including the key pairs created by this project, just run __teardown.sh__. It will check AWS for the specified key pair public key, the local key pair private key, prompt the user to confirm deletion, and then run ```terraform destroy -force``` to tear down the AWS resources created by this project.


# Customizing the Project
- As mentioned above, you must have valid AWS credentials at ~/.aws/credentials. My assumption is that your credentials file only has the default profile in it. If so, then you don't need to make any changes. However, if your AWS credentials file DOES contain multiple credential profiles, and you want to use a profile other than __```[default]```__, you'll need to specify it in:
  - devops-am/deploy.sh (aws_profile // line 7)
  - devops-am/ansible/playbooks/devops-am.yml (aws_profile // line 4)
  - devops-am/terraform/variables.tf (aws_profile // line 14)

- This project is configured to use us-east-2 (Ohio), but if another region is desired, you can change it in the same files mentioned above, but at the following lines:
  - devops-am/deploy.sh (aws_region // line 6)
  - devops-am/ansible/playbooks/devops-am.yml (aws_region // line 5)
  - devops-am/terraform/variables.tf (aws_region // line 5)

- The devops-am/deploy.sh script will also create the necessary key pair configured in other files. However, if you would like to use your own key pair:
  - ensure it resides in the same region you are going to deploy to
  - in devops-am/deploy.sh, comment out the __```f_keypair_check```__ function at line 122
  - then you can update the key pair in the following files:
    - devops-am/deploy.sh (key_name // line 5)
    - devops-am/ansible/ansible.cfg (private_key_file // line 8)
    - devops-am/terraform/ansible.cfg (private_key_file // line 8)
    - devops-am/terraform/ec2/variables.tf (key_name // line 17)
---
### For any questions or comments, please contact me. Thanks!
