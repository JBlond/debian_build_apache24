# debian build apache2.4.x with mod fcgid and OpenSSL

Build apache 2.4 on debian from scratch with a semi automatic setup.


```
#clone
git clone https://github.com/JBlond/debian_build_apache24.git
cd debian_build_apache24

# on a fresh system
./preparesystem.sh

#then
./build_apache.sh
```

The new apache will be installed in /opt/apache2

To start apache

```
sudo /opt/apache2/bin/httpd -k start
```

To stop apache

```
sudo /opt/apache2/bin/httpd -k stop
```

To restart apache

```
sudo /opt/apache2/bin/httpd -k graceful
```

Proof [SSL config](ssl.conf)

To update an existing installation just run build_apache.sh again.

Install as daemon

```
./install_as_daemon.sh
```

Uninstall daemon

```
./uninstall_daemon.sh
```

# PHP setup
[PHP Setup](php.md)