
TOPDIR := .
SUBDIRS := Astro DafYomi Zmanim
export APPNAME := maluach

VFSSRCS := main.tcl tclkit.inf
APPMAIN := Maluach.tcl
APPSRCS := $(APPMAIN) Location.tcl pkgIndex.tcl

APPVDIR = $(VFSLIB)/app-$(APPNAME)
VFSOBJS = $(addprefix $(VFSDIR)/,$(VFSSRCS))
APPOBJS = $(addprefix $(APPVDIR)/,$(APPSRCS))

EXTRA_CLEAN_FILES = $(APPNAME).exe $(APPNAME).kit $(APPNAME).bat
EXTRA_NAGELFAR_FILES := Astro/Astro.tcl

APPLIBS := Astro DafYomi Zmanim
EXTLIBS := snit
PACKAGES := $(APPLIBS) $(EXTLIBS)

include $(TOPDIR)/common.mk

.PHONY: $(PACKAGES)

all: $(APPNAME).exe

$(APPNAME).kit: $(VFSOBJS) $(APPOBJS) $(PACKAGES)
	$(SDX) wrap $@ -vfs $(VFSDIR)
	-@$(RM) $(APPNAME).bat

$(APPNAME).exe: $(VFSOBJS) $(APPOBJS) $(PACKAGES)
	$(SDX) wrap $@ -vfs $(VFSDIR) -runtime $(TCLKIT)

$(APPVDIR): $(VFSLIB)
	$(MKDIR) $@

$(VFSOBJS): $(VFSDIR) $(VFSSRCS)
	$(CP) $(@F) $(VFSDIR)

$(APPOBJS): $(APPVDIR) $(APPSRCS)
	$(CP) $(@F) $(APPVDIR)

$(APPLIBS): $(VFSLIB)
	@$(MAKE) -C $@

$(EXTLIBS): $(VFSLIB)
	$(MKDIR) $(VFSLIB)/$@
	$(CP) $(@)/* $(VFSLIB)/$@

vfsclean:
	-$(RM) -r $(addprefix $(VFSLIB)/,$(EXTLIBS))
	-$(RM) $(VFSOBJS) $(APPOBJS)
	-$(RMDIR) $(APPVDIR)
	-$(RMDIR) $(VFSLIB)
	-$(RMDIR) $(VFSDIR)

