help:
	@echo " make prepare       prepares the system for building"
	@echo ""
	@echo " make build         build from sources, but no daemon installation"
	@echo ""
	@echo make clean           clear build artifacts
	@echo ""
	@echo make purge           Removes everything from this on the system.
	@echo ""
	@echo " make install       install as daemon"
	@echo ""
	@echo " make uninstall     uninstall daemon"
	@echo ""
	@echo " make install       run the deploy script"
	@echo ""
	@echo " make update        update from the sources and install as daemon"
	@echo ""
	@echo ""
	@echo " make graceful      graceful apache restart"
	@echo ""
	@echo " make stop          stops apache"
	@echo ""
	@echo " make start         starts apache"
	@echo ""
	@echo " make checksyntax   apache config syntax check"
	@echo ""

prepare:
	@./preparesystem.sh

build:
	@echo "Build"
	@./build_apache.sh

clean:
	@./clean.sh

install:
	@echo "Install as daemon"
	@./install_as_daemon.sh

uninstall:
	@echo "Uninstall daemon"
	@./uninstall_daemon.sh

update:
	@./update.sh

graceful:
	@sudo /opt/apache2/bin/httpd -k graceful

stop:
	@sudo /opt/apache2/bin/httpd -k stop

start:
	@sudo /opt/apache2/bin/httpd -k start

checksyntax:
	@sudo /opt/apache2/bin/httpd -S
