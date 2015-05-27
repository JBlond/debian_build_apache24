<h1>Install PHP over fcgid</h1>

<h2>On x86 and x64</h2>

The step adding dot deb is not needed in Jessie. Only wheezy

```
sudo nano /etc/apt/sources.list
```

```
deb http://packages.dotdeb.org wheezy all
deb-src http://packages.dotdeb.org wheezy all

deb http://packages.dotdeb.org wheezy-php56 all
deb-src http://packages.dotdeb.org wheezy-php56 all
```

```
wget http://www.dotdeb.org/dotdeb.gpg
sudo apt-key add dotdeb.gpg
sudo aptitude update
sudo aptitude dist-upgrade
```
<h3>Install PHP as CGI</h3>

```
sudo aptitude install php5-cgi php5-cli php5-curl php5-gd php5-mcrypt
```

List the dotdeb installed binaries
```
sudo dpkg -l |grep dotdeb 
```


<h2>On arm just</h2>
```
sudo aptitude install php5-cgi php5-cli php5-curl php5-gd php5-mcrypt
```
[PHP Example config](php_example.conf)
