include config-host.mak

llvm-build specrun2006 specbuild2006 specrebuild2006 specbuild2000 specrebuild2000 specrun2000 compcert:: $(build)/Makefile
	make -C $(build) BUILDFLAGS="$(BUILDFLAGS)" $@

$(build)/Makefile: Makefile.build
	cp $< $@

kill::
	killall -9 runspec
