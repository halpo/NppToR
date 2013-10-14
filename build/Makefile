# Makefile for NppToR
# Copyright 2013 Andrew Redd
# Use govorned by the MIT licence see license.txt
include ../VERSION


#' the following can be changed in a ENV.mak file that defines values
#' For a specific system setup.
#' 
#' 
-include ENV.mak

#' R script
Rscript ?= Rscript
ROptions ?= --no-restore --no-save

#' Zip file compressor
ZIP        ?= 7z
# for compressing to Zip files
ZIP_FLAGS  ?= a -mx9 -tzip -aoa
# For self contained extraction exes
SFX_FLAGS  ?= a -sfx7z.sfx -mx9 -aoa

#' Ahk Compiler
AHK2EXE ?= Ahk2Exe

#' Resource Hacker available from http://www.angusj.com/resourcehacker/
RESHACK ?= ResHacker

#' Resource Compiler
RC      ?= windres

#' Perl Binary
PERL    ?= perl

#' Git
GIT     ?= git

#' File Operators
DEL        ?= rm -f
COPY       ?= cp
COPY_FLAGS ?= 
DATE 	   ?= date

#' Compression Tool
UPX     ?= upx

#' Binary components
AHK_BIN    ?= u32.bin
N2R_BIN = NppToR.bin

#' 
PORTABLE_DIR = ../NppToRPortable




#{ Source Files
NPPTOR_SOURCES = 	   \
  NppToR.ahk               \
  Notepad++Interface.ahk   \
  counter.ahk              \
  inigui.ahk               \
  _reg64.ahk               \
  NTRError.ahk             \
  QuickKeys.ahk            \
  GetModuleFileName.ahk    \
  RInterface.ahk           \
  make_R_xml.r

INSTALL_SOURCES = \
  install.ahk     \
  uninstall.ahk   \
  scheduler.ahk   \
#}  
  
ALL_EXE_FILES = \
  NppToR.exe    \
  NppEditR.exe  \
  License.txt   \
  ../Readme.md  \
  Changelog.txt

PORTABLE_FILES = \
  $(PORTABLE_DIR)/App/AppInfo/appinfo.ini \
  $(PORTABLE_DIR)/App/AppInfo/appicon.ico \
  $(PORTABLE_DIR)/App/NppToR/npptor.ini   \
  $(PORTABLE_DIR)/App/NppToR/NppEditR.exe \
  $(PORTABLE_DIR)/App/NppToR/NppToR.exe
  
  
ICONS_DIR = ../icons
ICON = $(ICONS_DIR)/npptor.ico


FILEVERSION := $(shell $(GIT) rev-parse --short HEAD)
BUILDYEAR   := $(shell date +%Y)
BUILDDATE   := $(shell date +%m/%d/%y)

ALL_SOURCES = $(NPPTOR_SOURCES) $(INSTALL_SOURCES) NppEditR.ahk $(ICON_DIR)

vpath %.ahk .. ../iniGUI \
	../Counter   \
	../NppEditsR \
	../Installer
vpath %.txt ..
vpath %.r ..
vpath %.md ..
vpath %.rc.in ../buildtools
vpath %.rhs.in ../buildtools
vpath %.ico ../icons

.PHONY: installer clean all distro portable
all: NppToR.exe NppEditR.exe install.exe
rc: u32.rc u64.rc
NppToR.exe: $(NPPTOR_SOURCES)
NppEditR.exe:../NppEditsR/NppEditR.ahk
installer: install.exe
install.exe: NppEditR.exe NppToR.exe uninstall.exe R.xml

%.exe:%.ahk
	$(AHK2EXE) /in "$<" /out "$@" /icon "$(ICON)" /bin "$(N2R_BIN)"
	$(UPX) $@

%.rc: %.rc.in
	$(COPY) "$<" "$@" $(COPY_FLAGS)
	$(PERL) -i.bak -p -e 's/FILEVERSION \d,\d,\d,\d/FILEVERSION $(VERSION_MAJOR),$(VERSION_MINOR),$(VERSION_FIX),$(VERSION_OTHER)/' $@
	$(PERL) -i.bak -p -e 's/PRODUCTVERSION \d,\d,\d,\d/PRODUCTVERSION $(VERSION_MAJOR),$(VERSION_MINOR),$(VERSION_FIX),$(VERSION_OTHER)/' $@
	$(PERL) -i.bak -p -e 's/VALUE "FileVersion", ""/VALUE "FileVersion", "$(FILEVERSION)"/' $@
	$(PERL) -i.bak -p -e 's/VALUE "LegalCopyright", "(c)XXXX/VALUE "LegalCopyright", "(c)$(BUILDYEAR)/' $@
	$(PERL) -i.bak -p -e 's/VALUE "ProductVersion", ""/VALUE "ProductVersion", "$(VERSION)"/' $@
	$(RM) *.rc.bak

%.rhs: %.rhs.in
	$(COPY) "$<" "$@" $(COPY_FLAGS)
	$(PERL) -i.bak -p -e 's/%IN%/"$(AHK_BIN)"/' $@
	$(PERL) -i.bak -p -e 's/%OUT%/"$(N2R_BIN)"/' $@
	$(RM) *.rhs.bak

%.res: %.rc
	$(RC) $< -o $@

$(N2R_BIN): Version.res
	$(RESHACK) -script Version.rhs
	$(TOUCH) $<

R.xml: autocomplete.r
	$(Rscript) $(ROptions) $<

include distro.mak
include test.mak

.PHONY: clean
clean:
	-$(DEL) *.exe *.zip *.rc *.rhs *.log *.res
