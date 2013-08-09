
TOPDIR := ..
VERSION := $(shell cat VERSION)

LIBNAME := zmanim
LIBSRCS := zmanim.tcl \
	   cache.tcl

LIBVDIR = $(VFSLIB)/$(LIBNAME)
LIBOBJS = $(addprefix $(LIBVDIR)/,$(LIBSRCS) pkgIndex.tcl)

include $(TOPDIR)/common.mk

ifneq ($(MAKELEVEL),0)
    all: $(LIBOBJS)

    $(LIBVDIR): | $(VFSLIB)
	$(MKDIR) $@

    $(LIBVDIR)/pkgIndex.tcl: pkgIndex.tcl.in VERSION | $(LIBVDIR)
	$(SED) 's%@VERSION@%$(VERSION)%' $< > $@

    $(filter-out %pkgIndex.tcl, $(LIBOBJS)): $(LIBVDIR)/% : % | $(LIBVDIR)
	$(CP) $< $@

    vfsclean:
	-$(RM) $(LIBOBJS)
	-$(RMDIR) $(LIBVDIR)
endif
