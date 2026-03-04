#!/bin/bash
eth1_interface="eno1"
eth2_interface="enp3s0"
default_interface="eth1"
proxy_url="http://soc-ah1.swnet.sw.gov.pl/wpad.dat"

eth1_status=$(nmcli -f GENERAL.STATE device show $eth1_interface | awk '{print $2}')
eth2_status=$(nmcli -f GENERAL.STATE device show $eth2_interface | awk '{print $2}')

enable_proxy() {
    gsettings set org.gnome.system.proxy mode 'auto'
    gsettings set org.gnome.system.proxy autoconfig-url "$proxy_url"
    echo "Proxy włączone: $proxy_url"
}

disable_proxy() {
    gsettings set org.gnome.system.proxy mode 'none'
    echo "Proxy wyłączone."
}

# Jeśli eth1 jest podłączony — przełącz na eth2
if [ "$eth1_status" == "100" ]; then
    echo "Wyłączanie eth1 ($eth1_interface), włączanie eth2..."
    disable_proxy
    nmcli device disconnect $eth1_interface
    nmcli device connect $eth2_interface
    echo "Przełączono na eth2 ($eth2_interface)."

# Jeśli eth2 jest podłączony — przełącz na eth1
elif [ "$eth2_status" == "100" ]; then
    echo "Wyłączanie eth2 ($eth2_interface), włączanie eth1..."
    nmcli device disconnect $eth2_interface
    nmcli device connect $eth1_interface
    enable_proxy
    echo "Przełączono na eth1 ($eth1_interface)."

else
    if [ "$default_interface" == "eth1" ]; then
        nmcli device connect $eth1_interface
        enable_proxy
        echo "Próba połączenia z eth1 ($eth1_interface)."
    else
        nmcli device connect $eth2_interface
        disable_proxy
        echo "Próba połączenia z eth2 ($eth2_interface)."
    fi
fi
