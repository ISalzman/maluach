
TOPDIR := ..

LIBNAME := Zmanim
LIBMAIN := Zmanim.tcl
LIBSRCS := $(LIBMAIN) pkgIndex.tcl

LIBVDIR = $(VFSLIB)/$(LIBNAME)
LIBOBJS = $(addprefix $(LIBVDIR)/,$(LIBSRCS))

include $(TOPDIR)/common.mk

ifneq ($(MAKELEVEL),0)
    all: $(LIBOBJS) $(MSGOBJS)

    $(LIBVDIR): $(VFSLIB)
	    $(MKDIR) $@

    $(LIBOBJS): $(LIBVDIR) $(LIBSRCS)
	    $(CP) $(notdir $@) $(LIBVDIR)

    vfsclean:
	-$(RM) $(LIBOBJS)
	-$(RMDIR) $(LIBVDIR)
endif

