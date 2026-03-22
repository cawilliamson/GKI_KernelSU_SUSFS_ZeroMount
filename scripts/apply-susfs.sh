#!/bin/bash
set -euo pipefail

ANDROID_VERSION="$1"
KERNEL_VERSION="$2"
SUB_LEVEL="$3"

SUSFS=/build/tmp/susfs4ksu
PATCHES=/build/tmp/kernel_patches
ACTION_BUILD=/build/tmp/action-build

echo "==> copying susfs source files..."
cp "$SUSFS/kernel_patches/50_add_susfs_in_gki-${ANDROID_VERSION}-${KERNEL_VERSION}.patch" .
cp "$SUSFS/kernel_patches/fs/"* ./fs/
cp "$SUSFS/kernel_patches/include/linux/"* ./include/linux/

echo "==> applying susfs gki patch..."
patch -p1 -F3 --no-backup-if-mismatch \
    < "50_add_susfs_in_gki-${ANDROID_VERSION}-${KERNEL_VERSION}.patch" || true

echo "==> applying susfs compatibility fixes..."
if [[ "$SUB_LEVEL" =~ ^[0-9]+$ ]]; then
    if [[ "$SUB_LEVEL" -le 141 || "$SUB_LEVEL" -ge 145 ]]; then
        if [[ -f "$PATCHES/wild/susfs_fix_patches/v2.0.0/a14-6.1/base.c.patch" ]]; then
            patch -p1 < "$PATCHES/wild/susfs_fix_patches/v2.0.0/a14-6.1/base.c.patch" || true
        fi
    fi
fi

# ensure required includes
if ! grep -qF '#include <linux/dma-buf.h>' fs/proc/base.c; then
    sed -i '/#include <linux\/cpufreq_times.h>/a #include <linux\/dma-buf.h>' fs/proc/base.c
fi
if grep -q 'susfs_is_current_proc_umounted' fs/proc/base.c && ! grep -qF '#include <linux/susfs.h>' fs/proc/base.c; then
    sed -i '/#include <linux\/dma-buf.h>/a #include <linux\/susfs.h>' fs/proc/base.c
fi

# unicode bypass fix
echo "==> applying unicode bypass fix..."
if [[ -f "$ACTION_BUILD/patches/unicode_bypass_fix_6.1+.patch" ]]; then
    patch -p1 --forward < "$ACTION_BUILD/patches/unicode_bypass_fix_6.1+.patch" || true
fi

echo "==> susfs patches applied"
