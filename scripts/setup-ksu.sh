#!/bin/bash
set -euo pipefail

KSU_VARIANT="$1"

echo "==> setting up ${KSU_VARIANT}..."
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash -s main
echo "==> ${KSU_VARIANT} installed"
