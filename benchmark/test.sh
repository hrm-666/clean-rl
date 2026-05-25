#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Minimal local Atari benchmark for laptops:
# - installs only the Atari extras
# - no SLURM
# - single worker
# - single seed by default
# - one Atari game by default to keep the load manageable
#
# This script is only for:
#   cleanrl/ppo_atari.py on PongNoFrameskip-v4
#
# If your uv environment is already prepared, you can comment out the
# next install lines to skip dependency installation.
uv pip install ".[atari]"
uv run AutoROM --accept-license

if command -v xvfb-run >/dev/null 2>&1; then
    RUN_PREFIX=(xvfb-run -a)
else
    RUN_PREFIX=()
fi

OMP_NUM_THREADS=1 "${RUN_PREFIX[@]}" uv run python -m cleanrl_utils.benchmark \
    --env-ids PongNoFrameskip-v4 \
    --command "uv run python cleanrl/ppo_atari.py --capture_video" \
    --num-seeds 1 \
    --workers 1
