MODULE_NAME := slab_pdc

obj-m    := slab_pdc.o
#kobj-objs := xxx.o
#MODULE_SOURCES := slab_pdc.c

WARN     := -W -Wall -Wstrict-prototypes -Wmissing-prototypes
ccflag-y := -O2 -DMODULE -D__KERNEL__ ${WARN}
#PWD      := $(shell pwd)
#EXTRA_CFLAGS += -I$(src)

KBUILD_DIR=$(shell sh ./scripts/find_kernel_src.sh)
UNAME=$(shell uname -r)
PWD := $(shell pwd)

all: $(MODULE_NAME).ko

$(MODULE_NAME).ko: $(MODULE_SOURCES)
	@ $(MAKE) -C $(KBUILD_DIR)/ M=$(PWD) modules

install_files: $(MODULE_NAME).ko
	@ echo Installing $(MODULE_NAME).ko
	@ mkdir -p $(DESTDIR)/lib/modules/$(UNAME)/extra/slab_pdc
	@ mkdir -p $(DESTDIR)/etc/modprobe.d
	@ mkdir -p $(DESTDIR)/etc/sysctl.d
	@ mkdir -p $(KBUILD_DIR)/include/slab_pdc # Copy exported headers
	@ install -m 644 conf/slab_pdc.modprobe.conf $(DESTDIR)/etc/modprobe.d/slab_pdc.conf
	@ install -m 644 conf/slab_pdc.sysctl $(DESTDIR)/etc/sysctl.d/slab_pdc.conf
	@ [ -d $(DESTDIR)/etc/sysconfig/modules ] && install -m 755 conf/slab_pdc.sysconfig $(DESTDIR)/etc/sysconfig/modules/slab_pdc.modules || :
	@ install -m 644 slab_pdc.h $(KBUILD_DIR)/include/slab_pdc/slab_pdc.h
	@ install -m 755 $(MODULE_NAME).ko $(DESTDIR)/lib/modules/$(UNAME)/extra/slab_pdc/.
	@ install -m 755 Module.symvers $(DESTDIR)/lib/modules/$(UNAME)/extra/slab_pdc/.
	@ /sbin/depmod

install: install_files
	@ rmmod $(MODULE_NAME) || :
	@ modprobe $(MODULE_NAME)

tarball:
	@ echo Creating tarball
	sh ./scripts/make_tarball.sh

clean:
	@ echo Cleanup
	@ $(MAKE) -C $(KBUILD_DIR) M=$(PWD) clean
	@ rm -f Module* $(TESTS) tests.out

.PHONY: all clean install install_files tarball
