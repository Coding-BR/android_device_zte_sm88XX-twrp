/*
 * Copyright (C) 2022-2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/logging.h>
#include <android-base/properties.h>
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include <unordered_map>
#include <string>

using android::base::GetProperty;

struct ModelInfo {
    const char* brand;              // ro.product.brand
    const char* device;             // ro.product.device
    const char* manufacturer;       // ro.product.manufacturer
    const char* model;              // ro.product.model
    const char* twversion;          // ro.twrp.device_version
};

// Маппинг устройств на основе реальных SKU плат ZTE / Nubia
const std::unordered_map<std::string, ModelInfo> kModelInfoMap = {
    {"NX741J",  {"ZTE",   "Z80_Ultra",       "ZTE",   "Z80 Ultra",       "ZTE-Z80-Ultra"}},
    {"NX809J",  {"nubia", "RedMagic_11_Pro", "nubia", "RedMagic 11 Pro", "RedMagic-11-Pro"}},
    {"DEFAULT", {"ZTE",   "SM88XX",          "ZTE",   "SM88XX",          "ZTE-SM88XX"}},
};

/*
 * Функция для прямой перезаписи read-only свойств в пространстве recovery.
 */
void OverrideProperty(const char* name, const char* value) {
    size_t valuelen = strlen(value);

    prop_info* pi = (prop_info*)__system_property_find(name);
    if (pi != nullptr) {
        __system_property_update(pi, value, valuelen);
    } else {
        __system_property_add(name, strlen(name), value, valuelen);
    }
}

void SetupModelProperties(const ModelInfo& info) {
    struct PropPair {
        const char* key;
        const char* value;
    } props[] = {
        {"ro.product.brand",                info.brand},
        {"ro.product.device",               info.device},
        {"ro.product.manufacturer",         info.manufacturer},
        {"ro.product.model",                info.model},
        {"ro.product.name",                 info.model},
        {"ro.product.system.device",        info.device},
        {"ro.product.system.model",         info.model},
        {"ro.product.product.device",       info.device},
        {"ro.product.product.model",        info.model},
        {"ro.product.system_ext.device",    info.device},
        {"ro.product.system_ext.model",     info.model},
        {"ro.product.vendor.device",        info.device},
        {"ro.product.vendor.model",         info.model},
        {"ro.product.odm.device",           info.device},
        {"ro.product.odm.model",            info.model},
        {"ro.twrp.device_version",          info.twversion},
        {"ro.build.date.utc",               "0"},
    };

    for (const auto& p : props) {
        OverrideProperty(p.key, p.value);
    }
}

void vendor_load_properties() {
    std::string sku = GetProperty("ro.boot.hardware.sku", "");
    if (sku.empty()) {
        sku = GetProperty("ro.boot.project_name", "");
    }
    if (sku.empty()) {
        sku = GetProperty("ro.boot.board_id", "");
    }
    if (sku.empty()) {
        sku = "DEFAULT";
    }

    auto model_info = kModelInfoMap.find(sku);
    if (model_info == kModelInfoMap.end()) {
        LOG(ERROR) << "Unknown ZTE/Nubia SKU: '" << sku << "', falling back to default SM88XX profile";
        model_info = kModelInfoMap.find("DEFAULT");
    }

    SetupModelProperties(model_info->second);
}