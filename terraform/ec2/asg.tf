## asg.tf

# -------------------------- LAUNCH CONFIGURATIONS --------------------------- #
resource "aws_launch_configuration" "lc0" {
  associate_public_ip_address = true
  name_prefix   = "${var.lc_name_prefix}"
  image_id      = "${var.ami}"
  instance_type = "${var.instance_type}"
  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = true
  }
  key_name        = "${var.key_name}"
  security_groups = ["${var.sg_internal0_id}"]
  lifecycle {
    create_before_destroy = true
  }
}


# --------------------------- AUTO SCALING GROUPS ---------------------------- #
resource "aws_autoscaling_group" "asg0" {
  vpc_zone_identifier       = ["${var.subpub0_id}","${var.subpub1_id}","${var.subpub2_id}"]
  name                      = "asg0"
  max_size                  = 6
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  load_balancers            = ["${aws_elb.elb0.name}"]
  launch_configuration      = "${aws_launch_configuration.lc0.name}"
}


# ----------------------------- SCALING POLICIES ----------------------------- #
resource "aws_autoscaling_policy" "scaling0" {
  name                   = "scaling0"
  scaling_adjustment     = 3
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.asg0.name}"
}


# ---------------------------- CLOUDWATCH METRICS ---------------------------- #
resource "aws_cloudwatch_metric_alarm" "asg0_metric0" {
  alarm_name          = "asg0_metric0"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg0.name}"
  }

  alarm_description = "Monitors ASG0 EC2 CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scaling0.arn}"]
}


# ------------------------------ NULL RESOURCES ------------------------------ #
resource "null_resource" "null_rsc_sleep" {
  depends_on  = ["aws_autoscaling_group.asg0"]
  provisioner "local-exec" {
    command = "echo 'Waiting 60 seconds for ASG instances to load...'; sleep 60"
  }
}

resource "null_resource" "null_rsc_inventory" {
  depends_on  = ["null_resource.null_rsc_sleep"]
  provisioner "local-exec" {
    command = "rm -f ~/Desktop/devops-am/ansible/playbooks/devops-am.retry"
  }
  provisioner "local-exec" {
    command = "rm -f ~/Desktop/devops-am/ansible/hosts"
  }
  provisioner "local-exec" {
    command = "echo \"[devops-am]\" > ~/Desktop/devops-am/ansible/hosts"
  }
  provisioner "local-exec" {
    command = "aws ec2 describe-instances --query \"Reservations[*].Instances[*].PublicIpAddress\" --filters \"Name=instance-state-name,Values=running\" --region \"${var.aws_region}\" --profile \"${var.aws_profile}\" --output=text >> ~/Desktop/devops-am/ansible/hosts"
  }
}

resource "null_resource" "null_rsc_ansible" {
  depends_on  = ["null_resource.null_rsc_inventory"]
  provisioner "local-exec" {
    command = "ansible-playbook ~/Desktop/devops-am/ansible/playbooks/devops-am.yml -v"
  }
}

resource "null_resource" "null_rsc_lb"{
  depends_on  = ["null_resource.null_rsc_ansible"]
  provisioner "local-exec" {
    command = "aws elb describe-load-balancers --query \"LoadBalancerDescriptions[*].DNSName\" --region \"${var.aws_region}\" --profile \"${var.aws_profile}\" --output=text"
  }
}
