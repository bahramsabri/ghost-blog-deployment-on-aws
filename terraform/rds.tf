resource "aws_db_instance" "default" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "ghostdb"
  username               = local.db_creds.username
  password               = local.db_creds.password
  db_subnet_group_name   = aws_db_subnet_group.mysql_subnet_group.name
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "main"
  subnet_ids = [module.vpc.database_subnets[0], module.vpc.database_subnets[1]]

  tags = merge(var.tags,
    {
      "Name" = "mysql-subnet-group"
  })
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql_sg"
  description = "mysql_sg"
  vpc_id      = module.vpc.vpc_id


  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "TCP"
    security_groups = [aws_security_group.ghost_asg_sg.id]
  }

  egress {
    from_port = 3306
    to_port   = 3306
    protocol  = "TCP"
    security_groups = [aws_security_group.ghost_asg_sg.id]
  }

  tags = merge(var.tags,
    {
      "Name" = "mysql-subnet-group"
  })
}