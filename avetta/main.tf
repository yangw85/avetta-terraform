provider "aws" {
  region = var.AWS_REGION
}

resource "aws_launch_configuration" "prod" {
  image_id        = var.IMAGE_ID
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "prod" {
  launch_configuration = aws_launch_configuration.prod.id

  vpc_zone_identifier = [aws_subnet.prod-subnet-private-1.id]

  min_size = 2
  max_size = 5

  load_balancers    = [aws_elb.prod.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "prod-asg"
    propagate_at_launch = true
  }
}

resource "aws_elb" "prod" {
  name               = "prod-asg"
  security_groups    = [aws_security_group.elb.id]

  subnets = [aws_subnet.prod-subnet-public-1.id]

  health_check {
      target              = "HTTP:${var.SERVER_PORT}/"
      interval            = 30
      timeout             = 3
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }

  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.SERVER_PORT
    instance_protocol = "http"
  }
}

output "clb_dns_name" {
  value       = aws_elb.prod.dns_name
  description = "The domain name of the load balancer"
}
