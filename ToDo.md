# ToDo:

- Option Installation as daemon
	Add below #!/bin/sh in apachectl
```
	### BEGIN INIT INFO
	# Provides:          apachectl
	# Required-Start:    $local_fs
	# Required-Stop:     $local_fs
	# Default-Start:     2 3 4 5
	# Default-Stop:      0 1 6
	# Short-Description: apachectl
	### END INIT INFO
```

```
	sudo ln -s /opt/apache2/bin/apachectl /etc/init.d/apachectl
	sudo update-rc.d apachectl defaults
```

- Option to uninstall

```
	sudo update-rc.d -f apachectl remove
```
