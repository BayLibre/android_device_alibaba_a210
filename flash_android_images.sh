#!/bin/sh
# Flash bootloader + Android images onto a Zhihe A210 board over fastboot.
#
# Same bootloader staging plus the Android boot chain 
# (boot/init_boot/vendor_boot, both A/B slots), vbmeta
# (+ chained vbmeta_vendor_dlkm/vbmeta_system_dlkm), and super
# (system/vendor/vendor_dlkm/system_dlkm).

FAIL="###### Images flashing failed ######"

if [ -n "$1" ]; then
    device="-s $1"
fi

if fastboot ${device} getvar product 2>&1 | grep -q "product: a2"; then
    echo "###### Start flash images ######"
else
    echo "###### Start the flashing tool"
    if [ -e bootzero-rvbl.bin ]; then
        fastboot ${device} flash ram bootzero-rvbl.bin || { echo $FAIL; exit 1; }
        fastboot ${device} reboot
        fastboot ${device} flash ram spl-with-fit-rvbl.bin || { echo $FAIL; exit 1; }
        fastboot ${device} reboot
    else
        fastboot ${device} flash ram spl-with-fit-rvbl.bin || { echo $FAIL; exit 1; }
        fastboot ${device} reboot
    fi
    echo "###### Wait for the flashing tool to be ready"
    sleep 5
fi

echo "###### Flash gpt"
fastboot ${device} flash gpt emmc-gpt_primary.img || { echo $FAIL; exit 1; }
echo "###### Flash loader"
fastboot ${device} flash mmc0boot0 emmc_boot-loader.img || { echo $FAIL; exit 1; }
echo "###### Flash partition uboot_env"
fastboot ${device} flash uboot_env emmc-uboot_env.img || { echo $FAIL; exit 1; }

echo "###### Flash boot (both slots)"
fastboot ${device} flash boot_a boot.img || { echo $FAIL; exit 1; }
fastboot ${device} flash boot_b boot.img || { echo $FAIL; exit 1; }
echo "###### Flash init_boot (both slots)"
fastboot ${device} flash init_boot_a init_boot.img || { echo $FAIL; exit 1; }
fastboot ${device} flash init_boot_b init_boot.img || { echo $FAIL; exit 1; }
echo "###### Flash vendor_boot (both slots)"
fastboot ${device} flash vendor_boot_a vendor_boot.img || { echo $FAIL; exit 1; }
fastboot ${device} flash vendor_boot_b vendor_boot.img || { echo $FAIL; exit 1; }
echo "###### Flash vbmeta (both slots)"
fastboot ${device} flash vbmeta_a vbmeta.img || { echo $FAIL; exit 1; }
fastboot ${device} flash vbmeta_b vbmeta.img || { echo $FAIL; exit 1; }
echo "###### Flash vbmeta_vendor_dlkm (both slots)"
fastboot ${device} flash vbmeta_vendor_dlkm_a vbmeta_vendor_dlkm.img || { echo $FAIL; exit 1; }
fastboot ${device} flash vbmeta_vendor_dlkm_b vbmeta_vendor_dlkm.img || { echo $FAIL; exit 1; }
echo "###### Flash vbmeta_system_dlkm (both slots)"
fastboot ${device} flash vbmeta_system_dlkm_a vbmeta_system_dlkm.img || { echo $FAIL; exit 1; }
fastboot ${device} flash vbmeta_system_dlkm_b vbmeta_system_dlkm.img || { echo $FAIL; exit 1; }
echo "###### Flash super"
fastboot ${device} flash super super.img || { echo $FAIL; exit 1; }

echo "###### Erase misc, select slot a"
fastboot ${device} erase misc || { echo $FAIL; exit 1; }
fastboot ${device} set_active a

echo "###### Images flashed success ######"
