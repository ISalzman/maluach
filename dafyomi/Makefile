
TOPDIR := ..

LIBNAME := dafyomi
LIBSRCS := dafyomi.tcl pkgIndex.tcl

MSGSDIR := msgs
MSGSRCS := $(MSGSDIR)/he.msg

LIBVDIR = $(VFSLIB)/$(LIBNAME)
MSGVDIR = $(LIBVDIR)/$(MSGSDIR)
LIBOBJS = $(addprefix $(LIBVDIR)/,$(LIBSRCS))
MSGOBJS = $(addprefix $(MSGVDIR)/,$(notdir $(MSGSRCS)))

include $(TOPDIR)/common.mk

ifneq ($(MAKELEVEL),0)
    all: $(LIBOBJS) $(MSGOBJS)

    $(LIBVDIR): $(VFSLIB)
	$(MKDIR) $@

    $(MSGVDIR): $(LIBVDIR)
	$(MKDIR) $@

    $(LIBOBJS): $(LIBVDIR) $(LIBSRCS)
	$(CP) $(notdir $@) $(LIBVDIR)

    $(MSGOBJS): $(MSGVDIR) $(MSGSRCS)
	$(CP) $(MSGSDIR)/$(notdir $@) $(MSGVDIR)

    vfsclean:
	-$(RM) $(LIBOBJS)
	-$(RM) $(MSGOBJS)
	-$(RMDIR) $(MSGVDIR)
	-$(RMDIR) $(LIBVDIR)
endif
