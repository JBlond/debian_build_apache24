#!/bin/bash
mkdir $HOME/apache24
cd $HOME/apache24

if command -v nala &> /dev/null
then
    sudo nala update || echo nala update hit problems but continuing anyway...
    sudo nala install wget build-essential zlib1g-dev liblua5.1-dev autoconf libtool libpcre2-dev libxml2-dev libexpat1-dev libcurl4-openssl-dev libyajl-dev brotli python3 unzip gcc libzstd-dev
else
    sudo apt update || echo apt update hit problems but continuing anyway...
    sudo apt -y install wget build-essential zlib1g-dev liblua5.1-dev autoconf libtool libpcre2-dev libxml2-dev libexpat1-dev libcurl4-openssl-dev libyajl-dev brotli python3 unzip gcc libzstd-dev
fi

exit 0
