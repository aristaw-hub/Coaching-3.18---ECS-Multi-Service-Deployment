# Coaching 3.18 - ECS Multi-Service Deployment

Mono repo: All applications & IaC goes into a single repository.

## Architecture

- **Service 1 (S3 Upload)**: Flask app that allows users to upload files to S3 bucket
- **Service 2 (SQS Sender)**: Flask app that allows users to send messages to SQS queue
- **Infrastructure**: Terraform-managed ECS cluster with Fargate tasks

## Repository Structure

ecs-monorepo/
├── applications/
│   ├── s3-service/
│   │   ├── app.py
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   └── sqs-service/
│       ├── app.py
│       ├── requirements.txt
│       ├── Dockerfile
│       └── .dockerignore
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── ecs.tf
│   ├── iam.tf
│   ├── ecr.tf
│   ├── s3.tf
│   └── sqs.tf
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       ├── s3-service.yml
│       └── sqs-service.yml
├── README.md
└── .gitignore

## Prerequisites

- AWS Account with appropriate permissions
- GitHub repository with the following secrets:
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
- Terraform installed locally (for testing)

## Deployment Order

1. Deploy Infrastructure (Terraform) - Manual trigger
2. Deploy Applications - Automatic on push to main

## Accessing Services

After deployment, get the public IP from ECS tasks:

```bash
aws ecs list-tasks --cluster ecs-monorepo-cluster --service-name s3-upload-service
aws ecs describe-tasks --cluster ecs-monorepo-cluster --tasks <task-id>
