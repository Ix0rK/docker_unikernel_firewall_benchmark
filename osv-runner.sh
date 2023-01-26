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
$(run_qemu osv-images/u1-osv-rsx217/u1-osv-rsx217.qemu U1/u1-osv-net.sh) & #> ./logs/U1.log)
echo U1 UP!
# #U2
$(run_qemu osv-images/u2-osv-rsx217/u2-osv-rsx217.qemu U2/u2-osv-net.sh) & #> ./logs/U2.log)
echo U2 UP!
# #F1
$(run_qemu osv-images/F1-osv-rsx217/F1-osv-rsx217.qemu F1/f1-osv-net.sh) & #> ./logs/F1.log)
echo F1 UP!
echo RUN U3 !
# #U3
$(run_qemu osv-images/u3-osv-rsx217/u3-osv-rsx217.qemu U3/u3-osv-net.sh) &

down_vInterfaces


