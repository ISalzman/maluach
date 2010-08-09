
TOPDIR := .
SUBDIRS := Astro DafYomi Zmanim
export APPNAME := maluach

VFSSRCS := main.tcl tclkit.inf
APPMAIN := Maluach.tcl
APPSRCS := $(APPMAIN) Location.tcl Date.tcl Calendar.tcl pkgIndex.tcl

APPVDIR = $(VFSLIB)/app-$(APPNAME)
VFSOBJS = $(addprefix $(VFSDIR)/,$(VFSSRCS))
APPOBJS = $(addprefix $(APPVDIR)/,$(APPSRCS))

EXTRA_CLEAN_FILES := $(APPNAME).exe $(APPNAME).kit $(APPNAME).bat runtime
EXTRA_NAGELFAR_FILES := Astro/Astro.tcl DafYomi/DafYomi.tcl Zmanim/Zmanim.tcl

APPLIBS := Astro DafYomi Zmanim
EXTLIBS := $(TOPDIR)/snit $(TOPDIR)/csv
TZDATA := /c/programs/tcl/lib/tcl8.5/tzdata
TZVDIR = $(VFSLIB)/$(notdir $(patsubst %/,%,$(dir $(TZDATA))))/$(notdir $(TZDATA))
PACKAGES := $(APPLIBS) $(EXTLIBS) $(TZDATA)

RUNTIME = $(TCLKITSH)
#RUNTIME = $(TCLKIT)

include $(TOPDIR)/common.mk

.PHONY: $(PACKAGES)

all: $(APPNAME).exe

$(APPNAME).kit: $(VFSOBJS) $(APPOBJS) $(PACKAGES)
	$(SDX) wrap $@ -vfs $(VFSDIR)
	-@$(RM) $(APPNAME).bat

$(APPNAME).exe: $(VFSOBJS) $(APPOBJS) $(PACKAGES)
	@$(CP) $(RUNTIME) runtime
	$(SDX) wrap $@ -vfs $(VFSDIR) -runtime runtime
	-@$(RM) runtime

$(APPVDIR): $(VFSLIB)
	$(MKDIR) $@

$(VFSOBJS): $(VFSDIR) $(VFSSRCS)
	$(CP) $(@F) $(VFSDIR)

$(APPOBJS): $(APPVDIR) $(APPSRCS)
	$(CP) $(@F) $(APPVDIR)

$(APPLIBS): $(VFSLIB)
	@$(MAKE) -C $@

$(EXTLIBS): $(VFSLIB)
	$(MKDIR) $(VFSLIB)/$(notdir $@)
	$(CP) -r $@/* $(VFSLIB)/$(notdir $@)

$(TZDATA): $(VFSLIB)
	$(MKDIR) $(dir $(TZVDIR))
	$(MKDIR) $(TZVDIR)
	$(CP) -r $@/* $(TZVDIR)

vfsclean:
	-$(RM) -r $(TZVDIR)
	-$(RMDIR) $(dir $(TZVDIR))
	-$(RM) -r $(addprefix $(VFSLIB)/,$(notdir $(EXTLIBS)))
	-$(RM) $(VFSOBJS) $(APPOBJS)
	-$(RMDIR) $(APPVDIR)
	-$(RMDIR) $(VFSLIB)
	-$(RMDIR) $(VFSDIR)

