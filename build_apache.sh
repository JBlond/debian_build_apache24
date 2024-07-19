#!/bin/bash
mkdir -p "${HOME}/apache24"
cd "${HOME}/apache24"

SSL_VERSION="3.0.14"
HTTPD_VERSION="2.4.62"
APR_VERSION="1.7.4"
APRU_VERSION="1.6.3"
APRI_VERSION="1.2.2"
ZLIB_VERSION="1.3.1"
PCRE_VERSION="8.45"
PCRE2_VERSION="10.44"
HTTP2_VERSION="1.62.1"
MOD_SEC_VERSION="2.9.7"
JANSON_VERSION="2.14"

CURL_VERSION="8.8.0"
CURL_PATH="8_8_0"

SSL_FILE="openssl-${SSL_VERSION}.tar.gz"
HTTPD_FILE="httpd-${HTTPD_VERSION}.tar.gz"
APR_FILE="apr-${APR_VERSION}.tar.gz"
APRU_FILE="apr-util-${APRU_VERSION}.tar.gz"
APRI_FILE="apr-iconv-${APRI_VERSION}.tar.gz"
ZLIB_FILE="zlib-${ZLIB_VERSION}.tar.gz"
PCRE_FILE="${PCRE_VERSION}.tar.gz"
PCRE2_FILE="pcre2-${PCRE2_VERSION}.tar.gz"
HTTP2_FILE="nghttp2-${HTTP2_VERSION}.tar.gz"
MOD_SEC_FILE="modsecurity-${MOD_SEC_VERSION}.tar.gz"

if [[ ! -f "${SSL_FILE}" ]]
then
	echo -e " \e[32mOpenSSL\e[0m"
	echo
	wget https://www.openssl.org/source/${SSL_FILE}
	tar xfz ${SSL_FILE}
	cd openssl-${SSL_VERSION}
	./config --prefix=/opt/openssl --openssldir=/opt/openssl no-ssl3 no-ec2m no-rc5 no-idea no-camellia no-weak-ssl-ciphers threads no-psk zlib-dynamic shared enable-ec_nistp_64_gcc_128
	make
	sudo make install_sw
	sudo make install_ssldirs
	sudo cp libcrypto.a libcrypto.so libcrypto.so.3 libssl.a libssl.so libssl.so.3 /usr/local/lib
	sudo ldconfig
fi

cd "${HOME}/apache24"

if [[ ! -f "${HTTP2_FILE}" ]]
then
	echo -e " \e[32mnghttp2\e[0m"
	echo
	wget https://github.com/tatsuhiro-t/nghttp2/releases/download/v${HTTP2_VERSION}/${HTTP2_FILE}
	tar xfz ${HTTP2_FILE}
	cd nghttp2-${HTTP2_VERSION}
	export LDFLAGS="-Wl,-rpath,/opt/openssl/lib64"
	./configure --prefix=/opt/nghttp2  --disable-python-bindings
	make
	sudo make install
fi

cd "${HOME}/apache24"

if [[ ! -f "curl-${CURL_VERSION}.tar.gz" ]]
then
	echo -e " \e[32mDownload CURL\e[0m"
	wget https://github.com/curl/curl/releases/download/curl-${CURL_PATH}/curl-${CURL_VERSION}.tar.gz
	tar xvfz curl-${CURL_VERSION}.tar.gz
	cd curl-${CURL_VERSION}
	./configure --prefix=/opt/curl --enable-optimize --disable-manual --disable-debug --with-nghttp2=/opt/nghttp2 --without-ssl
	make
	sudo make install
fi

cd "${HOME}/apache24"

if [[ ! -f "jansson-${JANSON_VERSION}.tar.gz" ]]
then
	echo -e " \e[32JANSON\e[0m"
	wget https://github.com/akheron/jansson/releases/download/v${JANSON_VERSION}/jansson-${JANSON_VERSION}.tar.gz
	tar xvfz jansson-${JANSON_VERSION}.tar.gz
	cd jansson-${JANSON_VERSION}
	./configure --prefix=/opt/jansson
	make
	sudo make install
fi

cd "${HOME}/apache24"

if [[ ! -f "${HTTPD_FILE}" ]]
then
	echo -e " \e[32mDownload httpd\e[0m"
	echo
	wget https://dlcdn.apache.org/httpd/${HTTPD_FILE}
	tar xvfz ${HTTPD_FILE}
fi

cd httpd-${HTTPD_VERSION}/srclib

if [[ ! -f "${APR_FILE}" ]]
then
	echo -e " \e[32mDownload APR\e[0m"
	echo
	wget https://dlcdn.apache.org/apr/${APR_FILE}
	tar xvfz ${APR_FILE}
	mv apr-${APR_VERSION} apr
fi

if [[ ! -f "${APRI_FILE}" ]]
then
	echo -e " \e[32mDownload APR-ICONV\e[0m"
	echo
	wget https://dlcdn.apache.org/apr/${APRI_FILE}
	tar xvfz ${APRI_FILE}
	mv apr-iconv-${APRI_VERSION} apr-iconv
fi

if [[ ! -f "${APRU_FILE}" ]]
then
	echo -e " \e[32mDownload APR-UTIL\e[0m"
	echo
	wget https://dlcdn.apache.org/apr/${APRU_FILE}
	tar xvfz ${APRU_FILE}
	mv apr-util-${APRU_VERSION} apr-util
fi


if [[ ! -f "${ZLIB_FILE}" ]]
then
	echo -e " \e[32mDownload ZLIB\e[0m"
	echo
	wget https://zlib.net/${ZLIB_FILE}
	tar xvfz ${ZLIB_FILE}
	mv zlib-${ZLIB_VERSION} zlib
fi

if [[ ! -f "${PCRE2_FILE}" ]]
then
	echo -e " \e[32mDownload PCRE2\e[0m"
	echo
	wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/${PCRE2_FILE}
	tar xvfz ${PCRE2_FILE}
	mv pcre2-${PCRE2_VERSION} pcre
fi

if [[ ! -f "${PCRE_FILE}" ]]
then
	echo -e " \e[32mDownload PCRE\e[0m"
	echo
	wget https://github.com/JBlond/pcre/archive/refs/tags/${PCRE_FILE}
	tar xvfz ${PCRE_FILE}
	mv pcre-${PCRE_VERSION} pcre1
fi

cd ..
echo -e " \e[32mBuild httpd\e[0m"
echo
./buildconf
export LD_LIBRARY_PATH=~/apache24/httpd-${HTTPD_VERSION}/srclib/apr:${LD_LIBRARY_PATH}
export LDFLAGS="-Wl,-rpath,/opt/openssl/lib64"

./configure --prefix=/opt/apache2 --enable-pie --enable-mods-shared=all --enable-so --disable-include --disable-access-compat --enable-lua --enable-luajit --enable-deflate \
	--enable-headers --enable-expires --with-curl=/opt/curl --enable-http2 --with-nghttp2=/opt/nghttp2 --enable-proxy-http2 \
	--enable-ssl=shared --with-ssl=/opt/openssl --with-openssl=/opt/openssl --enable-module=ssl \
	--with-apr-util=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/apr-util \
	--enable-mpms-shared=all --with-mpm=event --enable-rewrite --with-z=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/zlib --enable-fcgid \
	--with-jansson=/opt/jansson/ --enable-md \
	--with-included-apr --enable-nonportable-atomics=yes

patch server/main.c < ~/debian_build_apache24/info.diff
make
sudo make install

currentver="$(cat /etc/debian_version)"
requiredver="9.0"
if [[ "$(printf "$requiredver\n$currentver" | sort -V | head -n1)" == "$currentver" ]] && [[ "$currentver" != "$requiredver" ]]; then
	echo -e " \e[33mMod_brotli requires Debian 9 or newer"
else
	cd "${HOME}/apache24"
	if [[ ! -f "/opt/apache2/modules/mod_brotli.so" ]]
	then
		echo -e " \e[32mBuild brotli\e[0m"
		echo
		git clone --depth=1 --recursive https://github.com/kjdev/apache-mod-brotli.git mod_brotli
		cd mod_brotli
		./autogen.sh
		./configure --with-apxs=/opt/apache2/bin --with-apr=~/apache24/httpd-${HTTPD_VERSION}/srclib/apr
		make
		sudo install -p -m 755 -D .libs/mod_brotli.so /opt/apache2/modules/mod_brotli.so
	fi
fi

cd "${HOME}/apache24"
echo
if [[ ! -f "mod_fcgid.zip" ]]
then
	echo -e " \e[32mmod_fcgid\e[0m"
	wget https://github.com/apache/httpd-mod_fcgid/archive/refs/heads/trunk.zip
	mv trunk.zip mod_fcgid.zip
	unzip mod_fcgid.zip
	cd httpd-mod_fcgid-trunk
	echo -e " \e[32mBuild mod_fcgid\e[0m"
	APXS=/opt/apache2/bin/apxs ./configure.apxs
	make
	sudo make install
	make clean
fi

cd "${HOME}/apache24"
if [[ ! -f "0.1.0.tar.gz" ]]
then
	wget https://github.com/JBlond/mod_bikeshed/archive/refs/tags/1.0.0.tar.gz
	tar xvfz 1.0.0.tar.gz
	cd mod_bikeshed-1.0.0/
	/opt/apache2/bin/apxs -i mod_bikeshed.c
	sudo /opt/apache2/bin/apxs -i mod_bikeshed.c
fi

cd "${HOME}/apache24"
if [[ ! -f "${MOD_SEC_FILE}" ]]
then
	echo -e " \e[32mBuild mod_security\e[0m"
	cd "${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/pcre1"
	./configure
	make

	cd "${HOME}/apache24"

	echo -e " \e[32mDownload mod security\e[0m"
	wget https://github.com/SpiderLabs/ModSecurity/releases/download/v${MOD_SEC_VERSION}/${MOD_SEC_FILE}
	tar xvfz ${MOD_SEC_FILE}
	cd modsecurity-${MOD_SEC_VERSION}
	./autogen.sh
	./configure --enable-htaccess-config --prefix=/opt/apache2 --libdir=/opt/apache2/modules --with-apxs=/opt/apache2/bin/apxs \
		--with-pcre=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/pcre1 \
		--with-apr=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/apr \
		--with-apu=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/apr-util \
		--with-curl=/opt/curl
	make
	sudo make install
	sudo chmod 0755 /opt/apache2/modules/mod_security2.so
fi

cd "${HOME}/apache24"
if [[ ! -d "mod_xsendfile" ]]
then
	mkdir mod_xsendfile
	cd mod_xsendfile
	wget https://raw.githubusercontent.com/nmaier/mod_xsendfile/master/mod_xsendfile.c
	sudo /opt/apache2/bin/apxs -cia mod_xsendfile.c
fi
