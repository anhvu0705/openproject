# OpenProject Google Cloud Run Deployment Guide

## Project Status: IN PROGRESS

### ✅ Completed Steps:
1. ✅ Fork OpenProject repository to GitHub
   - Fork URL: https://github.com/anhvu0705/openproject

2. ✅ Google Cloud Project Setup
   - Project ID: openproject-481014
   - Enabled APIs:
     - Cloud Run Admin API
     - Artifact Registry API
     - Cloud SQL Admin API

3. ✅ Cloud SQL PostgreSQL Setup
   - Instance Name: openproject-db
   - Database Engine: PostgreSQL 17
   - Region: us-central1 (Iowa)
   - Status: CREATING (will be ready in ~10-15 minutes)

4. ✅ Artifact Registry Setup
   - Repository Name: openproject-docker
   - Format: Docker
   - Region: us-central1
   - Status: READY

## 📋 Next Steps (Local Machine):

### Prerequisites:
- Docker installed
- gcloud CLI installed and configured
- Git installed

### Step 1: Clone Repository Locally
```bash
git clone https://github.com/anhvu0705/openproject.git
cd openproject
```

### Step 2: Wait for Cloud SQL Instance to be Ready
Monitor progress at: https://console.cloud.google.com/sql/instances/openproject-db
Status shows "Available" when ready.

### Step 3: Configure gcloud
```bash
# Set project
gcloud config set project openproject-481014

# Authenticate Docker
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### Step 4: Build Docker Image
```bash
# Build the slim image (recommended for Cloud Run)
docker build -t us-central1-docker.pkg.dev/openproject-481014/openproject-docker/openproject:latest \
  -f docker/prod/Dockerfile \
  --target slim \
  .
```

### Step 5: Push to Artifact Registry
```bash
docker push us-central1-docker.pkg.dev/openproject-481014/openproject-docker/openproject:latest
```

### Step 6: Setup Cloud SQL Database
```bash
# Get the Cloud SQL IP address
CLOUD_SQL_IP=$(gcloud sql instances describe openproject-db --format="value(ipAddresses[0].ipAddress)")

# Create database
gcloud sql databases create openproject --instance=openproject-db

# Create database user (or use default postgres)
# Password was generated during instance creation - retrieve from Cloud SQL console
```

### Step 7: Deploy to Cloud Run
```bash
# Generate a secure SECRET_KEY_BASE
SECRET_KEY=$(head -c 32 /dev/urandom | base64)

# Deploy OpenProject to Cloud Run
gcloud run deploy openproject \
  --image us-central1-docker.pkg.dev/openproject-481014/openproject-docker/openproject:latest \
  --platform managed \
  --region us-central1 \
  --memory 2Gi \
  --cpu 2 \
  --timeout 3600 \
  --add-cloudsql-instances openproject-481014:us-central1:openproject-db \
  --set-env-vars="SECRET_KEY_BASE=${SECRET_KEY},OPENPROJECT_HOST__NAME=YOUR_DOMAIN,RAILS_ENV=production,RAILS_LOG_TO_STDOUT=1" \
  --allow-unauthenticated
```

### Step 8: Initial Database Setup
```bash
# Run database migrations via Cloud Run Job
gcloud run jobs create openproject-migrate \
  --image us-central1-docker.pkg.dev/openproject-481014/openproject-docker/openproject:latest \
  --set-env-vars="DATABASE_URL=postgresql://postgres:PASSWORD@${CLOUD_SQL_IP}:5432/openproject" \
  --add-cloudsql-instances openproject-481014:us-central1:openproject-db \
  --task-timeout 1800

# Execute the migration
gcloud run jobs execute openproject-migrate
```

## 🔒 Security Recommendations:

1. **Change Default Password**
   - Access admin console and change default admin credentials
   - Default credentials printed after database setup

2. **Enable HTTPS**
   - Cloud Run auto-provides HTTPS
   - Update OPENPROJECT_HOST__NAME to your domain
   - Use Google Cloud Load Balancer for custom domain

3. **Setup Firewall Rules**
   - Restrict Cloud SQL access to Cloud Run service only
   - Use Cloud SQL Proxy for connections

4. **Regular Backups**
   - Enable automatic backups in Cloud SQL
   - Setup Cloud Storage for backup storage

## 📊 Cost Estimation:

- **Cloud Run**: ~$0/month (within free tier: 2M requests/month)
- **Cloud SQL**: $0-50/month (depending on usage, free tier available)
- **Artifact Registry**: ~$0.10/GB storage
- **Total**: Usually under $50/month for small deployments

## 🆘 Troubleshooting:

### Cloud SQL Connection Issues:
```bash
# Check Cloud SQL instance status
gcloud sql instances describe openproject-db

# View Cloud SQL logs
gcloud sql operations list --instance=openproject-db
```

### Cloud Run Logs:
```bash
# Stream logs in real-time
gcloud run logs read openproject --limit 50

# View detailed service info
gcloud run services describe openproject --region us-central1
```

### Database Issues:
```bash
# Connect directly to Cloud SQL for debugging
cloud_sql_proxy -instances=openproject-481014:us-central1:openproject-db=tcp:5432

# Then connect via psql
psql -h localhost -U postgres -d openproject
```

## 📚 Additional Resources:

- [OpenProject Docker Documentation](https://github.com/anhvu0705/openproject/tree/dev/docs/installation-and-operations/installation/docker)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)

## 🎯 Deployment Status Tracking:

| Component | Status | Link |
|-----------|--------|------|
| GitHub Fork | ✅ Complete | [anhvu0705/openproject](https://github.com/anhvu0705/openproject) |
| GCP Project | ✅ Complete | [openproject-481014](https://console.cloud.google.com/welcome?project=openproject-481014) |
| Cloud SQL Instance | 🔄 Creating | [openproject-db](https://console.cloud.google.com/sql/instances/openproject-db/overview?project=openproject-481014) |
| Artifact Registry | ✅ Complete | [openproject-docker](https://console.cloud.google.com/artifacts?project=openproject-481014) |
| Cloud Run Service | ⏳ Pending | Ready for deployment |

---

**Last Updated**: 2025-12-12 21:00 UTC+7
**Deployment Type**: Google Cloud Run (Recommended for Open Source)
**OpenProject Edition**: Community/Standard
**Database**: PostgreSQL 17
