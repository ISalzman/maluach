
TOPDIR := .
export APPNAME := maluach

VFSSRCS := main.tcl tclkit.inf
APPSRCS := maluach.tcl 	\
	   calendar.tcl	\
	   date.tcl 	\
	   location.tcl	\
	   pkgIndex.tcl

APPVDIR = $(VFSLIB)/$(APPNAME)
VFSOBJS = $(addprefix $(VFSDIR)/,$(VFSSRCS))
APPOBJS = $(addprefix $(APPVDIR)/,$(APPSRCS))

APPLIBS := astronomica calendrica dafyomi zmanim
EXTLIBS := $(TOPDIR)/snit $(TOPDIR)/tcl8

TZDATA := /c/programs/tcl/lib/tcl8.5/tzdata
TZVDIR = $(VFSLIB)/$(notdir $(patsubst %/,%,$(dir $(TZDATA))))/$(notdir $(TZDATA))

ENCDATA := /c/programs/tcl/lib/tcl8.5/encoding
ENCVDIR = $(VFSLIB)/$(notdir $(patsubst %/,%,$(dir $(ENCDATA))))/$(notdir $(ENCDATA))

PACKAGES := $(APPLIBS) $(EXTLIBS)
#PACKAGES += $(TZDATA)
#PACKAGES += $(ENCDATA)

#RUNTIME = $(TCLKITSH)
RUNTIME = $(TCLKIT)

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
	$(CPR) $@/* $(VFSLIB)/$(notdir $@)

$(TZDATA): $(VFSLIB)
	$(MKDIR) $(dir $(TZVDIR))
	$(MKDIR) $(TZVDIR)
	$(CPR) $@/* $(TZVDIR)

$(ENCDATA): $(VFSLIB)
	$(MKDIR) $(dir $(ENCVDIR))
	$(MKDIR) $(ENCVDIR)
	$(CPR) $@/* $(ENCVDIR)

vfsclean:
	-$(RMR) $(TZVDIR)
	-$(RMDIR) $(dir $(TZVDIR))
	-$(RMR) $(ENCVDIR)
	-$(RMDIR) $(dir $(ENCVDIR))
	-$(RMR) $(addprefix $(VFSLIB)/,$(notdir $(EXTLIBS)))
	-$(RM) $(VFSOBJS) $(APPOBJS)
	-$(RMDIR) $(APPVDIR)
	-$(RMDIR) $(VFSLIB)
	-$(RMDIR) $(VFSDIR)

header: $(APPSRCS)
	$(NAGELFAR) -header header $(filter-out %pkgIndex.tcl, $(APPSRCS) \
	    $(foreach dir,$(APPLIBS),$(addprefix $(dir)/,$(shell $(MAKE) -s -C $(dir) libsrcs))) \
	    $(foreach dir,$(EXTLIBS),\
		$(if $(findstring tcl8,$(notdir $(dir))),\
		$(foreach sub,$(wildcard $(dir)/*),$(wildcard $(sub)/*.tm)),\
		$(wildcard $(dir)/*.tcl))))

tags: $(APPSRCS)
	$(CTAGS) --langmap=tcl:+.tm $(filter-out %pkgIndex.tcl, $(APPSRCS) \
	    $(foreach dir,$(APPLIBS),$(addprefix $(dir)/,$(shell $(MAKE) -s -C $(dir) libsrcs))) \
	    $(foreach dir,$(EXTLIBS),\
		$(if $(findstring tcl8,$(notdir $(dir))),\
		$(foreach sub,$(wildcard $(dir)/*),$(wildcard $(sub)/*.tm)),\
		$(wildcard $(dir)/*.tcl))))
