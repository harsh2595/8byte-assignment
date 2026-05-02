# 8Byte DevOps Assignment Blueprint

## Goal

Build a small production-style application platform that demonstrates end-to-end ownership across infrastructure provisioning, CI/CD, monitoring, logging, documentation, and operational best practices.

Application business logic is not the focus. We will use a simple ready-made web application, containerize it, and spend most effort on the platform around it.

## Recommended Approach

Use AWS with Terraform, Docker, GitHub Actions, and a lightweight application stack.

Preferred architecture:

- Frontend/API application hosted on ECS Fargate
- PostgreSQL database on Amazon RDS
- Application Load Balancer in public subnets
- ECS tasks in private subnets
- RDS in private database subnets
- Docker images stored in Amazon ECR
- Logs sent to CloudWatch Logs
- Metrics and dashboards in CloudWatch
- Secrets stored in AWS Secrets Manager or SSM Parameter Store

This keeps the assignment realistic, cloud-native, and easier to explain than managing EC2 instances manually.

## Repository Structure

```text
.
├── app/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── application source code
├── terraform/
│   ├── environments/
│   │   ├── staging/
│   │   └── production/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── ecs/
│   │   ├── rds/
│   │   ├── alb/
│   │   ├── security-groups/
│   │   └── monitoring/
│   ├── backend.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── main.tf
├── .github/
│   └── workflows/
│       ├── pr-checks.yml
│       ├── deploy-staging.yml
│       └── deploy-production.yml
├── docs/
│   ├── APPROACH.md
│   ├── ARCHITECTURE.md
│   └── CHALLENGES.md
└── README.md
```

## Part 1: Infrastructure Provisioning

### Terraform Infrastructure

Create Terraform modules for:

- VPC
- Public and private subnets across two Availability Zones
- Internet Gateway and NAT Gateway
- Route tables
- Security groups
- Application Load Balancer
- ECS cluster, task definition, and service
- ECR repository
- RDS PostgreSQL instance
- CloudWatch log groups
- CloudWatch dashboards and alarms

### Networking Design

Public subnets:

- Application Load Balancer
- NAT Gateway

Private subnets:

- ECS application tasks
- RDS PostgreSQL database

Traffic flow:

```text
User -> ALB -> ECS Service -> RDS PostgreSQL
```

### Security Groups

Use least-privilege access:

- ALB accepts HTTP/HTTPS from the internet
- ECS accepts traffic only from ALB security group
- RDS accepts PostgreSQL traffic only from ECS security group
- No public access to RDS
- No direct SSH access required if using ECS Fargate

### Terraform State Management

Use remote state:

- S3 bucket for Terraform state
- DynamoDB table for state locking
- Separate state paths for staging and production

Example:

```text
s3://terraform-state-bucket/8byte/staging/terraform.tfstate
s3://terraform-state-bucket/8byte/production/terraform.tfstate
```

### Terraform Variables

Make these configurable in `variables.tf`:

- AWS region
- environment name
- VPC CIDR
- public/private subnet CIDRs
- ECS CPU and memory
- application image tag
- RDS instance class
- database name
- database username
- desired ECS task count

### Terraform Outputs

Expose key outputs:

- ALB DNS name
- ECS cluster name
- ECS service name
- RDS endpoint
- ECR repository URL
- VPC ID
- public subnet IDs
- private subnet IDs

## Part 2: Deployment Automation

Use GitHub Actions.

### Pull Request Pipeline

Triggered on pull requests.

Steps:

- Checkout code
- Install dependencies
- Run linting
- Run unit tests
- Run integration tests if lightweight
- Run dependency vulnerability scan
- Run Docker build check
- Run container vulnerability scan

Recommended tools:

- `npm test`, `pytest`, or equivalent depending on app
- Trivy for container scanning
- GitHub dependency review or npm audit
- Terraform fmt and validate
- Checkov or tfsec for Terraform scanning

### Merge to Main Pipeline

Triggered on push to `main`.

Steps:

- Run tests again
- Build Docker image
- Tag image with commit SHA
- Push image to Amazon ECR
- Deploy to staging ECS service
- Run smoke test against staging ALB URL
- Notify Slack/email on failure

### Production Deployment

Use GitHub Actions environment protection.

Flow:

```text
Merge to main -> staging deploy -> smoke test -> manual approval -> production deploy
```

Production deployment should:

- Require manual approval
- Reuse the already-built image tag
- Update production ECS service
- Wait for ECS service stability
- Run production smoke test

### Notifications

For assignment scope, implement one of:

- Slack webhook notification on failure
- Email notification through GitHub Actions marketplace action
- GitHub issue/comment notification

Slack webhook is easiest to demonstrate.

## Part 3: Monitoring and Logging

### Infrastructure Metrics

Monitor:

- ECS CPU utilization
- ECS memory utilization
- ECS running task count
- ALB request count
- ALB target response time
- ALB 4xx and 5xx errors
- RDS CPU utilization
- RDS memory
- RDS connections
- RDS storage

### Application Metrics

Minimum useful metrics:

- request rate
- error rate
- latency
- health-check status

Happy-path implementation:

- Expose `/health`
- Use ALB metrics for request/error/latency
- Optionally add app-level Prometheus-style metrics if time permits

### Centralized Logging

Send logs to CloudWatch Logs:

- ECS application logs
- ECS task/system logs
- ALB access logs to S3
- RDS logs if enabled

Log groups:

```text
/8byte/staging/app
/8byte/production/app
```

### Dashboards

Create at least two dashboards:

1. Application Health Dashboard
   - ALB request count
   - ALB 5xx errors
   - target response time
   - ECS CPU and memory
   - ECS task count

2. Database Health Dashboard
   - RDS CPU
   - RDS connections
   - free storage
   - read/write IOPS
   - database latency if available

### Alerts

Create basic CloudWatch alarms:

- high ECS CPU
- high ECS memory
- ALB 5xx error spike
- unhealthy ECS targets
- high RDS CPU
- low RDS free storage

## Part 4: Documentation and Best Practices

### README Content

The final `README.md` should include:

- Project overview
- Architecture diagram
- Prerequisites
- Local development steps
- Docker build/run steps
- Terraform setup steps
- Staging deployment flow
- Production deployment flow
- CI/CD explanation
- Monitoring/logging explanation
- Security considerations
- Cost optimization notes
- Cleanup instructions

### Approach Documentation

`docs/APPROACH.md` should explain:

- Why ECS Fargate was selected
- Why RDS is private
- Why Terraform modules are used
- Why remote state is required
- Why GitHub Actions environments are used for approvals
- What tradeoffs were made to finish in assignment time

### Challenges Documentation

`docs/CHALLENGES.md` should include:

- Challenge
- Root cause
- Resolution
- What would be improved with more time

This is important because the assignment explicitly asks for challenges faced and resolutions.

## Security Practices

Minimum implementation:

- RDS is not publicly accessible
- ECS tasks run in private subnets
- Security groups allow only required traffic
- Secrets are not committed to Git
- Database password stored in Secrets Manager or SSM Parameter Store
- GitHub Actions uses OIDC to assume AWS role if time permits
- Terraform state is stored remotely and locked
- Container vulnerability scanning is included

Good talking points:

- Use IAM roles instead of static AWS keys where possible
- Rotate secrets periodically
- Use HTTPS listener with ACM certificate in production
- Restrict production deployments through manual approval
- Enable deletion protection for production RDS

## Backup Strategy

Implement RDS automated backups:

- Enable automated backups
- Set retention period, for example 7 days for staging and 14-30 days for production
- Enable final snapshot before deletion for production
- Document restore approach

Optional improvement:

- Add AWS Backup plan for RDS

## Cost Optimization

For assignment/demo:

- Use small RDS instance class
- Use minimal ECS task CPU/memory
- Use one NAT Gateway for cost control, with note that production can use one NAT Gateway per AZ
- Use short log retention for staging
- Use autoscaling only where useful
- Destroy staging resources after demo if not needed

## Implementation Phases

### Phase 1: Foundation

- Pick simple ready-made app
- Make app run locally
- Add Dockerfile
- Add docker-compose with PostgreSQL
- Add health endpoint if missing

### Phase 2: Terraform

- Create VPC module
- Create security groups
- Create RDS module
- Create ECR repository
- Create ECS module
- Create ALB module
- Add outputs and variables
- Add remote backend documentation

### Phase 3: CI/CD

- Add PR checks workflow
- Add Docker build and push workflow
- Add staging deployment workflow
- Add production deployment with manual approval
- Add vulnerability scans
- Add failure notification

### Phase 4: Observability

- Add CloudWatch log groups
- Configure ECS logs
- Configure ALB access logs
- Add dashboards
- Add alarms

### Phase 5: Documentation

- Write README
- Write approach documentation
- Write challenges and resolutions
- Add architecture diagram
- Add cleanup instructions

## Happy Path First

To finish efficiently, build this order:

1. Local app works with Docker
2. Terraform creates staging infrastructure
3. ECS serves app behind ALB
4. App connects to RDS
5. GitHub Actions deploys staging
6. Monitoring/logging added
7. Production environment added by reusing staging pattern
8. Documentation polished

## Extra Improvements If Time Allows

- HTTPS with ACM certificate
- ECS autoscaling
- Blue/green deployment using CodeDeploy
- GitHub OIDC instead of static AWS credentials
- Prometheus/Grafana instead of only CloudWatch
- Database migration workflow
- Load testing with k6
- WAF in front of ALB
- Private VPC endpoints for ECR and CloudWatch

## Final Deliverables

The final submission should include:

- GitHub repository URL
- Working application source
- Dockerfile and local run instructions
- Terraform infrastructure code
- GitHub Actions workflows
- Monitoring dashboards
- Centralized logging setup
- Secret management implementation
- Backup strategy
- README
- Approach documentation
- Challenges and resolutions document

## Recommended Candidate Explanation

The assignment should be presented as:

> I focused on building a practical production-like deployment platform around a simple application. The application logic is intentionally simple because the assignment evaluates infrastructure ownership, automation, security, observability, and operational thinking. I used Terraform modules for repeatable infrastructure, ECS Fargate to avoid server management overhead, RDS for managed PostgreSQL, GitHub Actions for CI/CD, and CloudWatch for centralized logs and dashboards. I implemented the happy path first, then added security, monitoring, vulnerability scanning, approvals, and documentation.

