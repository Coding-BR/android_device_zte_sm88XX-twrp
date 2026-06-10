#
# Copyright (C) 2025 The Android Open Source Project
# Copyright (C) 2025 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2024 The OrangeFox Recovery Project
# SPDX-License-Identifier: GPL-3.0-or-later
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/twrp_sm88XX.mk

COMMON_LUNCH_CHOICES := \
    twrp_sm88XX-eng \
    twrp_sm88XX-userdebug \
    twrp_sm88XX-aosp_current-eng \
    twrp_sm88XX-aosp_current-userdebug
