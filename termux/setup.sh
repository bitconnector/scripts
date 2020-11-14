#!/bin/bash

termux-setup-storage
mkdir .shortcuts

pkg install openssh nano rsync wget grep termux-api
pkg install nmap autossh mosh bash-completion ccrypt pwgen man

ssh-keygen -b 4096
#ln -s .ssh/id_rsa.pub ssh-key.pub
cat .ssh/id_rsa.pub
termux-clipboard-set <.ssh/id_rsa.pub
cat <<EOF >.ssh/config
Host template
    HostName serveraddress.com
    Port 22
	User user
EOF
