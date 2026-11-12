#!/bin/bash

set -Eeuo pipefail

mkdir -p "${HOME}/apache24"

cd "${HOME}/apache24"

LOG_FILE="build-$(date '+%Y%m%d-%H%M%S').log"
exec > >(tee -a "$LOG_FILE") 2>&1
trap 'rc=$?; printf "\nERROR: Line %s, Exit-Code %s, command: %s\n" "$LINENO" "$rc" "$BASH_COMMAND"; printf "Logfile: %s\n" "$LOG_FILE"; exit "$rc"' ERR
printf 'Build start: %s\n' "$(date '+%F %T')"
printf 'Logfile: %s\n\n' "$LOG_FILE"

SSL_VERSION="3.5.9"
HTTPD_VERSION="2.4.71"
APR_VERSION="1.7.6"
APRU_VERSION="1.6.6"
APRI_VERSION="1.2.2"
ZLIB_VERSION="1.4"
PCRE2_VERSION="10.49"
HTTP2_VERSION="1.71.0"
HTTP3_VERSION="1.19.0"
NGTCP2_VERSION="1.26.0"
JANSON_VERSION="2.15.1"
ZSTD_VERSION="1.0.3"
CURL_VERSION="8.23.0"
CURL_PATH="8_23_0"
BROTLI_VERSION="1.2.1"

SSL_FILE="openssl-${SSL_VERSION}.tar.gz"
HTTPD_FILE="httpd-${HTTPD_VERSION}.tar.gz"
APR_FILE="apr-${APR_VERSION}.tar.gz"
APRU_FILE="apr-util-${APRU_VERSION}.tar.gz"
APRI_FILE="apr-iconv-${APRI_VERSION}.tar.gz"
ZLIB_FILE="zlib-${ZLIB_VERSION}.tar.gz"
PCRE2_FILE="pcre2-${PCRE2_VERSION}.tar.gz"
HTTP2_FILE="nghttp2-${HTTP2_VERSION}.tar.gz"
HTTP3_FILE="nghttp3-${HTTP3_VERSION}.tar.gz"
NGTCP2_FILE="ngtcp2-${NGTCP2_VERSION}.tar.gz"
BROTLI_FILE="brotli-${BROTLI_VERSION}.tar.gz"

export CC="ccache gcc"
export CXX="ccache g++"

# Granular builds: a component is (re)built only when no ".installed-<name>-<version>"
# marker exists (i.e. its pinned version changed or it never finished installing).
# A rebuilt dependency forces its dependents and finally httpd to be recompiled.
needs_build() { [[ ! -f "${HOME}/apache24/.installed-$1-$2" ]]; }
mark_built() { touch "${HOME}/apache24/.installed-$1-$2"; }
fetch() { [[ -f "$2" ]] || wget -O "$2" "$1"; [[ -d "$3" ]] || tar xfz "$2"; }
SSL_CHANGED=0
HTTP3_CHANGED=0
JANSON_CHANGED=0
LIBS_CHANGED=0

if needs_build openssl "${SSL_VERSION}"
then
	SSL_CHANGED=1
	LIBS_CHANGED=1
	echo -e " \e[32mOpenSSL\e[0m"
	echo
	fetch https://github.com/openssl/openssl/releases/download/openssl-${SSL_VERSION}/${SSL_FILE} ${SSL_FILE} openssl-${SSL_VERSION}
	cd openssl-${SSL_VERSION}
	./config --prefix=/opt/openssl --openssldir=/opt/openssl no-ssl3 no-ec2m no-rc5 no-idea no-camellia no-weak-ssl-ciphers threads no-psk zlib-dynamic enable-ec_nistp_64_gcc_128 no-tests
	make -j2
	sudo make install_sw
	sudo make install_ssldirs
	mark_built openssl "${SSL_VERSION}"
else
	echo -e "✅ \e[32mOpenSSL\e[0m"
fi

cd "${HOME}/apache24"

if needs_build jansson "${JANSON_VERSION}"
then
	LIBS_CHANGED=1
	JANSON_CHANGED=1
	echo -e " \e[32mJANSON\e[0m"
	fetch https://github.com/akheron/jansson/releases/download/v${JANSON_VERSION}/jansson-${JANSON_VERSION}.tar.gz jansson-${JANSON_VERSION}.tar.gz jansson-${JANSON_VERSION}
	cd jansson-${JANSON_VERSION}
	./configure --prefix=/opt/jansson
	make -j2
	sudo make install
	mark_built jansson "${JANSON_VERSION}"
else
	echo -e "✅ \e[32mjansson\e[0m"
fi

if needs_build nghttp3 "${HTTP3_VERSION}"
then
	HTTP3_CHANGED=1
	LIBS_CHANGED=1
	echo -e " \e[32mnghttp3\e[0m"
	echo
	fetch https://github.com/ngtcp2/nghttp3/releases/download/v${HTTP3_VERSION}/${HTTP3_FILE} ${HTTP3_FILE} nghttp3-${HTTP3_VERSION}
	cd nghttp3-${HTTP3_VERSION}
	export LDFLAGS="-Wl,-rpath,/opt/openssl/lib64"
	./configure --prefix=/opt/nghttp3
	make -j2
	sudo make install
	mark_built nghttp3 "${HTTP3_VERSION}"
else
	echo -e "✅ \e[32nghttp3\e[0m"
fi

cd "${HOME}/apache24"

if (( SSL_CHANGED || HTTP3_CHANGED || JANSON_CHANGED )) || needs_build nghttp2 "${HTTP2_VERSION}"
then
	LIBS_CHANGED=1
	echo -e " \e[32mnghttp2\e[0m"
	echo
	fetch https://github.com/nghttp2/nghttp2/releases/download/v${HTTP2_VERSION}/${HTTP2_FILE} ${HTTP2_FILE} nghttp2-${HTTP2_VERSION}
	cd nghttp2-${HTTP2_VERSION}
	export PKG_CONFIG_PATH="/opt/openssl/lib64/pkgconfig"
	export LDFLAGS="-Wl,-rpath,/opt/openssl/lib64"
	./configure --prefix=/opt/nghttp2 --with-jansson=/opt/jansson  --enable-http3=/opt/nghttp3
	make -j2
	sudo make install
	mark_built nghttp2 "${HTTP2_VERSION}"
else
	echo -e "✅ \e[32mnghttp2\e[0m"
fi

cd "${HOME}/apache24"

if (( SSL_CHANGED || HTTP3_CHANGED )) || needs_build ngtcp2 "${NGTCP2_VERSION}"
then
	LIBS_CHANGED=1
	echo -e " \e[32ngtcp2\e[0m"
	echo
	fetch https://github.com/ngtcp2/ngtcp2/releases/download/v${NGTCP2_VERSION}/${NGTCP2_FILE} ${NGTCP2_FILE} ngtcp2-${NGTCP2_VERSION}
	cd ngtcp2-${NGTCP2_VERSION}
	export PKG_CONFIG_PATH="/opt/openssl/lib64/pkgconfig:/opt/nghttp3/lib/pkgconfig"
	./configure --prefix=/opt/ngtcp2 --with-openssl --with-nghttp3=/opt/nghttp3
	make -j2
	sudo make install
	mark_built ngtcp2 "${NGTCP2_VERSION}"
else
	echo -e "✅ \e[32ngtcp2\e[0m"
fi

cd "${HOME}/apache24"

if (( LIBS_CHANGED )) || needs_build curl "${CURL_VERSION}"
then
	LIBS_CHANGED=1
	echo -e " \e[32mDownload CURL\e[0m"
	fetch https://github.com/curl/curl/releases/download/curl-${CURL_PATH}/curl-${CURL_VERSION}.tar.gz curl-${CURL_VERSION}.tar.gz curl-${CURL_VERSION}
	cd curl-${CURL_VERSION}
	./configure --prefix=/opt/curl --enable-libcurl-option --enable-optimize --disable-manual --disable-debug --with-nghttp2=/opt/nghttp2 --with-nghttp3=/opt/nghttp3 --with-openssl=/opt/openssl --with-ngtcp2=/opt/ngtcp2
	make -j2
	sudo make install
	mark_built curl "${CURL_VERSION}"
else
	echo -e "✅ \e[32mCURL\e[0m"
fi

cd "${HOME}/apache24"

if needs_build brotli "${BROTLI_VERSION}"
then
	LIBS_CHANGED=1
	echo -e " \e[32mbrotli\e[0m"
	echo
	fetch https://github.com/google/brotli/archive/refs/tags/v${BROTLI_VERSION}.tar.gz ${BROTLI_FILE} brotli-${BROTLI_VERSION}
	cd brotli-${BROTLI_VERSION}
	mkdir -p out
	cd out
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/brotli -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_RPATH=/opt/brotli/lib ..
	cmake --build . --config Release -j2
	sudo cmake --install . --config Release
	mark_built brotli "${BROTLI_VERSION}"
else
	echo -e "✅ \e[32mbrotli\e[0m"
fi

cd "${HOME}/apache24"

HTTPD_CHANGED=0
if needs_build httpd "${HTTPD_VERSION}"
then
	HTTPD_CHANGED=1
	echo -e " \e[32mDownload httpd\e[0m"
	echo
	fetch https://dlcdn.apache.org/httpd/${HTTPD_FILE} ${HTTPD_FILE} httpd-${HTTPD_VERSION}
else
	echo -e "✅ \e[32mhttpd\e[0m"
fi

cd httpd-${HTTPD_VERSION}/srclib

# Replace a bundled srclib component when its pinned version changed.
srclib_update() {
	local label="$1" file="$2" url="$3" dir="$4" extracted="$5"
	if [[ ! -f "${file}" || ! -d "${dir}" ]]
	then
		HTTPD_CHANGED=1
		echo -e " \e[32mDownload ${label}\e[0m"
		echo
		rm -rf "${dir}"
		[[ -f "${file}" ]] || wget -O "${file}" "${url}"
		tar xfz "${file}"
		mv "${extracted}" "${dir}"
		return 0
	fi
	echo -e "✅ \e[32m${label}\e[0m"
}

srclib_update APR "${APR_FILE}" https://dlcdn.apache.org/apr/${APR_FILE} apr apr-${APR_VERSION}
srclib_update APR-ICONV "${APRI_FILE}" https://dlcdn.apache.org/apr/${APRI_FILE} apr-iconv apr-iconv-${APRI_VERSION}
srclib_update APR-UTIL "${APRU_FILE}" https://dlcdn.apache.org/apr/${APRU_FILE} apr-util apr-util-${APRU_VERSION}
srclib_update ZLIB "${ZLIB_FILE}" https://zlib.net/${ZLIB_FILE} zlib zlib-${ZLIB_VERSION}

if [[ ! -f "${PCRE2_FILE}" || ! -d pcre ]]
then
	HTTPD_CHANGED=1
	echo -e " \e[32mDownload PCRE2\e[0m"
	echo
	rm -rf pcre
	[[ -f "${PCRE2_FILE}" ]] || wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/${PCRE2_FILE}
	tar xfz ${PCRE2_FILE}
	mv pcre2-${PCRE2_VERSION} pcre
	cd pcre
	./configure
	cd ..
else
	echo -e "✅ \e[32mPCRE2\e[0m"
fi

cd ..
if (( HTTPD_CHANGED || LIBS_CHANGED ))
then
	HTTPD_CHANGED=1
	echo -e " \e[32mBuild httpd\e[0m"
	echo
	[[ ! -f Makefile ]] || make distclean || true
	./buildconf
	export LD_LIBRARY_PATH=~/apache24/httpd-${HTTPD_VERSION}/srclib/apr:${LD_LIBRARY_PATH:-}
	export LDFLAGS="-Wl,-rpath,/opt/openssl/lib64 -Wl,-rpath,/opt/brotli/lib"

	./configure --prefix=/opt/apache2 --enable-pie --enable-mods-shared=all --enable-so --disable-include --disable-access-compat  --enable-lua --enable-deflate \
		--enable-headers --enable-expires --with-curl=/opt/curl --enable-http2 --with-nghttp2=/opt/nghttp2 --enable-proxy-http2 --enable-brotli --with-brotli=/opt/brotli \
		--enable-ssl=shared --with-ssl=/opt/openssl --with-openssl=/opt/openssl --enable-module=ssl \
		--with-apr-util=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/apr-util --with-pcre=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/pcre \
		--enable-mpms-shared=all --with-mpm=event --enable-rewrite --with-z=${HOME}/apache24/httpd-${HTTPD_VERSION}/srclib/zlib --enable-fcgid \
		--with-jansson=/opt/jansson/ --enable-md \
		--with-included-apr --enable-nonportable-atomics=yes

	patch -R -s -f --dry-run server/main.c < ~/debian_build_apache24/info.diff >/dev/null 2>&1 || patch server/main.c < ~/debian_build_apache24/info.diff
	make -j2
	sudo make install
	mark_built httpd "${HTTPD_VERSION}"
else
	echo -e "✅ \e[32mhttpd is up to date, nothing to compile\e[0m"
fi

# Third-party modules are built against httpd, so they are rebuilt whenever httpd was.
cd "${HOME}/apache24"
echo
if (( HTTPD_CHANGED )) || [[ ! -f "mod_fcgid.zip" ]]
then
	echo -e " \e[32mmod_fcgid\e[0m"
	rm -rf httpd-mod_fcgid-trunk
	[[ -f mod_fcgid.zip ]] || { wget https://github.com/apache/httpd-mod_fcgid/archive/refs/heads/trunk.zip; mv trunk.zip mod_fcgid.zip; }
	unzip -q mod_fcgid.zip
	cd httpd-mod_fcgid-trunk
	echo -e " \e[32mBuild mod_fcgid\e[0m"
	APXS=/opt/apache2/bin/apxs ./configure.apxs
	make -j2
	sudo make install
	make clean
else
	echo -e "✅ \e[32mmod_fcgid\e[0m"
fi

cd "${HOME}/apache24"
if (( HTTPD_CHANGED )) || [[ ! -f "1.0.1.tar.gz" ]]
then
	[[ -f 1.0.1.tar.gz ]] || wget https://github.com/JBlond/mod_bikeshed/archive/refs/tags/1.0.1.tar.gz
	tar xfz 1.0.1.tar.gz
	cd mod_bikeshed-1.0.1/
	sudo /opt/apache2/bin/apxs -cia mod_bikeshed.c
else
	echo -e "✅ \e[32mmod_mikeshed\e[0m"
fi

cd "${HOME}/apache24"
if (( HTTPD_CHANGED )) || [[ ! -d "mod_xsendfile" ]]
then
	echo -e " \e[32mBuild mod_xsendfile\e[0m"
	mkdir -p mod_xsendfile
	cd mod_xsendfile
	wget -O mod_xsendfile.c https://raw.githubusercontent.com/JBlond/mod_xsendfile/master/mod_xsendfile.c
	sudo /opt/apache2/bin/apxs -ci mod_xsendfile.c
else
	echo -e "✅ \e[32mmod_xsendfile\e[0m"
fi

cd "${HOME}/apache24"
if (( HTTPD_CHANGED )) || [[ ! -d "mod_zstd" ]]
then
	echo -e " \e[32mBuild mod_zstd\e[0m"
	[[ -f ${ZSTD_VERSION}.tar.gz ]] || wget https://github.com/nono303/mod_zstd/archive/refs/tags/${ZSTD_VERSION}.tar.gz
	rm -rf mod_zstd
	tar xfz ${ZSTD_VERSION}.tar.gz
	mv mod_zstd-${ZSTD_VERSION} mod_zstd
	cd mod_zstd
	sudo /opt/apache2/bin/apxs -cia mod_zstd.c -lzstd
else
	echo -e "✅ \e[32mmod_zstd\e[0m"
fi

printf '\nBuild finished: %s\n' "$(date '+%F %T')"
if [[ -n "${LOG_FILE:-}" && -f "$LOG_FILE" ]]; then
	printf 'Logfile: %s\n\n' "$LOG_FILE"
	cat "$LOG_FILE"
fi
