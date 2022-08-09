#!/bin/bash
sudo update-rc.d -f apachectl remove
sudo patch -R /opt/apache2/bin/apachectl < apachectl.diff
sudo rm /etc/init.d/apachectl
