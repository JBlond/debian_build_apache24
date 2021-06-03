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

```
sudo apt install php7.2-cgi php7.2-cli php7.2-common php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-mysql php7.2-opcache php7.2-xml
# OR 7.3 or both ;)
sudo apt install php7.3-cgi php7.3-cli php7.3-common php7.3-curl php7.3-gd php7.3-json php7.3-mbstring php7.3-mysql php7.3-opcache php7.3-readline php7.3-xml php7.3-zip php7.3-redis
##
sudo apt install php7.4-cgi php7.4-cli php7.4-common php7.4-curl php7.4-gd php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-zip php7.4-redis
```

If you need more php extenstions look at the output of 

```
sudo apt-cache search php7
```


[PHP Example config](php7_example.conf)


```BASH
sudo apt install php8.0-cgi php8.0-cli php8.0-common php8.0-curl php8.0-gd php-json php8.0-mbstring php8.0-mysql php8.0-opcache php8.0-readline php8.0-xml php8.0-zip php8.0-redis
```
