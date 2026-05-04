# Challenges and Resolutions

## Challenge: Keeping Scope Realistic

The assignment asks for infrastructure, CI/CD, monitoring, logging, security, backups, and documentation. Building a complex application would distract from those goals.

Resolution:

I used a small API with health, readiness, metrics, and PostgreSQL endpoints. This gives the platform enough surface area to demonstrate deployment and observability without spending time on business logic.

## Challenge: First-Time ECR Bootstrap

The deployment workflow pushes images to ECR, but the ECR repository itself is managed by Terraform.

Resolution:

The documented bootstrap flow provisions infrastructure with `desired_count=0` first. That creates ECR without requiring ECS to pull an image. After the first image is pushed, Terraform can deploy the ECS service normally.

## Challenge: Secret Handling

Database credentials must be available to the app without being committed to the repository or exposed in pipeline logs.

Resolution:

Terraform generates the database password and stores it in AWS Secrets Manager. ECS injects the password into the container at runtime using the task execution role.

## Challenge: Balancing Cost and Production Practices

High availability choices like NAT Gateway per AZ and RDS Multi-AZ increase reliability but also increase assignment cost.

Resolution:

The default configuration uses cost-aware settings and documents the production upgrades clearly. Production has safer defaults like deletion protection and longer backups, while Multi-AZ is configurable.

## Challenge: Observability Without Extra Platform Overhead

Prometheus and Grafana are powerful, but they add operational components that may be too heavy for a 9-12 hour assignment.

Resolution:

CloudWatch is used for infrastructure metrics, logs, dashboards, and alarms. The application still exposes `/metrics`, so a Prometheus-based setup can be added later.
