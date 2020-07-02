# Build last apache2.4.x with mod fcgid and last OpenSSL + mod_security

Build apache 2.4 on debian from scratch with a semi automatic setup.

This works also on RedHat / CentOS / fedora / scientific linux and openSUSE / SUSE

On RedHat / fedora you might have to open your [firewall](readhat_firewall.md) 

```
#clone
git clone https://github.com/JBlond/debian_build_apache24.git
cd debian_build_apache24
```

```
# on a fresh system
./preparesystem.sh

#then
./build_apache.sh
```

The new apache will be installed in /opt/apache2

## 32 bit and arm build

This won't compile on 32 bit or arm based processor. If you want to use it on thoses systems like raspberry pi
remove the parameter `enable-ec_nistp_64_gcc_128` from build_apache.sh for openssl config script.
And remove the parameter `--enable-nonportable-atomics=yes` from the configure for httpd.

### OpenSSL
enable-ec_nistp_64_gcc_128: Use on little endian platforms when GCC supports `__uint128_t`. ECDH is about 2 to 4 times faster. Not enabled by default because Configure can't determine it. Enable it if your compiler defines `__SIZEOF_INT128__`, the CPU is little endian and it tolerates unaligned data access. 

### Event MPM
Event MPM depends on APR's atomic compare-and-swap operations for thread synchronization (`--enable-nonportable-atomics=yes`). This will cause APR to implement atomic operations using efficient opcodes not available in older CPUs.

## Manage the Service

To start apache

```BASH
sudo /opt/apache2/bin/httpd -k start
```

To stop apache

```BASH
sudo /opt/apache2/bin/httpd -k stop
```

To restart apache

```BASH
sudo /opt/apache2/bin/httpd -k graceful
```

troubleshooting apache config

```BASH
sudo /opt/apache2/bin/httpd -S
```

### systemctl

```BASH
systemctl status apachectl
```

## Bulltet proof SSL Configuration

```XML
<If "%{SERVER_PORT} == '443'">
    <IfModule mod_headers.c>
        Header always set Strict-Transport-Security "max-age=15553000; preload"
    </IfModule>
</If>
SSLUseStapling On
SSLSessionCache shmcb:C:/Windows/Temp/ssl_gcache_data(512000)
SSLStaplingCache shmcb:C:/Windows/Temp/ssl_stapling_data(512000)
SSLOptions +StrictRequire +StdEnvVars -ExportCertData
SSLProtocol -all +TLSv1.2 +TLSv1.3
SSLCompression Off
SSLHonorCipherOrder On
SSLCipherSuite SSL ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384
SSLCipherSuite TLSv1.3 TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384

SSLOpenSSLConfCmd ECDHParameters secp384r1
SSLOpenSSLConfCmd Curves sect571r1:sect571k1:secp521r1:sect409k1:sect409r1:secp384r1:sect283k1:sect283r1:secp256k1:prime256v1

SSLOpenSSLConfCmd SignatureAlgorithms rsa_pss_rsae_sha512:rsa_pss_rsae_sha256:ECDSA+SHA512:ECDSA+SHA256:RSA+SHA512:RSA+SHA256
SSLOpenSSLConfCmd ClientSignatureAlgorithms rsa_pss_rsae_sha512:rsa_pss_rsae_sha256:ECDSA+SHA512:ECDSA+SHA256:RSA+SHA512:RSA+SHA256
```
For download [SSL config](https://raw.githubusercontent.com/JBlond/debian_build_apache24/master/ssl.conf)

## Update && manage existing Installation

<details><summery>Use the make script</summery>

```
 make prepare       prepares the system for building
 make build         build from sources, but no daemon installation
 make install       install as daemon
 make uninstall     uninstall daemon
 make install       run the deploy script
 make update        update from the sources and install as daemon
 make graceful      graceful apache restart
 make stop          stops apache
 make start         starts apache
 make checksyntax   apache config syntax check

```
</details>

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
ProtocolsHonorOrder On
Protocols h2c h2 http/1.1
H2Direct On 
```

For more information see https://icing.github.io/mod_h2/howto.html

# mod_brotli

brotli compression with deflate as fallback

```
LoadModule brotli_module modules/mod_brotli.so
AddOutputFilterByType BROTLI;DEFLATE text/html text/plain text/xml text/php text/css text/js text/javascript text/javascript-x application/x-javascript font/truetype
AddOutputFilterByType BROTLI;DEFLATE application/javascript application/rss+xml
DeflateCompressionLevel 9
```

# PHP 7 setup
[PHP7 setup](php7.md)
