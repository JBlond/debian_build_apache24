#!/bin/bash
mkdir $HOME/apache24
cd $HOME/apache24

# debian
which apt-get  > /dev/null 2>&1 && {
	sudo aptitude update || echo aptitude update hit problems but continuing anyway...
	sudo aptitude -y install build-essential zlib1g-dev liblua5.1-dev autoconf libtool libpcre3-dev libxml2-dev subversion libexpat1-dev
}

# centos
which yum  > /dev/null 2>&1 && {
	sudo yum groupinstall "Development Tools" "Development Libraries"
	sudo yum install libtool lua-devel patch pcre-devel python-devel wget zlib-devel expat-devel
}

# opensuse
which zypper  > /dev/null 2>&1 && {
	sudo zypper install --type pattern devel_basis
	sudo zypper install autoconf libnghttp2-devel libtool libxml2-devel lua-devel pcre3-devel python-devel subversion zlib-devel libexpat1-dev
}


svn checkout http://svn.apache.org/repos/asf/httpd/mod_fcgid/trunk mod_fcgid
