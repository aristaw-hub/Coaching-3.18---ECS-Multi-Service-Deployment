# -----------------------------
# VPC (Default)
# -----------------------------
data "aws_vpc" "default" {
  default = true
}

# -----------------------------
# Subnets (Default VPC)
# -----------------------------
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -----------------------------
# ECS CLUSTER
# -----------------------------
resource "aws_ecs_cluster" "main" {
  name = "ecs-lab-cluster-arista"
}

# -----------------------------
# ECS SERVICE - S3
# -----------------------------
resource "aws_ecs_service" "s3_service" {
  name            = "s3-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.s3_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
  }
}

# -----------------------------
# ECS SERVICE - SQS
# -----------------------------
resource "aws_ecs_service" "sqs_service" {
  name            = "sqs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.sqs_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
  }
}