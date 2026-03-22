#!/bin/bash
set -euo pipefail

KERNEL_VERSION="$1"

GKI_CONFIG=/build/tmp/gki-config
SUKISU=/build/tmp/sukisu_patch

echo "==> upgrading lz4 to 1.10.0..."
rm -f lib/lz4/lz4_compress.c lib/lz4/lz4_decompress.c lib/lz4/lz4defs.h lib/lz4/lz4hc_compress.c
cp -r "$GKI_CONFIG/zram/lz4/"* ./lib/lz4/
cp -r "$GKI_CONFIG/zram/include/linux/"* ./include/linux/
bash "$GKI_CONFIG/zram/apply_lz4_neon.sh" || true

echo "==> adding lz4kd/lz4k_oplus..."
cp -r "$SUKISU/other/zram/lz4k/include/linux/"* ./include/linux/
cp -r "$SUKISU/other/zram/lz4k/lib/"* ./lib/
cp -r "$SUKISU/other/zram/lz4k/crypto/"* ./crypto/
cp -r "$SUKISU/other/zram/lz4k_oplus" ./lib/

[[ -f "$SUKISU/other/zram/zram_patch/${KERNEL_VERSION}/lz4kd.patch" ]] && \
    patch -p1 -F3 < "$SUKISU/other/zram/zram_patch/${KERNEL_VERSION}/lz4kd.patch" || true
[[ -f "$SUKISU/other/zram/zram_patch/${KERNEL_VERSION}/lz4k_oplus.patch" ]] && \
    patch -p1 -F3 < "$SUKISU/other/zram/zram_patch/${KERNEL_VERSION}/lz4k_oplus.patch" || true

echo "==> zram patches applied"
