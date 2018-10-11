# debian build apache2.4.x with mod fcgid and OpenSSL

Build apache 2.4 on debian from scratch with a semi automatic setup.

This works also on RedHat / CentOS / fedora / scientific linux and openSUSE / SUSE


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

## Manage the Service

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

## Bulltet proof SSL Configuration

```
<If "%{SERVER_PORT} == '443'">
    <IfModule mod_headers.c>
        Header always set Strict-Transport-Security "max-age=15553000; preload"
    </IfModule>
</If>
SSLUseStapling On
SSLSessionCache shmcb:/opt/apache2/logs/ssl_gcache_data(512000)
SSLStaplingCache shmcb:/opt/apache2/logs/ssl_stapling_data(512000)
SSLOptions +StrictRequire +StdEnvVars -ExportCertData
SSLProtocol -all +TLSv1.2
SSLCompression Off
SSLHonorCipherOrder On
SSLCipherSuite ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA

SSLOpenSSLConfCmd ECDHParameters secp384r1
SSLOpenSSLConfCmd Curves sect571r1:sect571k1:secp521r1:sect409k1:sect409r1:secp384r1:sect283k1:sect283r1:secp256k1:prime256v1
```
For download [SSL config](https://raw.githubusercontent.com/JBlond/debian_build_apache24/master/ssl.conf)

## Update existing Installation

To update an existing installation just run update.sh .

## Install as daemon

```
./install_as_daemon.sh
```

## Uninstall daemon

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
