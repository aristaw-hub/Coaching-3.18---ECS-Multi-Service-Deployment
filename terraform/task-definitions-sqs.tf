resource "aws_ecs_task_definition" "sqs_task" {
  family                   = "sqs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "sqs-service"
      image = "255945442255.dkr.ecr.ap-southeast-1.amazonaws.com/sqs-service-arista:latest"

      portMappings = [
        {
          containerPort = 5002
        }
      ]

      environment = [
        {
          name  = "AWS_REGION"
          value = "ap-southeast-1"
        },
        {
          name  = "QUEUE_URL"
          value = "https://sqs.ap-southeast-1.amazonaws.com/255945442255/ecs-message-queue-arista"
        }
      ]
    }
  ])
}