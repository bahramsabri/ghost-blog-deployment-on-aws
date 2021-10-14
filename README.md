# AWS Ghost Terraform module

Terraform module which creates a single instance Ghost deployment on AWS.

## Overview 

Ghost is a free and open source blogging platform written in JavaScript and distributed under the MIT License, designed to simplify the process of online publishing for individual bloggers as well as online publications. More information at [ghost.org](https://ghost.org/).

This module will allow you to deploy a single instance behind an Auto Scaling group and RDS using Terraform for high availability and ease of management. It is free tier eligible if you use the right instance sizes.

# Requirements

* An AWS account already setup
* A S3 bucket already defined for the Terraform state
* Terraform v0.14.x installed

## Usage

* Export your AWS credentials using the CLI or tools like Awsume or aws-vault
* Provide your remote state information in backend.tf -- feel free to remove s3 if you're not using it as you default backend
* Update all the default values in variables.tf 
* Then, run the below:
```
cd terraform
terraform init
terraform plan
terraform apply
```
