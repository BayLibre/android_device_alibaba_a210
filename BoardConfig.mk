#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Architecture
# XuanTie C908 which has NO dedicated riscv64 arch variant in build/soong/cc/config
# The AOSP riscv64 baseline (-march=rv64gcv_zba_zbb_zbs) is already a strict subset
# of what the C908 advertises (the only extra extension the C908 has is
# zbc), and nothing in this tree is gated on zbc today, so adding a variant right now
# would be a no-op. Leave this empty (baseline) until there's a concrete
# zbc-gated fast path or an upstream C908 tuning model to hang a variant on.
TARGET_ARCH := riscv64
TARGET_ARCH_VARIANT :=
TARGET_CPU_ABI := riscv64
TARGET_CPU_VARIANT := generic

# 64-bit only
TARGET_SUPPORTS_32_BIT_APPS := false
TARGET_SUPPORTS_64_BIT_APPS := true

# Platform
TARGET_BOARD_PLATFORM := a210
TARGET_BOOTLOADER_BOARD_NAME := a210

# Metadata partition (creates /metadata mount point in system image)
BOARD_USES_METADATA_PARTITION := true

# Bootloader: U-Boot 2024.10 + OpenSBI, built out-of-tree, staged as prebuilts.
TARGET_NO_BOOTLOADER := true

# Kernel
TARGET_KERNEL_ARCH := riscv64
KERNEL_MODULES_PATH := device/alibaba/kernel/mainline
TARGET_PREBUILT_KERNEL := $(KERNEL_MODULES_PATH)/Image

# Kernel command line: console as uart4. deferred_probe_timeout=30 as a safety margin.
BOARD_KERNEL_CMDLINE := init=/init
BOARD_KERNEL_CMDLINE += firmware_class.path=/vendor/firmware
BOARD_KERNEL_CMDLINE += deferred_probe_timeout=30
ifneq ($(TARGET_BUILD_VARIANT),user)
BOARD_KERNEL_CMDLINE += earlycon
BOARD_KERNEL_CMDLINE += console=ttyS4,115200
endif

# Kernel modules staged by zhihe_a210_dist; re-run its bazel dist to refresh.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(KERNEL_MODULES_PATH)/ramdisk/*.ko)

# Explicit load order (deps aren't alphabetical):
# clk core -> reset -> pinctrl/power domain -> gpio -> eMMC/SD -> watchdog.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    $(KERNEL_MODULES_PATH)/ramdisk/zhihe-clk-core.ko \
    $(KERNEL_MODULES_PATH)/ramdisk/clk-a210.ko \
    $(KERNEL_MODULES_PATH)/ramdisk/reset-a210.ko \
    $(KERNEL_MODULES_PATH)/ramdisk/pinctrl-a210.ko \
    $(KERNEL_MODULES_PATH)/ramdisk/a210-pd.ko \
    $(KERNEL_MODULES_PATH)/ramdisk/gpio-dwapb.ko \
    $(KERNEL_MODULES_PATH)/ramdisk/cqhci.ko \
    $(KERNEL_MODULES_PATH)/ramdisk/sdhci-of-dwcmshc.ko \
    $(KERNEL_MODULES_PATH)/ramdisk/dw_wdt.ko

# Vendor DLKM: loaded after rootfs mount (no load-order dependency here).
BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(KERNEL_MODULES_PATH)/vendor_dlkm/*.ko)
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(KERNEL_MODULES_PATH)/vendor_dlkm/phy-zhihe-snps-c10phy.ko \
    $(KERNEL_MODULES_PATH)/vendor_dlkm/phy-zhihe-snps-usb2.ko \
    $(KERNEL_MODULES_PATH)/vendor_dlkm/dwc3-zhihe.ko \
    $(KERNEL_MODULES_PATH)/vendor_dlkm/drm_display_helper.ko \
    $(KERNEL_MODULES_PATH)/vendor_dlkm/drm_dma_helper.ko \
    $(KERNEL_MODULES_PATH)/vendor_dlkm/dw-hdmi.ko \
    $(KERNEL_MODULES_PATH)/vendor_dlkm/th1520-dw-hdmi.ko \
    $(KERNEL_MODULES_PATH)/vendor_dlkm/verisilicon-dc.ko

BOARD_SYSTEM_KERNEL_MODULES := $(wildcard $(KERNEL_MODULES_PATH)/system_dlkm/*.ko)
BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(BOARD_SYSTEM_KERNEL_MODULES)

# Boot image
BOARD_BOOT_HEADER_VERSION := 4
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_RAMDISK_USE_LZ4 := true
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_BASE := 0x80000000
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION) --pagesize $(BOARD_KERNEL_PAGESIZE) --kernel_offset 0x200000 --ramdisk_offset 0x1e000000
BOARD_MKBOOTIMG_INIT_ARGS := --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

# Bootconfig
BOARD_BOOTCONFIG += androidboot.load_modules_parallel=true
BOARD_BOOTCONFIG += androidboot.logcat.buffersize=4M
BOARD_BOOTCONFIG += androidboot.hardware=a210
BOARD_BOOTCONFIG += androidboot.boot_devices=soc/500000.sdhci
BOARD_BOOTCONFIG += androidboot.fstab_suffix=a210
BOARD_BOOTCONFIG += androidboot.vendor.apex.com.android.hardware.keymint=com.android.hardware.keymint.rust_nonsecure
BOARD_BOOTCONFIG += androidboot.vendor.apex.com.android.hardware.gatekeeper=com.android.hardware.gatekeeper.nonsecure
BOARD_BOOTCONFIG += androidboot.selinux=permissive

# GKI
BOARD_USES_GENERIC_KERNEL_IMAGE := true

# Partition sizes derived from the prebuilt GPT via sgdisk -p (dtbo unused for now).
BOARD_BOOTIMAGE_PARTITION_SIZE := 41943040
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
# BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_USERDATAIMAGE_PARTITION_SIZE := 2348810752

# Dynamic partitions
TARGET_USE_DYNAMIC_PARTITIONS := true
BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
BOARD_SUPER_PARTITION_SIZE := 4831838208
BOARD_SUPER_PARTITION_GROUPS := a210_dynamic_partitions
BOARD_A210_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor vendor_dlkm system_dlkm
BOARD_A210_DYNAMIC_PARTITIONS_SIZE := 2411724800

# Filesystem
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_COPY_OUT_VENDOR := vendor

# Vendor DLKM (USB3.1 gadget - not needed to mount rootfs or in recovery,
# device/alibaba/kernel/mainline/vendor_dlkm)
BOARD_USES_VENDOR_DLKMIMAGE := true
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

# System DLKM (generic GKI modules, device/alibaba/kernel/mainline/system_dlkm)
BOARD_USES_SYSTEM_DLKMIMAGE := true
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm

# A/B OTA
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS := boot system vendor vendor_boot init_boot vendor_dlkm system_dlkm vbmeta vbmeta_vendor_dlkm vbmeta_system_dlkm

# Recovery
TARGET_NO_RECOVERY := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true
TARGET_RECOVERY_FSTAB_GENRULE := gen_fstab_a210

# AVB
BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_INIT_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_INIT_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX_LOCATION := 3

BOARD_AVB_VBMETA_CUSTOM_PARTITIONS := vendor_dlkm system_dlkm

BOARD_AVB_VBMETA_VENDOR_DLKM := vendor_dlkm
BOARD_AVB_VBMETA_VENDOR_DLKM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_VENDOR_DLKM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_VENDOR_DLKM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_VENDOR_DLKM_ROLLBACK_INDEX_LOCATION := 4

BOARD_AVB_VBMETA_SYSTEM_DLKM := system_dlkm
BOARD_AVB_VBMETA_SYSTEM_DLKM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_SYSTEM_DLKM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_SYSTEM_DLKM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_DLKM_ROLLBACK_INDEX_LOCATION := 5

# SELinux
BOARD_SEPOLICY_DIRS += hardware/generic/usb/aidl/sepolicy
BOARD_SEPOLICY_DIRS += device/alibaba/a210/sepolicy/vendor

# VNDK
BOARD_VNDK_VERSION := current

# VINTF
DEVICE_MANIFEST_FILE := device/alibaba/a210/manifest.xml

# Temporary
ALLOW_MISSING_DEPENDENCIES := true
