# TWRP device tree for ZTE SM88XX

## Supported devices
- RedMagic 11 pro
- ZTE Z80 Ultra
## Build it yourself?

```shell
mkdir twrp && cd twrp
repo init --depth=1 -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git -b twrp-16.0
repo sync
git clone --depth=1 https://github.com/KSN2redawew/android_device_zte_sm88XX-twrp device/zte/sm88XX
```

```shell
source build/envsetup.sh
lunch twrp_/sm88XX
m recoveryimage
```

If there is no error, recovery.img will be found in `out/target/product//sm88XX/recovery.img`

## Features

Works:

- [X] ADB
- [X] Display
- [X] Decryption
- Fasbootd (no work)
- [X] Flashing
- [X] MTP
- Sideload (?)
- [X] USB OTG
- [X] Touchscreen

## To use it:

```shell
fastboot flash recovery recovery.img
```

or

```shell
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
```

## Notes

- Touchscreen was tested on REDMAGIC 11 Pro / NX809J. The working build fixes the `synaptics_tcm_touch` coordinate mapping used by this panel.
