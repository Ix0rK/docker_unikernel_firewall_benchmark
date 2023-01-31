#!/bin/bash
#!/bin/sh

set_vInterfaces(){
    #lan-rsx217
    sudo brctl addbr br-lan-rsx217
    sudo ip link add name eth-lan-rsx217 type dummy
    sudo ip addr add 172.102.0.1/24 broadcast 172.102.0.255 dev eth-lan-rsx217 
    sudo brctl addif br-lan-rsx217 eth-lan-rsx217
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
    sudo ip link add name eth-wan-rsx217 type dummy
    sudo brctl addif br-wan-rsx217 eth-wan-rsx217
    sudo ip addr add 172.101.0.1/24 broadcast 172.101.0.255 dev eth-wan-rsx217
    
    #brctl addif br-wan-rsx217 eth-wan-rsx217
    #F1 wan
    sudo ip tuntap add dev tap_F1_wan mode tap
    sudo brctl addif br-wan-rsx217 tap_F1_wan
    #U3 wan
    sudo ip tuntap add dev tap_U3_wan mode tap
    sudo brctl addif br-wan-rsx217 tap_U3_wan

    # UP!
    sudo ifconfig eth-lan-rsx217 up
    # sudo ifconfig br-lan-rsx217 up
    sudo ifconfig eth-wan-rsx217 up
    # sudo ifconfig br-wan-rsx217 up
    sudo ifconfig tap_F1_lan up
    sudo ifconfig tap_U1_lan up
    sudo ifconfig tap_U2_lan up
    sudo ifconfig tap_F1_wan up
    sudo ifconfig tap_U3_wan up

    # dnsmasq for dhcp static ip on mac adress
    sudo dnsmasq --conf-file=$PWD/dnsmasq-utils/dnsmasq-lan-rsx217.conf
    sudo dnsmasq --conf-file=$PWD/dnsmasq-utils/dnsmasq-wan-rsx217.conf
}

down_vInterfaces(){
    sudo ifconfig br-lan-rsx217 down
    sudo ifconfig eth-lan-rsx217 down
    sudo ifconfig br-wan-rsx217 down
    sudo ifconfig eth-wan-rsx217 down
    sudo ifconfig tap_F1_lan down
    sudo ifconfig tap_U1_lan down
    sudo ifconfig tap_U2_lan down
    sudo ifconfig tap_F1_wan down
    sudo ifconfig tap_U3_wan down
    sudo ip addr delete 172.102.0.1/24 dev eth-lan-rsx217
    sudo ip addr delete 172.101.0.1/24 dev eth-wan-rsx217
    sudo ip tuntap del dev tap_F1_lan mode tap
    sudo ip tuntap del dev tap_U1_lan mode tap
    sudo ip tuntap del dev tap_U2_lan mode tap
    sudo ip tuntap del dev tap_F1_wan mode tap
    sudo ip tuntap del dev tap_U3_wan mode tap
    sudo brctl delbr br-lan-rsx217
    sudo brctl delbr br-wan-rsx217
    sudo killall dnsmasq
}
#QEMU U1
#run_qemu $1 osv_file_path $2 tap_device $3 mac_addr
run_qemu(){
    sudo qemu-system-x86_64 \
         -chardev stdio,mux=on,id=stdio -mon chardev=stdio,mode=readline \
         -device isa-serial,chardev=stdio -drive file=$1,if=virtio \
         -netdev tap,id=mynet0,ifname=$2,script=no,downscript=no \
         -device e1000,netdev=mynet0,mac=$3 \
         -device virtio-rng-pci \
         -nographic
}
         #-virtfs local,path=$PWD/logs,mount_tag=logs,security_model=passthrough,id=logs \
#         -netdev tap,id=hn0,script=$2,vhost=on \
#         -device virtio-net-pci,netdev=hn0,id=nic1 \
#run_f1 $1 osv_file_path $2 tap_device $3 mac_addr $4 tap_device2 
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
         #-virtfs local,path=$PWD/logs,mount_tag=logs,security_model=passthrough,id=logs \
run_osv(){
    ~/osv/scripts/run.py -i $osv_image
}

set_vInterfaces
# #sudo ../osv/scripts/run.py --verbose -n -b lan-rsx217 --ip=172.102.0.5 -i osv-images/u1-osv-rsx217/u1-osv-rsx217.qemu
# # #U1
# $(run_qemu osv-images/u1-osv-rsx217/u1-osv-rsx217.qemu tap_U1_lan 2c:4d:11:12:11:01) &
# # echo U1 UP!
# # #U2
# $(run_qemu osv-images/u2-osv-rsx217/u2-osv-rsx217.qemu tap_U2_lan 2c:4d:11:12:11:02) &
# # echo U2 UP!
# # #F1
# $(run_f1 osv-images/f1-osv-rsx217/f1-osv-rsx217.qemu tap_F1_lan 2c:4d:11:12:11:10 tap_F1_wan) &
# # echo F1 UP!
# #U3
# sleep 5
# run_qemu osv-images/u3-osv-rsx217/u3-osv-rsx217.qemu tap_U3_wan 2c:4d:11:12:11:03
down_vInterfaces


