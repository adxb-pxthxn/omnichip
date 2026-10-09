#!/usr/bin/env bash
# Install the ihp-sg13cmos5l PDK into $PDK_ROOT.
# Same pin as TinyTapeout/tt-gds-action@ihp-cmos5l (install_sg13cmos5l.sh).
set -euo pipefail

: "${PDK_ROOT:?PDK_ROOT must be set (e.g. export PDK_ROOT=\"\$HOME/ttsetup/pdk\")}"

IHP_PDK_REPO="https://github.com/IHP-GmbH/IHP-Open-PDK.git"
# IHP-Open-PDK, 2026-09-08 — the revision the CMOS5L GDS action pins.
IHP_PDK_REV="2bbec755dc67ca3db0261c3d6163e15735d66710"

mkdir -p "$PDK_ROOT"
if [ -f "$PDK_ROOT/ihp-sg13cmos5l/SOURCES" ] \
   && grep -q "$IHP_PDK_REV" "$PDK_ROOT/ihp-sg13cmos5l/SOURCES"; then
  echo "ihp-sg13cmos5l already at $IHP_PDK_REV under $PDK_ROOT"
  exit 0
fi

git -C "$PDK_ROOT" init -q
git -C "$PDK_ROOT" fetch -q --depth 1 "$IHP_PDK_REPO" "$IHP_PDK_REV"
git -C "$PDK_ROOT" checkout -q FETCH_HEAD

echo "IHP-Open-PDK $IHP_PDK_REV" > "$PDK_ROOT/ihp-sg13cmos5l/SOURCES"
echo "Installed ihp-sg13cmos5l at $PDK_ROOT (rev $IHP_PDK_REV)"
