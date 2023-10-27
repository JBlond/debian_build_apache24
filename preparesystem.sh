#!/bin/bash
mkdir $HOME/apache24
cd $HOME/apache24

if command -v nala &> /dev/null
then
    icmd='nala'
else
    icmd='apt'
fi

sudo $icmd update || echo $icmd update hit problems but continuing anyway...
sudo $icmd -y install wget build-essential zlib1g-dev liblua5.1-dev autoconf libtool libpcre3-dev libxml2-dev libexpat1-dev libcurl4-openssl-dev libyajl-dev brotli python3 unzip gcc

exit 0
