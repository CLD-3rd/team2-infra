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

# NAT Gateway 
# Single NAT Gateway shared across multiple private subnets.
module "nat_gateway" {
  source = "./modules/network/nat-gateway"

  name      = "${var.service_name}-NAT"
  subnet_id = module.subnets.public_subnet_ids[0]

  tags = {
    Name        = "${var.service_name}-NAT"
    Environment = var.environment
  }
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
          cidr_block     = "0.0.0.0/0"
          gateway_id     = module.internet_gateway.internet_gateway_id
          nat_gateway_id = null
        }
      ]
      tags = {}
    },
    {
      name       = "${var.service_name}-PrivateSubnetRouteTable"
      subnet_ids = module.subnets.private_subnet_ids
      routes = [
        {
          cidr_block     = "0.0.0.0/0"
          gateway_id     = null
          nat_gateway_id = module.nat_gateway.nat_gateway_id
        }
      ]
      tags = {}
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
# 호스팅사이트 네임서버 등록 필요
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
  subject_alternative_names = ["www.${local.domain_name}", "images.${local.domain_name}"]
  zone_id                   = module.dns.zone_id

  tags = {
    Name        = "DNS Certificate"
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
  service_name       = var.service_name
  allowed_methods    = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
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
    },
    {
      name = "images"
      type = "A"
      alias = {
        name                   = module.image_cdn.distribution_domain_name
        zone_id                = module.image_cdn.distribution_hosted_zone_id
        evaluate_target_health = false
      }
    }
  ]
}




# EKS Cluster
module "eks" {
  source = "./modules/eks"

  cluster_name       = "${lower(var.service_name)}-cluster"
  cluster_version    = var.eks_cluster_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = concat(module.subnets.public_subnet_ids, module.subnets.private_subnet_ids)
  private_subnet_ids = module.subnets.private_subnet_ids

  tags = {
    Name        = "${var.service_name}-EKS"
    Environment = var.environment
  }

  depends_on = [module.nat_gateway]
}

# Database Security Group
module "db_security_group" {
  source = "./modules/security-group"

  name        = "${var.service_name}-db-sg"
  description = "Security group for RDS database"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.eks.node_security_group_id
    }
  ]

  tags = {
    Name        = "${var.service_name}-db-sg"
    Environment = var.environment
  }
}

# Cache Security Group
module "cache_security_group" {
  source = "./modules/security-group"

  name        = "${var.service_name}-cache-sg"
  description = "Security group for ElastiCache"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                = 6379
      to_port                  = 6379
      protocol                 = "tcp"
      source_security_group_id = module.eks.node_security_group_id
    }
  ]

  tags = {
    Name        = "${var.service_name}-cache-sg"
    Environment = var.environment
  }
}

# RDS MySQL Database
module "rds" {
  source = "./modules/rds"

  identifier     = "${lower(var.service_name)}-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.m5.large"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "savemypodo"
  username = "admin"
  password = var.db_password

  vpc_security_group_ids = [module.db_security_group.security_group_id]
  subnet_ids            = module.subnets.private_subnet_ids

  multi_az                = true
  backup_retention_period = 3
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name        = "${var.service_name}-MySQL"
    Environment = var.environment
  }
}

# ElastiCache Redis
module "elasticache" {
  source = "./modules/elasticache"

  cluster_id     = "${lower(var.service_name)}-redis"
  engine         = "redis"
  engine_version = "7.0"
  node_type      = "cache.m5.large"

  security_group_ids = [module.cache_security_group.security_group_id]
  subnet_ids         = module.subnets.private_subnet_ids

  snapshot_retention_limit    = 3

  tags = {
    Name        = "${var.service_name}-Redis"
    Environment = var.environment
  }
}




module "image_bucket" {
  source = "./modules/s3"

  bucket_name               = "${lower(var.service_name)}-images"
  enable_website            = false
  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true

  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontOAC"
        Effect    = "Allow"
        Principal = {
          AWS = module.image_cdn.oac_arn
        }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${lower(var.service_name)}-images/*"
      }
    ]
  })

  tags = {
    Name        = "Image Storage"
    Environment = var.environment
  }
}

module "image_cdn" {
  source = "./modules/cloudfront"

  origin_domain_name = module.image_bucket.bucket_regional_domain_name
  origin_id          = "S3-${lower(var.service_name)}-images"
  aliases            = ["images.${local.domain_name}"]
  certificate_arn    = module.certificate.certificate_arn
  use_oac            = true
  service_name       = var.service_name

  tags = {
    Name        = "Image CDN"
    Environment = var.environment
  }

  depends_on = [module.certificate]
  
}
