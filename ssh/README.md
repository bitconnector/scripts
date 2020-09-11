# setup a secure SSH-Server

## groups

`groupadd <GROUP>`

| group | description |
| --- | --- |
| ssh | accessing ssh |
| sftp | restricted users |
| ssh-pw | enabling password login |
| ssh-tunnel | creating tunnels for other protocols |

adding:

`sudo gpasswd -a USER GROUP`

removing:

`sudo gpasswd -d USER GROUP`

---
**NOTE**

The admin **must be** in the "ssh" group otherwise he will lose access!

He also **must not** be in "sftp" or he will end up in a restricted shell!

---

## config

Copy the `sshd_config` to `/etc/ssh/`

Restart and enable ssh:

`sudo systemctl enable ssh && sudo systemctl restart ssh`


