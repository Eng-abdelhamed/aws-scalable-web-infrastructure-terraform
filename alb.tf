# Create Load Balancer
resource "aws_lb" "LoadBalancer" {
  name               = "LoadBalancer"
  load_balancer_type = "application"
  subnets            = [aws_subnet.PublicSubnet1.id, aws_subnet.PublicSubnet2.id]
  security_groups    = [aws_security_group.LB-SG.id]
  tags = {
    Env = "Production"
  }
}

# Create Security Group for the Load Balancer
resource "aws_security_group" "LB-SG" {
  name   = "LoadBalancerSG"
  vpc_id = aws_vpc.MainVpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

  tags = {
    Env = "Production"
  }
}

# Create Security Group for the EC2 Instances
resource "aws_security_group" "EC2-SecurityGroups" {
  name   = "instancesLoadBalancerSg"
  vpc_id = aws_vpc.MainVpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.LB-SG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Env = "Production"
  }
}

# Create Target Group for the Load Balancer
resource "aws_lb_target_group" "FrontEnd" {
  name     = "FrontendLoadBalanceTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.MainVpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Create HTTP Listener — redirects to HTTPS
resource "aws_lb_listener" "HTTP-Redirect" {
  load_balancer_arn = aws_lb.LoadBalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "80"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }
}

# Create HTTPS Listener (requires ACM certificate — set your certificate ARN in variables.tf)
resource "aws_lb_listener" "HTTPS-Listener" {
  load_balancer_arn = aws_lb.LoadBalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.FrontEnd.arn
  }
}

# Create Launch Template for the ASG
resource "aws_launch_template" "LT" {
  name          = "LT-ASG"
  image_id      = var.ami_id
  instance_type = var.instance_type
  

  vpc_security_group_ids = [aws_security_group.EC2-SecurityGroups.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo dnf install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "Hello world From Terraform" > /usr/share/nginx/html/index.html
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Env = "Production"
    }
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "ASG" {
  name                      = "TerraformAutoScalingGroup"
  vpc_zone_identifier       = [aws_subnet.PrivatSubnet1.id, aws_subnet.PrivatSubnet2.id]
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.FrontEnd.arn]

  launch_template {
    id      = aws_launch_template.LT.id
    version = "$Latest"
  }

  tag {
    key                 = "Env"
    value               = "Production"
    propagate_at_launch = true
  }
}
