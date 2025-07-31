#!/bin/bash

set -e

echo "🚀 Starting n8n Kubernetes deployment..."

# Create namespace first
echo "📁 Creating namespace..."
kubectl apply -f namespace.yaml

# Deploy persistent volume claims
echo "💾 Creating persistent volume claims..."
kubectl apply -f n8n-claim0-persistentvolumeclaim.yaml
kubectl apply -f postgres-claim0-persistentvolumeclaim.yaml
kubectl apply -f redis-claim0-persistentvolumeclaim.yaml

# Deploy secrets and configmaps
echo "🔐 Creating secrets and configmaps..."
kubectl apply -f postgres-secret.yaml
kubectl apply -f n8n-secret.yaml
kubectl apply -f postgres-configmap.yaml

# Deploy databases (PostgreSQL and Redis)
echo "🗄️  Deploying databases..."
kubectl apply -f postgres-deployment.yaml
kubectl apply -f redis-deployment.yaml

# Deploy database services
echo "🌐 Creating database services..."
kubectl apply -f postgres-service.yaml
kubectl apply -f redis-service.yaml

# Wait for databases to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/postgres -n n8n

echo "⏳ Waiting for Redis to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/redis -n n8n

# Deploy n8n main application
echo "🎯 Deploying n8n main application..."
kubectl apply -f n8n-deployment.yaml

# Deploy n8n service
echo "🌐 Creating n8n service..."
kubectl apply -f n8n-service.yaml

# Wait for n8n to be ready before deploying workers
echo "⏳ Waiting for n8n to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/n8n -n n8n

# Deploy n8n workers
echo "👷 Deploying n8n workers..."
kubectl apply -f n8n-worker-deployment.yaml

# Final status check
echo "✅ Deployment complete! Checking status..."
kubectl get pods -n n8n
kubectl get services -n n8n

echo ""
echo "🎉 n8n deployment finished successfully!"
echo "📊 Current status:"
kubectl get deployments -n n8n

echo ""
echo "🔗 To access n8n, you may need to port-forward:"
echo "   kubectl port-forward service/n8n-service 5678:5678 -n n8n"
echo "   Then visit: http://localhost:5678"