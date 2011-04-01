
TOPDIR := ..

LIBNAME := zmanim
LIBSRCS := zmanim.tcl cache.tcl pkgIndex.tcl

LIBVDIR = $(VFSLIB)/$(LIBNAME)
LIBOBJS = $(addprefix $(LIBVDIR)/,$(LIBSRCS))

include $(TOPDIR)/common.mk

ifneq ($(MAKELEVEL),0)
    all: $(LIBOBJS)

    $(LIBVDIR): $(VFSLIB)
	$(MKDIR) $@

    $(LIBOBJS): $(LIBVDIR) $(LIBSRCS)
	$(CP) $(notdir $@) $(LIBVDIR)

    vfsclean:
	-$(RM) $(LIBOBJS)
	-$(RMDIR) $(LIBVDIR)
endif
