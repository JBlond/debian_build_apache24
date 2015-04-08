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

# PHP setup
[PHP Setup](php.md)

#Notice

When you start Apache you get in the error.log the warning:
this version of mod_ssl was compiled against a newer library (OpenSSL 1.0.1l 15 Jan 2015, version currently loaded is OpenSSL 1.0.1e 11 Feb 2013)

That is a false warning you won't get rid of this SSL warning. It is that the debian people only patch the software instead and do not increase the version number. In this case the libssl-dev.