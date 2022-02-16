#!/bin/bash

# debian
which apt  > /dev/null 2>&1 && {
	sudo update-rc.d -f apachectl remove
	sudo patch -R /opt/apache2/bin/apachectl < apachectl.diff
	sudo rm /etc/init.d/apachectl
}

# opensuse
which zypper  > /dev/null 2>&1 && {
	sudo chkconfig -s apachectl off
	sudo patch -R /opt/apache2/bin/apachectl < apachectl_opensuse.diff
	sudo rm /etc/init.d/apachectl
}
