#!/system/bin/sh

[ "$1" = "bound" ] || [ "$1" = "renew" ] || exit 0
[ -n "$interface" ] || interface=wlan0

if [ -n "$ip" ]; then
    if [ -n "$subnet" ]; then
        ifconfig "$interface" "$ip" netmask "$subnet" up
    else
        ifconfig "$interface" "$ip" up
    fi
fi

if [ -n "$dns" ]; then
    : > /etc/resolv.conf
    for server in $dns; do
        echo "nameserver $server" >> /etc/resolv.conf
    done
fi
