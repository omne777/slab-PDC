.PHONY: clean install uninstall

obj-m    := slab_pdc.o
#kobj-objs := xxx.o
WARN     := -W -Wall -Wstrict-prototypes -Wmissing-prototypes
KDIR     := /lib/modules/$(shell uname -r)/build/
KMOD     := /lib/modules/$(shell uname -r)/kernel/
PWD      := $(shell pwd)
ccflag-y := -O2 -DMODULE -D__KERNEL__ ${WARN}

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	rm -rf *.ko *.o *.mod.* .H* .tm* .*cmd Module.symvers
