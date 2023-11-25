.DEFAULT_GOAL := help

.PHONY: help 
##help: Shows this list
help:
	@grep -E '\#\#[a-zA-Z\.\-]+:.*$$' $(MAKEFILE_LIST) \
		| tr -d '##' \
		| awk 'BEGIN {FS = ": "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' \

.PHONY: prepare
##prepare: prepares the system for building
prepare:
	@./preparesystem.sh

.PHONY: build
##build: build from sources, but no daemon installation
build:
	@echo "Build"
	@./build_apache.sh

.PHONY: clean # clear build artifacts
##clean: clear build artifacts
clean:
	@./clean.sh

.PHONY: purge
##purge: Removes everything from this on the system.
purge:
	@./purge.sh

.PHONY: install
##install: install as daemon
install:
	@echo "Install as daemon"
	@./install_as_daemon.sh

.PHONY: uninstall
##uninstall: uninstall daemon
uninstall:
	@echo "Uninstall daemon"
	@./uninstall_daemon.sh

.PHONY: update
##update: update from the sources and install as daemon
update:
	@./update.sh

.PHONY: graceful
##graceful: graceful apache restart
graceful:
	@sudo /opt/apache2/bin/httpd -k graceful

.PHONY: stop
##stop: stops apache
stop:
	@sudo /opt/apache2/bin/httpd -k stop

.PHONY: start
##start: starts apache
start:
	@sudo /opt/apache2/bin/httpd -k start

.PHONY: checksyntax
##checksyntax: apache config syntax check 
checksyntax:
	@sudo /opt/apache2/bin/httpd -S
