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
    sudo dnsmasq --conf-file=$PWD/dnmasq-utils/dnmasq-lan-rsx217.conf
    sudo dnsmasq --conf-file=$PWD/dnmasq-utils/dnmasq-wan-rsx217.conf
}
#QEMU U1
#run_qemu $1 osv_file_path; $2 qemu_net_script $3 mac_addr $4 bridge
run_qemu(){
    sudo qemu-system-x86_64 \
         -gdb tcp::1234,server,nowait -m 512M -smp 2 \
         -chardev stdio,mux=on,id=stdio -mon chardev=stdio,mode=readline \
         -device isa-serial,chardev=stdio -drive file=$1,if=virtio \
         -net nic,macaddr=$3 -net bridge,br=$4 \
         -device virtio-rng-pci \
         -nographic 
}
#         -netdev tap,id=hn0,script=$2,vhost=on \
#         -device virtio-net-pci,netdev=hn0,id=nic1 \
run_f1(){
    sudo qemu-system-x86_64 \
         -gdb tcp::1234,server,nowait -m 512M -smp 2 \
         -chardev stdio,mux=on,id=stdio -mon chardev=stdio,mode=readline \
         -device isa-serial,chardev=stdio -drive file=$1,if=virtio \
         -net nic,macaddr=$3 -net bridge,br=lan-rsx217,wan-rsx217 \
         -device virtio-rng-pci \
         -nographic 

}
run_osv(){
    ~/osv/scripts/run.py -i $osv_image
}

set_vInterfaces
#sudo ../osv/scripts/run.py --verbose -n -b lan-rsx217 --ip=172.102.0.5 -i osv-images/u1-osv-rsx217/u1-osv-rsx217.qemu
#U1
run_qemu osv-images/u1-osv-rsx217/u1-osv-rsx217.qemu U1/u1-osv-net.sh 2c:4d:11:12:11:11 lan-rsx217 #> ./logs/U1.log)
#U2
run_qemu osv-images/u2-osv-rsx217/u2-osv-rsx217.qemu U2/u2-osv-net.sh 2c:4d:11:12:11:12  lan-rsx217
# # echo U2 UP!
# # # #F1
run_f1 osv-images/F1-osv-rsx217/F1-osv-rsx217.qemu F1/f1-osv-net.sh 2c:4d:11:12:11:11,172.101.0.10
# $(run_qemu osv-images/F1-osv-rsx217/F1-osv-rsx217.qemu F1/f1-osv-net.sh) & #> ./logs/F1.log)
#U3
run_qemu osv-images/u2-osv-rsx217/u2-osv-rsx217.qemu U2/u2-osv-net.sh 2c:4d:11:12:11:03  wan-rsx217
# $(run_qemu osv-images/u3-osv-rsx217/u3-osv-rsx217.qemu U3/u3-osv-net.sh) &

down_vInterfaces


