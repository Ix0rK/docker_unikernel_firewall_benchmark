#!/bin/bash
#!/bin/sh

set_vInterfaces(){
    sudo brctl addbr lan-rsx217
    sudo brctl addbr wan-rsx217
    sudo ip addr add 172.102.0.1/24 broadcast 172.102.0.255 dev lan-rsx217
    sudo ip addr add 172.101.0.1/24 broadcast 172.101.0.255 dev wan-rsx217
    sudo ifconfig lan-rsx217 up
    sudo ifconfig wan-rsx217 up
}

down_vInterfaces(){
    sudo ifconfig lan-rsx217 down
    sudo ifconfig wan-rsx217 down
    sudo ip addr delete 172.102.0.1/24 dev lan-rsx217
    sudo ip addr delete 172.101.0.1/24 dev wan-rsx217
    sudo brctl delbr lan-rsx217
    sudo brctl delbr wan-rsx217 
}
U1_net_script(){
    ip address add 172.102.0.5/32 dev lan-rsx217
}
U2_net_script(){
    ip address add 172.102.0.6/32 dev lan-rsx217
}
U3_net_script(){
    ip address add 172.101.0.12/32 dev wan-rsx217
}
F1_net_script(){
    ip address add 172.101.0.10/32 dev wan-rsx217
    ip address add 172.102.0.10/32 dev lan-rsx217
}

#QEMU U1
#run_qemu $1 osv_file_path; $2 qemu_net_script
run_qemu(){
    sudo qemu-system-x86_64 \
         -gdb tcp::1234,server,nowait -m 512M -smp 2 \
         -chardev stdio,mux=on,id=stdio -mon chardev=stdio,mode=readline \
         -device isa-serial,chardev=stdio -drive file=$1,if=virtio \
         -netdev tap,id=hn0,script=$2,vhost=on -device virtio-net-pci,netdev=hn0,id=nic1 \
         -device virtio-rng-pci \
         -nographic 
}

set_vInterfaces
#U1
run_qemu osv-images/u1-osv-rsx217/u1-osv-rsx217.qemu U1/u1-osv-net.sh #&> ./logs/U1.log)
# #U2
# $(run_qemu osv-images/u2-osv-rsx217/u2-osv-rsx217.qemu U2_net_script &> ./logs/U2.log)
# #F1
# $(run_qemu osv-images/F1-osv-rsx217/F1-osv-rsx217.qemu F1_net_script &> ./logs/F1.log)
# #U3
# sleep 3
# run_qemu osv-images/u1-osv-rsx217/u3-osv-rsx217.qemu U3_net_script &> ./logs/U3.log





down_vInterfaces
# As indicated in the user-mode networking section, tap devices offer higher networking performance than user-mode. If the guest OS supports virtio network driver, then the networking performance will be increased considerably as well. Supposing the use of the tap0 device, that the virtio driver is used on the guest, and that no scripts are used to help start/stop networking, next is part of the qemu command one should see:

# -device virtio-net,netdev=network0 -netdev tap,id=network0,ifname=tap0,script=no,downscript=no

# But if already using a tap device with virtio networking driver, one can even boost the networking performance by enabling vhost, like:

# -device virtio-net,netdev=network0 -netdev tap,id=network0,ifname=tap0,script=no,downscript=no,vhost=on


