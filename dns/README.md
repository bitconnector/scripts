# dynv6 dns update-script

[dynv6.net](https://dynv6.com/) offers a great service to reach your IPv6 devices. Just sign up and create a new zone

## installation

```
sudo nano /opt/dynv6-update.sh
sudo chmod +x /opt/dynv6-update.sh
sudo nano /usr/lib/systemd/system/dynv6-update.service
sudo systemctl start dynv6-update.service
sudo systemctl enable dynv6-update.service
```
dont forget to change the TOKEN and the HOSTNAME in dynv6-update.sh and adapt the User in dynv6-update.service to a existing one
