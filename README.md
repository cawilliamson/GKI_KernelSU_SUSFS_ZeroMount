# GKI KernelSU SUSFS + ZeroMount

builds android14 GKI kernels with ReSukiSU + SUSFS + ZeroMount in a podman container.

## how it works

1. fetches kernel source from AOSP via `repo`
2. adds ReSukiSU (KernelSU fork with built-in SUSFS support)
3. applies SUSFS patches from [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)
4. applies ZeroMount patch from [Super-Builders](https://github.com/Enginex0/Super-Builders)
5. applies zram LZ4 upgrades + LZ4KD/LZ4K_OPLUS compression
6. builds with bazel (thin LTO)
7. packages as AnyKernel3 zip (xz ramdisk compression)

## prerequisites

- podman
- just
- ~50GB free disk space
- internet access (for AOSP kernel sync)

## usage

```bash
# full build (defaults: android14-6.1 LTS, ReSukiSU)
just

# build a specific sublevel instead of lts
SUB_LEVEL=157 OS_PATCH_LEVEL=2025-12 just

# individual steps
just build-container
just fetch-deps
just sync-kernel
just setup-ksu
just apply-susfs
just apply-zeromount
just apply-zram
just configure
just build-kernel
just package

# update dependency repos
just update-deps

# clean everything
just clean
```

## configuration

all configurable via environment variables:

| variable | default | description |
|----------|---------|-------------|
| `ANDROID_VERSION` | `android14` | android version |
| `KERNEL_VERSION` | `6.1` | kernel version |
| `SUB_LEVEL` | `X` | kernel sublevel (`X` = auto from lts) |
| `OS_PATCH_LEVEL` | `lts` | security patch level (`lts` = rolling) |
| `KSU_VARIANT` | `ReSukiSU` | kernelsu variant |

## sources

- kernel configs/patches: [GKI_KernelSU_SUSFS](https://github.com/zzh20188/GKI_KernelSU_SUSFS)
- zeromount patch: [Super-Builders](https://github.com/Enginex0/Super-Builders)
- susfs: [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)
- anykernel3: [WildKernels/AnyKernel3](https://github.com/WildKernels/AnyKernel3)
