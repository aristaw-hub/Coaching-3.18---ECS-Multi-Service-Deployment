resource "aws_ecs_task_definition" "s3_task" {
  family                   = "s3-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "s3-service"
      image = "255945442255.dkr.ecr.ap-southeast-1.amazonaws.com/s3-service-arista:latest"

      portMappings = [
        {
          containerPort = 5001
        }
      ]

      environment = [
        {
          name  = "AWS_REGION"
          value = "ap-southeast-1"
        },
        {
          name  = "BUCKET_NAME"
          value = "arista-ecs-upload-bucket-23may2026"
        }
      ]
    }
  ])
}