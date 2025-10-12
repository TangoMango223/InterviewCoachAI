# instructions:

# 1. Build your new version
docker build --platform linux/amd64 -t interviewcoach:v1.1.0 .

# 2. Tag for ECR
docker tag interviewcoach:v1.1.0 \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:v1.1.0

# 3. Tag the same image as "latest"
docker tag interviewcoach:v1.1.0 \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest

# 4. Push both tags
docker push 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:v1.1.0
docker push 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest

# 5. Apply settings to your EC2 instance, making it on the AWS website.

# 🚀 InterviewCoach LLM App – AWS EC2 Deployment Guide

This guide shows how to deploy the **InterviewCoach** LLM app on AWS EC2 using **Docker** and **ECR**.

---

## 🧩 1. EC2 Setup Summary

- **Region:** `ca-central-1`
- **Instance type:** `t3.small` (8GB storage)
- **AMI:** Amazon Linux 2023
- **Security Group:**
  - SSH (22) → My IP
  - HTTP (80) → 0.0.0.0/0
- **IAM Role:**  
  - `AmazonEC2ContainerRegistryReadOnly`
  - `AmazonEC2InstanceConnect` *(optional but helpful)*

---

## 🔑 2. SSH into EC2 on local machine
```bash
# From your local machine
ssh -i ~/.ssh/ec2-interviewcoach.pem ec2-user@<EC2-PUBLIC-IP>

```

## 3. Once inside the LINUX OS:

sudo dnf update -y
sudo dnf install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
newgrp docker

docker ps

## 4. Remaining work:

Pull image from AWS ECR:

# Install AWS CLI (if missing)
sudo dnf install -y awscli

# Authenticate Docker to ECR
aws ecr get-login-password --region ca-central-1 \
 | docker login --username AWS --password-stdin 904570587651.dkr.ecr.ca-central-1.amazonaws.com

# Pull your app image
docker pull 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest

# Run container:
docker rm -f app 2>/dev/null && docker run -d --name app --restart unless-stopped \
  -e OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  -p 80:8080 \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest

# Test on the terminal:
docker ps
# Confirm ports show 0.0.0.0:80->8080/tcp

# Test locally
curl -I http://localhost
# Expect HTTP/1.1 200 OK


# Other commands:

docker stop app
docker rm app

docker restart app 

docker pull 904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest
docker rm -f app
docker run -d --name app --restart unless-stopped \
  -e OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  -p 80:8080 \
  904570587651.dkr.ecr.ca-central-1.amazonaws.com/interviewcoach:latest
