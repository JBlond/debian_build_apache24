mkdir $HOME/apache24
cd $HOME/apache24
sudo aptitude install build-essential
sudo aptitude install zlib1g-dev
sudo aptitude install liblua5.1-dev
sudo aptitude install autoconf
sudo aptitude install libtool
sudo aptitude install libpcre3-dev
sudo aptitude install subversion
svn checkout http://svn.apache.org/repos/asf/httpd/mod_fcgid/trunk mod_fcgid
