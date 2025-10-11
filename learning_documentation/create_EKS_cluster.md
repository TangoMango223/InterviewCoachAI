# Make a cluster on AWS EKS

* Remember, using EKS for setup is for infrastructure setup

AWS EKS Cluster (Infrastructure) - like an apartment building
    ↓
Kubernetes Control Plane (orchestration brain)
    ↓
Your Kubernetes Resources (your application)
    ↓
Running Pods/Containers (your actual InterviewCoach app)

1 AWS Account
  └── 1 EKS Cluster + Kuberentes the manager
       └── 1 Node (t3.small server)
            ├── development namespace (folder)
            │    └── 1 Pod (app instance)
            │
            └── production namespace (folder)
                 ├── Pod #1 (app instance)
                 ├── Pod #2 (app instance)
                 └── Pod #3 (app instance)


* Kubernetes (the brain) can manage more than 1 node.

Multi-Node Cluster
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃            EKS CLUSTER (The Brain)                   ┃
┃         "I manage all these computers"               ┃
┃                                                      ┃
┃  ┏━━━━━━━━━━━━━━┓  ┏━━━━━━━━━━━━━━┓  ┏━━━━━━━━━━━┓ ┃
┃  ┃ NODE #1      ┃  ┃ NODE #2      ┃  ┃ NODE #3   ┃ ┃
┃  ┃ t3.small     ┃  ┃ t3.small     ┃  ┃ t3.small  ┃ ┃
┃  ┃              ┃  ┃              ┃  ┃           ┃ ┃
┃  ┃ ┌──────────┐ ┃  ┃ ┌──────────┐ ┃  ┃ ┌───────┐ ┃ ┃
┃  ┃ │ Pod #1   │ ┃  ┃ │ Pod #3   │ ┃  ┃ │ Pod #5│ ┃ ┃
┃  ┃ │ Frontend │ ┃  ┃ │ Backend  │ ┃  ┃ │ DB    │ ┃ ┃
┃  ┃ └──────────┘ ┃  ┃ └──────────┘ ┃  ┃ └───────┘ ┃ ┃
┃  ┃              ┃  ┃              ┃  ┃           ┃ ┃
┃  ┃ ┌──────────┐ ┃  ┃ ┌──────────┐ ┃  ┃           ┃ ┃
┃  ┃ │ Pod #2   │ ┃  ┃ │ Pod #4   │ ┃  ┃           ┃ ┃
┃  ┃ │ Frontend │ ┃  ┃ │ Backend  │ ┃  ┃           ┃ ┃
┃  ┃ └──────────┘ ┃  ┃ └──────────┘ ┃  ┃           ┃ ┃
┃  ┗━━━━━━━━━━━━━━┛  ┗━━━━━━━━━━━━━━┛  ┗━━━━━━━━━━━┛ ┃
┃                                                      ┃
┃  Kubernetes decides which pod goes on which node     ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┌────────────────────────────────────────┐
│  1 EKS Cluster                         │
│  (1 Kubernetes "brain")                │
│                                        │
│  Manages:                              │
│    ├── Node #1                         │
│    ├── Node #2                         │
│    └── Node #3 (if you add more)       │
│                                        │
│  Each node runs pods                   │
└────────────────────────────────────────┘

In production, clusters can manage:
* Small: 10-50 nodes
* Medium: 100-500 nodes
* Large: 1,000+ nodes
* Google/Amazon scale: 5,000+ nodes per cluster
AWS EKS limits:
* Default: Up to 450 nodes per cluster
* Can request increase: Up to 5,000 nodes

* EKS (Kubernetes) to 1 cluster (1:1)

EKS Cluster = You (the human brain)
   ↓
   Decides: "I need 3 Chrome windows open"
   Manages everything
   ↓
Node = Your MacBook (the computer)
   ↓
   The physical hardware doing the work
   ↓
3 Pods = 3 Chrome windows open
   ↓
   Each one is running the same app (Chrome)
   Each one can handle different users/tasks


┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  NODE (t3.small - Your Computer/Server)        ┃
┃  2 vCPU, 2GB RAM                               ┃
┃                                                ┃
┃  ┌─────────────┐  ┌─────────────┐             ┃
┃  │ Pod #1      │  │ Pod #2      │             ┃
┃  │ Service 1:  │  │ Service 1:  │             ┃
┃  │ Frontend    │  │ Frontend    │             ┃
┃  │ (React)     │  │ (React)     │             ┃
┃  │ 256MB       │  │ 256MB       │             ┃
┃  └─────────────┘  └─────────────┘             ┃
┃                                                ┃
┃  ┌─────────────┐  ┌─────────────┐             ┃
┃  │ Pod #3      │  │ Pod #4      │             ┃
┃  │ Service 2:  │  │ Service 2:  │             ┃
┃  │ Backend API │  │ Backend API │             ┃
┃  │ (FastAPI)   │  │ (FastAPI)   │             ┃
┃  │ 256MB       │  │ 256MB       │             ┃
┃  └─────────────┘  └─────────────┘             ┃
┃                                                ┃
┃  ┌─────────────┐                               ┃
┃  │ Pod #5      │                               ┃
┃  │ Service 3:  │                               ┃
┃  │ Database    │                               ┃
┃  │ (Postgres)  │                               ┃
┃  │ 512MB       │                               ┃
┃  └─────────────┘                               ┃
┃                                                ┃
┃  Total: 1.5GB / 2GB RAM used ✅                ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# Note the following:
* Check compatibility of AMD vs. ARM64 infrastructure base build builds with your Docker image and the cluster.

* Make sure to use the cheapest most affordable one, as you are using the free-tier of AWS.

Quick Reference
Your Mac	EC2 Instance	Docker Flag Needed
Apple Silicon (M1/M2/M3)	t3.small (AMD64)	✅ --platform linux/amd64
Intel Mac	t3.small (AMD64)	❌ Not needed (same architecture)


# What each Tool Does:

What Each Tool Does:

eksctl - Creates the EKS Cluster (Nodes)
eksctl create cluster \
  --name interviewcoach-cluster \
  --nodes 2
This creates:
✅ The EKS cluster
✅ The 2 nodes (EC2 t3.medium servers)
❌ Does NOT create pods/containers


Helm - Deploys Your App (Pods)
helm install interviewcoach ./helm-chart
This creates:
✅ Pods (your application)
✅ Containers (Docker)
✅ Service (LoadBalancer)
✅ Secret (OpenAI key)
❌ Does NOT create cluster or nodes
The Order You Must Do Things
Step 1: Create the cluster (ONE TIME)
┌────────────────────────────────┐
│ eksctl create cluster          │  ← Creates nodes
└────────────────────────────────┘
              ↓
    EKS Cluster is ready
    2 nodes running
              ↓
Step 2: Deploy your app (MANY TIMES)
┌────────────────────────────────┐
│ helm install myapp ./helm-chart│  ← Creates pods
└────────────────────────────────┘
              ↓
    3 pods running on the 2 nodes
Visual Breakdown
BEFORE running any commands:
┌─────────────────────────┐
│     AWS Account         │
│                         │
│     (Empty)             │
│                         │
└─────────────────────────┘
AFTER running eksctl create cluster:
┌─────────────────────────────────────┐
│          AWS Account                │
│                                     │
│  ┌───────────────────────────────┐  │
│  │   EKS Cluster                 │  │
│  │                               │  │
│  │   ┌────────┐   ┌────────┐    │  │
│  │   │Node #1 │   │Node #2 │    │  │
│  │   │ Empty  │   │ Empty  │    │  │
│  │   └────────┘   └────────┘    │  │
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
You have infrastructure, but no application yet.
AFTER running helm install:
┌─────────────────────────────────────────────┐
│          AWS Account                        │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │   EKS Cluster                         │  │
│  │                                       │  │
│  │   ┌────────────┐   ┌────────────┐    │  │
│  │   │  Node #1   │   │  Node #2   │    │  │
│  │   │            │   │            │    │  │
│  │   │ ┌────────┐ │   │ ┌────────┐ │    │  │
│  │   │ │Pod #1  │ │   │ │Pod #2  │ │    │  │
│  │   │ └────────┘ │   │ └────────┘ │    │  │
│  │   │ ┌────────┐ │   │            │    │  │
│  │   │ │Pod #3  │ │   │            │    │  │
│  │   │ └────────┘ │   │            │    │  │
│  │   └────────────┘   └────────────┘    │  │
│  │                                       │  │
│  └───────────────────────────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘

Summary of Math:
✅ 1 Kubernetes = 1 Cluster = 1 Brain
✅ 1 Cluster = Multiple Nodes (computers)
✅ 1 Node = Multiple Pods (limited by resources)
✅ 1 Pod = Usually 1 Container (can be more in advanced cases)
✅ 1 Container = Runs 1 Docker image (usually, unless you include helper functions or images)


### What are NameSpaces?
* Thematic or imaginary grouping of pods (i.e. applications, think back to Chrome browser analogy)
* A common namespace pattern is "production" and "development"
* Along with node affinities, you can use this plus namespace to mark which nodes (computers) will carry out development work, and which nodes (computers) will carry out production work.

Your MacBook
├── /Work (namespace)
│   ├── Excel.app (pod)
│   ├── PowerPoint.app (pod)
│   └── Teams.app (pod)
│
└── /Personal (namespace)
    ├── Spotify.app (pod)
    ├── Netflix.app (pod)
    └── Games.app (pod)


1 Node (t3.small computer)
│
├── development namespace (folder)
│   ├── Pod: interviewcoach-dev
│   ├── Pod: database-dev
│   └── Pod: redis-dev
│
└── production namespace (folder)
    ├── Pod: interviewcoach-prod-1
    ├── Pod: interviewcoach-prod-2
    ├── Pod: interviewcoach-prod-3
    ├── Pod: database-prod
    └── Pod: redis-prod


Example setup at work:
* 1 cluster via EKS, P5 Instance (that uses NVIDIDA N100 Tensor Core GPU) - https://aws.amazon.com/blogs/aws/new-amazon-ec2-p5-instances-powered-by-nvidia-h100-tensor-core-gpus-for-accelerating-generative-ai-and-hpc-applications/

That one cluster will be carrying out both development work using two nodes:
* You can label the node to carry out production or dev work, and also label the "pods" (applications) as being for dev or production

Diagram Setup:
1 EKS Cluster
├── Node #1: labeled environment=staging
│   └── Namespace: staging
│       └── Pod 1 (InterviewCoach staging instance)
│
└── Node #2: labeled environment=production
    └── Namespace: production
        ├── Pod 1 (InterviewCoach prod replica 1)
        ├── Pod 2 (InterviewCoach prod replica 2)
        └── Pod 3 (InterviewCoach prod replica 3)


The pods themselves aren't "labeled to carry out dev/prod work" - instead:
* The pods are identical (same application code: your InterviewCoach app)
* The deployment configuration specifies:
* Which namespace they belong to (staging or production)
* Which nodes they should run on (via nodeSelector: environment=staging or environment=production)
What makes them "dev" vs "prod":
* Environment variables (different API keys, configs)
* Which namespace they're deployed in
* Which node they're scheduled on


# Setup - 1 cluster, 2 nodes (one for dev, one for prod)


Steps:

### 1. Run this command to make the eks cluster
eksctl create cluster \
  --name interviewcoach-cluster \
  --region ca-central-1 \
  --nodegroup-name standard-workers \
  --node-type t3.small \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 2 \
  --managed

This usually takes ~15-20 minutes.

# Scale your node group from 1 to 2 nodes
eksctl scale nodegroup \
  --cluster=interviewcoach-cluster \
  --region=ca-central-1 \
  --nodes=2 \
  --name=standard-workers

### 2. Label Nodes (Node Affinity), one for dev work, one for prod work

Future: Terraform (manages AWS/EKS resources), instead of running all of these kubectl code.

# Find the name of your nodes:
kubectl get nodes -o wide

# Label Node 1 for staging
kubectl label nodes ip-192-168-26-237.ca-central-1.compute.internal environment=staging

# Label Node 2 for production
kubectl label nodes ip-192-168-55-22.ca-central-1.compute.internal environment=production

# Verify the labels were applied
kubectl get nodes --show-labels | grep environment


### 3. Make the Namespaces

* Remember, we have some "apps" for production, some for dev, this is making the imaginary folder for the work.
Staging pods will go in the staging namespace
Production pods will go in the production namespace

# Create staging namespace
kubectl create namespace staging

# Create production namespace
kubectl create namespace production

# Verify they were created
kubectl get namespaces

### 4. Push Docker Images via AWS ECR

* Build the frontend
cd web
npm install
npm run build
cd ..

* Build the Docker Image. make sure image is AMD64 compatible - make sure you are running this in your repo:

```code
docker build --platform linux/amd64 -t interviewcoach:latest .

```

* Login to AWS ECR, tag (rename it), and push

```code
aws ecr get-login-password --region ca-central-1 | \
  docker login --username AWS --password-stdin \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com

docker tag interviewcoach:latest \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest

aws ecr create-repository --repository-name interviewcoach --region ca-central-1

docker push 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest

```

Make sure to make the ECR private repository to "house" the docker image you made.

904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest
└────────────┬────────────────────────────┘ └─────┬─────┘ └──┬──┘
             │                                     │          │
        Registry URL                         Repository    Tag
     (where to push)                           (name)    (version)


* The docker image and repository name must be the same.

### 4. Set up any secrets via Kubernetes

* This solution requires more time, so we will skip it for now.

* We will be using Kubernetes Secrets - this will store in the cluster database until deleted.

```code
kubectl create secret generic interviewcoach-openai \
  --from-literal=OPENAI_API_KEY="your-key-here" \
  --namespace staging
```

Now we can deploy without passing the API key via helm:
```code
helm install interviewcoach ./helm-chart \
  --namespace staging \
  -f helm-chart/values-dev.yaml
```

Now, your development/staging environment should be ready to play around my application!

### 5. Verify your staging development worked.

* Since this is staging, this means it's not publicly available yet but with AWS EKS you can run this on your localhost without having to run the image on Docker.

```code
kubectl port-forward service/interviewcoach 8080:8080 --namespace staging
```

How to Verify Everything via kubectl:
1. See Namespaces:
kubectl get namespaces
2. See Node Labels:
kubectl get nodes --show-labels
or more specific:
kubectl get nodes -L environment
3. See Secrets:
# List secrets in staging
kubectl get secrets --namespace staging

# See secret details (still base64 encoded)
kubectl describe secret interviewcoach-openai --namespace staging

# Decode and view the actual secret value (be careful!)
kubectl get secret interviewcoach-openai --namespace staging -o jsonpath='{.data.OPENAI_API_KEY}' | base64 --decode
4. See Pods with Node Assignment:
kubectl get pods --namespace staging -o wide


### 6. Production Time!

What is different?
* 3 replicas instead of 1 (high availability) - aka 3 pods
* LoadBalancer service instead of ClusterIP (public access!)
* Higher resource limits
* Runs on the production node


Step 1: Create Production Secret

kubectl create secret generic interviewcoach-prod-openai \
  --from-literal=OPENAI_API_KEY="your-openai-key-here" \
  --namespace production

Step 2: Deploy to Production with Helm
helm install interviewcoach-prod ./helm-chart \
  --namespace production \
  -f helm-chart/values-prod.yaml

helm list -A


What this will create:
✅ 3 pods (for high availability)
✅ LoadBalancer service (public access with a real URL!)
✅ All pods scheduled on the production node (via nodeSelector)
✅ Autoscaling enabled (can scale from 3 to 10 pods based on CPU)

Step 3: Wait for LoadBalancer to Provision
This takes 2-3 minutes. Check the status:
kubectl get service interviewcoach-prod --namespace production --watch

Check all the services with the namespace of production

kubectl get svc -n production

* look for the external-IP

Example:

NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP                                                                 PORT(S)        AGE
interviewcoach-prod   LoadBalancer   10.100.220.69   ab1aba217d4ef408fb65d8cff8d72da2-844348531.ca-central-1.elb.amazonaws.com   80:32036/TCP   2m19s