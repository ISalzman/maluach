
TOPDIR := .
VERSION := $(shell cat VERSION)
export APPNAME := maluach

VFSSRCS := main.tcl
APPSRCS := maluach.tcl 	\
	   calendar.tcl	\
	   date.tcl 	\
	   location.tcl

APPVDIR = $(VFSLIB)/$(APPNAME)
VFSOBJS = $(addprefix $(VFSDIR)/,$(VFSSRCS) tclkit.inf)
APPOBJS = $(addprefix $(APPVDIR)/,$(APPSRCS) pkgIndex.tcl)

APPLIBS = astronomica calendrica dafyomi zmanim
EXTLIBS = $(TOPDIR)/snit $(TOPDIR)/tcl8
EXTOBJS = $(patsubst $(TOPDIR)%,$(VFSLIB)%,$(shell find $(EXTLIBS) -type f))
EXTDIRS = $(patsubst $(TOPDIR)%,$(VFSLIB)%,$(shell find $(EXTLIBS) -depth -type d))

TCLVDIR = $(VFSLIB)/tcl8.5
TZVDIR  = $(TCLVDIR)/tzdata
ENCVDIR = $(TCLVDIR)/encoding
MSGVDIR = $(TCLVDIR)/msgs

PACKAGES = $(APPLIBS) $(EXTOBJS)
#PACKAGES += $(TZVDIR)
#PACKAGES += $(ENCVDIR)
#PACKAGES += $(MSGVDIR)

ALLSRCS = $(filter %.tcl %.tm,$(APPSRCS) $(VFSSRCS) $(shell find $(EXTLIBS) -type f) \
	    $(foreach dir,$(APPLIBS),$(addprefix $(dir)/,$(shell $(MAKE) -s -C $(dir) libsrcs))))

include common.mk

.PHONY: $(APPLIBS)

all: $(APPNAME).kit

$(APPNAME).kit: $(VFSOBJS) $(APPOBJS) $(PACKAGES)
	$(SDX) wrap $@ -vfs $(VFSDIR)
	-@$(RM) $(APPNAME).bat

$(APPNAME).exe: $(VFSOBJS) $(APPOBJS) $(PACKAGES)
	$(SDX) wrap $@ -vfs $(VFSDIR) -runtime $(RUNTIME)

$(APPVDIR) $(TCLVDIR): | $(VFSLIB)
	$(MKDIR) $@

$(filter-out %tclkit.inf, $(VFSOBJS)): $(VFSDIR)/% : % | $(VFSDIR)
	$(CP) $< $@

$(filter-out %pkgIndex.tcl, $(APPOBJS)): $(APPVDIR)/% : % | $(APPVDIR)
	$(CP) $< $@

$(VFSDIR)/tclkit.inf: tclkit.inf.in VERSION | $(VFSDIR)
	$(SED) 's%@VERSION@%$(VERSION)%' $< > $@

$(APPVDIR)/pkgIndex.tcl: pkgIndex.tcl.in VERSION | $(APPVDIR)
	$(SED) 's%@VERSION@%$(VERSION)%' $< > $@

$(APPLIBS): | $(VFSLIB)
	@$(MAKE) -C $@

$(EXTOBJS): $(VFSLIB)/% : $(TOPDIR)/% | $(VFSLIB)
	$(INSTALL) $< $@

$(TZVDIR) $(ENCVDIR) $(MSGVDIR): $(VFSLIB)/% : $(TCLLIBDIR)/% | $(TCLVDIR)
	$(RMR) $@
	$(CPR) $< $@

vfsclean:
	-$(RM) $(VFSOBJS) $(APPOBJS) $(EXTOBJS)
	-$(RMR) $(TZVDIR) $(ENCVDIR) $(MSGVDIR)
	-$(RMDIR) $(EXTDIRS)
	-$(RMDIR) $(TCLVDIR)
	-$(RMDIR) $(APPVDIR)
	-$(RMDIR) $(VFSLIB)
	-$(RMDIR) $(VFSDIR)

header.syntax: $(ALLSRCS)
	$(NAGELFAR) -header header.syntax $(ALLSRCS)

tags: $(ALLSRCS)
	$(CTAGS) --langmap=tcl:+.tm $(ALLSRCS)
