#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="${REPO_URL:-https://github.com/LakshyaSingh354/mlsys-roadmap.git}"
REPO_DIR="${REPO_DIR:-/workspace/mlsys-roadmap}"
WORKSPACE="${WORKSPACE:-/workspace}"

mkdir -p "$WORKSPACE"

if [[ -d "$REPO_DIR/.git" ]]; then
  echo "[mlsys] Repo already exists at $REPO_DIR; preserving working tree."
  echo "[mlsys] Not running pull/reset automatically, so uncommitted work is safe."
elif [[ -e "$REPO_DIR" ]]; then
  echo "[mlsys] ERROR: $REPO_DIR exists but is not a Git checkout." >&2
  echo "[mlsys] Move it aside or set REPO_DIR to another path; refusing to overwrite." >&2
  exit 2
else
  echo "[mlsys] Cloning $REPO_URL into $REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR"
fi

if [[ -f "$REPO_DIR/requirements.txt" ]]; then
  echo "[mlsys] Installing repo requirements.txt"
  python -m pip install -r "$REPO_DIR/requirements.txt"
fi

echo "[mlsys] Environment ready."
echo "[mlsys] Repo: $REPO_DIR"
echo "[mlsys] Python: $(python --version)"
python - <<'PY'
try:
    import torch
    print(f"[mlsys] PyTorch: {torch.__version__}")
    print(f"[mlsys] CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"[mlsys] GPU: {torch.cuda.get_device_name(0)}")
except Exception as exc:
    print(f"[mlsys] PyTorch check failed: {exc}")
PY
