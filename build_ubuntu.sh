#!/bin/sh -x
# Exit on any errors in subcommands
set -e

# $1: Ubuntu Release datestring from https://cloud-images.ubuntu.com/releases/

RELEASE_YYDD=$1
RELEASE_STR=`echo $RELEASE_YYDD | sed -e 's/\.//g'`
LOCAL_IMG_PATH=/tmp/ubuntu-$RELEASE_YYDD-server-cloudimg-amd64.img

VM_ID=`pvesh get /cluster/nextid`

# TODO: make this a flag?
VM_STORAGE="lvm-vmstore"

apt install libguestfs-tools -y

wget -O $LOCAL_IMG_PATH http://cloud-images.ubuntu.com/releases/$RELEASE_YYDD/release/ubuntu-$RELEASE_YYDD-server-cloudimg-amd64.img

virt-customize -v -x -a $LOCAL_IMG_PATH --install qemu-guest-agent

qm importdisk $NEXTID $LOCAL_IMG_PATH $VM_STORAGE

qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $VM_STORAGE:vm-$VM_ID-disk-0

qm set $VM_ID --ide2 $VM_STORAGE:cloudinit

qm set $VM_ID --boot c --bootdisk scsi0

qm set $VM_ID -agent enabled=1,fstrim_cloned_disks=1,type=virtio

qm set $VM_ID --serial0 socket --vga serial0

qm set $VM_ID --name template-ubuntu-$RELEASE_STR-server

qm template $NEXTID