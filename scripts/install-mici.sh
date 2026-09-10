#!/usr/bin/env bash
# openpilotKSA manual install for comma four (mici)
# Run ON the mici via: bash <(curl -s https://raw.githubusercontent.com/Eng-Omar-Alkatheri/openpilotKSA/master/scripts/install-mici.sh)
set -e

FORK="https://github.com/Eng-Omar-Alkatheri/openpilotKSA.git"
BRANCH="master"
FORCED_CAR="MAZDA_CX9_2021"

echo "[-] openpilotKSA installer (comma four / mici)"
echo "    This REPLACES the current openpilot install."

read -r -p "Continue? [y/N] " ok
[ "$ok" = "y" ] || exit 1

cd /data
if [ -d openpilot ]; then
  ts=$(date +%Y%m%d-%H%M%S)
  echo "[-] Backing up current install -> openpilot.bak.$ts"
  mv openpilot "openpilot.bak.$ts"
fi

echo "[-] Cloning fork (this pulls ~1GB, be patient)..."
git clone -b "$BRANCH" --recurse-submodules --shallow-submodules "$FORK" openpilot
cd openpilot

echo "[-] Setting forced car fingerprint: $FORCED_CAR"
mkdir -p /data/params/d
printf '%s' "$FORCED_CAR" > /data/params/d/GccForcedCar

echo "[-] Building (20-40 min on mici, screen may stay dark)..."
cd openpilot/system/manager
./build.py || { echo "BUILD FAILED - check output above"; exit 1; }

echo "[+] Done. Rebooting..."
sudo reboot
