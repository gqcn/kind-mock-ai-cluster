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

echo "adding labels to node: ${NODE_NAME}, GPU Product: ${GPU_PRODUCT}, GPU Memory: ${GPU_MEMORY}Mi, GPU Count: 7, Sharing Strategy: MIG, Share Count: 4"

# GFD标签 - NVIDIA GPU相关
kubectl label node ${NODE_NAME} \
    nvidia.com/gpu.present=true \
    nvidia.com/gpu.count=8 \
    nvidia.com/gpu.product=${GPU_PRODUCT} \
    nvidia.com/gpu.sharing-strategy=mig \
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
    --overwrite > /dev/null 2>&1


# MIG标签
kubectl label node ${NODE_NAME} \
    nvidia.com/mig-1g.18gb.count=1 \
    nvidia.com/mig-1g.18gb.engines.copy=1 \
    nvidia.com/mig-1g.18gb.engines.decoder=1 \
    nvidia.com/mig-1g.18gb.engines.encoder=0 \
    nvidia.com/mig-1g.18gb.engines.jpeg=1 \
    nvidia.com/mig-1g.18gb.engines.ofa=0 \
    nvidia.com/mig-1g.18gb.memory=24192 \
    nvidia.com/mig-1g.18gb.multiprocessors=8 \
    nvidia.com/mig-1g.18gb.product=NVIDIA-H20-MIG-1g.18gb \
    nvidia.com/mig-1g.18gb.replicas=1 \
    nvidia.com/mig-1g.18gb.sharing-strategy=none \
    nvidia.com/mig-1g.18gb.slices.ci=1 \
    nvidia.com/mig-1g.18gb.slices.gi=1 \
    nvidia.com/mig-3g.71gb.count=1 \
    nvidia.com/mig-3g.71gb.engines.copy=3 \
    nvidia.com/mig-3g.71gb.engines.decoder=3 \
    nvidia.com/mig-3g.71gb.engines.encoder=0 \
    nvidia.com/mig-3g.71gb.engines.jpeg=3 \
    nvidia.com/mig-3g.71gb.engines.ofa=0 \
    nvidia.com/mig-3g.71gb.memory=48512 \
    nvidia.com/mig-3g.71gb.multiprocessors=32 \
    nvidia.com/mig-3g.71gb.product=NVIDIA-H20-MIG-3g.71gb \
    nvidia.com/mig-3g.71gb.replicas=1 \
    nvidia.com/mig-3g.71gb.sharing-strategy=none \
    nvidia.com/mig-3g.71gb.slices.ci=3 \
    nvidia.com/mig-3g.71gb.slices.gi=3 \
    nvidia.com/mig.capable=true \
    nvidia.com/mig.config=mock-test-config \
    nvidia.com/mig.config.state=success \
    nvidia.com/mig.strategy=mixed \
    nvidia.com/mps.capable=false \
    --overwrite > /dev/null 2>&1

# 7张整卡
kubectl get node ${NODE_NAME} -o json \
    | jq '.status.capacity["nvidia.com/gpu"]="7" | .status.allocatable["nvidia.com/gpu"]="7"' \
    | kubectl replace --raw /api/v1/nodes/${NODE_NAME}/status -f - \
    > /dev/null 2>&1

# 4张MPS子卡  
# 3张 nvidia.com/mig-1g.18gb
# 1张 nvidia.com/mig-3g.71gb
kubectl get node ${NODE_NAME} -o json \
    | jq '.status.capacity["nvidia.com/mig-1g.18gb"]="3" | .status.allocatable["nvidia.com/mig-1g.18gb"]="3"' \
    | kubectl replace --raw /api/v1/nodes/${NODE_NAME}/status -f - \
    > /dev/null 2>&1

kubectl get node ${NODE_NAME} -o json \
    | jq '.status.capacity["nvidia.com/mig-3g.71gb"]="1" | .status.allocatable["nvidia.com/mig-3g.71gb"]="1"' \
    | kubectl replace --raw /api/v1/nodes/${NODE_NAME}/status -f - \
    > /dev/null 2>&1