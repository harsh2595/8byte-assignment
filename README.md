# 8Byte DevOps Assignment

This repository demonstrates a production-style deployment platform around a small Node.js API. The application logic is intentionally simple; the focus is infrastructure provisioning, CI/CD, monitoring, logging, security, backups, and clear operational documentation.

## Stack

- Node.js API with health, readiness, metrics, and PostgreSQL-backed sample endpoints
- Docker and Docker Compose for local development
- Terraform for AWS infrastructure
- ECS Fargate for application hosting
- Amazon RDS PostgreSQL for the database
- Application Load Balancer for public traffic
- Amazon ECR for container images
- CloudWatch Logs, dashboards, and alarms
- GitHub Actions for PR checks, staging deployment, and approved production deployment

## Architecture

```text
Internet
  -> Application Load Balancer in public subnets
  -> ECS Fargate tasks in private subnets
  -> RDS PostgreSQL in private subnets

GitHub Actions
  -> test and scan
  -> build Docker image
  -> push image to ECR
  -> terraform apply
  -> smoke test
```

More detail is available in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Repository Layout

```text
app/                         Node.js API, Dockerfile, docker-compose
terraform/bootstrap/          Terraform state S3 bucket and DynamoDB lock table
terraform/environments/       Staging and production Terraform roots
terraform/modules/            Reusable AWS infrastructure modules
.github/workflows/            CI/CD workflows
docs/                         Approach, architecture, and challenges
ASSIGNMENT_BLUEPRINT.md       Original execution blueprint
```

## Local Development

Run the application and local PostgreSQL:

```bash
cd app
docker compose up --build
```

Check the service:

```bash
curl -sS http://localhost:4000/health
curl -sS http://localhost:4000/ready
curl -sS http://localhost:4000/metrics
```

Run the smoke test:

```bash
bash scripts/smoke-test.sh http://localhost:4000
```

Run tests locally:

```bash
cd app
npm install
npm test
```

## Terraform State Setup

Remote state is managed with:

- S3 bucket for state storage
- DynamoDB table for state locking
- Separate state keys for staging and production

Bootstrap the state backend once:

```bash
cd terraform/bootstrap
terraform init
terraform apply -var="state_bucket_name=<globally-unique-bucket-name>"
```

Then update these backend files with the created bucket name:

- `terraform/environments/staging/backend.tf`
- `terraform/environments/production/backend.tf`

## Provision Staging

The first deployment needs ECR to exist before the CI pipeline can push an image. A practical bootstrap path is:

```bash
cd terraform/environments/staging
terraform init
terraform apply -var="desired_count=0" -var="image_tag=bootstrap"
```

After that, push an image through the staging GitHub Actions workflow or manually push to ECR, then deploy normally:

```bash
terraform apply -var="image_tag=<image-tag>" -var="desired_count=1"
```

Useful outputs:

```bash
terraform output application_url
terraform output ecr_repository_url
terraform output application_dashboard_name
terraform output database_dashboard_name
```

## CI/CD

### Pull Requests

`.github/workflows/pr-checks.yml` runs:

- Node dependency install
- syntax/lint check
- unit tests
- dependency vulnerability scan
- Docker image build
- container vulnerability scan with Trivy
- Terraform format and validation
- Terraform security scan with Trivy

### Staging

`.github/workflows/deploy-staging.yml` runs on merge to `main`:

- assumes AWS role through GitHub OIDC
- builds Docker image
- pushes image to ECR
- runs Terraform apply for staging
- smoke tests `/health` and `/ready`
- sends Slack notification on failure if `SLACK_WEBHOOK_URL` is configured

### Production

`.github/workflows/deploy-production.yml` is manually triggered with an image tag. It uses GitHub Environments for production approval before deployment.

Required repository configuration:

- GitHub environment: `staging`
- GitHub environment: `production` with required reviewers
- Secret: `AWS_ROLE_TO_ASSUME`
- Optional secret: `SLACK_WEBHOOK_URL`
- Optional variable: `AWS_REGION`
- Optional variable: `STAGING_ECR_REPOSITORY`
- Optional variable: `PRODUCTION_ECR_REPOSITORY`

## Monitoring and Logging

The Terraform monitoring module creates:

- Application dashboard
- Database dashboard
- ECS CPU and memory alarms
- ALB 5xx and unhealthy target alarms
- RDS CPU and low storage alarms
- Optional SNS email notifications

Application logs are written as structured JSON to stdout and collected by ECS into CloudWatch Logs.

ALB access logs are written to an encrypted S3 bucket with lifecycle retention. You can provide an existing bucket with `alb_access_logs_bucket`; otherwise Terraform creates one.

## Security Considerations

- RDS is private and not publicly accessible
- ECS tasks run in private subnets
- ALB is the only public application entry point
- Security groups allow only required traffic paths
- Database password is generated by Terraform and stored in AWS Secrets Manager
- ECS receives the DB password as a runtime secret
- Terraform state is stored remotely with encryption and locking
- GitHub Actions is designed for OIDC role assumption instead of long-lived AWS keys
- Container and Terraform scans run in CI

## Backup Strategy

RDS automated backups are enabled:

- staging default retention: 7 days
- production default retention: 14 days
- production has deletion protection and final snapshot enabled

Restore approach:

1. Create a new RDS instance from the selected automated backup or snapshot.
2. Validate application connectivity.
3. Update Terraform or application configuration to point traffic to the restored database if required.

## Cost Optimization

- Small ECS task sizes by default
- Small RDS instance classes by default
- One NAT Gateway for assignment cost control
- Shorter log retention in staging
- ECR lifecycle policy limits old images
- Staging can be destroyed after review

For a real high-availability production system, use one NAT Gateway per AZ and enable RDS Multi-AZ.

## Cleanup

Destroy environments when no longer needed:

```bash
cd terraform/environments/staging
terraform destroy
```

Production RDS has deletion protection enabled, so disable it intentionally before destroying production.
