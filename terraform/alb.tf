resource "aws_lb" "ghost_alb" {
  name               = "ghost-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ghost_lb_sg.id]
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  tags = merge(var.tags,
    {
      "Name" = "ghost-alb"
  })
}

resource "aws_lb_listener" "ghost_lb_listener" {
  load_balancer_arn = aws_lb.ghost_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ghost_lb_tg.arn
  }
}

resource "aws_lb_target_group" "ghost_lb_tg" {
  name                 = "ghost-tg"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 180
  vpc_id               = module.vpc.vpc_id

  health_check {
    healthy_threshold = 3
    interval          = 10
  }

  tags = merge(var.tags,
    {
      "Name" = "ghost-alb"
  })
}

resource "aws_security_group" "ghost_lb_sg" {
  name   = "ghost-sg-alb"
  vpc_id = module.vpc.vpc_id

  # Accept http traffic from the internet
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

  tags = merge(var.tags,
    {
      "Name" = "ghost-alb-sg"
  })
}

resource "aws_route53_zone" "ghost_zone" {
  name = "ghost-devblog-eu.com"
}

# This creates an SSL certificate
resource "aws_acm_certificate" "ghost_cert" {
  domain_name               = "ghost-devblog-eu.com"
  subject_alternative_names = ["*.ghost-devblog-eu.com"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_route53_record" "cert_validation" {
#   allow_overwrite = true
#   name            = tolist(aws_acm_certificate.ghost_cert.domain_validation_options)[0].resource_record_name
#   records         = [ tolist(aws_acm_certificate.ghost_cert.domain_validation_options)[0].resource_record_value ]
#   type            = tolist(aws_acm_certificate.ghost_cert.domain_validation_options)[0].resource_record_type
#   zone_id  = data.aws_route53_zone.public.id
#   ttl      = 60
#   provider = aws.account_route53
# }

# # This tells terraform to cause the route53 validation to happen
# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.ghost_cert.arn
#   validation_record_fqdns = [ aws_route53_record.cert_validation.fqdn ]
# }

# resource "aws_route53_record" "ghost-alias" {
#   zone_id = aws_route53_zone.ghost_zone.zone_id 
#   name    = "www.ghost-devblog-eu.com" 
#   type    = "A"

#   alias {
#     name                   = aws_lb.ghost_alb.dns_name
#     zone_id                = aws_lb.ghost_alb.zone_id
#     evaluate_target_health = false
#   }
# }
