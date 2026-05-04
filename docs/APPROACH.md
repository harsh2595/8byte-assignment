# Approach

## Guiding Principle

The assignment evaluates platform ownership more than application complexity. I kept the app intentionally small and focused the implementation on infrastructure, automation, security, observability, and documentation.

## Infrastructure Choice

AWS was selected because the requested components map naturally to managed services:

- VPC, public subnets, and private subnets for network isolation
- ECS Fargate for container hosting
- RDS PostgreSQL for managed database operations
- ALB for frontend traffic
- ECR for container registry
- CloudWatch for logs, metrics, dashboards, and alarms
- Secrets Manager for database credentials

## Why ECS Fargate

ECS Fargate gives a strong happy path for this assignment:

- no EC2 instance patching
- simple Docker deployment model
- direct ALB integration
- native CloudWatch logging
- task-level IAM roles
- easier to explain and operate than Kubernetes for this scope

EKS would be reasonable for a larger platform, but it would add cluster management overhead that does not improve this assignment much.

## Terraform Design

Terraform is split into reusable modules:

- VPC
- security groups
- ALB
- RDS
- ECS
- monitoring

Staging and production have separate root modules and separate remote state keys. This avoids accidental cross-environment changes and makes environment-specific defaults explicit.

## CI/CD Design

The pipeline follows a normal promotion flow:

```text
pull request -> tests and scans
main merge -> build image -> deploy staging -> smoke test
manual approval -> deploy production
```

GitHub Actions environments are used for production approval because they are simple, auditable, and built into GitHub.

## Security Design

Security controls implemented:

- no public RDS access
- ECS tasks in private subnets
- ALB is the only public entry point
- security group references instead of broad CIDR access
- Secrets Manager for DB password
- encrypted RDS storage
- encrypted S3 buckets for ALB access logs
- encrypted Terraform state bucket
- CI vulnerability scanning
- OIDC-compatible AWS authentication in GitHub Actions

## Backup Strategy

RDS automated backups are enabled with different retention by environment:

- staging: 7 days
- production: 14 days

Production also enables deletion protection and final snapshot behavior.

## Cost Decisions

The design intentionally keeps assignment cost under control:

- small ECS tasks
- small RDS instances
- single NAT Gateway
- short staging log retention
- access log lifecycle expiration
- optional Multi-AZ RDS in production

In a real production environment, the first upgrades would be Multi-AZ RDS and NAT Gateway per AZ.

## Tradeoffs

- HTTP listener is included by default; HTTPS with ACM is listed as a next improvement.
- CloudWatch dashboards are used instead of a full Prometheus/Grafana stack to keep operational setup smaller.
- Database migration is handled by the small app bootstrapping its table; a real service should use a dedicated migration tool.
- Production workflow rebuilds the image for the selected ref; a stricter promotion model would copy the exact staged image digest into the production registry.

## Future Improvements

- ACM certificate and HTTPS listener
- WAF in front of ALB
- VPC endpoints for ECR, CloudWatch, and Secrets Manager
- blue/green ECS deployments with CodeDeploy
- database migration pipeline
- load testing with k6
- tighter IAM policies for KMS decrypt
- exact image digest promotion from staging to production
