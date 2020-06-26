#!/bin/bash
mkdir $HOME/apache24
cd $HOME/apache24

# debian
which apt  > /dev/null 2>&1 && {
	sudo apt update || echo apt update hit problems but continuing anyway...
	sudo apt -y install wget build-essential zlib1g-dev liblua5.1-dev autoconf libtool libpcre3-dev libxml2-dev subversion libexpat1-dev libcurl4-openssl-dev libyajl-dev brotli
}

# centos
which yum  > /dev/null 2>&1 && {
	sudo dnf config-manager --enable PowerTools
	sudo dnf install libtool lua-devel patch pcre-devel python-devel wget zlib-devel expat-devel svn wget make autoconf gcc zlib-devel pcre-devel lua-devel libtool expat-devel brotli-devel
	sudo dnf group install "Development Tools"
}

# opensuse
which zypper  > /dev/null 2>&1 && {
	sudo zypper install --type pattern devel_basis
	sudo zypper install autoconf wget libnghttp2-devel libtool libxml2-devel lua-devel pcre-devel python-devel subversion zlib-devel libexpat1-devsudop
}


svn checkout http://svn.apache.org/repos/asf/httpd/mod_fcgid/trunk mod_fcgid
