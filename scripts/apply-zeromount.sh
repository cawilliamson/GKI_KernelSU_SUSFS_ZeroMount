#!/bin/bash
set -euo pipefail

ANDROID_VERSION="$1"
KERNEL_VERSION="$2"

# zeromount patch is identical across ksu variants
PATCH="/build/tmp/super-builders/android14-6.1/KernelSU-Next/patches/60_zeromount-${ANDROID_VERSION}-${KERNEL_VERSION}.patch"

echo "==> applying zeromount patch..."
patch -p1 -F3 --no-backup-if-mismatch < "$PATCH"
echo "==> zeromount applied"
