# distro.mak
# Copyright 2012 Andrew Redd
# Use govorned by the MIT licence see license.txt
# 
# Build rules for distribution install.exe.


.PHONY: distro version install portable
distro: NppToR-$(VERSION).exe NppToR-$(VERSION).zip NppToR-$(VERSION).src.zip 

NppToR-$(VERSION).exe: install.exe
	cp $< $@

NppToR-$(VERSION).zip: $(ALL_EXE_FILES)
	$(ZIP) $(ZIP_FLAGS) $@ $^

NppToR-$(VERSION).src.zip: $(NPPTOR_SOURCES) $(OTHER_SOURCES)
	$(ZIP) $(ZIP_FLAGS) $@ $^

portable:NppToRPortable-$(VERSION).paf.exe
NppToRPortable-$(VERSION).paf.exe: $(PORTABLE_DIR) $(PORTABLE_FILES)	
	$(ZIP) $(SFX_FLAGS) $@ $<

$(PORTABLE_DIR)/App/NppToR/%.exe:%.exe
	$(COPY) "$<" "$@" $(COPY_FLAGS)
	
version:
	echo $(VERSION)

install: NppToR-$(VERSION).exe
	./$< --silent -global
