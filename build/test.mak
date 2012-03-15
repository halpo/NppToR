
CD = $(shell cd)

.PHONEY:test testglobal
test: NppToR-$(VERSION).exe
	./$< --silent ../test -no-startup
	CMD /C "start ../test/NppToR.exe"
	
testglobal: NppToR-$(VERSION).exe
	./$< --silent -no-startup -global ../testglobal
	CMD /C "start ../testglobal/NppToR.exe"

testinstall: NppToR-$(VERSION).exe
	@echo $(CD)
	CMD /C "start ./$< "$(CD)/../test""
	