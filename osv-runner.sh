#!/bin/bash
set_vDevices(){
    #lan-rsx217
    sudo brctl addbr br-lan-rsx217
    sudo ip addr add 172.102.0.1/24 broadcast 172.102.0.255 dev br-lan-rsx217 
    # F1 lan
    sudo ip tuntap add dev tap_F1_lan mode tap
    sudo brctl addif br-lan-rsx217 tap_F1_lan
    # U1 lan
    sudo ip tuntap add dev tap_U1_lan mode tap
    sudo brctl addif br-lan-rsx217 tap_U1_lan
    # U2 lan
    sudo ip tuntap add dev tap_U2_lan mode tap
    sudo brctl addif br-lan-rsx217 tap_U2_lan

    #wan-rsx217
    sudo brctl addbr br-wan-rsx217
    sudo ip addr add 172.101.0.1/24 broadcast 172.101.0.255 dev br-wan-rsx217
    #F1 on wan
    sudo ip tuntap add dev tap_F1_wan mode tap
    sudo brctl addif br-wan-rsx217 tap_F1_wan
    #U3 on wan
    sudo ip tuntap add dev tap_U3_wan mode tap
    sudo brctl addif br-wan-rsx217 tap_U3_wan

    # dnsmasq for dhcp static ip on mac adress
    sudo dnsmasq --conf-file=$PWD/dnsmasq-utils/dnsmasq-lan-rsx217.conf
    sudo dnsmasq --conf-file=$PWD/dnsmasq-utils/dnsmasq-wan-rsx217.conf

    # Up devices
    sudo ifconfig br-lan-rsx217 up
    sudo ifconfig br-wan-rsx217 up
    sudo ifconfig tap_F1_lan up
    sudo ifconfig tap_U1_lan up
    sudo ifconfig tap_U2_lan up
    sudo ifconfig tap_F1_wan up
    sudo ifconfig tap_U3_wan up
    echo "END set Interfaces"
}

down_vDevices(){
    sudo ifconfig br-lan-rsx217 down
    sudo ifconfig br-wan-rsx217 down
    sudo ifconfig tap_F1_lan down
    sudo ifconfig tap_U1_lan down
    sudo ifconfig tap_U2_lan down
    sudo ifconfig tap_F1_wan down
    sudo ifconfig tap_U3_wan down
    sudo ip addr delete 172.102.0.1/24 dev br-lan-rsx217
    sudo ip addr delete 172.101.0.1/24 dev br-wan-rsx217
    sudo ip tuntap del dev tap_F1_lan mode tap
    sudo ip tuntap del dev tap_U1_lan mode tap
    sudo ip tuntap del dev tap_U2_lan mode tap
    sudo ip tuntap del dev tap_F1_wan mode tap
    sudo ip tuntap del dev tap_U3_wan mode tap
    sudo brctl delbr br-lan-rsx217
    sudo brctl delbr br-wan-rsx217
    sudo killall dnsmasq
    sudo killall qemu-system-x86_64
}
run_qemu(){
    sudo qemu-system-x86_64 \
         -chardev stdio,mux=on,id=stdio -mon chardev=stdio,mode=readline \
         -device isa-serial,chardev=stdio -drive file=$1,if=virtio \
         -netdev tap,id=mynet0,ifname=$2,script=no,downscript=no \
         -device e1000,netdev=mynet0,mac=$3 \
         -device virtio-rng-pci \
         -nographic
}
run_f1(){
    sudo qemu-system-x86_64 \
         -chardev stdio,mux=on,id=stdio -mon chardev=stdio,mode=readline \
         -device isa-serial,chardev=stdio -drive file=$1,if=virtio \
         -netdev tap,id=mynet0,ifname=$2,script=no,downscript=no \
         -device e1000,netdev=mynet0,mac=$3 \
         -netdev tap,id=mynet1,ifname=$4,script=no,downscript=no \
         -device e1000,netdev=mynet1,mac=$3 \
         -device virtio-rng-pci \
         -nographic

}
set_vDevices
#U1
$(run_qemu osv-images/u1-osv-rsx217/u1-osv-rsx217.qemu tap_U1_lan 2c:4d:11:12:11:01) &
#U2
$(run_qemu osv-images/u2-osv-rsx217/u2-osv-rsx217.qemu tap_U2_lan 2c:4d:11:12:11:02) &
#F1
$(run_f1 osv-images/f1-osv-rsx217/f1-osv-rsx217.qemu tap_F1_lan 2c:4d:11:12:11:10 tap_F1_wan) &
#U3
run_qemu osv-images/u3-osv-rsx217/u3-osv-rsx217.qemu tap_U3_wan 2c:4d:11:12:11:03
down_vDevices


