.PHONY: all clean install install_files tarball

# Installation and/or DKMS environment
# Exported heqaders SHALL be separated by a pipe '|'
MOD_NAME       = slab_pdc
PRJ_NAME       = slab-pdc
MAJOR          = `cat slab_pdc_version.h |grep -P "\s+SLAB_PDC_MAJOR\s+" |perl -pe "s/.*SLAB_PDC_MAJOR ([0-9])/\1/g"`
MINOR          = `cat slab_pdc_version.h |grep -P "\s+SLAB_PDC_MINOR\s+" |perl -pe "s/.*SLAB_PDC_MINOR ([0-9])/\1/g"`
VERSION        = $(MAJOR).$(MINOR)
PRJ_FOLDER     = $(PRJ_NAME)-$(VERSION)
TMP_DIRECTORY  = /usr/src/$(PRJ_FOLDER)
BUILD_FILES    = slab_pdc.c slab_pdc.h slab_pdc_version.h Makefile LICENSE README.md
BUILD_SCRIPTS  = dkms.conf dkms.post_build dkms.post_install dkms.post_remove $(MOD_NAME).modprobe.conf $(MOD_NAME).sysconfig
EXP_HEADERS    = slab_pdc.h

WARN          := -W -Wall -Wstrict-prototypes -Wmissing-prototypes
KDIR          := /lib/modules/$(shell uname -r)/build/
PWD           := $(shell pwd)

obj-m         := slab_pdc.o
ccflag-y      := -O2 -DMODULE -D__KERNEL__ ${WARN}

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	@rm -rf *.ko *.o *.mod.* .H* .tm* .*cmd Module.symvers modules.order

dkms_clean_env:
	@echo "Cleanup DKMS environment"
	@rm -rf $(BUILD_SCRIPTS)

dist_clean: clean dkms_clean_env

dkms_make_env: dkms_clean_env
	@echo "Create DKMS environment"
	@$(foreach ml, $(BUILD_SCRIPTS), touch $(ml) ; chmod 755 $(ml) ;)
	@echo "install slab_pdc { modprobe --ignore-install slab_pdc; } ; sysctl -p /etc/sysctl.d/slab_pdc.conf &> /dev/null ; true" > $(MOD_NAME).modprobe.conf
	@echo "#!/bin/bash" > $(MOD_NAME).sysconfig
	@echo "exec modprobe slab_pdc" >> $(MOD_NAME).sysconfig
	@echo "PACKAGE_NAME=\"$(PRJ_NAME)\"" > dkms.conf
	@echo "PACKAGE_VERSION="\"$(VERSION)\" >> dkms.conf
	@echo "CLEAN[0]=\"make clean\"" >> dkms.conf
	@echo "MAKE[0]=\"make\"" >> dkms.conf
	@echo "BUILT_MODULE_NAME[0]="\"$(MOD_NAME)\" >> dkms.conf
	@echo "BUILT_MODULE_LOCATION[0]=./" >> dkms.conf
	@echo "DEST_MODULE_LOCATION[0]="\"/extra\" >> dkms.conf
	@echo "STRIP[0]=no" >> dkms.conf
	@echo "POST_INSTALL=dkms.post_install" >> dkms.conf
	@echo "AUTOINSTALL=\"yes\"" >> dkms.conf
	@echo "REMAKE_INITRD=no" >> dkms.conf
	@echo "POST_BUILD=\"dkms.post_build $(MOD_NAME) \$$dkms_tree/\$$module/\$$module_version/build/Module.symvers\"" >> dkms.conf
	@echo "POST_REMOVE=\"dkms.post_remove \$${kernelver}\"" >> dkms.conf
	@echo "#!/bin/bash" > dkms.post_build
	@echo "cp \$$2 ./\$$1-Module.symvers" >> dkms.post_build
	@echo "#!/bin/bash" > dkms.post_install
	@echo "mkdir -p /lib/modules/\$$kernelver/build/include/$(MOD_NAME)" >> dkms.post_install
	@echo "install -m 644 $(EXP_HEADERS) /lib/modules/\$$kernelver/build/include/$(MOD_NAME)/." >> dkms.post_install
	@echo "echo \"Installing headers: /lib/modules/\$$kernelver/build/include/$(MOD_NAME)\"" >> dkms.post_install
	@echo "install -m 644 $(MOD_NAME).modprobe.conf /etc/modprobe.d/$(MOD_NAME).conf" >> dkms.post_install
	@echo "[ -d /etc/sysconfig/modules ] && install -m 755 $(MOD_NAME).sysconfig /etc/sysconfig/modules/$(MOD_NAME).modules || :" >> dkms.post_install
	@echo "#!/bin/bash" > dkms.post_remove
	@echo "rm -rf /lib/modules/\$$1/build/include/$(MOD_NAME)" >> dkms.post_remove
	@echo "rm -rf /etc/modprobe.d/$(MOD_NAME).conf" >> dkms.post_remove
	@echo "rm -rf /etc/sysconfig/modules/$(MOD_NAME).modules" >> dkms.post_remove
	@echo "rm -rf /etc/sysctl.d/$(MOD_NAME).conf" >> dkms.post_remove

dkms_build: dkms_make_env
	@rm -rf /var/lib/dkms/$(PRJ_NAME)
	@rm -rf $(TMP_DIRECTORY)
	@mkdir -p $(TMP_DIRECTORY)
	@$(foreach ml, $(BUILD_FILES), cp $(ml) $(TMP_DIRECTORY) ;)
	@$(foreach ml, $(BUILD_SCRIPTS), cp $(ml) $(TMP_DIRECTORY) ;)
	@cd $(TMP_DIRECTORY)
	@dkms add -m $(PRJ_NAME) -v $(VERSION)
	@dkms build -m $(PRJ_NAME) -v $(VERSION)
	@dkms mkdsc -m $(PRJ_NAME) -v $(VERSION) --source-only
	@dkms mkdeb -m $(PRJ_NAME) -v $(VERSION) --source-only
	@cd -
	@cp "/var/lib/dkms/"$(PRJ_NAME)"/"$(VERSION)"/deb/"$(PRJ_NAME)"-dkms_"$(VERSION)"_all.deb" .
	@rm -rf /var/lib/dkms/$(PRJ_NAME)
	@rm -rf $(TMP_DIRECTORY)

dkms_deb:
	@make dkms_build
	@make dist_clean

install_files: $(MOD_NAME).ko
	@mkdir -p $(DESTDIR)/lib/modules/$(shell uname -r)/extra/
	@mkdir -p $(DESTDIR)/etc/modprobe.d
	@mkdir -p $(DESTDIR)/etc/sysctl.d
	@mkdir -p /usr/src/$(PRJ_FOLDER)
	@ install -m 644 conf/slab_pdc.modprobe.conf $(DESTDIR)/etc/modprobe.d/slab_pdc.conf
	@ install -m 644 conf/slab_pdc.sysctl $(DESTDIR)/etc/sysctl.d/slab_pdc.conf
	@ [ -d $(DESTDIR)/etc/sysconfig/modules ] && install -m 755 conf/slab_pdc.sysconfig $(DESTDIR)/etc/sysconfig/modules/slab_pdc.modules || :
	@ install -m 644 slab_pdc.h /usr/src/$(PRJ_FOLDER)/slab_pdc.h
	@ install -m 755 $(MOD_NAME).ko $(DESTDIR)/lib/modules/$(shell uname -r)/extra/.
	@ install -m 755 Module.symvers $(DESTDIR)/lib/modules/$(shell uname -r)/extra/slab_pdc.symvers
	@ /sbin/depmod

install: install_files
	@ rmmod $(MOD_NAME) || :
	@ modprobe $(MOD_NAME)
