#!/bin/bash -x

# Exit on any error
set -e

VM_IMAGE_URL=$1
TEMPLATE_NAME=$2
TEMPLATE_STORAGE=lvm-vmstore

wget $VM_IMAGE_URL

VMID=`pvesh get /cluster/nextid`

qm create $VMID

qm set $VMID --name $TEMPLATE_NAME

qm importdisk $VMID `basename $VM_IMAGE_URL` $TEMPLATE_STORAGE 
qm set $VMID --scsihw virtio-scsi-pci --scsi0 "$TEMPLATE_STORAGE:vm-$VMID-disk-0"
qm set $VMID --ide2 "$TEMPLATE_STORAGE:cloudinit"
qm set $VMID --boot order=scsi0
qm set $VMID --agent enabled=1,fstrim_cloned_disks=1,type=virtio
qm set $VMID --serial0 socket --vga serial0
qm template $VMID
