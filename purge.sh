#!/bin/bash
read -r -p "Are you sure to purge everything from this on your system. Including Your config. Maybe also your document root.? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
	sudo /opt/apache2/bin/httpd -k stop
	./uninstall_daemon.sh
	./clean.sh
	sudo rm -rf /opt/apache2/
	sudo rm -rf /opt/curl
	sudo rm -rf /opt/jansson
	sudo rm -rf /opt/nghttp2
	sudo rm -rf /opt/openssl
fi
