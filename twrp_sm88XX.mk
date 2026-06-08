#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/zte/sm88XX

# Inherit from device.mk configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

## Device identifier
PRODUCT_DEVICE  := sm88XX
PRODUCT_NAME    := twrp_sm88XX
PRODUCT_BRAND   := zte

# Theme
TW_STATUS_ICONS_ALIGN   := center