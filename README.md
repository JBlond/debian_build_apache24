# Build last apache2.4.x + mod fcgid + last OpenSSL + mod_security

Build apache 2.4 on debian from scratch with a semi automatic setup. Since OpenSSL 3.0.x this works only on x86_64 Systems. 32 bit is no longer supported.

```
#clone
git clone https://github.com/JBlond/debian_build_apache24.git
cd debian_build_apache24
```

## Inastall && Update && manage existing Installation

Use the make script

```
 make prepare       prepares the system for building
 make build         build from sources, but no daemon installation
 make clean         clear build artifacts
 make purge         Removes everything from this on the system.
 make install       install as daemon
 make uninstall     uninstall daemon
 make update        update from the sources and install as daemon
 make graceful      graceful apache restart
 make stop          stops apache
 make start         starts apache
 make checksyntax   apache config syntax check
```

The new apache will be installed in /opt/apache2


### Raspberry PI note

<details><summery>Changes needed</summery>

In order to get this build working on a raspberry pi your need to delete two parameters in build_apache.sh

in the openssl config options delete `enable-ec_nistp_64_gcc_128`

in the httpd configure option delete `--enable-nonportable-atomics=yes`

note that 32 bit do not work with the OpenSSL 3!

Patches are more than welcome to have that in a single script. Fork this repo and open a PR.
</details>

## Manage the Service

```BASH
# To start apache
sudo /opt/apache2/bin/httpd -k start

# To stop apache
sudo /opt/apache2/bin/httpd -k stop

# To restart apache
sudo /opt/apache2/bin/httpd -k graceful
```

# troubleshooting apache config

```BASH
sudo /opt/apache2/bin/httpd -S
```

### systemctl

```BASH
systemctl status apachectl
```

## Bulltet proof SSL Configuration

[SSL config](https://raw.githubusercontent.com/JBlond/debian_build_apache24/master/ssl.conf)

## httpd apache MPMs

This builds all available mpms. You can load them in httpd.conf. event mpm is loaded set in httpd.conf by this script. There can be only one mpm at the time. It is not advised to change the mpm during restart. For that stop and start apache.

<details><summery>Local the MPM's</summery><br>

```
LoadModule mpm_event_module modues/mod_mpm_event.so

LoadModule mpm_worker_module modues/mod_mpm_worker.so

LoadModule mpm_prefork_module modues/mod_mpm_prefork.so
```
</details>

### Event MPM
Event MPM depends on APR's atomic compare-and-swap operations for thread synchronization (`--enable-nonportable-atomics=yes`). This will cause APR to implement atomic operations using efficient opcodes not available in older CPUs.

## Third party modules

- mod_brotli
- mod_fcgid
- mod_md
- mod_security 2 [example config](https://raw.githubusercontent.com/JBlond/debian_build_apache24/master/1_security_mod_security.conf)
- mod_xsendfiles [code](https://github.com/nmaier/mod_xsendfile)

## mod_h[ttp]2

```
LoadModule http2_module modules/mod_http2.so
```

By default, the HTTP/2 protocol is not enabled anywhere in your server.
You can add this for the server in general or for specific vhosts.

```
ProtocolsHonorOrder On
Protocols h2 h2c http/1.1
H2Direct On 
```

For more information see https://icing.github.io/mod_h2/howto.html

## mod_brotli

brotli compression with deflate as fallback

```
LoadModule brotli_module modules/mod_brotli.so
AddOutputFilterByType BROTLI;DEFLATE text/html text/plain text/xml text/php text/css text/js text/javascript text/javascript-x application/x-javascript font/truetype
AddOutputFilterByType BROTLI;DEFLATE application/javascript application/rss+xml
DeflateCompressionLevel 9
```

## PHP setup
[PHP setup](php.md)
