# InterviewCoach Helm Chart

This Helm chart deploys the InterviewCoach AI application to Kubernetes (AWS EKS).

## Prerequisites

- Helm 3.x installed
- kubectl configured to connect to your EKS cluster
- OpenAI API key
- Docker image pushed to AWS ECR

## Quick Start

### 1. Install to Development Environment

```bash
# Deploy with minimal resources (1 replica, ClusterIP service)
helm install interviewcoach ./helm-chart \
  -f helm-chart/values-dev.yaml \
  --set openai.apiKey="your-openai-api-key"

# Access via port-forward (since ClusterIP doesn't create LoadBalancer)
kubectl port-forward svc/interviewcoach 8080:8080

# Visit: http://localhost:8080
```

### 2. Install to Production Environment

```bash
# Deploy with high availability (3 replicas, LoadBalancer, autoscaling)
helm install interviewcoach ./helm-chart \
  -f helm-chart/values-prod.yaml \
  --set openai.apiKey="your-openai-api-key" \
  --set image.tag="v1.0.0"

# Get the LoadBalancer URL
kubectl get svc interviewcoach
```

### 3. Using Default Values (Production-like)

```bash
# Uses values.yaml defaults (2 replicas, LoadBalancer)
helm install interviewcoach ./helm-chart \
  --set openai.apiKey="your-openai-api-key"
```

---

## Configuration

### Key Configuration Options

| Parameter | Description | Default | Dev Override | Prod Override |
|-----------|-------------|---------|--------------|---------------|
| `replicaCount` | Number of pods | `2` | `1` | `3` |
| `image.repository` | ECR repository | `904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach` | - | - |
| `image.tag` | Docker image tag | `latest` | `latest` | `v1.0.0` |
| `service.type` | Service type | `LoadBalancer` | `ClusterIP` | `LoadBalancer` |
| `service.port` | External port | `80` | `8080` | `80` |
| `openai.apiKey` | OpenAI API key | `""` (required) | - | - |
| `resources.limits.memory` | Max memory per pod | `512Mi` | `256Mi` | `1Gi` |
| `autoscaling.enabled` | Enable HPA | `false` | `false` | `true` |

### Full Configuration

See [values.yaml](values.yaml) for all available options with detailed comments.

---

## Common Operations

### View Deployed Releases

```bash
# List all Helm releases
helm list

# Get status of a specific release
helm status interviewcoach

# View deployment history
helm history interviewcoach
```

### Upgrade Deployment

```bash
# After building and pushing a new Docker image (e.g., v1.0.1)
helm upgrade interviewcoach ./helm-chart \
  --set image.tag="v1.0.1" \
  --set openai.apiKey="your-key"

# Or upgrade using prod values file
helm upgrade interviewcoach ./helm-chart \
  -f helm-chart/values-prod.yaml \
  --set image.tag="v1.0.1" \
  --set openai.apiKey="your-key"
```

### Rollback Deployment

```bash
# Rollback to previous version
helm rollback interviewcoach

# Rollback to specific revision
helm rollback interviewcoach 2
```

### Uninstall

```bash
# Remove the deployment completely
helm uninstall interviewcoach

# This deletes: deployment, service, secret, and pods
```

---

## Testing Before Deployment

### Validate Chart Syntax

```bash
# Check for errors in templates
helm lint helm-chart/
```

### Dry-Run (See Generated YAML)

```bash
# Preview what would be deployed (default values)
helm install interviewcoach ./helm-chart \
  --dry-run --debug \
  --set openai.apiKey="test-key"

# Preview dev configuration
helm install interviewcoach ./helm-chart \
  -f helm-chart/values-dev.yaml \
  --dry-run --debug \
  --set openai.apiKey="test-key"
```

### Template Rendering

```bash
# Generate Kubernetes YAML without installing
helm template interviewcoach ./helm-chart \
  --set openai.apiKey="test-key" > output.yaml

# Inspect the generated YAML
cat output.yaml
```

---

## Troubleshooting

### Check Pod Status

```bash
# View all resources
kubectl get all -l app.kubernetes.io/name=interviewcoach

# View pod logs
kubectl logs -l app.kubernetes.io/name=interviewcoach --tail=50 -f

# Describe a specific pod
kubectl describe pod <pod-name>
```

### Common Issues

**1. ImagePullBackOff**
- Verify image exists in ECR: `aws ecr list-images --repository-name interviewcoach`
- Check EKS node IAM role has ECR pull permissions

**2. CrashLoopBackOff with "Server missing OPENAI_API_KEY"**
- Ensure you provided `--set openai.apiKey="..."` during install
- Check secret: `kubectl get secret <release-name>-openai -o yaml`

**3. Service Pending (LoadBalancer not getting EXTERNAL-IP)**
- Wait 2-3 minutes for AWS to provision the LoadBalancer
- Check: `kubectl describe svc interviewcoach`

**4. Health Check Failures**
- Verify /health endpoint works: `kubectl logs <pod-name>`
- Adjust `healthCheck.initialDelaySeconds` if app takes longer to start

---

## Environment-Specific Deployments

### Development Workflow

```bash
# 1. Deploy to dev
helm install interviewcoach-dev ./helm-chart \
  -f helm-chart/values-dev.yaml \
  --set openai.apiKey="$OPENAI_API_KEY"

# 2. Test locally via port-forward
kubectl port-forward svc/interviewcoach-dev 8080:8080

# 3. Update code, rebuild, push image with :latest tag

# 4. Restart pods to pull new image
kubectl rollout restart deployment interviewcoach-dev
```

### Staging Workflow

```bash
# Deploy to staging namespace
helm install interviewcoach-staging ./helm-chart \
  --namespace staging \
  --create-namespace \
  --set image.tag="v1.0.1-rc1" \
  --set openai.apiKey="$OPENAI_API_KEY"
```

### Production Workflow

```bash
# 1. Deploy specific version to production
helm install interviewcoach ./helm-chart \
  -f helm-chart/values-prod.yaml \
  --set image.tag="v1.0.1" \
  --set openai.apiKey="$OPENAI_API_KEY"

# 2. Monitor rollout
kubectl rollout status deployment/interviewcoach

# 3. If issues occur, rollback immediately
helm rollback interviewcoach
```

---

## Security Best Practices

### Managing Secrets

**Option 1: Command-line flag (Quick, not recommended for prod)**
```bash
helm install interviewcoach ./helm-chart \
  --set openai.apiKey="sk-proj-..."
```

**Option 2: Secrets file (Better, but must not commit to git)**
```bash
# Create helm-chart/values-secrets.yaml (already in .gitignore)
cat > helm-chart/values-secrets.yaml <<EOF
openai:
  apiKey: "sk-proj-your-actual-key"
EOF

# Deploy using secrets file
helm install interviewcoach ./helm-chart \
  -f helm-chart/values-prod.yaml \
  -f helm-chart/values-secrets.yaml
```

**Option 3: External Secrets (Production recommended)**
- Use AWS Secrets Manager or Parameter Store
- Install External Secrets Operator in your cluster
- Reference secrets from AWS instead of passing via Helm

---

## Chart Structure

```
helm-chart/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values (production-like)
├── values-dev.yaml         # Development overrides
├── values-prod.yaml        # Production configuration
├── README.md               # This file
└── templates/
    ├── _helpers.tpl        # Reusable template functions
    ├── deployment.yaml     # Kubernetes Deployment
    ├── service.yaml        # Kubernetes Service (LoadBalancer)
    └── secret.yaml         # Kubernetes Secret (OpenAI key)
```

---

## Next Steps

1. **CI/CD Integration**:
   - GitHub Actions: Automate `helm upgrade` on push to main
   - Harness: Create deployment pipelines with approval gates

2. **Monitoring**:
   - Add Prometheus metrics
   - Set up Grafana dashboards
   - Configure alerts for pod failures

3. **Advanced Features**:
   - Add Ingress for custom domain
   - Implement horizontal pod autoscaling (HPA)
   - Add PodDisruptionBudget for high availability

---

## Questions?

- Review the main [deployment-howto.md](../deployment-howto.md) for AWS EKS setup
- Check Helm documentation: https://helm.sh/docs/
- Review Kubernetes concepts: https://kubernetes.io/docs/concepts/
