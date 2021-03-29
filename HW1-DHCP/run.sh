#!/bin/bash
cd "`dirname $0`"

echo "  * Reload iptables"
iptables-restore < iptables-rules

echo "  * Flush connection state"
conntrack -F

echo "  * Shutdown Network"
wg-quick down na

echo "  * Start Network"
ifconfig enp0s8 down
ifconfig enp0s3 down
netplan apply

echo "  * Start WireGuard"
wg-quick up na

echo "  * WireGuard Status"
wg

echo "  * Restart DHCP Server"
service isc-dhcp-server restart
