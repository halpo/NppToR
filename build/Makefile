# Makefile for NppToR
# Copyright 2012 Andrew Redd
# Use govorned by the MIT licence see license.txt
VERSION = 2.6.2

ZIP     = 7z
AHK2EXE = ../buildtools/Ahk2exe.exe
DEL     = rm -f
COPY    = cp

ZIP_FLAGS  ?= a -mx9 -tzip -aoa
SFX_FLAGS  ?= a -sfx7z.sfx -mx9 -aoa
AHK_BIN    ?= ../buildtools/NppToR-Unicode32.bin
COPY_FLAGS ?= -f


PORTABLE_DIR = ../NppToRPortable

NPPTOR_SOURCES = 	       \
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

ALL_SOURCES = $(NPPTOR_SOURCES) $(INSTALL_SOURCES) NppEditR.ahk $(ICON_DIR)

vpath %.ahk .. ../iniGUI \
	../Counter   \
	../NppEditsR \
	../Installer
vpath %.txt ..
vpath %.r ..
vpath %.md ..
vpath %.ico ../icons

.PHONY: installer clean all distro portable
all: NppToR.exe NppEditR.exe install.exe
NppToR.exe: $(NPPTOR_SOURCES)
NppEditR.exe:../NppEditsR/NppEditR.ahk
installer: install.exe
install.exe: NppEditR.exe NppToR.exe uninstall.exe

%.exe:%.ahk
	$(AHK2EXE) /in $< /out $@ /icon $(ICON) /bin $(AHK_BIN)

include distro.mak
include test.mak

clean:
	-$(DEL) *.exe *.zip
