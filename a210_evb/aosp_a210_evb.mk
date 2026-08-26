#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call inherit-product, device/alibaba/a210/device.mk)

PRODUCT_NAME := aosp_a210_evb
PRODUCT_DEVICE := a210
PRODUCT_BRAND := Alibaba
PRODUCT_MODEL := Zhihe A210 EVB
PRODUCT_MANUFACTURER := Alibaba
