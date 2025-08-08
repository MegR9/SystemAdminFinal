#!/bin/bash
echo 'Please enter the path to your database drive (ALL DATA WILL BE DELETED)'
read drivepath
if [[ $drivepath -eq '/dev/sda' ]] ; then
	echo 'no'
	exit 1
fi
#delete old partition and make a new one with type LVM
fdisk $drivepath <<EEOF
d
n
1



t
44
w
EEOF
echo 'Drive partitioned'
#create volume group
partition="${drivepath}1"
vgcreate db-vg $partition
#create logical volume
lvcreate -l 100%FREE -n lv-dbdata db-vg
#format
mkfs.ext4 /dev/db-vg/lv-dbdata
#mount the filesystem
mkdir /mnt/dbdata
mount /dev/db-vg/lv-dbdata /mnt/dbdata
#start docker compose
docker compose up -d
echo 'Docker started'

