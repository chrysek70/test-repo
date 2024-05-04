# Sample Kickstart configuration for Rocky Linux
#version=RHEL8

# Use CDROM installation media
cdrom

# System authorization information
auth --enableshadow --passalgo=sha512

# System keyboard
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Root password (replace with your encrypted password)
rootpw --iscrypted $6$QC6SVy7m.rt2zQL1$ilIaOdAZhSStw0KyqSRW4wh.IXOQq1Wz.IA27.T4su07IXB/KQy5sX54DP79FeKIYhEZ5JFaaFKFqmVJ9/ybF/

# Firewall configuration
firewall --enabled --ssh

# Network information
network  --bootproto=dhcp --device=eth0 --onboot=on --ipv6=auto

# Timezone setting
timezone UTC

# User account setup
user --name=cw --password=$6$QC6SVy7m.rt2zQL1$ilIaOdAZhSStw0KyqSRW4wh.IXOQq1Wz.IA27.T4su07IXB/KQy5sX54DP79FeKIYhEZ5JFaaFKFqmVJ9/ybF/ --iscrypted --gecos="CW User" --groups=wheel

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda

# Clear the Master Boot Record
zerombr

# Disk partitioning information
clearpart --all --initlabel --drives=sda
part /boot --fstype="xfs" --size=500 --ondisk=sda --asprimary
part /     --fstype="xfs" --size=2000 --ondisk=sda --asprimary
part pv.01 --size=1 --grow --ondisk=sda

volgroup vg01 pv.01

# Create a thin pool within the volume group
logvol /dev/vg01/thinpool --size=15000 --name=thinpool --vgname=vg01 --grow --thinpool

# Define thin logical volumes
logvol /usr  --vgname=vg01 --size=4000 --name=lv_usr --thin --poolname=thinpool
logvol /tmp  --vgname=vg01 --size=2000 --name=lv_tmp --thin --poolname=thinpool
logvol /var  --vgname=vg01 --size=5000 --name=lv_var --thin --poolname=thinpool
logvol /home --vgname=vg01 --size=2000 --name=lv_home --thin --poolname=thinpool
logvol /opt  --vgname=vg01 --size=1000 --name=lv_opt --thin --poolname=thinpool

# Package installation section
%packages
@core
epel-release
git
ansible
lynx
%end

# Post-installation script
%post
# Install Python 3 pip
dnf install -y python3-pip

# Install required Python packages
pip3 install passlib
pip3 install requests

# Optional: Disable SELinux enforcement
echo "SELINUX=permissive" > /etc/selinux/config
# or if you want to completely disable it (not recommended)
# echo "SELINUX=disabled" > /etc/selinux/config

echo "Kickstart installation completed" > /etc/issue
%end
