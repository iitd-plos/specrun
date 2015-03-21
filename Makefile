include config-host.mak

specbuild specrun:: $(build)/Makefile
	make -C $(build) BUILDFLAGS="$(BUILDFLAGS)" $@

$(build)/Makefile: Makefile.build
	cp $< $@
