#!/bin/sh

# 创建cluster集群
echo "creating mock cluster..."
kind create cluster --name mock-cluster-127 --config kind-1.27.yaml

# 添加GPU Mock资源
echo "adding GPU mock resources..."
sh add-label-resource.sh gpu-node-h200 NVIDIA-H200
sh add-label-resource.sh gpu-node-4090 NVIDIA-GeForce-RTX-4090
sh add-label-resource.sh gpu-node-h800 NVIDIA-H800
sh add-label-resource-mps.sh gpu-node-h800-mps NVIDIA-H800
sh add-label-resource-mig.sh gpu-node-h200-mig NVIDIA-H200

echo "mock cluster created successfully!"