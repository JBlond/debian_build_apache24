<h1>Install PHP over fcgid</h1>

<h2>On x86 and x64</h2>



```
sudo nano /etc/apt/sources.list
```

```
deb http://packages.dotdeb.org jessie all
deb-src http://packages.dotdeb.org jessie all
```

```
wget http://www.dotdeb.org/dotdeb.gpg
sudo apt-key add dotdeb.gpg
sudo aptitude update
sudo aptitude dist-upgrade
```
<h3>Install PHP as CGI</h3>

```
sudo aptitude install php7.0-cgi php7.0-cli php7.0-common php7.0-curl php7.0-gd php7.0-json php7.0-mcrypt php7.0-mysql php7.0-opcache
```

List the dotdeb installed binaries
```
sudo dpkg -l |grep dotdeb 
```

If you need more php extenstions look at the output of 

```
sudo apt-cache search php7
```


[PHP Example config](php7_example.conf)
