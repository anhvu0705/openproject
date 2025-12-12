#!/bin/bash

# OpenProject Google Cloud Run Deployment Script
# This script automates the deployment of OpenProject to Google Cloud Run

set -e

echo "🚀 OpenProject Google Cloud Run Deployment Script"
echo "================================================="

# Configuration
PROJECT_ID="openproject-481014"
REGION="us-central1"
CLOUD_SQL_INSTANCE="openproject-db"
ARTIFACT_REGISTRY="openproject-docker"
IMAGE_NAME="openproject"
SERVICE_NAME="openproject"
MEMORY="2Gi"
CPU="2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v gcloud &> /dev/null; then
        log_error "gcloud CLI is not installed"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed"
        exit 1
    fi
    
    log_info "All prerequisites met"
}

# Configure gcloud
configure_gcloud() {
    log_info "Configuring gcloud..."
    
    gcloud config set project $PROJECT_ID
    gcloud auth configure-docker $REGION-docker.pkg.dev
    
    log_info "gcloud configured"
}

# Build Docker image
build_image() {
    log_info "Building Docker image..."
    
    docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/$IMAGE_NAME:latest \
        -f docker/prod/Dockerfile \
        --target slim \
        .
    
    log_info "Docker image built successfully"
}

# Push image to Artifact Registry
push_image() {
    log_info "Pushing image to Artifact Registry..."
    
    docker push $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/$IMAGE_NAME:latest
    
    log_info "Image pushed successfully"
}

# Get Cloud SQL info
get_cloud_sql_info() {
    log_info "Retrieving Cloud SQL information..."
    
    CLOUD_SQL_IP=$(gcloud sql instances describe $CLOUD_SQL_INSTANCE --format="value(ipAddresses[0].ipAddress)")
    CLOUD_SQL_CONNECTION="$PROJECT_ID:$REGION:$CLOUD_SQL_INSTANCE"
    
    log_info "Cloud SQL IP: $CLOUD_SQL_IP"
}

# Deploy to Cloud Run
deploy_to_cloud_run() {
    log_info "Deploying to Cloud Run..."
    
    # Generate SECRET_KEY_BASE
    SECRET_KEY=$(head -c 32 /dev/urandom | base64)
    
    gcloud run deploy $SERVICE_NAME \
        --image $REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/$IMAGE_NAME:latest \
        --platform managed \
        --region $REGION \
        --memory $MEMORY \
        --cpu $CPU \
        --timeout 3600 \
        --add-cloudsql-instances $CLOUD_SQL_CONNECTION \
        --set-env-vars="SECRET_KEY_BASE=$SECRET_KEY,OPENPROJECT_HOST__NAME=YOUR_DOMAIN_HERE,RAILS_ENV=production,RAILS_LOG_TO_STDOUT=1,DATABASE_URL=postgresql://postgres:PASSWORD@$CLOUD_SQL_IP:5432/openproject" \
        --allow-unauthenticated
    
    log_info "Deployment completed"
}

# Get service URL
get_service_url() {
    log_info "Retrieving service URL..."
    
    SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format='value(status.url)')
    
    echo ""
    echo "================================================="
    echo -e "${GREEN}✓ Deployment successful!${NC}"
    echo "================================================="
    echo -e "Service URL: ${GREEN}$SERVICE_URL${NC}"
    echo ""
    echo -e "${YELLOW}⚠ Important Next Steps:${NC}"
    echo "1. Wait for Cloud SQL instance to be fully ready (if not already)"
    echo "2. Set up the database:"
    echo "   gcloud sql databases create openproject --instance=$CLOUD_SQL_INSTANCE"
    echo "3. Run database migrations"
    echo "4. Access admin console and change default credentials"
    echo "5. Configure your custom domain"
    echo ""
}

# Main execution
main() {
    check_prerequisites
    configure_gcloud
    build_image
    push_image
    get_cloud_sql_info
    deploy_to_cloud_run
    get_service_url
}

# Run main function
main
