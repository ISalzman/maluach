
SHELL := /bin/sh

ifeq ($(MAKE),)
    MAKE := make
endif

TCLBINDIR := /c/programs/tcl/bin
TCLLIBDIR := /c/programs/tcl/lib

TCLSH := $(TCLBINDIR)/tclsh86.exe
TCLKIT := $(TCLBINDIR)/tclkit86.exe
TCLKITSH := $(TCLBINDIR)/tclkitsh86.exe
#TCLKIT := $(TCLBINDIR)/base-tk8.6-thread-win32-ix86.exe
#TCLKITSH := $(TCLBINDIR)/base-tcl8.6-thread-win32-ix86.exe

#RUNTIME = $(TCLKITSH)
RUNTIME = $(TCLKIT)

RM := rm -f
RMR := $(RM) -r
CP := cp -p
CPR := $(CP) -r
ZIP := zip
TAR := tar
SED := sed
CAT := cat
GZIP := gzip
MKDIR := mkdir -p
RMDIR := rmdir
INSTALL := install -Dp
CTAGS := ~/usr/bin/ctags
SDX := $(TCLSH) ~/bin/sdx.kit
NAGELFAR := $(TCLSH) ~/bin/nagelfar.kit

VFSDIR = $(TOPDIR)/$(APPNAME).vfs
VFSLIB = $(VFSDIR)/lib

NAGELFARFLAGS = -strictappend
NAGELFARFILES = $(filter %.tcl %.tm, $(APPSRCS) $(LIBSRCS) $(VFSSRCS))

.SUFFIXES:
.SUFFIXES: .tcl

.PHONY: all clean distclean update subdirs pkgIndex nagelfar tags header.syntax

all:

$(VFSDIR):
	$(MKDIR) $@

$(VFSLIB): | $(VFSDIR)
	$(MKDIR) $@

libsrcs:
	@echo $(LIBSRCS)

subdirs:
	@for dir in $(APPLIBS); do \
	    $(MAKE) -C $$dir $(MAKECMDGOALS); \
	done

nagelfar: $(NAGELFARFILES)
	$(NAGELFAR) $(NAGELFARFLAGS) $(TOPDIR)/header.syntax $(TOPDIR)/helper.syntax $^

pkgIndex: $(APPSRCS) $(LIBSRCS)
	echo 'pkg_mkIndex . $^' | $(TCLSH)

tclIndex: $(APPSRCS) $(LIBSRCS)
	echo 'auto_mkindex . $^' | $(TCLSH)

test: tests.tcl
	-@$(TCLSH) ./tests.tcl $(TESTFLAGS)

update: tags header.syntax

clean: subdirs vfsclean
	-$(RM) $(APPNAME).bat $(APPNAME).exe $(APPNAME).bin $(APPNAME).kit

distclean: clean
	-$(RM) tags header.syntax pkgIndex.tcl tclkit.inf tclIndex

vfsclean:

