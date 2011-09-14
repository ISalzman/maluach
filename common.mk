
SHELL := /bin/sh

ifeq ($(MAKE),)
    MAKE := make
endif

# 8.5
TCLSH := /c/programs/tcl/bin/tclsh85.exe
TCLKIT := /c/programs/tcl/bin/tclkit85.exe
TCLKITSH := /c/programs/tcl/bin/tclkitsh85.exe
#TCLKIT := /c/programs/tcl/bin/tclkit-gui.exe
#TCLKITSH := /c/programs/tcl/bin/tclkit-cli.exe
#TCLKIT := /c/programs/tcl/bin/base-tk8.5-thread-win32-ix86.exe
#TCLKITSH := /c/programs/tcl/bin/base-tcl8.5-thread-win32-ix86.exe

# 8.6
#TCLKIT := /c/programs/tcl/bin/tclkit86.exe
#TCLKITSH := /c/programs/tcl/bin/tclkitsh86.exe

RM := rm -f
RMR := $(RM) -r
CP := cp -p
CPR := $(CP) -r
MKDIR := mkdir -p
RMDIR := rmdir
CTAGS := ~/usr/bin/ctags
SDX := $(TCLKITSH) ~/bin/sdx.kit
NAGELFAR := $(TCLKITSH) ~/bin/nagelfar.kit

VFSDIR = $(TOPDIR)/$(APPNAME).vfs
VFSLIB = $(VFSDIR)/lib

NAGELFARFLAGS = -strictappend
NAGELFARFILES = $(filter-out %pkgIndex.tcl, $(APPSRCS) $(LIBSRCS))

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

nagelfar: $(NAGELFARFILES)
	$(NAGELFAR) $(NAGELFARFLAGS) $(TOPDIR)/header $^

pkgIndex: $(APPSRCS) $(LIBSRCS)
	echo 'pkg_mkIndex . $^' | $(TCLSH)

tclIndex: $(APPSRCS) $(LIBSRCS)
	echo 'auto_mkindex . $^' | $(TCLSH)

test: tests.tcl
	-@$(TCLSH) ./tests.tcl $(TESTFLAGS)

update: tags header

clean: subdirs vfsclean
	-$(RM) tclIndex runtime $(APPNAME).bat $(APPNAME).exe $(APPNAME).kit

distclean: clean
	-$(RM) tags header

vfsclean:

