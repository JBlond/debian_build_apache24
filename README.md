# debian build apache2.4.x with mod fcgid and OpenSSL

Build apache 2.4 on debian from scratch with a semi automatic setup.


```
#clone
git clone https://github.com/JBlond/debian_build_apache24.git
cd debian_build_apache24
```

if you are on RedHat / CentOS / fedora / scientific linux
```
git checkout redhat
```

if you are on openSUSE
```
git checkout opensuse
```

```
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

troubleshooting apache config

```
sudo /opt/apache2/bin/httpd -S
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

# httpd apache MPMs

This builds all available mpms. You can load them in httpd.conf. event mpm is loaded set in httpd.conf by this script. There can be only one mpm at the time. It is not advised to change the mpm during restart. For that stop and start apache.

```
LoadModule mpm_event_module modues/mod_mpm_event.so
```

```
LoadModule mpm_worker_module modues/mod_mpm_worker.so
```

```
LoadModule mpm_prefork_module modues/mod_mpm_prefork.so
```

# mod_h[ttp]2
```
LoadModule http2_module modules/mod_http2.so
```

By default, the HTTP/2 protocol is not enabled anywhere in your server.
You can add this for the server in general or for specific vhosts.

```
# for a https server
ProtocolsHonorOrder On
Protocols h2 http/1.1
...

# for a http server
ProtocolsHonorOrder On
Protocols h2c http/1.1
```

For more information see https://icing.github.io/mod_h2/howto.html

# PHP setup
[PHP Setup](php.md)

#PHP 7 setup
[PHP7 setup](php7.md)
