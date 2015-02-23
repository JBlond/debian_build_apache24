#!/bin/bash
sudo patch /opt/apache2/bin/apachectl < apachectl.diff
sudo ln -s /opt/apache2/bin/apachectl /etc/init.d/apachectl
sudo update-rc.d apachectl defaults
