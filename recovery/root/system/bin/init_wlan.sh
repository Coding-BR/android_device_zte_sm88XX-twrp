#!/system/bin/sh

MODDIR=/tmp/vendor/lib/modules
SYSDLKM=/system_dlkm/lib/modules
CTRL_DIR=/tmp/recovery/sockets
WPA_CONF=/tmp/recovery/wpa_supplicant.conf
WPA_SUPP=/system/bin/wpa_supplicant_recovery
LD_LIBRARY_PATH=/vendor/lib64:/system/lib64
export LD_LIBRARY_PATH

load_module() {
    [ -f "$1" ] || return 0
    insmod "$1" 2>/dev/null || true
}

/system/bin/twrp mount vendor >/dev/null 2>&1 || true
/system/bin/twrp mount system_dlkm >/dev/null 2>&1 || true

load_module "$SYSDLKM/rfkill.ko"
load_module "$MODDIR/smem-mailbox.ko"
load_module "$MODDIR/cnss_prealloc.ko"
load_module "$MODDIR/wlan_firmware_service.ko"
load_module "$MODDIR/cnss_utils.ko"
load_module "$MODDIR/cnss_nl.ko"
load_module "$MODDIR/cnss_plat_ipc_qmi_svc.ko"
load_module "$MODDIR/qcom_ramdump.ko"
load_module "$MODDIR/qcom_va_minidump.ko"
load_module "$MODDIR/gsim.ko"
load_module "$MODDIR/rmnet_mem.ko"
load_module "$MODDIR/wcd_usbss_i2c.ko"
load_module "$MODDIR/repeater.ko"
load_module "$MODDIR/redriver.ko"
load_module "$MODDIR/dwc3-msm.ko"
load_module "$MODDIR/usb_f_gsi.ko"
load_module "$MODDIR/ipam.ko"
load_module "$MODDIR/cfg80211.ko"
load_module "$MODDIR/mhi.ko"
load_module "$MODDIR/pcie-pdc.ko"
load_module "$MODDIR/pci-msm-drv.ko"
load_module "$MODDIR/cnss2.ko"
load_module "$MODDIR/qca_cld3_peach_v2.ko"

if ! pidof cnss-daemon >/dev/null 2>&1; then
    /vendor/bin/cnss-daemon >/dev/null 2>&1 &
fi

sleep 1
[ -e /sys/kernel/cnss/fs_ready ] && echo 1 > /sys/kernel/cnss/fs_ready 2>/dev/null || true

for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24; do
    if ifconfig wlan0 >/dev/null 2>&1; then
        ifconfig wlan0 up >/dev/null 2>&1 || true
        if ifconfig wlan0 2>/dev/null | grep -q "UP"; then
            break
        fi
    fi
    sleep 1
done

mkdir -p /tmp/recovery "$CTRL_DIR"
chmod 0775 /tmp/recovery
chmod 0777 "$CTRL_DIR"

if [ ! -s "$WPA_CONF" ]; then
    cat > "$WPA_CONF" <<EOF
ctrl_interface=$CTRL_DIR
update_config=1
ap_scan=1
EOF
fi
chmod 0644 "$WPA_CONF"

if ! pidof wpa_supplicant_recovery >/dev/null 2>&1 && [ -x "$WPA_SUPP" ]; then
    exec "$WPA_SUPP" -iwlan0 -Dnl80211 -c"$WPA_CONF" -O"$CTRL_DIR"
fi
