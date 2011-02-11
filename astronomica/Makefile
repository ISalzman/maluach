
TOPDIR := ..

LIBNAME := Astro
LIBMAIN := Astro.tcl
LIBSRCS := $(LIBMAIN) pkgIndex.tcl

CALCSDIR := calcs
CALCSRCS := $(CALCSDIR)/Meeus.calc $(CALCSDIR)/Schlyter.calc $(CALCSDIR)/USNO.calc $(CALCSDIR)/Zombeck.calc

LIBVDIR = $(VFSLIB)/$(LIBNAME)
CALCVDIR = $(LIBVDIR)/$(CALCSDIR)
LIBOBJS = $(addprefix $(LIBVDIR)/,$(LIBSRCS))
CALCOBJS = $(addprefix $(CALCVDIR)/,$(notdir $(CALCSRCS)))

include $(TOPDIR)/common.mk

ifneq ($(MAKELEVEL),0)
    all: $(LIBOBJS) $(CALCOBJS)

    $(LIBVDIR): $(VFSLIB)
	    $(MKDIR) $@

    $(CALCVDIR): $(LIBVDIR)
	    $(MKDIR) $@

    $(LIBOBJS): $(LIBVDIR) $(LIBSRCS)
	    $(CP) $(notdir $@) $(LIBVDIR)

    $(CALCOBJS): $(CALCVDIR) $(CALCSRCS)
	    $(CP) $(CALCSDIR)/$(notdir $@) $(CALCVDIR)

    vfsclean:
	-$(RM) $(LIBOBJS)
	-$(RM) $(CALCOBJS)
	-$(RMDIR) $(CALCVDIR)
	-$(RMDIR) $(LIBVDIR)
endif

