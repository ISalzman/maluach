
TOPDIR := ..
VERSION := $(shell cat VERSION)

LIBNAME := dafyomi
LIBSRCS := dafyomi.tcl
MSGSDIR := msgs

LIBVDIR = $(VFSLIB)/$(LIBNAME)
MSGVDIR = $(LIBVDIR)/$(MSGSDIR)
LIBOBJS = $(addprefix $(LIBVDIR)/,$(LIBSRCS) pkgIndex.tcl)
MSGOBJS = $(addprefix $(LIBVDIR)/,$(shell find $(MSGSDIR) -type f))

include $(TOPDIR)/common.mk

ifneq ($(MAKELEVEL),0)
    all: $(LIBOBJS) $(MSGOBJS)

    $(LIBVDIR): | $(VFSLIB)
	$(MKDIR) $@

    $(MSGVDIR): | $(LIBVDIR)
	$(MKDIR) $@

    $(LIBVDIR)/pkgIndex.tcl: pkgIndex.tcl.in VERSION | $(LIBVDIR)
	$(SED) 's%@VERSION@%$(VERSION)%' $< > $@

    $(filter-out %pkgIndex.tcl, $(LIBOBJS)): $(LIBVDIR)/% : % | $(LIBVDIR)
	$(CP) $< $@

    $(MSGOBJS): $(MSGVDIR)/% : $(MSGSDIR)/% | $(MSGVDIR)
	$(CP) $< $@

    vfsclean:
	-$(RM) $(LIBOBJS)
	-$(RM) $(MSGOBJS)
	-$(RMDIR) $(MSGVDIR)
	-$(RMDIR) $(LIBVDIR)
endif
