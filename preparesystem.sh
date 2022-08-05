#!/bin/bash
mkdir $HOME/apache24
cd $HOME/apache24

sudo apt update || echo apt update hit problems but continuing anyway...
sudo apt -y install wget build-essential zlib1g-dev liblua5.1-dev autoconf libtool libpcre3-dev libxml2-dev libexpat1-dev libcurl4-openssl-dev libyajl-dev brotli python unzip

exit 0
