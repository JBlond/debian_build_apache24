# Install PHP over fcgid

```
sudo nano /etc/apt/sources.list
```

```
deb http://packages.dotdeb.org wheezy all
deb-src http://packages.dotdeb.org wheezy all

deb http://dotdeb.netmirror.org/ stable all
deb-src http://dotdeb.netmirror.org/ stable all

deb http://packages.dotdeb.org wheezy-php56 all
deb-src http://packages.dotdeb.org wheezy-php56 all
```

```
wget http://www.dotdeb.org/dotdeb.gpg
sudo apt-key add dotdeb.gpg
sudo aptitude update
sudo aptitude dist-upgrade
sudo aptitude install php5-cgi php5-cli php5-curl php5-gd php5-mcrypt
```

List the dotdeb installed binaries
```
sudo dpkg -l |grep dotdeb 
```

[PHP Example config](php_example.conf)