setup:

add the public ssh-key of USER to a user on the REMOTE-HOST and make sure he has  "AllowTcpForwarding yes" enabled in "/etc/sshd_config"

in the USER directory add a line for REMOTE-HOST in the ssh-config

`sudo nano /etc/systemd/system/ssh-reverse-tunnel.service`

change "12345" to the actual port to forward

`sudo systemctl start ssh-reverse-tunnel.service`

`sudo systemctl enable ssh-reverse-tunnel.service`

checking:

`sudo systemctl status ssh-reverse-tunnel.service`

