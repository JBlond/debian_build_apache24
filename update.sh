#!/bin/bash
sudo rm -rf "${HOME}/apache24"
git pull
./uninstall_daemon.sh
./preparesystem.sh
./build_apache.sh
./install_as_daemon.sh
sudo rm -rf /opt/apache2/conf/httpd.conf.bak
sudo rm -rf /opt/apache2/conf/original
sudo rm -rf /opt/apache2/conf/extra
sudo /opt/apache2/bin/httpd -k stop
sleep 5
sudo /opt/apache2/bin/httpd -k start
