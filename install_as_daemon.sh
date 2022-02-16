#!/bin/bash

# debian
which apt  > /dev/null 2>&1 && {
	sudo patch /opt/apache2/bin/apachectl < apachectl.diff
	sudo ln -s /opt/apache2/bin/apachectl /etc/init.d/apachectl
	sudo update-rc.d apachectl defaults
}

# opensuse
which zypper  > /dev/null 2>&1 && {
	sudo patch /opt/apache2/bin/apachectl < apachectl_opensuse.diff
	sudo ln -s /opt/apache2/bin/apachectl /etc/init.d/apachectl
	sudo chkconfig -s apachectl on
}
