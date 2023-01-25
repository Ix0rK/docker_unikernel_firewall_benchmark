#!/bin/bash
#!/bin/sh
nested_script(){
    OSV_BRIDGE=virbr0
    brctl addif \$OSV_BRIDGE \$1
    brctl stp \$OSV_BRIDGE off
    ifconfig \$1 up
    EOF
}
#QEMU U1
sudo qemu-system-x86_64 -runas -D /tmp/qemu-debug-log  -vnc :1 -gdb tcp::1234,server,nowait -m 512M -smp 2 \
  -chardev stdio,mux=on,id=stdio -mon chardev=stdio,mode=readline \
  -device isa-serial,chardev=stdio -drive file=./osv-images/u1-osv-rsx217/u1-osv-rsx217.qemu,if=virtio,cache=unsafe \
  -netdev tap,id=hn0,script=./test_osv_bridge.sh,vhost=on -device virtio-net-pci,netdev=hn0,id=nic1 \
  -device virtio-rng-pci -cpu host,+x2apic

