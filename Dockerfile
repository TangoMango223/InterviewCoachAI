# syntax=docker/dockerfile:1

######## 1) Build the React frontend ########
FROM node:20-alpine AS webbuild
WORKDIR /web
COPY web/package*.json ./
RUN npm install
COPY web/ .
RUN npm run build

######## 2) Build the Python app image ########
FROM python:3.11-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app

# System deps (Install curl useful for debugging)
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# Python deps
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app/ folder to make a new folder in Docker that has these fles in /app/
COPY app/ /app/

# Copy from webbuild, in here, copy the web/dist/ folder to /app/static/
COPY --from=webbuild /web/dist/ /app/static/

# Container uses port 8080
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
