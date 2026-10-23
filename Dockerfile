# syntax=docker/dockerfile:1
# Reproducible CUDA development environment for the mlsys-roadmap repo.
# Vast.ai's SSH/Jupyter launch mode supplies its own access setup.
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    WORKSPACE=/workspace \
    REPO_DIR=/workspace/mlsys-roadmap

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git git-lfs build-essential cmake ninja-build pkg-config \
      gdb g++ gcc make ccache \
      python3 python3-dev python3-pip python3-venv \
      tmux htop nvtop less vim nano rsync openssh-client \
      && rm -rf /var/lib/apt/lists/* \
      && git lfs install

# A dedicated venv avoids depending on distro-managed Python packages.
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

RUN python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install \
      torch==2.7.1 \
      --index-url https://download.pytorch.org/whl/cu128 \
    && python -m pip install \
      ipython ipykernel jupyterlab \
      numpy scipy pandas matplotlib seaborn \
      pytest pytest-benchmark hypothesis \
      # Triton is installed as the version compatible with this PyTorch build.

# Startup script is also available for Vast.ai's On-start Script field.
COPY scripts/mlsys-onstart.sh /usr/local/bin/mlsys-onstart
RUN chmod 0755 /usr/local/bin/mlsys-onstart \
    && mkdir -p /workspace

WORKDIR /workspace
CMD ["/bin/bash"]
