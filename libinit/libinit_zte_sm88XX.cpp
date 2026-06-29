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
#include <vector>

using android::base::GetProperty;

struct ModelInfo {
    const char* brand;              // ro.product.brand
    const char* device;             // ro.product.device
    const char* manufacturer;       // ro.product.manufacturer
    const char* model;              // ro.product.model
    const char* twversion;          // ro.twrp.device_version
};

// ZTE SM88XX platform device variants
const std::unordered_map<std::string, ModelInfo> kModelInfoMap = {
    {"NX741J",  {"ZTE",   "Z80_Ultra",       "ZTE",   "Z80 Ultra",       "ZTE-Z80-Ultra"}},
    {"NX809J",  {"nubia", "RedMagic_11_Pro", "nubia", "RedMagic 11 Pro", "RedMagic-11-Pro"}},
    {"DEFAULT", {"ZTE",   "SM88XX",          "ZTE",   "SM88XX",          "ZTE-SM88XX"}},
};

/*
 * Directly overwrite read-only properties in recovery property space.
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

// Try to extract a known model name from a property value.
std::string ExtractModelFromString(const std::string& value) {
    if (value.empty()) return "";

    for (const auto& entry : kModelInfoMap) {
        const std::string& model = entry.first;
        if (model == "DEFAULT") continue;
        if (value.find(model) != std::string::npos) {
            return model;
        }
    }
    return "";
}

// Detect the actual device model from various boot properties.
std::string DetectModel() {
    // 1. ro.boot.hardware.revision often contains the model (e.g. "NX809JHW1.0")
    std::string revision = GetProperty("ro.boot.hardware.revision", "");
    std::string model = ExtractModelFromString(revision);
    if (!model.empty()) return model;

    // 2. ro.product.bootimage.name / model directly identify the device
    model = ExtractModelFromString(GetProperty("ro.product.bootimage.name", ""));
    if (!model.empty()) return model;
    model = ExtractModelFromString(GetProperty("ro.product.bootimage.model", ""));
    if (!model.empty()) return model;

    // 3. bootimage build fingerprint contains the model
    model = ExtractModelFromString(GetProperty("ro.bootimage.build.fingerprint", ""));
    if (!model.empty()) return model;

    // 4. Traditional SKU properties used on some ZTE/Nubia devices
    std::vector<std::string> sku_props = {
        "ro.boot.hardware.sku",
        "ro.boot.product.hardware.sku",
        "ro.boot.product.vendor.sku",
        "ro.boot.project_name",
        "ro.boot.board_id",
        "ro.boot.product.name",
        "ro.boot.product.model",
    };
    for (const auto& prop : sku_props) {
        std::string value = GetProperty(prop, "");
        model = ExtractModelFromString(value);
        if (!model.empty()) return model;
        // Some SKU properties directly equal the model (e.g. ro.boot.hardware.sku=NX809J)
        if (kModelInfoMap.count(value)) return value;
    }

    return "";
}

void vendor_load_properties() {
    std::string model = DetectModel();
    if (model.empty()) {
        LOG(WARNING) << "Could not detect ZTE/Nubia SM88XX model; falling back to default profile";
        model = "DEFAULT";
    } else {
        LOG(INFO) << "Detected ZTE/Nubia SM88XX model: " << model;
    }

    auto model_info = kModelInfoMap.find(model);
    if (model_info == kModelInfoMap.end()) {
        LOG(ERROR) << "Unknown ZTE/Nubia SKU: '" << model << "', falling back to default SM88XX profile";
        model_info = kModelInfoMap.find("DEFAULT");
    }

    SetupModelProperties(model_info->second);
}
