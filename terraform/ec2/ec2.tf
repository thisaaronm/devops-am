## ec2.tf

# ------------------------------ EC2 INSTANCES ------------------------------- #
resource "aws_instance" "bastion" {
  count                       = 1
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subpub00_id}"
  associate_public_ip_address	= true
  root_block_device {
    volume_type			= "gp2"
    volume_size			= 10
    delete_on_termination	= true
  }
  ebs_block_device {
    device_name			= "/dev/sdb"
    volume_type			= "gp2"
    volume_size			= 5
    delete_on_termination	= true
  }
  key_name      	     = "${var.key_name}"
  security_groups	     = ["${var.sg_secure00_id}"]
  iam_instance_profile = "${aws_iam_instance_profile.iam_bastion_prof00.id}"
  connection {
    host        = "${aws_instance.bastion.public_ip}"
    type        = "${var.prov_conn_type}"
    user        = "${var.prov_conn_user}"
    private_key = "${file("${var.prov_conn_key_path}/${var.key_name}.pem")}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo pip install --upgrade pip",
      "sudo pip install ansible"
    ]
  }
  provisioner "file" {
    source      = "${var.prov_conn_key_path}"
    destination = "~"
  }
  provisioner "remote-exec" {
    inline  = [
      "echo -e \"MAILTO=''\\n\\n*/5 * * * * /usr/local/bin/ansible-playbook ~/ansible/devops-am.yml\" | crontab -",
      "chmod 400 ~/ansible/\"${var.key_name}.pem\"",
      "mv ~/ansible/ansible.cfg ~/.ansible.cfg",
      "echo \"[devops-am]\" | tee ~/ansible/hosts",
      "aws ec2 describe-instances --query \"Reservations[*].Instances[*].PrivateIpAddress\" --filters \"Name=instance-state-name,Values=running\" \"Name=tag:Name,Values=asg00\" --region \"${var.aws_region}\" --output=text | tee --append ~/ansible/hosts",
      "ansible-playbook ~/ansible/devops-am.yml"
    ]
  }
  lifecycle {
    create_before_destroy	= false
  }
  tags {
    Name        = "bastion",
    Environment = "Development",
    Demo        = "devops-am"
  }
}


# ------------------------ IDENTITY ACCESS MANAGEMENT ------------------------ #
resource "aws_iam_role" "iam_bastion_role00" {
  name                = "iam_bastion_role00"
  path                = "/"
  assume_role_policy  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "iam_bastion_prof00" {
  name  = "iam_bastion_prof00"
  role  = "${aws_iam_role.iam_bastion_role00.name}"
}

resource "aws_iam_role_policy" "iam_bastion_role_pol00" {
  name    = "iam_bastion_role_pol00"
  role    = "${aws_iam_role.iam_bastion_role00.id}"
  policy  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}
