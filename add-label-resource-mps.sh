#!/bin/sh

# Check if required parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <NODE_NAME> <GPU_PRODUCT>"
    echo "Example: $0 gpu-node-h200 NVIDIA-H200"
    exit 1
fi

NODE_NAME="$1"
GPU_PRODUCT="$2"
GPU_MEMORY=81920

echo "adding labels to node: ${NODE_NAME}, GPU Product: ${GPU_PRODUCT}, GPU Memory: ${GPU_MEMORY}Mi, GPU Count: 4, Sharing Strategy: MPS, Share Count: 8"

# GFD标签 - NVIDIA GPU相关
kubectl label node ${NODE_NAME} \
    nvidia.com/gpu.present=true \
    nvidia.com/gpu.count=8 \
    nvidia.com/gpu.replicas=2 \
    nvidia.com/gpu.product=${GPU_PRODUCT} \
    nvidia.com/gpu.sharing-strategy=mps \
    nvidia.com/gpu.family=ampere \
    nvidia.com/gpu.compute.major=8 \
    nvidia.com/gpu.compute.minor=0 \
    nvidia.com/gpu.memory=${GPU_MEMORY} \
    nvidia.com/cuda.driver-version.full=535.104.05 \
    nvidia.com/gpu.driver.major=535 \
    nvidia.com/gpu.driver.minor=104 \
    nvidia.com/gpu.driver.rev=05 \
    nvidia.com/gpu.cuda.major=12 \
    nvidia.com/gpu.cuda.minor=2 \
    nvidia.com/gpu.cuda.patch=0 \
    nvidia.com/mig.capable=false \
    nvidia.com/mps.capable=true \
    nvidia.com/gpu.multiprocessors=108 \
    --overwrite > /dev/null 2>&1

# 4张整卡
kubectl get node ${NODE_NAME} -o json \
    | jq '.status.capacity["nvidia.com/gpu"]="4" | .status.allocatable["nvidia.com/gpu"]="4"' \
    | kubectl replace --raw /api/v1/nodes/${NODE_NAME}/status -f - \
    > /dev/null 2>&1

# 8张MPS子卡  
kubectl get node ${NODE_NAME} -o json \
    | jq '.status.capacity["nvidia.com/gpu.shared"]="8" | .status.allocatable["nvidia.com/gpu.shared"]="8"' \
    | kubectl replace --raw /api/v1/nodes/${NODE_NAME}/status -f - \
    > /dev/null 2>&1