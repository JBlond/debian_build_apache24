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
sudo apt install php7.2-cgi php7.2-cli php7.2-common php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-mysql php7.2-opcache php7.2-xml
```

If you need more php extenstions look at the output of 

```
sudo apt-cache search php7
```


[PHP Example config](php7_example.conf)
