/*--------------------------------------------------------------------------------------------------
  Global 
--------------------------------------------------------------------------------------------------*/

variable "region" {
  description = "Region where the resources will be deployed"
  type        = string
  default     = "eu-west-1"
}

variable "tags" {
  description = "Global tags applied to every resource by default"
  default = {
    Terraform = "true"
    Project   = "ghost"
  }
}

/*--------------------------------------------------------------------------------------------------
  VPC
--------------------------------------------------------------------------------------------------*/

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnets" {
  description = "Public subnets where the ghost instances will be deployed"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
  description = "Private subvnets where the RDS instance will be deployed"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

/*--------------------------------------------------------------------------------------------------
  EC2 / ASG
--------------------------------------------------------------------------------------------------*/

variable "asg_max_size" {
  description = "ASG maximum instance count"
  type        = string
  default     = 1
}

variable "asg_min_size" {
  description = "ASG minumum instance count"
  type        = string
  default     = 1
}
