#!/bin/bash
set -euo pipefail

DEFCONFIG="common/arch/arm64/configs/gki_defconfig"
FRAG="common/arch/arm64/configs/ksu.fragment"

cp "$DEFCONFIG" "$DEFCONFIG.orig"

echo "==> configuring kernel options..."
cat >> "$DEFCONFIG" <<EOF
CONFIG_KPM=y
CONFIG_KSU=y
CONFIG_KSU_SUSFS=y
CONFIG_KSU_SUSFS_ENABLE_LOG=y
CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y
CONFIG_KSU_SUSFS_OPEN_REDIRECT=y
CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y
CONFIG_KSU_SUSFS_SPOOF_UNAME=y
CONFIG_KSU_SUSFS_SUS_KSTAT=y
CONFIG_KSU_SUSFS_SUS_MAP=y
CONFIG_KSU_SUSFS_SUS_MOUNT=y
CONFIG_KSU_SUSFS_SUS_PATH=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_ZEROMOUNT=y
EOF

echo "==> configuring zram..."
sed -i 's/CONFIG_ZSMALLOC=m/CONFIG_ZSMALLOC=y/g' "$DEFCONFIG"
sed -i 's/CONFIG_ZRAM=m/CONFIG_ZRAM=y/g' "$DEFCONFIG"
grep -q 'CONFIG_ZSMALLOC=y' "$DEFCONFIG" || echo 'CONFIG_ZSMALLOC=y' >> "$DEFCONFIG"

sed -i '/zsmalloc\.ko/d; /zram\.ko/d' common/modules.bzl 2>/dev/null || true
sed -i '/zsmalloc\.ko/d; /zram\.ko/d' common/android/gki_aarch64_modules 2>/dev/null || true

cat >> "$DEFCONFIG" <<EOF
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4HC=y
CONFIG_CRYPTO_LZ4K=y
CONFIG_CRYPTO_LZ4KD=y
CONFIG_CRYPTO_LZ4K_OPLUS=y
CONFIG_ZRAM_DEF_COMP_LZ4KD=y
CONFIG_ZRAM_WRITEBACK=y
EOF

echo "==> removing build checks..."
[[ -f build/kernel/abi/check_buildtime_symbol_protection.py ]] && \
    perl -i -pe 's/^(\s*)return 1$/$1return 0/g if /if missing_symbols:/../return 1/' \
        build/kernel/abi/check_buildtime_symbol_protection.py || true
sed -i 's/check_defconfig//' common/build.config.gki 2>/dev/null || true
sed -i '/stable_scmversion_cmd/s/-maybe-dirty//g' build/kernel/kleaf/impl/stamp.bzl 2>/dev/null || true
sed -i 's/-dirty//' common/scripts/setlocalversion 2>/dev/null || true
rm -rf common/android/abi_gki_protected_exports_*
perl -pi -e 's/^\s*"protected_exports_list"\s*:\s*"android\/abi_gki_protected_exports_aarch64",\s*$//;' \
    common/BUILD.bazel 2>/dev/null || true
sed -i '/kmi_symbol_list_strict_mode/d' common/BUILD.bazel 2>/dev/null || true
sed -i 's/BUILD_SYSTEM_DLKM=1/BUILD_SYSTEM_DLKM=0/' common/build.config.gki.aarch64 2>/dev/null || true
sed -i '/MODULES_ORDER=android\/gki_aarch64_modules/d' common/build.config.gki.aarch64 2>/dev/null || true
sed -i '/KMI_SYMBOL_LIST_STRICT_MODE/d' common/build.config.gki.aarch64 2>/dev/null || true

echo "==> generating defconfig fragment..."
diff "$DEFCONFIG.orig" "$DEFCONFIG" | grep '^>' | sed 's/^> //' > "$FRAG" || true
cp "$DEFCONFIG.orig" "$DEFCONFIG"

# dedup (last wins)
tac "$FRAG" | awk -F= '/^CONFIG_/{if(seen[$1]++)next} {print}' | tac > "${FRAG}.tmp"
mv "${FRAG}.tmp" "$FRAG"
sed -i 's/^\(CONFIG_[A-Za-z0-9_]*\)=n$/# \1 is not set/' "$FRAG"

echo "==> defconfig fragment:"
cat "$FRAG"

cd common
git add -A
git commit -m "ksu+susfs+zeromount: configured" --allow-empty || true
echo "==> configuration complete"
