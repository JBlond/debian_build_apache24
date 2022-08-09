<h1>Install PHP over fcgid</h1>

<h2>On x86 and x64</h2>

**Note: If you update your debian version, you need to re-run the  echo into the php.list file.**

```
#!/bin/bash
if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

${SUDO} apt-get install apt-transport-https lsb-release ca-certificates
${SUDO} curl -ssL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
${SUDO} sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
${SUDO} apt-get update
```

<h3>Install PHP as CGI</h3>

```bash
sudo apt install php7.4-cgi php7.4-cli php7.4-common php7.4-curl php7.4-gd php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-zip php7.4-redis
# OR 8.0 or both ;)
sudo apt install php8.0-cgi php8.0-cli php8.0-common php8.0-curl php8.0-gd php-json php8.0-mbstring php8.0-mysql php8.0-opcache php8.0-readline php8.0-xml php8.0-zip php8.0-redis
## or even more
sudo apt install php8.1-cgi php8.1-cli php8.1-common php8.1-curl php8.1-gd php-json php8.1-mbstring php8.1-mysql php8.1-opcache php8.1-readline php8.1-xml php8.1-zip php8.1-redis
```

<h3>Change the default interpreter for composer after this!</h3>

```bash
sudo update-alternatives --config php

sudo update-alternatives --config php-cgi
```

If you need more php extenstions look at the output of 

```bash
sudo apt-cache search php8
```

mod_fcgid requires mod_unixd to be loaded before it in the configuration!

```xml
LoadModule unixd_module modules/mod_unixd.so
LoadModule fcgid_module modules/mod_fcgid.so
```

The default socket for mod_fcgid is in /opt/apache2/logs. So the logs directory needs to be writeable for the apache. 

```xml
<IfModule unixd_module>
        User www-data
        Group www-data
</IfModule>
```

This user must exist on the system. Do not use the root user.

[PHP Example config](php_example.conf)
