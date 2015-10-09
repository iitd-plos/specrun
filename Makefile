include config-host.mak

specbuild2000 specrun2000:: $(build)/Makefile
	make -C $(build) BUILDFLAGS="$(BUILDFLAGS)" $@

$(build)/Makefile: Makefile.build
	cp $< $@
