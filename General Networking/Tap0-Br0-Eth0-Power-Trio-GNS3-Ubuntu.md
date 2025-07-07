# Tap0-Br0-Eth0 in Ubuntu
## Granting GNS3 Appliances Access To the Wild Yonder

This was less trivial than I would've expected, and therefore it's time to take notes. There are two approaches that I took to bridgin' (Br0) my physical and TAP interfaces, manual and persistent.

### Manual
# One-time installation
sudo apt-get install uml-utilities bridge-utils

# Create a TAP interface
sudo ip link set tap0 up

# Bind both TAP (tap0) and ethernet (enp12s0f1) to bridge (br0)
sudo ip link set enp12s0f1 master br0
sudo ip link set tap0 master bro

# Assign an IP address to the bridge device
sudo ip addr add 172.16.1.30/23 dev br0

# Connect to TAP0 in GNS3


sudo ip link set enp12s0f1 down
sudo ip link set tap0 down
sudo ip link set br0 down
sudo ip addr remove 172.16.1.30/23 dev br0
sudo ip link set enp12s0f1 nomaster
sudo ip link set tap0 nomaster
sudo ip link delete tap0
sudo ip linke delete br0

![image](https://github.com/user-attachments/assets/72046eaa-30d0-4409-9b18-5d2958aed384)

### Persistent
