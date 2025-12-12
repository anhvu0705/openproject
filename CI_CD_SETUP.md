# GitHub Actions & Cloud Build CI/CD Setup Guide

## Overview

This document explains how to set up GitHub Secrets for automated deployment to Google Cloud Run using GitHub Actions and Cloud Build.

## Prerequisites

- Google Cloud Project: `openproject-481014`
- Service Account with necessary permissions
- Workload Identity Federation (WIF) configured
- GitHub repository with admin access

## Step 1: Set up Workload Identity Federation (WIF)

### Create a Service Account

```bash
gcloud iam service-accounts create openproject-sa \
  --project=openproject-481014 \
  --display-name="OpenProject Deployment Service Account"
```

### Grant necessary permissions

```bash
# Cloud Run deployment
gcloud projects add-iam-policy-binding openproject-481014 \
  --member=serviceAccount:openproject-sa@openproject-481014.iam.gserviceaccount.com \
  --role=roles/run.admin

# Artifact Registry access
gcloud projects add-iam-policy-binding openproject-481014 \
  --member=serviceAccount:openproject-sa@openproject-481014.iam.gserviceaccount.com \
  --role=roles/artifactregistry.admin

# Cloud SQL access
gcloud projects add-iam-policy-binding openproject-481014 \
  --member=serviceAccount:openproject-sa@openproject-481014.iam.gserviceaccount.com \
  --role=roles/cloudsql.client

# Service Account User
gcloud projects add-iam-policy-binding openproject-481014 \
  --member=serviceAccount:openproject-sa@openproject-481014.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountUser
```

### Set up Workload Identity Federation

```bash
# Create WIF pool
gcloud iam workload-identity-pools create "github" \
  --project="openproject-481014" \
  --location="global" \
  --display-name="GitHub Actions"

# Create WIF provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="openproject-481014" \
  --location="global" \
  --workload-identity-pool="github" \
  --display-name="GitHub OIDC Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

### Bind Service Account to WIF

```bash
gcloud iam service-accounts add-iam-policy-binding \
  openproject-sa@openproject-481014.iam.gserviceaccount.com \
  --project="openproject-481014" \
  --role="roles/iam.workloadIdentityUser" \
  --condition='resource.matchTag("github", "repository") && resource.name.startsWith("projects/-/locations/global/workloadIdentityPools/github/providers/github-provider")' \
  --member="principalSet://iam.googleapis.com/projects/openproject-481014/locations/global/workloadIdentityPools/github/attribute.repository/anhvu0705/openproject"
```

## Step 2: Configure GitHub Secrets

Add the following secrets to your GitHub repository (Settings > Secrets and variables > Actions):

### Required Secrets:

1. **WIF_PROVIDER**
   ```
   projects/PROJECT_ID/locations/global/workloadIdentityPools/github/providers/github-provider
   ```
   Replace `PROJECT_ID` with your actual GCP project ID: `openproject-481014`

2. **WIF_SERVICE_ACCOUNT**
   ```
   openproject-sa@openproject-481014.iam.gserviceaccount.com
   ```

3. **OPENPROJECT_HOST_NAME** (Optional)
   ```
   openproject.yourdomain.com
   ```
   Or use the Cloud Run service URL

4. **CLOUD_SQL_INSTANCE**
   ```
   openproject-481014:us-central1:openproject-db
   ```

## Step 3: GitHub Actions Workflow

The `.github/workflows/deploy.yml` file is already configured and will:

1. **Trigger**: On push to `dev` branch
2. **Authenticate**: Using Workload Identity Federation
3. **Build**: Docker image locally
4. **Push**: To Artifact Registry
5. **Deploy**: To Cloud Run with environment variables
6. **Report**: Service URL on completion

### Manual Trigger

You can manually trigger the workflow from GitHub:
- Go to Actions tab
- Select "Deploy OpenProject to Cloud Run"
- Click "Run workflow"

## Step 4: Cloud Build Configuration

The `cloudbuild.yaml` file provides an alternative deployment method:

```bash
# Manually trigger Cloud Build
gcloud builds submit --config=cloudbuild.yaml
```

### Cloud Build Trigger (Optional)

To automatically trigger Cloud Build from GitHub:

1. Go to Cloud Console > Cloud Build > Triggers
2. Click "Create Trigger"
3. Connect GitHub repository
4. Set up trigger conditions
5. Select `cloudbuild.yaml` as build config

## Deployment Flow

```
Push to dev branch
    ↓
GitHub Actions triggered
    ↓
Checkout code
    ↓
Authenticate with GCP (WIF)
    ↓
Build Docker image
    ↓
Push to Artifact Registry
    ↓
Deploy to Cloud Run
    ↓
Get service URL
    ↓
Deployment complete ✅
```

## Troubleshooting

### 1. WIF Authentication fails
- Verify WIF pool and provider are created
- Check service account bindings
- Review GitHub Actions logs for errors

### 2. Artifact Registry push fails
- Ensure service account has `artifactregistry.admin` role
- Check Docker credentials configuration
- Verify repository exists

### 3. Cloud Run deployment fails
- Check Cloud SQL connectivity
- Verify environment variables are set correctly
- Review Cloud Run logs in Cloud Console
- Ensure service account has `run.admin` role

### 4. Docker build fails
- Review OpenProject Dockerfile
- Check system resources (CPU, memory)
- Verify all dependencies are available

## Useful Commands

```bash
# View deployment logs
gcloud run logs read openproject --limit 50

# Get service URL
gcloud run services describe openproject \
  --platform managed \
  --region us-central1 \
  --project openproject-481014

# View GitHub Actions logs
# Go to GitHub repository > Actions > Select workflow run

# Test WIF configuration
gcloud iam workload-identity-pools get-iam-policy \
  projects/openproject-481014/locations/global/workloadIdentityPools/github
```

## Security Best Practices

1. ✅ Use Workload Identity Federation (no static credentials)
2. ✅ Limit service account permissions (principle of least privilege)
3. ✅ Enable Cloud Audit Logs for monitoring
4. ✅ Use Cloud KMS for sensitive data encryption
5. ✅ Review and rotate credentials regularly
6. ✅ Keep GitHub Actions secrets minimal and specific

## Support

For issues or questions:
- GitHub Issues: https://github.com/anhvu0705/openproject/issues
- OpenProject Docs: https://docs.openproject.org/
- Google Cloud Docs: https://cloud.google.com/docs
