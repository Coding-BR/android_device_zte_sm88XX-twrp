#!/system/bin/sh

# Give the kernel 2 seconds to fully populate /dev/input after modules are loaded
sleep 2

deleted=0

for dev in /sys/class/input/input*; do
    if [ ! -e "$dev/name" ]; then continue; fi
    name=$(cat "$dev/name")
    
    if [ "$name" = "goodix_fp" ] || [ "$name" = "nubia_tgk_aw_sar0_ch0" ] || [ "$name" = "nubia_tgk_aw_sar1_ch0" ]; then
        
        # 1. Unbind the driver from the kernel
        dev_path=$(readlink -f "$dev/device")
        if [ -n "$dev_path" ] && [ -e "$dev_path/driver/unbind" ]; then
            dev_name=${dev_path##*/}
            echo "$dev_name" > "$dev_path/driver/unbind"
            deleted=1
        fi
        
        # 2. Delete the event node
        event_name=$(ls "$dev/" | grep event)
        if [ -n "$event_name" ] && [ -e "/dev/input/$event_name" ]; then
            rm -f "/dev/input/$event_name"
            deleted=1
        fi
    fi
done

# Architectural bypass:
# If we successfully removed the garbage inputs, we kill the recovery process.
# Android init will instantly respawn it, but this time in a clean environment.
if [ "$deleted" -eq 1 ]; then
    killall recovery
fi