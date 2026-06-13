#!/system/bin/sh

MODDIR=/tmp/vendor/lib/modules
SYSDLKM=/system_dlkm/lib/modules
CTRL_DIR=/tmp/recovery/sockets
WPA_CONF=/tmp/recovery/wpa_supplicant.conf

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

for _ in 1 2 3 4 5 6 7 8 9 10 11 12; do
    if ifconfig wlan0 >/dev/null 2>&1; then
        ifconfig wlan0 up >/dev/null 2>&1 || true
        break
    fi
    sleep 1
done

mkdir -p "$CTRL_DIR"
chmod 0770 "$CTRL_DIR"

cat > "$WPA_CONF" <<EOF
ctrl_interface=$CTRL_DIR
update_config=1
ap_scan=1
EOF
chmod 0600 "$WPA_CONF"

if ! pidof wpa_supplicant >/dev/null 2>&1; then
    wpa_supplicant -B -iwlan0 -Dnl80211 -c"$WPA_CONF" -O"$CTRL_DIR" >/tmp/recovery/wpa_supplicant.log 2>&1 || true
fi
