#!/bin/bash
mkdir $HOME/apache24
cd $HOME/apache24
sudo aptitude update || echo aptitude update hit problems but continuing anyway...
sudo aptitude -y install build-essential zlib1g-dev liblua5.1-dev autoconf libtool libpcre3-dev libxml2-dev subversion
svn checkout http://svn.apache.org/repos/asf/httpd/mod_fcgid/trunk mod_fcgid
