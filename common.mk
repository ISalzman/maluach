
SHELL := /bin/sh

ifeq ($(MAKE),)
    MAKE := make
endif

# 8.5
TCLSH := /c/programs/tcl/bin/tclsh85.exe
#TCLKIT := /c/programs/tcl/bin/tclkit-8.5.9-win32.upx.exe
#TCLKITSH := /c/programs/tcl/bin/tclkitsh-8.5.9-win32.upx.exe
TCLKIT := /c/programs/tcl/bin/tclkit-gui-859.exe
TCLKITSH := /c/programs/tcl/bin/tclkit-cli-859.exe
#TCLKIT := /c/programs/tcl/bin/base-tk8.5-thread-win32-ix86.exe
#TCLKITSH := /c/programs/tcl/bin/base-tcl8.5-thread-win32-ix86.exe

# 8.6
#TCLKIT := /c/programs/tcl/bin/tclkit.exe
#TCLKITSH := /c/programs/tcl/bin/tclkitsh.exe
#TCLKIT := /c/programs/tcl/bin/tclkit-gui.exe
#TCLKITSH := /c/programs/tcl/bin/tclkit-cli.exe

RM := rm -f
#CP := cp -p
CP := cp
MKDIR := mkdir -p
RMDIR := rmdir
CTAGS := ~/usr/bin/ctags
SDX := $(TCLKITSH) ~/bin/sdx.kit
NAGELFAR := $(TCLKITSH) ~/bin/nagelfar.kit

VFSDIR = $(TOPDIR)/$(APPNAME).vfs
VFSLIB = $(VFSDIR)/lib

.SUFFIXES:
.SUFFIXES: .tcl

.PHONY: all clean distclean update subdirs pkgIndex header nagelfar

all:

$(VFSDIR):
	$(MKDIR) $@

$(VFSLIB): $(VFSDIR)
	$(MKDIR) $@

libsrcs:
	@echo $(LIBSRCS)

subdirs:
	@for dir in $(APPLIBS); do \
	    $(MAKE) -C $$dir $(MAKECMDGOALS); \
	done

tags: $(APPSRCS) $(LIBSRCS)
	$(CTAGS) $(APPSRCS) $(LIBSRCS)

nagelfar: $(APPSRCS) $(LIBSRCS)
	$(NAGELFAR) -strictappend $(TOPDIR)/header $(filter-out %pkgIndex.tcl,$(APPSRCS) $(LIBSRCS))

pkgIndex: $(APPSRCS) $(LIBSRCS)
	echo 'pkg_mkIndex . $^' | $(TCLSH)

tclIndex: $(APPSRCS) $(LIBSRCS)
	echo 'auto_mkindex . $^' | $(TCLSH)

clean: subdirs vfsclean
	-$(RM) tclIndex $(EXTRA_CLEAN_FILES)

distclean: clean
	-$(RM) tags header

update: subdirs tags header

vfsclean:

