
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
    env = var.env
  }
}

resource "aws_subnet" "pub-sub-1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.public_subnet_1_cidr

  tags = {
    Name = "pub-sub"
    env = var.env 
  }
  availability_zone = "ap-south-1a" 
  map_public_ip_on_launch = true

}

resource "aws_subnet" "pub-sub-2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.public_subnet_2_cidr

  tags = {
    Name = "pub-sub"
    env = var.env 
  }
  availability_zone = "ap-south-1b" 
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "IGW-01"
    env = var.env
  }
}

resource "aws_default_route_table" "public_rt" {
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  
  tags = {
    Name = "public_rt"
    env = var.env
  }
}

resource "aws_security_group" "sg-01" {
    description = "devops engineering"
    name = "sg"
    vpc_id = aws_vpc.my-vpc.id

    ingress {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        protocol = "tcp"
        from_port = 443
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"]
    }


    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_route_table_association" "pub-sub-1-association" {
  subnet_id      = aws_subnet.pub-sub-1.id
  route_table_id = aws_default_route_table.public_rt.id
}

resource "aws_route_table_association" "pub-sub-2-association" {
  subnet_id      = aws_subnet.pub-sub-2.id
  route_table_id = aws_default_route_table.public_rt.id

}

resource "aws_launch_template" "lt-home" {
    name_prefix = "lt-home-"
    image_id = var.image_id
    key_name = var.key_name
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.sg-01.id]
    
    user_data = filebase64("${path.module}/home_script.sh")  
}


resource "aws_launch_template" "lt-laptop" {
    name_prefix = "lt-laptop-"
    image_id = var.image_id
    key_name = var.key_name
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.sg-01.id]
    
    user_data = filebase64("${path.module}/laptop_script.sh")  
}


resource "aws_launch_template" "lt-cloth" {
    name_prefix = "lt-cloth-"
    image_id = var.image_id
    key_name = var.key_name
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.sg-01.id]
    
    user_data = filebase64("${path.module}/cloth_script.sh")  
}


resource "aws_autoscaling_group" "asg-home" {
  desired_capacity   = 2
  max_size           = 4
  min_size           = 1
  launch_template {
    id = aws_launch_template.lt-home.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.tg-home.arn]
  vpc_zone_identifier = [
  aws_subnet.pub-sub-1.id,
  aws_subnet.pub-sub-2.id
]
  wait_for_capacity_timeout = "0"
}

resource "aws_autoscaling_group" "asg-laptop" {
  desired_capacity   = 2
  max_size           = 4
  min_size           = 1
  launch_template {
    id = aws_launch_template.lt-laptop.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.tg-laptop.arn]
  vpc_zone_identifier = [
  aws_subnet.pub-sub-1.id,
  aws_subnet.pub-sub-2.id
]
   wait_for_capacity_timeout = "0"
}

resource "aws_autoscaling_group" "asg-cloth" {
  desired_capacity   = 2
  max_size           = 4
  min_size           = 1
  launch_template {
    id = aws_launch_template.lt-cloth.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.tg-cloth.arn]
  vpc_zone_identifier = [
  aws_subnet.pub-sub-1.id,
  aws_subnet.pub-sub-2.id
]
  wait_for_capacity_timeout = "0"
}

resource "aws_autoscaling_policy" "policy-home" {
  name                   = "asgp-h"
  autoscaling_group_name = aws_autoscaling_group.asg-home.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }

}

resource "aws_autoscaling_policy" "policy-laptop" {
  name                   = "asgp-l"
  autoscaling_group_name = aws_autoscaling_group.asg-laptop.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }

}

resource "aws_autoscaling_policy" "policy-cloth" {
  name                   = "asgp-c"
  autoscaling_group_name = aws_autoscaling_group.asg-cloth.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }

}


resource "aws_lb_target_group" "tg-home" {
  name     = "tg-h"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id
  tags = {
    env = var.env
  }
}

resource "aws_lb_target_group" "tg-laptop" {
  name     = "tg-l"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id
  health_check {
    path = "/laptop"
  }
  tags = {
    env = var.env
  }
}

resource "aws_lb_target_group" "tg-cloth" {
  name     = "tg-c"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id
  health_check {
    path = "/cloth"
  }
  tags = {
    env = var.env
  }
}

resource "aws_lb" "app-lb" {
  name               = "my-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-01.id]
  subnets            = [aws_subnet.pub-sub-1.id,
                        aws_subnet.pub-sub-2.id ]
  tags = {
    Env = var.env
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg-home.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.alb_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-home.arn
  }
}

resource "aws_lb_listener_rule" "laptop" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-laptop.arn
  }

  condition {
    path_pattern {
      values = ["/laptop*"]
    }
  }
}

resource "aws_lb_listener_rule" "cloth" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-cloth.arn
  }

  condition {
    path_pattern {
      values = ["/cloth*"]
    }
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  default_root_object = "index.html"
  #aliases = ["sakshi.store", "www.sakshi.store"] 
  origin {
    domain_name = aws_lb.app-lb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront_cert.arn
    ssl_support_method   = "sni-only"
  }
}



resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "sakshi.store"
  type    = "A"
  depends_on = [aws_cloudfront_distribution.cdn]
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.sakshi.store"
  type    = "A"
  depends_on = [aws_cloudfront_distribution.cdn]
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}




