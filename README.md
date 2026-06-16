# TWRP device tree for ZTE SM88XX / NX809J

## Supported devices

- REDMAGIC 11 Pro / NX809J
- ZTE Z80 Ultra

## Build

```shell
mkdir twrp && cd twrp
repo init --depth=1 -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git -b twrp-16.0
repo sync
git clone --depth=1 https://github.com/Coding-BR/android_device_zte_sm88XX-twrp device/zte/sm88XX
```

```shell
source build/envsetup.sh
lunch twrp_sm88XX-aosp_current-eng
m recoveryimage
```

If there is no error, `recovery.img` will be generated at:

```text
out/target/product/sm88XX/recovery.img
```

## Features

Works:

- [X] ADB
- [X] Display
- [X] Decryption
- [X] Fastbootd
- [X] Flashing
- [X] Haptic feedback / vibration
- [X] MTP
- [X] ADB sideload mode
- [X] Touchscreen
- [X] USB OTG
- [X] Wi-Fi
- [X] WPA2-PSK connection
- [X] DHCP / DNS / internet access from TWRP

Needs more testing:

- [ ] Full sideload ZIP installation flow

## Install

Using a userdebug ABL can make installation easier because it enables fastboot access.

To enable fastboot with ZTE Toolbox:

1. Open ZTE Toolbox.
2. Select option `12`.
3. Enter the target ABL partition name: `abl_a` or `abl_b`.
4. Flash the userdebug ABL.
5. Boot into fastboot.

You can also flash the recovery image directly with ZTE Toolbox:

1. Select option `12`.
2. Enter the target recovery partition name: `recovery_a` or `recovery_b`.
3. Repeat the same step for the other recovery slot if you want to flash both `recovery_a` and `recovery_b`.

Manual fastboot commands:

```shell
fastboot flash recovery recovery.img
```

or flash both recovery slots:

```shell
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
```

On the tested NX809J unit, flashing the active recovery slot was enough. No extra vbmeta disable step was required for the tested TWRP recovery image.

## Notes

- Touchscreen was tested on REDMAGIC 11 Pro / NX809J.
- Touch coordinate mapping is fixed for the `synaptics_tcm_touch` panel.
- The touch debug pointer trail is disabled.
- Fastbootd was tested successfully.
- Wi-Fi scanning, WPA2 connection, DHCP, DNS, and network access were tested in TWRP.
- Haptic feedback was tested through the AWINIC driver using the `zte_vibrator` `duration_aw` / `activate_aw` path.
- ADB sideload mode was fixed and tested. The host now detects the device as `sideload` after starting sideload from TWRP.
- Full ZIP sideload installation still needs a harmless test package before marking the complete install flow as fully verified.
- It is not possible to fix the device fingerprint using TWRP.
