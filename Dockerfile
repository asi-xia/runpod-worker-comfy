# Stage 1: Base image with common dependencies
ARG NV_VERSION=12.6.3-cudnn-runtime-ubuntu22.04
FROM nvidia/cuda:${NV_VERSION}

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 
# Speed up some cmake builds
ENV CMAKE_BUILD_PARALLEL_LEVEL=8

RUN apt update && apt install software-properties-common -y \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && add-apt-repository ppa:ubuntuhandbook1/ffmpeg6 -y \
    && apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev pkg-config -y

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.11-dev \
    python3-pip \
    python3-apt \
    git \
    git-lfs \
    libgl1 \
    ffmpeg \
    && ln -sf /usr/bin/python3.11 /usr/bin/python \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/pip3 /usr/bin/pip \
    && python -m pip install --upgrade pip \
    && git lfs install

# Clean up to reduce image size
# RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install comfy-cli runpod
RUN pip install comfy-cli runpod requests opencv-python watchdog matplotlib

# Install ComfyUI
ARG COMFY_CUDA=12.6
RUN /usr/bin/yes | comfy --skip-prompt --workspace /comfyui install --nvidia --cuda-version ${COMFY_CUDA}

# Change working directory to ComfyUI
WORKDIR /comfyui

# Support for the network volume
ADD src/extra_model_paths.yaml ./

# Go back to the root
WORKDIR /

# Add scripts
ADD src/start.sh src/restore_snapshot.sh src/rp_handler.py test_input.json src/install_comfy_nodes.sh ./
RUN chmod +x /start.sh /restore_snapshot.sh /install_comfy_nodes.sh \
    && sed -i 's/\r$//' /start.sh \
    && sed -i 's/\r$//' /install_comfy_nodes.sh \
    && /install_comfy_nodes.sh

# Start container
CMD ["/start.sh"]
