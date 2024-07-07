provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "bucket1"
}

resource "aws_ecr_repository" "repo" {
  name = "ecrrepo1"
}

resource "aws_codecommit_repository" "repo" {
  repository_name = "MyRepo"
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_codebuild_project" "project" {
  name           = "codebuild1"
  service_role   = aws_iam_role.codebuild_role.arn
  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.repo.clone_url_http
    buildspec       = <<EOF
version: 0.2

phases:
  pre_build:
    commands:
      - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
  build:
    commands:
      - docker build -t ${aws_ecr_repository.repo.repository_url}:latest .
      - docker push ${aws_ecr_repository.repo.repository_url}:latest
EOF
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    environment_variable {
      name  = "REPOSITORY_URI"
      value = aws_ecr_repository.repo.repository_url
    }
  }
}

resource "aws_codepipeline" "pipeline" {
  name = "codepipeline1"

  role_arn = aws_iam_role.codebuild_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.repo.repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.project.name
      }
    }
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "cluster1"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "task1"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"

  container_definitions = <<DEFINITION
[
  {
    "name": "my-container",
    "image": "${aws_ecr_repository.repo.repository_url}:latest",
    "memory": 512,
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "logging1",
        "awslogs-region": "ap-south-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "service" {
  name            = "service1"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  network_configuration {
    subnets = ["subnet-1", "subnet-2"]
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/loggroup1"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name          = "cpu-80p-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = []

  dimensions = {
    ClusterName = aws_ecs_cluster.cluster.name
    ServiceName = aws_ecs_service.service.name
  }
}
