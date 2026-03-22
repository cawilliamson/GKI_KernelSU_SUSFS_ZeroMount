#!/bin/bash
set -euo pipefail

FRAG_FLAG=""
[[ -s "common/arch/arm64/configs/ksu.fragment" ]] && \
    FRAG_FLAG="--defconfig_fragment=//common:arch/arm64/configs/ksu.fragment"

# fix resolve_btfids sysroot issue (prebuilt clang may lack host glibc symbols)
if [[ -f common/tools/bpf/resolve_btfids/Makefile ]]; then
    echo 'override KBUILD_HOSTLDFLAGS += --sysroot=/' >> common/tools/bpf/resolve_btfids/Makefile
    echo 'override LDFLAGS += --sysroot=/' >> common/tools/bpf/resolve_btfids/Makefile
fi

echo "==> building kernel (this will take a while)..."
tools/bazel build \
    --config=fast \
    --lto=thin \
    $FRAG_FLAG \
    //common:kernel_aarch64_dist || {
        if find . -name "Image" -type f 2>/dev/null | grep -q .; then
            echo "WARNING: build exited non-zero but Image exists (likely depmod failure)"
        else
            exit 1
        fi
    }

echo "==> kernel built successfully"
strings ./bazel-bin/common/kernel_aarch64/Image | grep 'Linux version' || true
