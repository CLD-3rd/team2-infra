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

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
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



# Website Hosting
locals {
  domain_name = "savemypodo.shop"
  bucket_name = "savemypodo-website"
}

# S3 Bucket for Website
module "website_bucket" {
  source = "./modules/s3"

  bucket_name               = local.bucket_name
  enable_website            = true
  block_public_acls         = false
  block_public_policy       = false
  ignore_public_acls        = false
  restrict_public_buckets   = false
  
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${local.bucket_name}/*"
      }
    ]
  })

  tags = {
    Name        = "Website Hosting"
    Environment = var.environment
  }
}

# Route53 Hosted Zone
module "dns" {
  source = "./modules/route53"

  domain_name = local.domain_name
  create_zone = true

  tags = {
    Name        = "Website DNS"
    Environment = var.environment
  }
}

# ACM Certificate
module "certificate" {
  source = "./modules/acm"

  domain_name               = local.domain_name
  subject_alternative_names = ["www.${local.domain_name}"]
  zone_id                   = module.dns.zone_id

  tags = {
    Name        = "Website Certificate"
    Environment = var.environment
  }

  providers = {
    aws = aws.us_east_1
  }
}

# CloudFront Distribution
module "cdn" {
  source = "./modules/cloudfront"

  origin_domain_name = module.website_bucket.website_endpoint
  origin_id          = "S3-${local.bucket_name}"
  aliases            = [local.domain_name, "www.${local.domain_name}"]
  certificate_arn    = module.certificate.certificate_arn

  custom_error_responses = [
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]

  tags = {
    Name        = "Website CDN"
    Environment = var.environment
  }

  depends_on = [module.certificate]
}

# DNS Records
module "dns_records" {
  source = "./modules/route53"

  domain_name = local.domain_name
  create_zone = false
  zone_id     = module.dns.zone_id

  records = [
    {
      name = ""
      type = "A"
      alias = {
        name                   = module.cdn.distribution_domain_name
        zone_id                = module.cdn.distribution_hosted_zone_id
        evaluate_target_health = false
      }
    },
    {
      name = "www"
      type = "A"
      alias = {
        name                   = module.cdn.distribution_domain_name
        zone_id                = module.cdn.distribution_hosted_zone_id
        evaluate_target_health = false
      }
    }
  ]
}

