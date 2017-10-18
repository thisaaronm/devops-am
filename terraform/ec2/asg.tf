## asg.tf

# -------------------------- LAUNCH CONFIGURATIONS --------------------------- #
resource "aws_launch_configuration" "lc00" {
  associate_public_ip_address = false
  name_prefix                 = "lc00-"
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = true
  }
  key_name        = "${var.key_name}"
  security_groups = ["${var.sg_internal00_id}"]
  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------- AUTO SCALING GROUPS ---------------------------- #
resource "aws_autoscaling_group" "asg00" {
  vpc_zone_identifier       = ["${var.subpriv00_id}","${var.subpriv11_id}","${var.subpriv22_id}"]
  name                      = "asg00"
  max_size                  = 6
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  load_balancers            = ["${aws_elb.elb00.name}"]
  launch_configuration      = "${aws_launch_configuration.lc00.name}"
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name",
    value               = "asg00",
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment",
    value               = "Development",
    propagate_at_launch = true
  }
  tag {
    key                 = "Demo",
    value               = "devops-am",
    propagate_at_launch = true
  }
}

# ----------------------------- SCALING POLICIES ----------------------------- #
resource "aws_autoscaling_policy" "scaling00" {
  name                   = "scaling00"
  scaling_adjustment     = 3
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.asg00.name}"
}


# ---------------------------- CLOUDWATCH METRICS ---------------------------- #
resource "aws_cloudwatch_metric_alarm" "asg00_metric00" {
  alarm_name          = "asg00_metric00"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg00.name}"
  }
  alarm_description = "Monitors asg00 EC2 CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scaling00.arn}"]
}
