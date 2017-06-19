#!/bin/bash
cd "${HOME}/apache24"

SSL_VERSION="1.1.0f"
HTTPD_VERSION="2.4.26"
APR_VERSION="1.6.2"
APRU_VERSION="1.6.0"
APRI_VERSION="1.2.1"
ZLIB_VERSION="1.2.11"
PCRE_VERSION="8.38"
HTTP2_VERSION="1.23.1"
BROTLI_VERSION="0.4.0"

SSL_FILE="openssl-${SSL_VERSION}.tar.gz"
HTTPD_FILE="httpd-${HTTPD_VERSION}.tar.gz"
APR_FILE="apr-${APR_VERSION}.tar.gz"
APRU_FILE="apr-util-${APRU_VERSION}.tar.gz"
APRI_FILE="apr-iconv-${APRI_VERSION}.tar.gz"
ZLIB_FILE="zlib-${ZLIB_VERSION}.tar.gz"
PCRE_FILE="pcre-${PCRE_VERSION}.tar.gz"
HTTP2_FILE="nghttp2-${HTTP2_VERSION}.tar.gz"
BROTLI_FILE="${BROTLI_VERSION}.tar.gz"

if [ ! -f "${SSL_FILE}" ]
then
	wget http://www.openssl.org/source/${SSL_FILE}
	tar xfz ${SSL_FILE}
	cd openssl-${SSL_VERSION}
	./config --prefix=/opt/openssl --openssldir=/opt/openssl no-ssl2 no-ssl3 no-ec2m no-rc5 no-idea threads zlib-dynamic shared
	make depend
	make
	sudo make install
fi



cd "${HOME}/apache24"

if [ ! -f "${HTTP2_FILE}" ]
then
	wget https://github.com/tatsuhiro-t/nghttp2/releases/download/v${HTTP2_VERSION}/${HTTP2_FILE}
	tar xfz ${HTTP2_FILE}
	cd nghttp2-${HTTP2_VERSION}
	export LDFLAGS="-Wl,-rpath,/opt/openssl/lib"
	./configure --prefix=/opt/nghttp2
	make
	sudo make install
fi

cd "${HOME}/apache24"

if [ ! -f "${HTTPD_FILE}" ]
then
	wget http://www.apache.org/dist/httpd//${HTTPD_FILE}
	tar xvfz ${HTTPD_FILE}
fi

cd httpd-${HTTPD_VERSION}/srclib

if [ ! -f "${APR_FILE}" ]
then
	wget http://www.apache.org/dist/apr//${APR_FILE}
	tar xvfz ${APR_FILE}
	mv apr-${APR_VERSION} apr
fi

if [ ! -f "${APRU_FILE}" ]
then
	wget http://www.apache.org/dist/apr//${APRU_FILE}
	tar xvfz ${APRU_FILE}
	mv apr-util-${APRU_VERSION} apr-util
fi

if [ ! -f "${APRI_FILE}" ]
then
	wget http://www.apache.org/dist/apr//${APRI_FILE}
	tar xvfz ${APRI_FILE}
	mv apr-iconv-${APRI_VERSION} apr-iconv
fi

if [ ! -f "${ZLIB_FILE}" ]
then
	wget http://zlib.net/${ZLIB_FILE}
	tar xvfz ${ZLIB_FILE}
	mv zlib-${ZLIB_VERSION} zlib
fi

if [ ! -f "${PCRE_FILE}" ]
then
	wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE_FILE}
	tar xvfz ${PCRE_FILE}
	mv pcre-${PCRE_VERSION} pcre
fi

if [ ! -f "${BROTLI_FILE}"]
then
	wget https://github.com/kjdev/apache-mod-brotli/archive/v${BROTLI_FILE}
	tar xvfz ${BROTLI_FILE}
	mv apache-mod-brotli-${BROTLI_VERSION} brotli
fi

cd apr
./configure --with-crypto
make

cd ../..
./buildconf
export LDFLAGS="-Wl,-rpath,/opt/openssl/lib"
./configure --prefix=/opt/apache2 --enable-pie --enable-mods-shared=all --enable-so --disable-include --enable-lua --enable-deflate --enable-headers --enable-expires --enable-http2 --with-nghttp2=/opt/nghttp2 --enable-ssl=shared --with-ssl=/opt/openssl --with-openssl=/opt/openssl --with-crypto --enable-module=ssl --enable-mpms-shared=all --with-mpm=event --enable-rewrite --with-z=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/zlib --enable-fcgid --with-included-apr --enable-brotli --with-brotli=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/brotli 
make
sudo make install

cd "${HOME}/apache24/mod_fcgid"
svn up
APXS=/opt/apache2/bin/apxs ./configure.apxs
make
sudo make install
make clean
