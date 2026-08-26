LOCAL_PATH := $(call my-dir)

# Copy A210 EVB bootloader prebuilts (built by alibaba-bootloaders) and flash script
# to PRODUCT_OUT.
BL_PREBUILT := vendor/alibaba/a210/bootloader

# Single A210 product; TARGET_DEVICE check isolates rules from other products.
ifeq ($(TARGET_DEVICE),a210)

ALIBABA_A210_FLASH_FILES :=

# bootzero-rvbl.bin (BROM-loaded first stage, RVBL header)
$(PRODUCT_OUT)/bootzero-rvbl.bin: $(BL_PREBUILT)/bootzero-rvbl.bin
	cp $< $@
ALIBABA_A210_FLASH_FILES += $(PRODUCT_OUT)/bootzero-rvbl.bin

# spl-with-fit-rvbl.bin (SPL + FIT: OpenSBI + U-Boot proper)
$(PRODUCT_OUT)/spl-with-fit-rvbl.bin: $(BL_PREBUILT)/spl-with-fit-rvbl.bin
	cp $< $@
ALIBABA_A210_FLASH_FILES += $(PRODUCT_OUT)/spl-with-fit-rvbl.bin

# emmc_boot-loader.img (flashed to the mmc0boot0 eMMC hardware boot partition)
$(PRODUCT_OUT)/emmc_boot-loader.img: $(BL_PREBUILT)/emmc_boot-loader.img
	cp $< $@
ALIBABA_A210_FLASH_FILES += $(PRODUCT_OUT)/emmc_boot-loader.img

$(PRODUCT_OUT)/emmc-gpt_primary.img: $(BL_PREBUILT)/emmc-gpt_primary.img
	cp $< $@
ALIBABA_A210_FLASH_FILES += $(PRODUCT_OUT)/emmc-gpt_primary.img

# emmc-uboot_env.img (U-Boot environment, flashed to the uboot_env GPT partition)
$(PRODUCT_OUT)/emmc-uboot_env.img: $(BL_PREBUILT)/emmc-uboot_env.img
	cp $< $@
ALIBABA_A210_FLASH_FILES += $(PRODUCT_OUT)/emmc-uboot_env.img

# flash script (bootloader + Android images)
$(PRODUCT_OUT)/flash_android_images.sh: device/alibaba/a210/flash_android_images.sh
	cp $< $@
ALIBABA_A210_FLASH_FILES += $(PRODUCT_OUT)/flash_android_images.sh

droidcore: $(ALIBABA_A210_FLASH_FILES)

endif # TARGET_DEVICE is a210
