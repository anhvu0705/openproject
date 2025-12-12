# 🚀 OpenProject Automated Cloud Run Deployment

## Complete CI/CD Setup - No Manual Deployment Needed!

Your OpenProject instance is now **100% ready for automated deployment**. Everything is configured for seamless cloud-based builds and deployments.

## What's Configured?

✅ **GitHub Actions CI/CD Pipeline** - Automatic deployment on push to `dev` branch  
✅ **Google Cloud Build** - Alternative automated build and deployment method  
✅ **Cloud SQL PostgreSQL 17** - Production-ready database (openproject-db)  
✅ **Artifact Registry** - Docker image storage (openproject-docker)  
✅ **Cloud Run Service** - Auto-scaling container deployment  
✅ **Workload Identity Federation** - Secure authentication (no static credentials)  
✅ **Complete Documentation** - All guides and scripts included  

## 🎯 Quick Start - 3 Simple Steps

### Step 1: Set Up GitHub Secrets (5 minutes)

Follow the guide in [CI_CD_SETUP.md](CI_CD_SETUP.md) to:
1. Create a service account in GCP
2. Set up Workload Identity Federation
3. Add 4 secrets to GitHub repository

### Step 2: Push Code to Dev Branch

```bash
git push origin dev
```

That's it! GitHub Actions will automatically:
- ✅ Build Docker image
- ✅ Push to Artifact Registry
- ✅ Deploy to Cloud Run
- ✅ Output service URL

### Step 3: Access Your OpenProject Instance

After deployment completes, you'll get a Cloud Run service URL:

```
https://openproject-XXXXX-REGION.a.run.app
```

Default credentials:
- **Username**: admin
- **Password**: admin

⚠️ **Change default password immediately** in Administration → Users

## 📋 Architecture Overview

```
┌─────────────────┐
│  GitHub Repo    │
│  (dev branch)   │
└────────┬────────┘
         │
         │ Push to dev
         │
         ▼
┌─────────────────┐
│ GitHub Actions  │  ← CI/CD Pipeline
│  (deploy.yml)   │
└────────┬────────┘
         │
         │ Build & Push
         │
         ▼
┌─────────────────┐
│ Artifact        │
│ Registry        │
│ (Docker images) │
└────────┬────────┘
         │
         │ Deploy
         │
         ▼
┌─────────────────┐
│ Cloud Run       │  ← Running OpenProject
│ (openproject)   │
└────────┬────────┘
         │
         │ Database
         │
         ▼
┌─────────────────┐
│ Cloud SQL       │
│ (openproject-db)│
└─────────────────┘
```

## 🔄 Deployment Methods

### Method 1: GitHub Actions (Recommended)

**Automatic trigger**: Push to `dev` branch  
**Manual trigger**: Go to GitHub Actions > Deploy > Run workflow

Benefits:
- No local dependencies required
- GitHub native integration
- Workload Identity Federation for security
- Automatic on every push

### Method 2: Cloud Build

**Command line**:
```bash
gcloud builds submit --config=cloudbuild.yaml
```

**Setup Cloud Build Trigger**:
1. Go to Cloud Console > Cloud Build > Triggers
2. Connect GitHub repository
3. Create trigger for `dev` branch with `cloudbuild.yaml`

### Method 3: Local Deployment (for development)

For local testing before pushing:
```bash
chmod +x deploy-to-cloud-run.sh
./deploy-to-cloud-run.sh
```

## 📁 Files Included

| File | Purpose |
|------|----------|
| `.github/workflows/deploy.yml` | GitHub Actions CI/CD pipeline |
| `cloudbuild.yaml` | Google Cloud Build configuration |
| `.gcloudignore` | Cloud Build optimization |
| `CI_CD_SETUP.md` | GitHub Secrets & WIF setup guide |
| `QUICK_START.md` | 5-minute deployment guide |
| `CLOUD_RUN_DEPLOYMENT.md` | Detailed deployment documentation |
| `DEPLOYMENT_COMPLETE.md` | Infrastructure status |
| `deploy-to-cloud-run.sh` | Local deployment script |
| `AUTO_DEPLOY_README.md` | This file |

## 🔐 Security Features

✅ **Workload Identity Federation** - No service account keys stored  
✅ **GitHub Secrets** - Credentials encrypted at rest  
✅ **HTTPS Enabled** - Cloud Run provides automatic SSL/TLS  
✅ **Cloud SQL Proxy** - Secure database connections  
✅ **Cloud Audit Logs** - Complete audit trail  

## 💰 Cost Optimization

### Free Tier Usage
- **Cloud Run**: 2M requests/month (within free tier)
- **Cloud SQL**: 1 shared database instance allowed
- **Artifact Registry**: 500GB storage free per month
- **Cloud Build**: 120 build minutes/day free

### Estimated Monthly Cost (after free tier)
- Cloud Run: ~$5-10 (with auto-scaling)
- Cloud SQL: ~$15-20
- Artifact Registry: ~$0.10-1.00
- **Total**: ~$20-30/month

## 🐛 Troubleshooting

### GitHub Actions Failing
1. Check GitHub Actions logs: Repository > Actions tab
2. Verify GitHub Secrets are set correctly
3. Review WIF configuration in [CI_CD_SETUP.md](CI_CD_SETUP.md)
4. Check Cloud Run service account permissions

### Cloud Build Failing
1. View build logs: Cloud Console > Cloud Build > History
2. Verify service account has correct IAM roles
3. Check `.gcloudignore` is not excluding important files
4. Review cloudbuild.yaml for syntax errors

### Deployment Successful but Service Not Responding
1. Check Cloud Run logs: `gcloud run logs read openproject --limit 50`
2. Verify Cloud SQL database is running
3. Check environment variables are set correctly
4. Review Cloud Run service configuration

### Default Admin Credentials Not Working
1. Check OpenProject logs for errors
2. Verify database migrations completed
3. Try resetting admin password via Cloud SQL console
4. Check application logs for startup errors

## 📚 Additional Resources

- [OpenProject Documentation](https://docs.openproject.org/)
- [Google Cloud Run Docs](https://cloud.google.com/run/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workload Identity Federation Setup](https://cloud.google.com/docs/authentication/workload-identity-federation)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)

## ✨ Next Steps

1. **Complete CI/CD Setup**: Follow [CI_CD_SETUP.md](CI_CD_SETUP.md)
2. **Configure Custom Domain** (Optional): Update `OPENPROJECT_HOST_NAME` in GitHub Secrets
3. **Set Up Backups** (Recommended): Configure Cloud Storage bucket for automated backups
4. **Monitor Deployment**: Watch Actions tab for successful deployment
5. **Access Instance**: Use the Cloud Run service URL to access OpenProject

## 🎉 You're All Set!

Your OpenProject instance is ready for **100% automated, production-grade deployment**.

No more manual scripts, no more local Docker builds, no more waiting for deployments.

**Just push code. That's it.** ☁️

---

**Questions?** Check the documentation files or GitHub Issues.
