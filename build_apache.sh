cd "$HOME/apache24"

SSL_VERSION="1.0.1m"
HTTPD_VERSION="2.4.12"
APR_VERSION="1.5.1"
APRU_VERSION="1.5.4"
APRI_VERSION="1.2.1"
ZLIB_VERSION="1.2.8"
PCRE_VERSION="8.37"

SSL_FILE="openssl-$SSL_VERSION.tar.gz"
HTTPD_FILE="httpd-$HTTPD_VERSION.tar.gz"
APR_FILE="apr-$APR_VERSION.tar.gz"
APRU_FILE="apr-util-$APRU_VERSION.tar.gz"
APRI_FILE="apr-iconv-$APRI_VERSION.tar.gz"
ZLIB_FILE="zlib-$ZLIB_VERSION.tar.gz"
PCRE_FILE="pcre-$PCRE_VERSION.tar.gz"

if [ ! -f "$SSL_FILE" ]
then
	wget http://www.openssl.org/source/$SSL_FILE
	tar xfz $SSL_FILE
fi

cd openssl-$SSL_VERSION
./config --prefix=/usr zlib-dynamic --openssldir=/etc/ssl shared no-ssl2
make depend
make
sudo make install

cd "$HOME/apache24"

if [ ! -f "$HTTPD_FILE" ]
then
	wget http://artfiles.org/apache.org/httpd/$HTTPD_FILE
	tar xvfz $HTTPD_FILE
fi

cd httpd-$HTTPD_VERSION/srclib

if [ ! -f "$APR_FILE" ]
then
	wget http://www.carfab.com/apachesoftware/apr/$APR_FILE
	tar xvfz $APR_FILE
	mv apr-$APR_VERSION apr
fi

if [ ! -f "$APRU_FILE" ]
then
	wget http://mirror.netcologne.de/apache.org/apr/$APRU_FILE
	tar xvfz $APRU_FILE
	mv apr-util-$APRU_VERSION apr-util
fi

if [ ! -f "$APRI_FILE" ]
then
	wget http://mirror.netcologne.de/apache.org/apr/$APRI_FILE
	tar xvfz $APRI_FILE
	mv apr-iconv-$APRI_VERSION apr-iconv
fi

if [ ! -f "$ZLIB_FILE" ]
then
	wget http://zlib.net/$ZLIB_FILE
	tar xvfz $ZLIB_FILE
	mv zlib-$ZLIB_VERSION zlib
fi

if [ ! -f "$PCRE_FILE" ]
then
	wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$PCRE_FILE
	tar xvfz $PCRE_FILE
	mv pcre-$PCRE_VERSION pcre
fi

cd ..
./buildconf
./configure --prefix=/opt/apache2 --enable-pie --enable-mods-shared=all --enable-so --disable-include --enable-lua --enable-deflate --enable-headers --enable-expires --enable-ssl=shared --enable-mpms-shared=all --with-mpm=event --enable-rewrite --with-z=$HOME/apache24/httpd-$HTTPD_VERSION/srclib/zlib --enable-module=ssl --enable-fcgid --with-included-apr
make
sudo make install

cd "$HOME/apache24/mod_fcgid"
svn up
APXS=/opt/apache2/bin/apxs ./configure.apxs
make
sudo make install
make clean
