.PHONY: install

DIR=$(shell pwd)

install:
	su - ${LOGNAME} bash -c "ln -sf  $(DIR)/bash_aliases /home/$(LOGNAME)/.bash_aliases"
	@echo "Installation OK"
