#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Single board variant; embed raw DTB directly (U-Boot here rejects mkdtimg's DT_TABLE format).

ifneq ($(filter a210, $(TARGET_DEVICE)),)

DTBIMAGE := $(PRODUCT_OUT)/dtb.img

LOCAL_DTB := device/alibaba/kernel/mainline/a210-evb.dtb

ifeq ($(wildcard $(LOCAL_DTB)),)
$(error A210 DTB not found at $(LOCAL_DTB))
endif

$(DTBIMAGE): $(LOCAL_DTB)
	cp $< $@

include $(CLEAR_VARS)
LOCAL_MODULE := dtbimage
LOCAL_LICENSE_KINDS := legacy_notice
LOCAL_LICENSE_CONDITIONS := notice
LOCAL_ADDITIONAL_DEPENDENCIES := $(DTBIMAGE)
include $(BUILD_PHONY_PACKAGE)

droidcore: dtbimage

endif
