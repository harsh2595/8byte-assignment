data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "random_id" "alb_logs" {
  count = var.alb_access_logs_bucket == null ? 1 : 0

  byte_length = 4
}

resource "aws_s3_bucket" "alb_logs" {
  count = var.alb_access_logs_bucket == null ? 1 : 0

  bucket        = "${local.name}-alb-logs-${random_id.alb_logs[0].hex}"
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "${local.name}-alb-logs"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  count = var.alb_access_logs_bucket == null ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  count = var.alb_access_logs_bucket == null ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  count = var.alb_access_logs_bucket == null ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    id     = "expire-old-access-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 30
    }
  }
}

data "aws_iam_policy_document" "alb_logs" {
  count = var.alb_access_logs_bucket == null ? 1 : 0

  statement {
    sid = "AllowLoadBalancerAccessLogs"

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.alb_logs[0].arn}/${local.name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  count = var.alb_access_logs_bucket == null ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id
  policy = data.aws_iam_policy_document.alb_logs[0].json
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name
  cidr_block           = var.vpc_cidr
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  name     = local.name
  vpc_id   = module.vpc.vpc_id
  app_port = var.app_port
  tags     = local.common_tags
}

resource "aws_ecr_repository" "app" {
  name                 = "app-${local.name}-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-app"
  })
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 20 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

module "alb" {
  source = "../../modules/alb"

  name               = local.name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_id  = module.security_groups.alb_security_group_id
  app_port           = var.app_port
  access_logs_bucket = var.alb_access_logs_bucket == null ? aws_s3_bucket.alb_logs[0].id : var.alb_access_logs_bucket
  tags               = local.common_tags

  depends_on = [aws_s3_bucket_policy.alb_logs]
}

module "rds" {
  source = "../../modules/rds"

  name                      = local.name
  private_subnet_ids        = module.vpc.private_subnet_ids
  security_group_id         = module.security_groups.db_security_group_id
  db_name                   = var.db_name
  db_username               = var.db_username
  instance_class            = var.db_instance_class
  allocated_storage         = var.db_allocated_storage
  backup_retention_days     = var.backup_retention_days
  multi_az                  = false
  deletion_protection       = false
  skip_final_snapshot       = true
  final_snapshot_identifier = null
  tags                      = local.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  name                   = local.name
  aws_region             = var.aws_region
  environment            = var.environment
  ecr_repository_url     = aws_ecr_repository.app.repository_url
  image_tag              = var.image_tag
  app_port               = var.app_port
  desired_count          = var.desired_count
  cpu                    = var.ecs_cpu
  memory                 = var.ecs_memory
  private_subnet_ids     = module.vpc.private_subnet_ids
  security_group_id      = module.security_groups.app_security_group_id
  target_group_arn       = module.alb.target_group_arn
  db_host                = module.rds.db_address
  db_port                = module.rds.db_port
  db_name                = var.db_name
  db_user                = var.db_username
  db_password_secret_arn = module.rds.db_password_secret_arn
  log_retention_days     = var.log_retention_days
  tags                   = local.common_tags

  depends_on = [module.alb]
}

module "monitoring" {
  source = "../../modules/monitoring"

  name                    = local.name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  db_instance_identifier  = module.rds.db_instance_identifier
  alarm_email             = var.alarm_email
  tags                    = local.common_tags
}
