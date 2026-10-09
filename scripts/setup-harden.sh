#!/usr/bin/env bash
# Local harden path: CMOS5L tt-support-tools + PDK + LibreLane.
# Needs Docker. Day-to-day RTL work does not — use ./scripts/setup-sim.sh.
# Run from the repo root: ./scripts/setup-harden.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null; then
  echo "Docker is required for local hardening (LibreLane runs in a container)."
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "Docker is installed but the daemon is not reachable. Start it and retry."
  exit 1
fi

export PDK_ROOT="${PDK_ROOT:-$HOME/ttsetup/pdk}"
export PDK="${PDK:-ihp-sg13cmos5l}"

mkdir -p "$(dirname "$PDK_ROOT")"
"$ROOT/scripts/install-pdk-cmos5l.sh"

if [ ! -d "$ROOT/tt/.git" ]; then
  git clone -b ihp-sg13cmos5l https://github.com/TinyTapeout/tt-support-tools "$ROOT/tt"
else
  git -C "$ROOT/tt" fetch -q origin ihp-sg13cmos5l
  git -C "$ROOT/tt" checkout -q ihp-sg13cmos5l
  git -C "$ROOT/tt" pull -q --ff-only
fi

VENV="${OMNICHIP_HARDEN_VENV:-$HOME/ttsetup/venv}"
if [ ! -d "$VENV" ]; then
  python3 -m venv "$VENV"
fi
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install -U pip
pip install -r "$ROOT/tt/requirements.txt"
pip install 'librelane==3.1.0.dev3'

cat <<EOF

Harden env ready.
  export PDK_ROOT=$PDK_ROOT
  export PDK=$PDK
  source $VENV/bin/activate

Then from the repo root (same commands CI uses):
  ./tt/tt_tool.py --create-user-config --ihp
  ./tt/tt_tool.py --harden --ihp

GDS and reports land under runs/. First PDK fetch is large; later runs reuse \$PDK_ROOT.
EOF
