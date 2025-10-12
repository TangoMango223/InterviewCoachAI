# 👩‍💻 InterviewCoach

Do you ever struggle with getting the right answer in your interviews? Get amazing and quick feedback on your interview response with "InterviewCoach"! The InterviewCoach is designed to help you improve your behavioral and technical interview responses.

## Ways to use InterviewCoach

👉 Deployed on AWS EC2: https://bit.ly/interviewcoach-v1 

## Tech Stack

- **Frontend:** React + Vite + Tailwind CSS
- **Backend:** Python + FastAPI
- **AI:** OpenAI GPT-4o-mini
- **Deployment:** Docker + Kubernetes + AWS EKS

## Running Locally

### Prerequisites

- Python 3.11+
- Node.js 20+
- OpenAI API key

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/TangoMango223/InterviewCoachAI.git
   cd interviewcoach
   ```

2. **Set up environment variables**
   ```bash
   # Create .env file in the root directory
   echo "OPENAI_API_KEY=your-api-key-here" > .env
   ```

3. **Build the frontend**
   ```bash
   cd web
   npm install
   npm run build
   cd ..
   ```
   This builds the React app and copies it to `app/static/`

4. **Set up Python environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r app/requirements.txt
   ```

5. **Run the backend server**
   ```bash
   cd app
   uvicorn main:app --host 0.0.0.0 --port 8080
   ```

6. **Access the app**

   Open your browser and go to: `http://localhost:8080`

## Running with Docker

### Option 1: Pull Pre-built Image from Docker Hub (Easiest)

**Available on Docker Hub:** https://hub.docker.com/r/tangomango223/interviewcoach

```bash
# Pull the image
docker pull tangomango223/interviewcoach:v1.0.1

# Run the container
docker run -p 8080:8080 -e OPENAI_API_KEY=your-api-key-here tangomango223/interviewcoach:v1.0.1
```

Then open your browser and go to: `http://localhost:8080`

### Option 2: Build Locally

* This solution requires installing and running Docker on your machine!

1. **Build the Docker image**
   ```bash
   docker build -t interviewcoach .
   ```

2. **Run the container**
   ```bash
   docker run -p 8080:8080 --env-file .env interviewcoach
   ```

3. **Access the app**

   Open your browser and go to: `http://localhost:8080`

---

## Publishing Your Docker Image

### To Docker Hub:

1. **Login to Docker Hub**
   ```bash
   docker login
   ```

2. **Tag and push your image**
   ```bash
   docker tag interviewcoach <your-dockerhub-username>/interviewcoach:latest
   docker push <your-dockerhub-username>/interviewcoach:latest
   ```

### To AWS ECR Public:

1. **Create a public repository** (one-time setup)
   ```bash
   aws ecr-public create-repository \
     --repository-name interviewcoach \
     --region us-east-1
   ```

2. **Authenticate and push**
   ```bash
   aws ecr-public get-login-password --region us-east-1 | \
     docker login --username AWS --password-stdin public.ecr.aws

   docker tag interviewcoach public.ecr.aws/<your-alias>/interviewcoach:latest
   docker push public.ecr.aws/<your-alias>/interviewcoach:latest
   ```

## Project Structure

```
interviewcoach/
├── app/                  # Backend (FastAPI)
│   ├── main.py          # API endpoints
│   ├── prompt.py        # AI prompt configuration
│   ├── requirements.txt # Python dependencies
│   └── static/          # Built frontend (auto-generated)
├── web/                 # Frontend (React)
│   ├── src/
│   │   ├── App.jsx      # Main React component
│   │   └── styles.css   # Tailwind styles
│   └── package.json
├── Dockerfile           # Multi-stage Docker build
├── .env                 # Environment variables (not in git)
└── .gitignore
```

## Development

- Frontend development server: `cd web && npm run dev`
- Backend development: `cd app && uvicorn main:app --reload`

---

Built for learning deployment concepts: Docker → Kubernetes → Helm → AWS EKS