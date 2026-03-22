#!/bin/bash
set -euo pipefail

KERNEL_BRANCH="$1"

echo "==> initialising repo for common-${KERNEL_BRANCH}..."
repo init --depth=1 \
    -u https://android.googlesource.com/kernel/manifest \
    -b "common-${KERNEL_BRANCH}" \
    --repo-rev=v2.16

REMOTE=$(git ls-remote https://android.googlesource.com/kernel/common "${KERNEL_BRANCH}" 2>/dev/null || true)
if grep -q deprecated <<< "$REMOTE"; then
    echo "  -> branch is deprecated, adjusting manifest..."
    sed -i "s/\"${KERNEL_BRANCH}\"/\"deprecated\/${KERNEL_BRANCH}\"/g" .repo/manifests/default.xml
fi

echo "==> syncing kernel source..."
repo --trace sync -c -j$(nproc --all) --no-tags --fail-fast
echo "==> kernel source ready"
