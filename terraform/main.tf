# InterviewCoach ECR Repository Terraform Configuration
# This creates an Elastic Container Registry to store Docker images

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create ECR Repository for InterviewCoach application
resource "aws_ecr_repository" "interviewcoach" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  # Enable image scanning for security vulnerabilities
  image_scanning_configuration {
    scan_on_push = true
  }

  # Enable encryption at rest
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "InterviewCoach ECR Repository"
    Project     = "InterviewCoach"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Lifecycle policy to clean up old images (keep last 10 images)
resource "aws_ecr_lifecycle_policy" "interviewcoach_policy" {
  repository = aws_ecr_repository.interviewcoach.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
