#!/bin/sh
case $1 in 
winxp)
    qemu-system-x86_64 -m 512 -soundhw ac97 -vga vmware \
    -drive file=/home/gfrog/vms/winxp-priv.vdi,cache=writeback \
    -vnc 127.0.0.1:0    \
    -net nic,vlan=3,macaddr=08:00:11:11:03:25,name=vn3,model=rtl8139 \
    -net tap,vlan=3,ifname=tap35,script=no,downscript=no    \
    -net nic,vlan=4,macaddr=08:00:11:11:04:25,name=vn4,model=rtl8139 \
    -net tap,vlan=4,ifname=tap45,script=no,downscript=no
    ;;
ubuntu)
    qemu-system-x86_64 -m 512 -soundhw ac97 -usb \
    -drive file=/home/gfrog/vms/ubuntu.vdi,cache=writeback \
    -net nic,vlan=4,model=e1000 -net tap,vlan=4,ifname=tap46,script=no,downscript=no
    ;;
debian1)
    qemu-system-x86_64 -m 64 -usb -nographic \
    -drive file=/home/gfrog/vms/debian1.vdi,cache=writeback \
    -net nic,vlan=1,macaddr=08:00:11:11:01:27,name=vn1,model=e1000 \
    -net tap,vlan=1,ifname=tap17,script=no,downscript=no \
    -net nic,vlan=2,macaddr=08:00:11:11:02:27,name=vn2,model=e1000 \
    -net tap,vlan=2,ifname=tap27,script=no,downscript=no \
    -net nic,vlan=3,macaddr=08:00:11:11:03:27,name=vn3,model=e1000 \
    -net tap,vlan=3,ifname=tap37,script=no,downscript=no \
    -net nic,vlan=4,macaddr=08:00:11:11:04:27,name=vn4,model=e1000 \
    -net tap,vlan=4,ifname=tap47,script=no,downscript=no
    ;;
debian2)
    qemu-system-x86_64 -m 64 -usb -nographic \
    -drive file=/home/gfrog/vms/debian2.vdi,cache=writeback \
    -net nic,vlan=1,macaddr=08:00:11:11:01:28,name=vn1,model=e1000 \
    -net tap,vlan=1,ifname=tap18,script=no,downscript=no \
    -net nic,vlan=2,macaddr=08:00:11:11:02:28,name=vn2,model=e1000 \
    -net tap,vlan=2,ifname=tap28,script=no,downscript=no \
    -net nic,vlan=3,macaddr=08:00:11:11:03:28,name=vn3,model=e1000 \
    -net tap,vlan=3,ifname=tap38,script=no,downscript=no \
    -net nic,vlan=4,macaddr=08:00:11:11:04:28,name=vn4,model=e1000 \
    -net tap,vlan=4,ifname=tap48,script=no,downscript=no
    ;;
freebsd)
    #qemu-system-x86_64 -m 64 -usb -nographic \
    qemu-system-x86_64 -m 256 -usb \
    -drive file=/home/gfrog/vms/freebsd.vdi,cache=writeback \
    -net nic,vlan=1,macaddr=08:00:11:11:01:29,name=vn1,model=e1000 \
    -net tap,vlan=1,ifname=tap17,script=no,downscript=no \
    -net nic,vlan=2,macaddr=08:00:11:11:02:29,name=vn2,model=e1000 \
    -net tap,vlan=2,ifname=tap27,script=no,downscript=no \
    -net nic,vlan=3,macaddr=08:00:11:11:03:29,name=vn3,model=e1000 \
    -net tap,vlan=3,ifname=tap37,script=no,downscript=no \
    -net nic,vlan=4,macaddr=08:00:11:11:04:29,name=vn4,model=e1000 \
    -net tap,vlan=4,ifname=tap47,script=no,downscript=no
    ;;
*)
    echo "Usage: $0 {machine name}, available vms:"
    grep "^.*)$" $0 |grep -v "*" | sed 's/)//'
    ;;
esac
