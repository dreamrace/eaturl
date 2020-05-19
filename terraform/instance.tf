resource "aws_iam_role" "instance" {
  name = "${var.prefix}-instance-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_policy" "ssm_access_policy" {
  name        = "${var.prefix}-ssm-access"
  path        = "/"
  description = "Policy to access SSM"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:419372442926:parameter/${var.prefix}.*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "instance-ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = aws_iam_role.instance.name
}

resource "aws_security_group" "allow_ssl" {
  vpc_id      = aws_default_vpc.default.id
  name        = "allow-ssl"
  description = "Allow all ssl traffic"

  ingress {
    description = "SSL traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_lb" {
  vpc_id      = aws_default_vpc.default.id
  name        = "allow-lb"
  description = "Allow internal traffic to and from lb"

  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 8080
    to_port   = 8080
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/////////////////////////////////////////////////////////////////////////

resource "aws_lb" "main" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssl.id, aws_security_group.allow_lb.id]
  subnets            = data.aws_subnet_ids.target.ids
}

resource "aws_lb_target_group" "instance" {
  name     = "${var.prefix}-alb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_listener" "instance" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance.arn
  }

}

resource "aws_route53_record" "target" {
  zone_id = data.aws_route53_zone.target.zone_id
  name    = "${var.sub_domain}.${var.host_zone}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }

}

/////////////////////////////////////////////////////////////////////////

resource "aws_autoscaling_group" "instance" {
  name                      = "${var.prefix}-instance-asg"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_template {
    id      = aws_launch_template.instance.id
    version = "$Latest"
  }
  target_group_arns   = [aws_lb_target_group.instance.id]
  vpc_zone_identifier = data.aws_subnet_ids.target.ids
}

resource "aws_launch_template" "instance" {
  name_prefix            = var.prefix
  image_id               = "ami-0f6a417d56acd0b54"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_lb.id, aws_security_group.allow_localaccess.id, aws_default_security_group.default.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

}
