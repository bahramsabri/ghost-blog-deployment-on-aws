module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name             = "ghost_vpc"
  cidr             = "10.0.0.0/16"
  azs              = var.azs
  database_subnets = var.database_subnets
  public_subnets   = var.public_subnets

  tags = var.tags
}