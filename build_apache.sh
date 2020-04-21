#!/bin/bash
cd "${HOME}/apache24"

SSL_VERSION="1.1.1g"
HTTPD_VERSION="2.4.43"
APR_VERSION="1.7.0"
APRU_VERSION="1.6.1"
APRI_VERSION="1.2.2"
ZLIB_VERSION="1.2.11"
PCRE_VERSION="8.44"
HTTP2_VERSION="1.40.0"

SSL_FILE="openssl-${SSL_VERSION}.tar.gz"
HTTPD_FILE="httpd-${HTTPD_VERSION}.tar.gz"
APR_FILE="apr-${APR_VERSION}.tar.gz"
APRU_FILE="apr-util-${APRU_VERSION}.tar.gz"
APRI_FILE="apr-iconv-${APRI_VERSION}.tar.gz"
ZLIB_FILE="zlib-${ZLIB_VERSION}.tar.gz"
PCRE_FILE="pcre-${PCRE_VERSION}.tar.gz"
HTTP2_FILE="nghttp2-${HTTP2_VERSION}.tar.gz"

if [[ ! -f "${SSL_FILE}" ]]
then
	echo -e " \e[32mOpenSSL\e[0m"
	echo
	wget https://www.openssl.org/source/${SSL_FILE}
	tar xfz ${SSL_FILE}
	cd openssl-${SSL_VERSION}
	./config --prefix=/opt/openssl --openssldir=/opt/openssl no-ssl3 no-ec2m no-rc5 no-idea no-weak-ssl-ciphers enable-ec_nistp_64_gcc_128 threads zlib-dynamic shared
	make depend
	make
	sudo make install
fi

cd "${HOME}/apache24"

if [[ ! -f "${HTTP2_FILE}" ]]
then
	echo -e " \e[32mnghttp2\e[0m"
	echo
	wget https://github.com/tatsuhiro-t/nghttp2/releases/download/v${HTTP2_VERSION}/${HTTP2_FILE}
	tar xfz ${HTTP2_FILE}
	cd nghttp2-${HTTP2_VERSION}
	export LDFLAGS="-Wl,-rpath,/opt/openssl/lib"
	./configure --prefix=/opt/nghttp2
	make
	sudo make install
fi

cd "${HOME}/apache24"

if [[ ! -f "${HTTPD_FILE}" ]]
then
	echo -e " \e[32mDownload httpd\e[0m"
	echo
	wget https://www.apache.org/dist/httpd/${HTTPD_FILE}
	tar xvfz ${HTTPD_FILE}
fi

cd httpd-${HTTPD_VERSION}/srclib

if [[ ! -f "${APR_FILE}" ]]
then
	echo -e " \e[32mDownload APR\e[0m"
	echo
	wget https://www.apache.org/dist/apr/${APR_FILE}
	tar xvfz ${APR_FILE}
	mv apr-${APR_VERSION} apr
fi

if [[ ! -f "${APRU_FILE}" ]]
then
	echo -e " \e[32mDownload APR-UTIL\e[0m"
	echo
	wget https://www.apache.org/dist/apr/${APRU_FILE}
	tar xvfz ${APRU_FILE}
	mv apr-util-${APRU_VERSION} apr-util
fi

if [[ ! -f "${APRI_FILE}" ]]
then
	echo -e " \e[32mDownload APR-ICONV\e[0m"
	echo
	wget https://www.apache.org/dist/apr/${APRI_FILE}
	tar xvfz ${APRI_FILE}
	mv apr-iconv-${APRI_VERSION} apr-iconv
fi

if [[ ! -f "${ZLIB_FILE}" ]]
then
	echo -e " \e[32mDownload ZLIB\e[0m"
	echo
	wget http://zlib.net/${ZLIB_FILE}
	tar xvfz ${ZLIB_FILE}
	mv zlib-${ZLIB_VERSION} zlib
fi

if [[ ! -f "${PCRE_FILE}" ]]
then
	echo -e " \e[32mDownload PCRE\e[0m"
	echo
	wget https://ftp.pcre.org/pub/pcre/${PCRE_FILE}
	tar xvfz ${PCRE_FILE}
	mv pcre-${PCRE_VERSION} pcre
fi

cd ..
echo -e " \e[32mBuild httpd\e[0m"
echo
./buildconf
export LD_LIBRARY_PATH=~/apache24/httpd-${HTTPD_VERSION}/srclib/apr:${LD_LIBRARY_PATH}
export LDFLAGS="-Wl,-rpath,/opt/openssl/lib"
./configure --prefix=/opt/apache2 --enable-pie --enable-mods-shared=all --enable-so --disable-include --enable-lua --enable-deflate --enable-headers --enable-expires --enable-http2 --with-nghttp2=/opt/nghttp2 --enable-ssl=shared --with-ssl=/opt/openssl --with-openssl=/opt/openssl --with-crypto --enable-module=ssl --enable-mpms-shared=all --with-mpm=event --enable-rewrite --with-z=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/zlib --enable-fcgid --with-included-apr
make
sudo make install

currentver="$(cat /etc/debian_version)"
requiredver="9.0"
if [[ "$(printf "$requiredver\n$currentver" | sort -V | head -n1)" == "$currentver" ]] && [[ "$currentver" != "$requiredver" ]]; then
	echo -e " \e[33mMod_brotli requires Debian 9"
else
	echo -e " \e[32mBuild brotli\e[0m"
	echo
	cd "${HOME}/apache24"
	sudo aptitude -y install brotli
	git clone --depth=1 --recursive https://github.com/kjdev/apache-mod-brotli.git mod_brotli
	cd mod_brotli
	./autogen.sh
	./configure --with-apxs=/opt/apache2/bin --with-apr=~/apache24/httpd-${HTTPD_VERSION}/srclib/apr
	make
	sudo install -p -m 755 -D .libs/mod_brotli.so /opt/apache2/modules/mod_brotli.so
fi

cd "${HOME}/apache24/mod_fcgid"
echo -e " \e[32mBuild brotli\e[0m"
echo
svn up
APXS=/opt/apache2/bin/apxs ./configure.apxs
make
sudo make install
make clean
