include config-host.mak

specbuild:: $(build)/Makefile
	make -C $(build) BUILDFLAGS="$(BUILDFLAGS)" $@

$(build)/Makefile: Makefile.build
	cp $< $@
