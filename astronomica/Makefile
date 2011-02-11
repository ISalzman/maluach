
TOPDIR := ..

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
	   transform.tcl   \
	   pkgIndex.tcl

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
