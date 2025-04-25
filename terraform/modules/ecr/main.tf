# ECR module - creates an ECR repo for Docker images, add lifecycle policy to manage image retention, security config including encryption and scanning

# Create the ECR repository
resource "aws_ecr_repository" "ly_ecr" {
  name                 = var.repository_name # Repo name
  force_delete        = true  # Add this line to allow deletion even with images
  image_tag_mutability = "MUTABLE" # Allow overwriting of image tags

  # Config image scan for vulnerabilities
  image_scanning_configuration {
    scan_on_push = var.image_scan_on_push # Auto scan when pushed
  }

  # Config encryption for image at rest
  encryption_configuration {
    encryption_type = "KMS" # Use KMS encryption for enhanced security
  }

  # tags for resource management and cost allocation (Merge common tags)
  tags = merge(
    var.tags,
    {
      Name = var.repository_name
    }
  )
}

# Config lifecycle for image retention
resource "aws_ecr_lifecycle_policy" "main" {
  # Associate policy with ECR repo
  repository = aws_ecr_repository.ly_ecr.name

  # Policy JSON
  policy = jsonencode({
    rules = [{
      rulePriority = 1                    # Lower numbers are evaluated first
      description  = "Keep last 30 images" # Human-readable desc
      selection = {
        tagStatus   = "any"               # Apply to all images
        countType   = "imageCountMoreThan" # Type of count rule
        countNumber = 5                  # Number of images to keep
      }
      action = {
        type = "expire"                   # Delete images that match the selection criteria
      }
    }]
  })
}
