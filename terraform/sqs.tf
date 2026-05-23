resource "aws_sqs_queue" "queue" {
  name = "ecs-message-queue-arista"
}