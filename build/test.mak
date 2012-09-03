
CD = $(shell cd)

.PHONY:test testglobal testinstall
test: NppToR-$(VERSION).exe
	$< --silent "$(CD)\..\test" -no-startup
	CMD /C "start "NppToR" /B "$(CD)\..\test\NppToR.exe" -no-ini -rhome "C:\Programs\R\R-2.14.2""
	
testglobal: NppToR-$(VERSION).exe
	./$< --silent -no-startup -global ..\testglobal
	CMD /C "start "NppToR" /B "$(CD)\..\testglobal\NppToR.exe""

testinstall: NppToR-$(VERSION).exe
	CMD /C "start ./$< "$(CD)\..\test""
	