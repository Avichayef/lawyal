# Complete Deployment Guide

This repository uses a comprehensive GitHub Actions workflow for automated deployment. The workflow handles everything from infrastructure deployment to application updates.

## Deployment Process

The workflow triggers automatically on pushes to main branch when changes are detected in:
- `terraform/**`
- `app/**`
- `helm/**`
- `.github/workflows/**`

### Workflow Steps

1. **Set Secret in GH secrets**
   - set secrets to GitHub secrets/variables

2. **Infrastructure Deployment**
   - Initializes Terraform
   - Applies infrastructure changes

3. **Application Deployment**
   - Builds Docker image
   - Pushes to ECR
   - Deploys to EKS using Helm


## Maintenance

Regular maintenance tasks:
- Rotate AWS credentials
- Update GitHub PAT
- Review and update infrastructure code
- Keep dependencies updated