include config-host.mak

specrun2006 specbuild2006 specbuild2000 specrun2000:: $(build)/Makefile
	make -C $(build) BUILDFLAGS="$(BUILDFLAGS)" $@

$(build)/Makefile: Makefile.build
	cp $< $@
