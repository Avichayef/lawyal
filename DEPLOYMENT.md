# Complete Deployment Guide

This repository uses a comprehensive GitHub Actions workflow for automated deployment. The workflow handles everything from secret management to infrastructure deployment and application updates.

## Initial Setup

1. **Encrypt Your Secrets**
   ```bash
   # Install GPG if not already installed
   # Ubuntu: apt-get install gpg
   # MacOS: brew install gpg

   # Generate encryption key and encrypt secrets
   chmod +x scripts/encrypt_secrets.sh
   ./scripts/encrypt_secrets.sh
   ```

2. **GitHub Repository Setup**
   
   Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions → New repository secret):
   - `SECRETS_PASSPHRASE`: The passphrase output from encrypt_secrets.sh
   - `GH_PAT`: GitHub Personal Access Token with 'repo' scope
   - `AWS_ROLE_ARN`: AWS IAM Role ARN for OIDC authentication

3. **Required Files**
   - `terraform/secrets.tfvars.enc`: Encrypted secrets file (committed to repo)
   - `terraform/secrets.tfvars`: Local unencrypted secrets (never commit)

## Deployment Process

The workflow triggers automatically on pushes to main branch when changes are detected in:
- `terraform/**`
- `app/**`
- `helm/**`
- `.github/workflows/**`

### Workflow Steps

1. **Secrets Management**
   - Decrypts `secrets.tfvars.enc`
   - Syncs variables to GitHub secrets/variables

2. **Infrastructure Deployment**
   - Initializes Terraform
   - Applies infrastructure changes

3. **Application Deployment**
   - Builds Docker image
   - Pushes to ECR
   - Deploys to EKS using Helm

## Updating Secrets

When you need to update secrets:

1. Update your local `secrets.tfvars`
2. Re-encrypt:
   ```bash
   export SECRETS_PASSPHRASE='your-passphrase-here'
   ./scripts/encrypt_secrets.sh
   ```
3. Commit and push:
   ```bash
   git add terraform/secrets.tfvars.enc
   git commit -m "Update encrypted secrets"
   git push
   ```

## Security Considerations

- Never commit unencrypted `secrets.tfvars`
- Rotate GitHub PAT periodically
- Use branch protection rules on main
- Review GitHub Actions logs for sensitive information

## Troubleshooting

1. **Workflow Failures**
   - Check GitHub Actions logs
   - Verify secrets are properly set
   - Ensure AWS permissions are correct

2. **Secret Sync Issues**
   - Verify `SECRETS_PASSPHRASE` is correct
   - Check `GH_PAT` permissions
   - Validate secrets.tfvars format

3. **Deployment Issues**
   - Verify AWS credentials
   - Check EKS cluster status
   - Review Helm release history

## Maintenance

Regular maintenance tasks:
- Rotate AWS credentials
- Update GitHub PAT
- Review and update infrastructure code
- Keep dependencies updated