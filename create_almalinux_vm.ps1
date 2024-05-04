# Define VM parameters
$VMName = "AlmaLinuxVM"
$VMType = "Linux"
$ISOPath = "C:\Users\cw\Downloads\AlmaLinux-9.3-x86_64-dvd.iso"
$VMDiskPath = "C:\Users\cw\VirtualBox VMs\$VMName\$VMName.vdi"
$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" # Change this to the path where VirtualBox is installed

# Create VM
& $VBoxManage createvm --name $VMName --ostype "RedHat_64" --register

# Set VM settings
& $VBoxManage modifyvm $VMName --cpus 2 --memory 2048 --vram 16 --graphicscontroller vmsvga --nic1 nat

# Create a virtual hard disk
& $VBoxManage createhd --filename $VMDiskPath --size 20480 --variant Standard

# Create a SATA controller and attach the disk
& $VBoxManage storagectl $VMName --name "SATA Controller" --add sata --controller IntelAhci
& $VBoxManage storageattach $VMName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $VMDiskPath

# Attach the installation ISO
& $VBoxManage storagectl $VMName --name "IDE Controller" --add ide --controller PIIX4
& $VBoxManage storageattach $VMName --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $ISOPath

# Set up NAT Network Port Forwarding for SSH
& $VBoxManage modifyvm $VMName --natpf1 "guestssh,tcp,,2222,,22"

# Start the VM (optional)
& $VBoxManage startvm $VMName
