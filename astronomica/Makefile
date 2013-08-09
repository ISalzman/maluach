
TOPDIR := ..
VERSION := $(shell cat VERSION)

LIBNAME := astronomica
LIBSRCS := astronomica.tcl \
	   aberration.tcl  \
	   date.tcl 	   \
	   deltat.tcl 	   \
	   earth.tcl	   \
	   elliptical.tcl  \
	   equinox.tcl	   \
	   fk5.tcl 	   \
	   interpolate.tcl \
	   jewish.tcl 	   \
	   math.tcl 	   \
	   nutation.tcl    \
	   riseset.tcl 	   \
	   sidereal.tcl    \
	   solstice.tcl	   \
	   sun.tcl	   \
	   transform.tcl

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
