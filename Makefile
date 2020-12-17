INSTALL_PATH := /usr/bin

install:
	cp tdo.js $(INSTALL_PATH)/tdo
	chmod +x $(INSTALL_PATH)/tdo

uninstall:
	rm $(INSTALL_PATH)/tdo
