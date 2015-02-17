cd $HOME/apache24
wget http://www.openssl.org/source/openssl-1.0.2.tar.gz
tar xfz openssl-1.0.2.tar.gz
cd openssl-1.0.2
./config --prefix=/usr zlib-dynamic --openssldir=/etc/ssl shared no-ssl2
make depend
make
sudo make install
wget http://artfiles.org/apache.org/httpd/httpd-2.4.12.tar.gz
tar xvfz httpd-2.4.12.tar.gz
cd httpd-2.4.12/srclib
wget http://www.carfab.com/apachesoftware/apr/apr-1.5.1.tar.gz
tar xvfz apr-1.5.1.tar.gz
mv apr-1.5.1 apr
wget http://mirror.netcologne.de/apache.org/apr/apr-util-1.5.4.tar.gz
tar xvfz apr-util-1.5.4.tar.gz
mv apr-util-1.5.4 apr-util 
wget http://mirror.netcologne.de/apache.org/apr/apr-iconv-1.2.1.tar.gz
tar xvfz apr-iconv-1.2.1.tar.gz
mv apr-iconv-1.2.1 apr-iconv
wget http://zlib.net/zlib-1.2.8.tar.gz
tar xvfz zlib-1.2.8.tar.gz
mv zlib-1.2.8 zlib
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.gz
tar xvfz pcre-8.36.tar.gz
mv pcre-8.36 pcre
cd ..
./buildconf
./configure --prefix=/opt/apache2 --enable-pie --enable-mods-shared=all --enable-so --disable-include --enable-lua --enable-deflate --enable-headers --enable-expires --enable-ssl=shared --enable-mpms-shared=all --with-mpm=event --enable-rewrite --with-z=$HOME/apache24/httpd-2.4.10/srclib/zlib --enable-module=ssl --enable-fcgid --with-included-apr
make
cd mod_fcgid
svn up
APXS=/opt/apache2/bin/apxs ./configure.apxs
make
sudo make install
make clean