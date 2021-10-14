data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "ghost" {
  key_name   = "ghost-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0sFNx88YL41vfsCWrLfP0EUn+sX57yjXqZUi07MkNQZ88CG7KeTm5HpmyJEN+jXnJy58RKleGEsdO64g0sEBrGaCYlvkupVpM3vO6QgWhyaeqfdWMpvFlDzuqXSxUb36g5OdHRXyo3f4WIiTV6Q7xwrOWdFXp3gMRUXh2W+3DeehulQzRTzgtSqGm2g9Oi/QsKdLIy/cgp9/cCdCqA+YpODE/R7SYQrGyBF3Zvipw+F3qRZhiVD6+LVskJcsMbPNO+9FCrqT5KdtVkXgKzsRJpohFtzVyDYCPht5zLCYYdSiCd2hBfY7fM1F4HeEkmtxS1f0gpNVrZAbIVMv+3DuLg25UT3FONJt91fQG8xMfumynJkhB4TDP6GxsdH7EpujTHNIMKdlTVRwtjfkFvIh3snH1Aq5KiL+rMRTRc1NrdYmuiIBR2qdFdpv9DfjQ+1aB1tSgWId0CP+ZtMNeWdw/+/azmYgGmljCEstJHCtflbuFv5R1Nhfp0tSMk4gBygXMnZBEdhhZCVCLmuf4ud1YpgkF1VOLDvin19tfBf/X2Ha7cuiUZMhcbZiJp5aMmVJGkqNuauNSG9wJCZRJKjsN42UCPVzAsVPgfONOYc/XbagEyLx7ap4rTZ1PLOwYR2avb/ElLSJhp0Iet8IkTWfPD1NO4WOaYEyvsCm4AzJoOQ== bas@bas-Precision-5550"
}

resource "aws_launch_configuration" "ghost_lc" {
  name_prefix          = "ghost-lc"
  image_id             = data.aws_ami.ubuntu.image_id
  security_groups      = [aws_security_group.ghost_asg_sg.id]
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name             = aws_key_pair.ghost.key_name

  user_data = templatefile("${path.module}/user_data/ghost_init.sh",
    {
      "endpoint"  = aws_db_instance.default.address,
      "database"  = aws_db_instance.default.name,
      "username"  = aws_db_instance.default.username,
      "password"  = aws_db_instance.default.password,
      "admin_url" = "http://admin.ghost-devblog-eu.com",
      "url"       = "http://ghost-devblog-eu.com"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ghost_asg" {
  name                 = "ghost-asg"
  launch_configuration = aws_launch_configuration.ghost_lc.name
  max_size             = var.asg_max_size
  min_size             = var.asg_min_size
  vpc_zone_identifier  = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  target_group_arns = [aws_lb_target_group.ghost_lb_tg.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ghost_asg_sg" {
  name        = "ghost-asg-sg"
  description = "Security group for the ghost instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Ingress rule for http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.ghost_lb_sg.id]
  }

  ingress {
    description = "Ingress rule for https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.ghost_lb_sg.id]
  }

  ingress {
    description = "Ingress rule for ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["80.208.77.34/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    {
      "Name" : "ghost-asg-sg"
  })
}
