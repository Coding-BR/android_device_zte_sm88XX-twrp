#!/system/bin/sh

[ "$1" = "bound" ] || [ "$1" = "renew" ] || exit 0
[ -n "$interface" ] || interface=wlan0
BUSYBOX=

for candidate in /data/adb/ksu/bin/busybox /data/local/Droidspaces/bin/busybox /system/bin/busybox; do
    if [ -x "$candidate" ]; then
        BUSYBOX="$candidate"
        break
    fi
done

if [ -w /proc/sys/net/ipv4/ping_group_range ]; then
    echo "0 2147483647" > /proc/sys/net/ipv4/ping_group_range
fi

if [ -n "$ip" ]; then
    if [ -n "$subnet" ]; then
        ifconfig "$interface" "$ip" netmask "$subnet" up
    else
        ifconfig "$interface" "$ip" up
    fi
fi

GATEWAY="${router:-$gateway}"
if [ -n "$GATEWAY" ] && [ -n "$BUSYBOX" ]; then
    "$BUSYBOX" route del default dev "$interface" >/dev/null 2>&1 || true
    "$BUSYBOX" route add default gw "$GATEWAY" dev "$interface" >/dev/null 2>&1 || true
fi

if [ -n "$dns" ]; then
    : > /etc/resolv.conf
    for server in $dns; do
        echo "nameserver $server" >> /etc/resolv.conf
    done
fi
