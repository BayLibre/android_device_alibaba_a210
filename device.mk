#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Use generic ramdisk (init_boot)
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Enable project quotas and casefolding for emulated storage without sdcardfs
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Dalvik heap config (ART/Zygote sizing, unrelated to display presence)
$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)

# GSI keys
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Kernel
LOCAL_KERNEL := device/alibaba/kernel/mainline/Image
PRODUCT_COPY_FILES += \
    $(LOCAL_KERNEL):kernel

# API level
PRODUCT_SHIPPING_API_LEVEL := 37

# Set Vendor SPL to match platform
VENDOR_SECURITY_PATCH = $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH = $(PLATFORM_SECURITY_PATCH)

# A/B OTA
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_client \
    update_verifier \
    checkpoint_gc

# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot-service.default \
    android.hardware.boot-service.default_recovery

# Fastboot
PRODUCT_PACKAGES += \
    fastbootd \
    android.hardware.fastboot-service.example

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.example \
    android.hardware.health-service.example_recovery

# USB HAL (BayLibre generic). &usb3 stays peripheral/gadget-only (ADB); usb2_0
# is now enabled in host mode (dwc2, see BoardConfig.mk vendor_dlkm modules),
# so declare the host feature. Still no .accessory.xml - nothing puts either
# controller into accessory mode.
PRODUCT_PACKAGES += \
    com.android.hardware.usb.generic

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml

# sys.usb.configfs=1: modern configfs gadget (mainline kernel has no legacy android_usb).
PRODUCT_PROPERTY_OVERRIDES += \
    sys.usb.configfs=1

# Audio HAL (BayLibre generic)
# No codec wired up yet; Config needed so AudioFlinger doesn't null-deref on startup.
PRODUCT_PACKAGES += \
    com.android.hardware.audio.generic

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration_7_0.xml \
    hardware/generic/audio/mixer_controls.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_controls.xml \
    device/alibaba/a210/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    device/alibaba/a210/audio/primary_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/primary_audio_policy_configuration.xml

PRODUCT_COPY_FILES += \
    hardware/generic/audio/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects_config.xml

PRODUCT_SOONG_NAMESPACES += \
    hardware/generic/audio

# Power HAL
PRODUCT_PACKAGES += \
    com.android.hardware.power

# KeyMint (software, no TEE)
PRODUCT_PACKAGES += \
    com.android.hardware.keymint.rust_nonsecure

# Gatekeeper (software, no TEE — required for FBE /data encryption)
PRODUCT_PACKAGES += \
    com.android.hardware.gatekeeper.nonsecure

# HIDL compatibility
PRODUCT_PACKAGES += \
    hwservicemanager \
    android.hidl.allocator@1.0-service

# ============================================================
# Display: android.hardware.composer.hwc3-service.drm (generic
# atomic-KMS composer) + minigbm allocator/mapper, backed by Mesa's
# gbm_mesa backend (see the GPU block below).
# ============================================================

# modetest: DRM/KMS test tool, bypasses SurfaceFlinger/gralloc/GPU for display bring-up.
PRODUCT_PACKAGES += \
    modetest

# Composer + gralloc ship their own VINTF fragments; no manifest.xml entry needed.
PRODUCT_PACKAGES += \
    android.hardware.composer.hwc3-service.drm \
    android.hardware.graphics.allocator-service.minigbm \
    mapper.minigbm

PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.gralloc=minigbm

PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=160 \
    ro.surface_flinger.protected_contents=false \
    config.disable_renderscript=true

PRODUCT_COPY_FILES += \
    device/linaro/hikey/etc/permissions/android.hardware.screen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.xml

# AON co-processor firmware must be shipped in the vendor ramdisk
PRODUCT_COPY_FILES += \
    device/alibaba/a210/firmware/a210-aon.bin:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/firmware/a210-aon.bin

# ============================================================
# GPU: Imagination PowerVR BXM-4-64 (IMG Rogue), via the upstream
# drivers/gpu/drm/imagination "powervr" driver (gpu@6c00000 in
# a210.dtsi). Userspace is Mesa3D: the PowerVR Vulkan driver, Zink
# for OpenGL ES on top of it, and gralloc via Mesa's gbm backend.
# ============================================================

# GPU firmware: same rogue_36.52.104.182_v1.fw as T-Head TH1520 (same
# GPU core/revision).
PRODUCT_COPY_FILES += \
    device/alibaba/a210/firmware/powervr/rogue_36.52.104.182_v1.fw:$(TARGET_COPY_OUT_VENDOR)/firmware/powervr/rogue_36.52.104.182_v1.fw

PRODUCT_SOONG_NAMESPACES += \
    device/alibaba/a210/mesa \
    external/minigbm/gbm_mesa_driver

PRODUCT_PACKAGES += \
    libGLES_mesa \
    libGLESv1_CM_mesa \
    libGLESv2_mesa \
    libgallium_dri \
    vulkan.mesa \
    libgbm_mesa \
    dri_gbm \
    vulkan_mesa_icd \
    libgbm_mesa_wrapper \
    zink_dri \
    powervr_dri \
    verisilicon_dri \
    kmsro_dri

PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.egl=mesa \
    ro.hardware.vulkan=mesa \
    debug.hwui.renderer=skiavk \
    debug.renderengine.backend=skiavkthreaded \
    vendor.gralloc.minigbm.backend=gbm_mesa \
    vendor.mesa.gbm_backends_path=/vendor/lib64/gbm \
    vendor.mesa.pvr.i.want.a.broken.vulkan.driver=1

PRODUCT_PROPERTY_OVERRIDES += \
    ro.opengles.version=196608 \
    persist.demo.rotationlock=1

TARGET_VULKAN_SUPPORT := true
TARGET_USES_VULKAN := true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2022-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml

# Vendor seccomp policy extension for media.swcodec: gralloc's gbm_mesa
# backend pulls in Mesa/Zink GPU init even for plain pixel-format queries,
# which mediaswcodec's default sandbox doesn't allow without this.
PRODUCT_COPY_FILES += \
    device/alibaba/a210/seccomp_policy/mediaswcodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaswcodec.policy

# WiFi
PRODUCT_PACKAGES += \
    linux_firmware_rtw88-rtw8822c

PRODUCT_PACKAGES += \
    wpa_supplicant \
    wpa_cli \
    wificond

PRODUCT_VENDOR_PROPERTIES += \
    wifi.interface=wlan0

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml

# Wifi P2P/Supplicant configs
PRODUCT_COPY_FILES += \
    device/alibaba/a210/wifi/wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    device/alibaba/a210/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    device/alibaba/a210/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf

# Fstab
PRODUCT_PACKAGES += \
    fstab.a210 \
    fstab.a210.vendor_ramdisk

# Init / ueventd
PRODUCT_COPY_FILES += \
    device/alibaba/a210/init.a210.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.a210.rc \
    device/alibaba/a210/init.a210.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.a210.usb.rc \
    device/alibaba/a210/ueventd.a210.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Permissions - generic OS software features unrelated to any specific
# hardware (verified_boot / secure_lock_screen match the AVB + nonsecure
# gatekeeper already enabled above; the rest are hardware-independent
# framework features). Deliberately no wifi/bluetooth/ethernet/usb.accessory
# permission XMLs - none of that hardware is enabled or has a driver on this
# board today. (usb.host.xml is copied in the USB HAL block above;
# android.hardware.screen.xml moved to the Display block above, now that a
# display composer is wired up.)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.software.backup.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.backup.xml \
    frameworks/native/data/etc/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml \
    frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml \
    frameworks/native/data/etc/android.software.secure_lock_screen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.secure_lock_screen.xml

# Codec2: force AIDL HAL selection (HIDL fallback finds no IComponentStore here; caused scrcpy encoder failures).
PRODUCT_PROPERTY_OVERRIDES += \
    media.c2.hal.selection=aidl \
    debug.stagefright.c2inputsurface=-1

# Media codecs: install stock Google C2 software codec defs (scrcpy needs c2.android.avc/opus encoders).
PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_audio.xml \
    device/alibaba/a210/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml

# SettingsProvider defaults (matches spacemit's k1/k3): def_screen_off_timeout=-1
# keeps the screen from ever sleeping, so the SoC never idles into s2idle
# suspend. A210 has no functional touch input yet, so once asleep nothing
# can wake it back up - the board just drops off adb/USB until power-cycled.
# Testing-only; drop once there's a real display + input path.
DEVICE_PACKAGE_OVERLAYS += device/alibaba/a210/overlay

# Storage: frp partition for factory reset protection (exists in vendor GPT).
PRODUCT_PROPERTY_OVERRIDES += \
    ro.frp.pst=/dev/block/by-name/frp
