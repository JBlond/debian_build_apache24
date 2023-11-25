.PHONY: help # Shows this list
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1	\2/' | expand -t20

.PHONY: prepare # prepares the system for building
prepare:
	@./preparesystem.sh

.PHONY: build # build from sources, but no daemon installation
build:
	@echo "Build"
	@./build_apache.sh

.PHONY: clean # clear build artifacts
clean:
	@./clean.sh

.PHONY: purge # Removes everything from this on the system.
purge:
	@./purge.sh

.PHONY: install # install as daemon
install:
	@echo "Install as daemon"
	@./install_as_daemon.sh

.PHONY: uninstall # uninstall daemon
uninstall:
	@echo "Uninstall daemon"
	@./uninstall_daemon.sh

.PHONY: update # update from the sources and install as daemon
update:
	@./update.sh

.PHONY: graceful # graceful apache restart
graceful:
	@sudo /opt/apache2/bin/httpd -k graceful

.PHONY: stop # stops apache
stop:
	@sudo /opt/apache2/bin/httpd -k stop

.PHONY: start # starts apache
start:
	@sudo /opt/apache2/bin/httpd -k start

.PHONY: checksyntax # apache config syntax check 
checksyntax:
	@sudo /opt/apache2/bin/httpd -S
