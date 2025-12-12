# 🚀 OpenProject Cloud Run - Quick Start Guide

## ⏱️ 5-Minute Setup (After Prerequisites)

All infrastructure is READY. Deploy OpenProject to production in minutes.

---

## 📋 Prerequisites

Make sure you have installed:
- ✅ [Docker Desktop](https://www.docker.com/products/docker-desktop) 
- ✅ [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- ✅ Git
- ✅ bash/zsh terminal

### Verify installations:
```bash
docker --version
gcloud --version
git --version
```

---

## 🎯 Step-by-Step Deployment (10-15 minutes)

### 1️⃣ Clone Your Fork
```bash
git clone https://github.com/anhvu0705/openproject.git
cd openproject
```

### 2️⃣ Authenticate with Google Cloud
```bash
gcloud auth login
gcloud config set project openproject-481014
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### 3️⃣ Run Automated Deployment
```bash
chmod +x deploy-to-cloud-run.sh
./deploy-to-cloud-run.sh
```

**What this script does:**
- ✅ Builds Docker image (slim version for Cloud Run)
- ✅ Pushes to Artifact Registry
- ✅ Gets Cloud SQL connection details
- ✅ Deploys to Cloud Run
- ✅ Outputs service URL

### 4️⃣ Initialize Database (After deployment succeeds)
```bash
gcloud sql databases create openproject --instance=openproject-db
```

### 5️⃣ Access Your OpenProject
- Service URL will be printed in terminal
- Navigate to the URL in your browser
- Default credentials: admin / admin (change immediately!)
- Complete database setup wizard

---

## ✅ Verification Checklist

- [ ] Docker running locally
- [ ] gcloud authenticated
- [ ] Project set to openproject-481014
- [ ] Docker credentials configured
- [ ] Script is executable
- [ ] Cloud SQL instance shows AVAILABLE
- [ ] Artifact Registry repository exists

---

## 🔗 Important Links

| Resource | Link |
|----------|------|
| **Deployment Guide** | [CLOUD_RUN_DEPLOYMENT.md](CLOUD_RUN_DEPLOYMENT.md) |
| **Deployment Script** | [deploy-to-cloud-run.sh](deploy-to-cloud-run.sh) |
| **GCP Project** | https://console.cloud.google.com/welcome?project=openproject-481014 |
| **Cloud SQL** | https://console.cloud.google.com/sql/instances/openproject-db?project=openproject-481014 |
| **Cloud Run** | https://console.cloud.google.com/run?project=openproject-481014 |

---

## 🆘 Troubleshooting

### Docker build fails
```bash
# Clear Docker cache and rebuild
docker builder prune
./deploy-to-cloud-run.sh
```

### gcloud authentication issues
```bash
# Re-authenticate
gcloud auth login
gcloud auth application-default login
```

### Cloud SQL connection fails
```bash
# Check instance status
gcloud sql instances describe openproject-db

# View operations
gcloud sql operations list --instance=openproject-db
```

### Cloud Run deployment fails
```bash
# Check deployment logs
gcloud run logs read openproject --limit 50

# View service details
gcloud run services describe openproject --region us-central1
```

---

## 📊 Expected Costs

| Service | Monthly Cost |
|---------|---------------|
| Cloud Run | **$0** (free tier) |
| Cloud SQL | **$0-20** (free trial + usage) |
| Artifact Registry | **~$0.10/GB** |
| **Total** | **$0-30/month** |

---

## 🔐 Post-Deployment Security

1. **Change Default Password**
   - Login with admin/admin
   - Go to Administration → Users
   - Change admin password immediately

2. **Enable HTTPS**
   - Cloud Run auto-provides HTTPS
   - Update OPENPROJECT_HOST__NAME if using custom domain

3. **Setup Backups**
   - Cloud SQL automatic backups enabled
   - Retention: 7 days (adjust if needed)

4. **Enable Monitoring**
   - Cloud Logging auto-enabled
   - View logs in Cloud Console

---

## 📞 Support

- **OpenProject Docs**: https://docs.openproject.org/
- **Google Cloud Help**: https://cloud.google.com/support
- **Issue Tracker**: https://github.com/anhvu0705/openproject/issues

---

## 🎉 Deployment Complete!

Your OpenProject instance is now running on Google Cloud Run!

**Infrastructure Created:**
- ✅ Cloud SQL PostgreSQL 17 database
- ✅ Artifact Registry Docker repository
- ✅ Cloud Run container service
- ✅ Automatic backups
- ✅ HTTPS enabled
- ✅ Monitoring & logging

---

**Ready to deploy? Run: `./deploy-to-cloud-run.sh`**
