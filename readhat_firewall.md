# open the firewall for the outside

```
sudo iptables -I INPUT 5 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -I INPUT 5 -i eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
```

# Virtualbox

on Virtualbox replace eth0 with your device name e.g. enp0s3

```
sudo iptables -I INPUT 5 -i enp0s3 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -I INPUT 5 -i enp0s3 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
```