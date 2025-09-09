# Python Flask Application

A simple Flask application that calculates change for given dollar amounts.

## Features
- Health check endpoints
- Change calculation API
- Production-ready with Docker and Kubernetes support

## Local Development
```bash
pip install -r requirements.txt
python app.py
```

## Docker
```bash
docker build -t python-app .
docker run -p 8080:8080 python-app
```

## Kubernetes
```bash
kubectl apply -f k8s/
```

## API Endpoints
- `GET /` - Health check with application info
- `GET /health` - Simple health check
- `GET /change/<dollar>/<cents>` - Calculate change
