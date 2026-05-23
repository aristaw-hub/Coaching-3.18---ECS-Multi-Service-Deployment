resource "aws_ecr_repository" "s3_repo" {
  name = "s3-service-arista"
}

resource "aws_ecr_repository" "sqs_repo" {
  name = "sqs-service-arista"
}