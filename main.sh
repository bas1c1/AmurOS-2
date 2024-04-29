#this stuff i need so yeah

#mkdir -p amuros/build/sources
#mkdir -p amuros/build/downloads
#mkdir -p amuros/build/out
#mkdir -p amuros/linux
#sudo apt update
#sudo apt install --yes make build-essential bc bison flex libssl-dev libelf-dev wget cpio fdisk extlinux dosfstools qemu-system-x86
#cd amuros/build
#wget -P downloads  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.79.tar.xz
#wget -P downloads https://busybox.net/downloads/busybox-1.35.0.tar.bz2
#tar -xvf downloads/linux-5.15.79.tar.xz -C sources
#tar -xjvf downloads/busybox-1.35.0.tar.bz2 -C sources
#cd sources/busybox-1.35.0
#make defconfig
#make LDFLAGS=-static
#cp busybox ../../out/
#cd ../linux-5.15.79
#make defconfig
#make -j4 || exit

sudo apt update

if [ ! -d "amuros/build/out" ]; then
  mkdir -p amuros/build/out
fi

if [ ! -d "amuros/linux" ]; then
  mkdir -p amuros/linux
  sudo apt install --yes make build-essential bc bison flex libssl-dev libelf-dev wget cpio fdisk extlinux dosfstools qemu-system-x86 xorriso
fi

if [ ! -d "amuros/build/downloads" ]; then
  mkdir -p amuros/build/downloads
  cd amuros/build/downloads
  wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.79.tar.xz
  wget https://busybox.net/downloads/busybox-1.35.0.tar.bz2
  cd ..
fi

if [ ! -d "amuros/build/sources" ]; then
  mkdir -p amuros/build/sources
  tar -xvf downloads/linux-5.15.79.tar.xz -C sources
  tar -xjvf downloads/busybox-1.35.0.tar.bz2 -C sources
  cd sources/busybox-1.35.0
  make defconfig
  make LDFLAGS=-static
  cp busybox ../../out/
  cd ../linux-5.15.79
  make defconfig
  make -j4
fi

cd amuros/build/sources/linux-5.15.79/
cp arch/x86_64/boot/bzImage ../../../../amuros/linux/vmlinuz-5.15.79
mkdir -p ../../../../amuros/build/initrd
cd ../../../../amuros/build/initrd
#nano init
cd ..
sudo cp ../../init initrd
cd initrd

chmod 777 init
mkdir -p bin dev proc sys
cd bin
cp ../../../../amuros/build/out/busybox ./
for prog in $(./busybox --list); do ln -s /bin/busybox $prog; done
cd ..
find . | cpio -o -H newc > ../../../amuros/linux/initrd-busybox-1.35.0.img
cd ../../../amuros/linux

sudo cp -r ../../iso iso
sudo cp initrd-busybox-1.35.0.img iso/boot
sudo cp vmlinuz-5.15.79 iso/boot
sudo grub-mkrescue -o amuros.iso iso
sudo rm -rf iso

#generating .img, u dont need this shit

#sudo dd if=/dev/zero of=boot-disk.img bs=1024K count=50
#sudo echo "type=83,bootable" | sudo sfdisk boot-disk.img
#sudo losetup -D
#LOOP_DEVICE=$(losetup -f)
#sudo losetup -o $(expr 512 \* 2048) ${LOOP_DEVICE} boot-disk.img
#sudo mkfs.vfat ${LOOP_DEVICE}
#sudo mkdir -p /mnt/os
#sudo mount -t auto ${LOOP_DEVICE} /mnt/os
#sudo cp vmlinuz-5.15.79 initrd-busybox-1.35.0.img /mnt/os
#sudo mkdir -p /mnt/os/boot
#sudo extlinux --install /mnt/os/boot
#sudo cp ../../syslinux.cfg /mnt/os/boot/syslinux.cfg
#sudo umount /mnt/os
#sudo losetup -D
#sudo dd if=/usr/lib/syslinux/mbr/mbr.bin of=boot-disk.img bs=440 count=1 conv=notrunc

#uncomment this if u need (DONT DO THIS)
#qemu-system-x86_64 -kernel vmlinuz-5.15.79 -initrd initrd-busybox-1.35.0.img -nographic -append 'console=ttyS0'

#sudo qemu-system-x86_64 boot-disk.img