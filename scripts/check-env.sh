#!/usr/bin/env bash
# Quick "is this machine ready" check. Exit 0 only if sim path is usable.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ok=0
fail=0

check() {
  local label=$1
  shift
  if "$@"; then
    echo "  ok  $label"
    ok=$((ok + 1))
  else
    echo "  !!  $label"
    fail=$((fail + 1))
  fi
}

have_iverilog() {
  command -v iverilog >/dev/null 2>&1
}

echo "omnichip env check (repo: $ROOT)"
check "python3 >= 3.11" python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)'
check "iverilog on PATH" have_iverilog
check "test/requirements.txt present" test -f "$ROOT/test/requirements.txt"
check "info.yaml tiles == 6x4" grep -q 'tiles: "6x4"' "$ROOT/info.yaml"
check "gds action is ihp-cmos5l" grep -q 'tt-gds-action@ihp-cmos5l' "$ROOT/.github/workflows/gds.yaml"
check "gds pdk is ihp-sg13cmos5l" grep -q 'pdk: ihp-sg13cmos5l' "$ROOT/.github/workflows/gds.yaml"

VENV_DIR="${OMNICHIP_VENV:-$ROOT/.venv}"
if [ -f "$VENV_DIR/bin/activate" ]; then
  # shellcheck disable=SC1091
  source "$VENV_DIR/bin/activate"
  check "cocotb importable" python -c 'import cocotb'
else
  echo "  ..  .venv missing (run ./scripts/setup-sim.sh)"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "sim path looks good ($ok checks)."
  exit 0
fi
echo "$fail check(s) failed. See docs/setup.md."
exit 1
