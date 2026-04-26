# Use Python 3.11 as the base image
FROM python:3.11-bullseye

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    texlive-full \
    poppler-utils \
    chktex \
    fonts-noto-cjk \
    && fc-cache -fv \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip==24.2

# Install PyTorch (CPU-only to save disk space; switch to cu124 if GPU is available)
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . /app/AI-Scientist-v2

# Set working directory to the app code
WORKDIR /app/AI-Scientist-v2

# Create entrypoint script
RUN printf '#!/bin/bash\n\
if [ "$1" = "ideation" ]; then\n\
    shift\n\
    python ai_scientist/perform_ideation_temp_free.py "$@"\n\
elif [ "$1" = "bfts" ]; then\n\
    shift\n\
    python launch_scientist_bfts.py "$@"\n\
else\n\
    exec "$@"\n\
fi\n' > /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Set the default command
CMD ["bash"]
