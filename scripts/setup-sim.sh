#!/usr/bin/env bash
# Day-to-day omnichip sim setup: Icarus + cocotb. No PDK, no Docker.
# Run from the repo root: ./scripts/setup-sim.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v python3 >/dev/null; then
  echo "python3 is required"
  exit 1
fi

PY_MAJOR=$(python3 -c 'import sys; print(sys.version_info.major)')
PY_MINOR=$(python3 -c 'import sys; print(sys.version_info.minor)')
if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 11 ]; }; then
  echo "Need Python 3.11+, got $(python3 --version)"
  exit 1
fi

if ! command -v iverilog >/dev/null; then
  echo "Icarus Verilog (iverilog) is not on PATH."
  echo "  macOS:  brew install icarus-verilog"
  echo "  Ubuntu: sudo apt-get install -y iverilog"
  exit 1
fi

VENV="${OMNICHIP_VENV:-$ROOT/.venv}"
if [ ! -x "$VENV/bin/python" ]; then
  if ! python3 -m venv "$VENV"; then
    echo "python3 -m venv failed. On Debian/Ubuntu: sudo apt-get install -y python3-venv"
    rm -rf "$VENV"
    exit 1
  fi
fi
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install -U pip
pip install -r test/requirements.txt

echo
echo "Sim env ready."
echo "  source $VENV/bin/activate"
echo "  cd test && make"
echo
echo "Optional: gtkwave or Surfer for test/tb.fst waveforms."
