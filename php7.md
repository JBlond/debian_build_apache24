<h1>Install PHP over fcgid</h1>

<h2>On x86 and x64</h2>





```

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

${SUDO} apt-get install apt-transport-https lsb-release ca-certificates
${SUDO} wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
${SUDO} sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
${SUDO} apt-get update

```
<h3>Install PHP as CGI</h3>

```
sudo aptitude install php7.0-cgi php7.0-cli php7.0-common php7.0-curl php7.0-gd php7.0-json php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-xml
```

If you need more php extenstions look at the output of 

```
sudo apt-cache search php7
```


[PHP Example config](php7_example.conf)
