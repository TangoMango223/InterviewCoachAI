# Deployment Guide: InterviewCoach to AWS EKS

## Prerequisites
- Docker installed locally
- AWS CLI configured (`aws configure`)
- kubectl installed
- eksctl installed (for cluster creation)
- **Helm 3.x installed** (`brew install helm`)
- Access to AWS account (Account ID: 904570587651)
- AWS region: ca-central-1

---

## Deployment Options

This guide covers **two deployment methods**:

1. **[Helm Chart Deployment](#helm-deployment-recommended)** - Modern, production-ready approach (RECOMMENDED)
2. **[Manual kubectl Deployment](#manual-kubectl-deployment)** - Original approach for learning basics

**If you're new to Kubernetes**, start with the manual method to understand the basics. Once comfortable, switch to Helm for better workflow.

---

## Step 0: Create EKS Cluster (One-Time Setup)

If you don't have an EKS cluster yet, create one first.

### Option 1: Using eksctl (Recommended - Easiest)

**Install eksctl** (if not already installed):
```bash
# macOS
brew install eksctl

# Verify installation
eksctl version
```

**Create the cluster:**
```bash
eksctl create cluster \
  --name interviewcoach-cluster \
  --region ca-central-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed
```

**What this does:**
- Creates an EKS cluster named `interviewcoach-cluster`
- Sets up 2 worker nodes (t3.medium instances)
- Configures auto-scaling (1-3 nodes)
- Uses managed node groups (AWS handles updates)
- Automatically configures kubectl to connect to the cluster

**Time:** Takes ~15-20 minutes

**Verify cluster is ready:**
```bash
eksctl get cluster --region ca-central-1
kubectl get nodes
```

### Option 2: Using AWS Console (Manual)

1. Go to AWS Console → EKS
2. Click "Create cluster"
3. Cluster name: `interviewcoach-cluster`
4. Region: `ca-central-1`
5. Kubernetes version: Latest
6. Follow wizard to create node group
7. After creation, configure kubectl:
   ```bash
   aws eks update-kubeconfig --region ca-central-1 --name interviewcoach-cluster
   ```

### Important Notes:

**Cost considerations:**
- t3.medium nodes cost ~$0.0416/hour each
- 2 nodes = ~$60/month if running 24/7
- Remember to delete the cluster when done learning!

**Security:**
- The cluster is created with default VPC and security groups
- For production, you'd want custom VPC and tighter security

---

## Step 1: Build the Frontend

```bash
cd web
npm install
npm run build
cd ..
```

This creates the `web/dist/` folder and copies it to `app/static/`.

---

## Step 2: Build Docker Image (IMPORTANT: Platform-Specific!)

### Problem: Mac (ARM64) vs AWS Linux (AMD64)
If you're on a Mac with Apple Silicon (M1/M2/M3), your default Docker builds create **ARM64** images. AWS EKS runs on **AMD64/x86** Linux, so you MUST build for the correct platform.

### Solution: Use `--platform linux/amd64` flag

```bash
# Build for AWS Linux (AMD64) - REQUIRED for EKS deployment
docker build --platform linux/amd64 -t interviewcoach:latest .

# You need an OpenAI key, add it to this command:
docker run -p 8080:8080 -e OPENAI_API_KEY="your_key" interviewcoach:latest
```

**Why this matters:**
- Without `--platform linux/amd64`: Image won't run on EKS (crashes or "exec format error")
- With the flag: Docker uses emulation to build a compatible image

### Optional: Test the image locally first
```bash
# Option 1: Using .env file (make sure you're in the project root directory)
docker run -p 8080:8080 --env-file .env interviewcoach:latest

# Option 2: Pass API key directly (more reliable)
docker run -p 8080:8080 -e OPENAI_API_KEY="your-api-key-here" interviewcoach:latest

# Test in browser: http://localhost:8080
# Test health: curl http://localhost:8080/health
```

---

## Step 3: Tag and Push to AWS ECR

### A) Create ECR repository (One-Time Setup)

If this is your first time or you deleted the repository:

```bash
# Create the repository
aws ecr create-repository \
  --repository-name interviewcoach \
  --region ca-central-1

# Verify it exists
aws ecr describe-repositories --region ca-central-1
```

### B) Login to AWS ECR
```bash
aws ecr get-login-password --region ca-central-1 | \
  docker login --username AWS --password-stdin \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com
```

### B) Tag the image for ECR
#### Connects interviewcoach docker image with the naming
```bash
docker tag interviewcoach:latest \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest
```

### C) Push to ECR
```bash
docker push 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest
```

## Interviewcoach in the name above refers to the location in AWS for the ECR private repo name ^

**Tip:** You can also add version tags:
```bash
docker tag interviewcoach:latest \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:v1.0.0
docker push 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:v1.0.0
```

---

## Step 4: Connect kubectl to EKS and Create Kubernetes Secret (One-Time Setup)

### A) Connect kubectl to your EKS cluster

First, configure kubectl to communicate with your EKS cluster:

```bash
# List your EKS clusters (to find the cluster name)
aws eks list-clusters --region ca-central-1

# Connect kubectl to your cluster (replace 'your-cluster-name' with actual name)
aws eks update-kubeconfig --region ca-central-1 --name your-cluster-name
```

**Verify connection:**
```bash
kubectl cluster-info
kubectl get nodes
```

You should see your EKS cluster details and running nodes.

### B) Create the Kubernetes secret

Your OpenAI API key must be stored as a Kubernetes secret (NOT in the Docker image).

```bash
kubectl create secret generic openai-secret \
  --from-literal=OPENAI_API_KEY="your-actual-api-key-here"
```

**Verify the secret:**
```bash
kubectl get secrets
kubectl describe secret openai-secret
```

**Important:** Once connected with `update-kubeconfig`, all `kubectl` commands will interact with your EKS cluster.

---

## Step 5: Deploy to Kubernetes

```bash
# Apply deployment (creates pods)
kubectl apply -f k8s-deployment.yaml

# Apply service (creates LoadBalancer)
kubectl apply -f k8s-service.yaml
```

---

## Step 6: Verify Deployment

```bash
# Check pods are running
kubectl get pods

# Check deployment status
kubectl get deployments

# Check service and get LoadBalancer URL
kubectl get services

# View logs
kubectl logs -l app=interviewcoach

# Describe pod for troubleshooting
kubectl describe pod <pod-name>
```

**Get the public URL:**
```bash
kubectl get service interviewcoach
```
Look for the `EXTERNAL-IP` column - this is your public URL!

---

## Step 7: Test the Deployment

```bash
# Health check
curl http://<EXTERNAL-IP>/health

# Test the app in browser
open http://<EXTERNAL-IP>
```

---

## Common Issues & Fixes

### Issue 1: "exec format error" or pod crashes
**Cause:** Built image for wrong architecture (ARM64 instead of AMD64)
**Fix:** Rebuild with `--platform linux/amd64` flag (see Step 2)

### Issue 2: "ImagePullBackOff"
**Cause:** EKS can't pull from ECR (permissions issue)
**Fix:**
- Verify ECR repository exists: `aws ecr describe-repositories`
- Check IAM role permissions for EKS nodes
- Verify image was pushed: `aws ecr list-images --repository-name interviewcoach`

### Issue 3: "CrashLoopBackOff" with "Server missing OPENAI_API_KEY"
**Cause:** Kubernetes secret not created or misconfigured
**Fix:**
```bash
# Delete old secret if exists
kubectl delete secret openai-secret

# Recreate with correct key
kubectl create secret generic openai-secret \
  --from-literal=OPENAI_API_KEY="sk-proj-..."

# Restart pods
kubectl rollout restart deployment interviewcoach
```

### Issue 4: Pods not updating after new push
**Cause:** Kubernetes caches the `:latest` tag
**Fix:**
```bash
# Option 1: Use imagePullPolicy: Always (already set in k8s-deployment.yaml)
kubectl rollout restart deployment interviewcoach

# Option 2: Use version tags instead of :latest
# See Step 3B for tagging with versions
```

---

## Updating the Application

When you make code changes:

```bash
# 1. Rebuild frontend
cd web && npm run build && cd ..

# 2. Rebuild Docker image (with correct platform!)
docker build --platform linux/amd64 -t interviewcoach:latest .

# 3. Tag with new version
docker tag interviewcoach:latest \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:v1.0.1

# 4. Push to ECR
docker push 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:v1.0.1

# 5. Update k8s-deployment.yaml to use new tag, then:
kubectl apply -f k8s-deployment.yaml

# OR force restart with :latest tag:
kubectl rollout restart deployment interviewcoach
```

---

## Cleanup (Delete Everything)

**IMPORTANT:** Always delete resources when done to avoid ongoing AWS charges!

### Step 1: Delete Kubernetes Resources
```bash
# Delete service and deployment
kubectl delete -f k8s-service.yaml
kubectl delete -f k8s-deployment.yaml
kubectl delete secret openai-secret
```

### Step 2: Delete EKS Cluster

**Using eksctl (if you created with eksctl):**
```bash
eksctl delete cluster --name interviewcoach-cluster --region ca-central-1
```

**Using AWS Console:**
1. Go to AWS Console → EKS
2. Select your cluster
3. Delete node group first
4. Then delete cluster

**Time:** Takes ~10-15 minutes

### Step 3: Delete ECR Repository (Optional)
```bash
# Delete all images in the repository
aws ecr batch-delete-image \
  --repository-name interviewcoach \
  --image-ids imageTag=latest

# Delete the repository itself
aws ecr delete-repository \
  --repository-name interviewcoach \
  --region ca-central-1 \
  --force
```

### Verify Everything is Deleted:
```bash
# Check clusters are gone
eksctl get cluster --region ca-central-1
aws eks list-clusters --region ca-central-1

# Check ECR repositories
aws ecr describe-repositories --region ca-central-1
```

---

## Quick Reference Commands

```bash
# View everything
kubectl get all

# View logs for all pods
kubectl logs -l app=interviewcoach --tail=50 -f

# Get shell into running pod (for debugging)
kubectl exec -it <pod-name> -- /bin/bash

# Test from inside the pod
kubectl exec -it <pod-name> -- curl http://localhost:8080/health

# Port forward to test locally without LoadBalancer
kubectl port-forward deployment/interviewcoach 8080:8080
# Then visit: http://localhost:8080
```

---

## Architecture Notes

**Why multi-stage Docker build?**
- Stage 1: Builds React frontend (Node.js environment)
- Stage 2: Creates minimal Python runtime with built frontend
- Result: Smaller final image (~200MB vs ~1GB+)

**Why not include .env in Docker?**
- Security: API keys shouldn't be baked into images
- Flexibility: Same image works in dev/staging/prod with different secrets
- Kubernetes secrets are encrypted and managed separately

**Platform flag explained:**
- Your Mac: ARM64 (Apple Silicon) or x86-64 (Intel)
- AWS EKS: AMD64/x86-64 (Linux)
- `--platform linux/amd64` ensures compatibility

---

# Helm Deployment (RECOMMENDED)

This is the modern, production-ready way to deploy Kubernetes applications. Helm simplifies deployment, enables environment-specific configurations, and provides version management.

## Why Use Helm?

**Benefits over manual kubectl:**
- **Single command deployment**: No need to run multiple `kubectl apply` commands
- **Environment management**: Easily deploy to dev/staging/prod with different configs
- **Version control**: Track deployment history and rollback easily
- **Templating**: Reuse configurations with variables
- **Package management**: Share and version your deployment configuration

---

## Helm Deployment Steps

### Step 1: Build and Push Docker Image

Same as manual deployment (see Steps 1-3 above):

```bash
# 1. Build frontend
cd web && npm run build && cd ..

# 2. Build Docker image for AMD64
docker build --platform linux/amd64 -t interviewcoach:latest .

# 3. Tag and push to ECR
aws ecr get-login-password --region ca-central-1 | \
  docker login --username AWS --password-stdin \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com

docker tag interviewcoach:latest \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest

docker push 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest
```

### Step 2: Connect kubectl to EKS (if not already done)

```bash
aws eks update-kubeconfig --region ca-central-1 --name interviewcoach-cluster
kubectl get nodes  # Verify connection
```

### Step 3: Deploy with Helm

**For Development:**
```bash
# Deploy with 1 replica, ClusterIP service, minimal resources
helm install interviewcoach ./helm-chart \
  -f helm-chart/values-dev.yaml \
  --set openai.apiKey="your-openai-api-key"

# Access via port-forward
kubectl port-forward svc/interviewcoach 8080:8080
# Visit: http://localhost:8080
```

**For Production:**
```bash
# Deploy with 3 replicas, LoadBalancer, autoscaling enabled
helm install interviewcoach ./helm-chart \
  -f helm-chart/values-prod.yaml \
  --set openai.apiKey="your-openai-api-key" \
  --set image.tag="v1.0.0"

# Get LoadBalancer URL
kubectl get svc interviewcoach
```

**Using Default Values (Production-like with 2 replicas):**
```bash
helm install interviewcoach ./helm-chart \
  --set openai.apiKey="your-openai-api-key"
```

### Step 4: Verify Deployment

```bash
# Check release status
helm status interviewcoach

# View all resources
kubectl get all -l app.kubernetes.io/name=interviewcoach

# View logs
kubectl logs -l app.kubernetes.io/name=interviewcoach --tail=50 -f

# Test health endpoint
kubectl port-forward svc/interviewcoach 8080:80
curl http://localhost:8080/health
```

### Step 5: Update/Upgrade Deployment

When you make code changes:

```bash
# 1. Rebuild and push new image with version tag
docker build --platform linux/amd64 -t interviewcoach:v1.0.1 .
docker tag interviewcoach:v1.0.1 \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:v1.0.1
docker push 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:v1.0.1

# 2. Upgrade the Helm release
helm upgrade interviewcoach ./helm-chart \
  -f helm-chart/values-prod.yaml \
  --set image.tag="v1.0.1" \
  --set openai.apiKey="your-key"

# 3. Monitor rollout
kubectl rollout status deployment/interviewcoach
```

### Step 6: Rollback if Needed

```bash
# View deployment history
helm history interviewcoach

# Rollback to previous version
helm rollback interviewcoach

# Rollback to specific revision
helm rollback interviewcoach 2
```

### Step 7: Cleanup

```bash
# Uninstall everything (deployment, service, secret, pods)
helm uninstall interviewcoach
```

---

## Helm Chart Configuration Reference

### Environment Comparison

| Setting | Development | Production |
|---------|-------------|------------|
| **Replicas** | 1 | 3 |
| **Image Tag** | latest | v1.0.0 (specific) |
| **Service Type** | ClusterIP | LoadBalancer |
| **Memory Limit** | 256Mi | 1Gi |
| **CPU Limit** | 200m | 1000m |
| **Autoscaling** | Disabled | Enabled (3-10 pods) |

### Key Configuration Options

Customize via `--set` flag or values files:

```bash
# Set specific values
helm install interviewcoach ./helm-chart \
  --set replicaCount=3 \
  --set image.tag="v1.0.1" \
  --set service.type="LoadBalancer" \
  --set openai.apiKey="sk-proj-..."

# Or create a custom values file
cat > my-values.yaml <<EOF
replicaCount: 2
image:
  tag: "v1.0.1"
resources:
  limits:
    memory: 1Gi
EOF

helm install interviewcoach ./helm-chart -f my-values.yaml
```

### Testing Before Deployment

```bash
# Validate chart syntax
helm lint helm-chart/

# Dry-run to see what would be deployed
helm install interviewcoach ./helm-chart \
  --dry-run --debug \
  --set openai.apiKey="test-key"

# Generate YAML without deploying
helm template interviewcoach ./helm-chart \
  --set openai.apiKey="test-key" > preview.yaml
```

---

## Helm Troubleshooting

### View Helm Releases

```bash
# List all releases
helm list

# Get detailed status
helm status interviewcoach

# View deployment history
helm history interviewcoach
```

### Common Helm Issues

**Issue: "Error: INSTALLATION FAILED: cannot re-use a name that is still in use"**
- A release with that name already exists
- Fix: Use `helm upgrade` instead of `helm install`, or uninstall first: `helm uninstall interviewcoach`

**Issue: Values not being applied**
- Check your values file path: `-f helm-chart/values-dev.yaml`
- Verify with dry-run: `helm install ... --dry-run --debug`
- Check precedence: `--set` overrides values files

**Issue: Secret not created**
- Ensure you provided `--set openai.apiKey="..."`
- Check: `kubectl get secret interviewcoach-openai`

---

## Helm Chart Documentation

For detailed Helm chart documentation, see [helm-chart/README.md](helm-chart/README.md), which includes:
- Full configuration reference
- Security best practices
- CI/CD integration examples
- Advanced features (Ingress, HPA, monitoring)

---

# Manual kubectl Deployment

This is the original deployment method. Good for learning Kubernetes basics, but Helm is recommended for production use.