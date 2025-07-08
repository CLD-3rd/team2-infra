terraform {
  required_providers{
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.96.0"
    }
  }
  required_version = ">=1.11.3"
}

provider "aws" {
  region = "ap-northeast-2"
}

# VPC
module "vpc" {
  source = "./modules/network/vpc"

  name       = "${var.service_name}-VPC"
  cidr_block = "192.168.0.0/16"
}

# Subnets
module "subnets" {
  source = "./modules/network/subnet"

  vpc_id = module.vpc.vpc_id
  subnets = [
    {
      name              = "${var.service_name}-PublicSubnet1"
      cidr_block        = "192.168.1.0/24"
      availability_zone = "ap-northeast-2a"
      public            = true
      tags              = { "kubernetes.io/role/elb" = "1" }
    },
    {
      name              = "${var.service_name}-PublicSubnet2"
      cidr_block        = "192.168.2.0/24"
      availability_zone = "ap-northeast-2b"
      public            = true
      tags              = { "kubernetes.io/role/elb" = "1" }
    },
    {
      name              = "${var.service_name}-PublicSubnet3"
      cidr_block        = "192.168.3.0/24"
      availability_zone = "ap-northeast-2c"
      public            = true
      tags              = { "kubernetes.io/role/elb" = "1" }
    },
    {
      name              = "${var.service_name}-PrivateSubnet1"
      cidr_block        = "192.168.11.0/24"
      availability_zone = "ap-northeast-2a"
      public            = false
      tags              = { "kubernetes.io/role/internal-elb" = "1" }
    },
    {
      name              = "${var.service_name}-PrivateSubnet2"
      cidr_block        = "192.168.12.0/24"
      availability_zone = "ap-northeast-2b"
      public            = false
      tags              = { "kubernetes.io/role/internal-elb" = "1" }
    },
    {
      name              = "${var.service_name}-PrivateSubnet3"
      cidr_block        = "192.168.13.0/24"
      availability_zone = "ap-northeast-2c"
      public            = false
      tags              = { "kubernetes.io/role/internal-elb" = "1" }
    }
  ]
}

# Internet Gateway
module "internet_gateway" {
  source = "./modules/network/internet-gateway"

  vpc_id = module.vpc.vpc_id
  name   = "${var.service_name}-IGW"
}

# Route Tables
module "route_tables" {
  source = "./modules/network/route-table"

  vpc_id = module.vpc.vpc_id
  route_tables = [
    {
      name       = "${var.service_name}-PublicSubnetRouteTable"
      subnet_ids = module.subnets.public_subnet_ids
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = module.internet_gateway.internet_gateway_id
        }
      ]
    },
    {
      name       = "${var.service_name}-PrivateSubnetRouteTable"
      subnet_ids = module.subnets.private_subnet_ids
      routes     = []
    }
  ]
}

