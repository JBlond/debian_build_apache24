#!/bin/bash
mkdir $HOME/apache24
cd $HOME/apache24

# debian
which apt  > /dev/null 2>&1 && {
	sudo apt update || echo apt update hit problems but continuing anyway...
	sudo apt -y install wget build-essential zlib1g-dev liblua5.1-dev autoconf libtool libpcre3-dev libxml2-dev libexpat1-dev libcurl4-openssl-dev libyajl-dev brotli python unzip
}

# opensuse
which zypper  > /dev/null 2>&1 && {
	sudo zypper install --type pattern devel_basis
	sudo zypper install autoconf wget libnghttp2-devel libtool libxml2-devel lua-devel pcre-devel python-devel zlib-devel libexpat-devel
}

exit 0
