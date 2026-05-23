# -----------------------------
# ECS EXECUTION ROLE
# -----------------------------
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsExecutionRoleArista"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach AWS managed policy for ECS execution
resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------
# ECS TASK ROLE (for S3 + SQS access)
# -----------------------------
resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRoleArista"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Custom permissions for S3 + SQS
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "ecsTaskPolicyArista"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ],
        Resource = "*"
      }

    ]
  })
}