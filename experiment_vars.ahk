#NOENV
#SINGLEINSTANCE force ;ignore
#MaxThreads 10

AUTOTRIM OFF
sendmode event
DetectHiddenWindows Off  ;needs to stay off to allow vista to find the appropriate window.

a :=1
b :=2
c :=3

var1 = a

var2 := %var1%

msgbox %var1%=%var2%

dstring = NppToR/%A_ScriptName%[%A_ThisLabel%%A_ThisFunc%]:%A_LineNumber%(EL=%ErrorLevel%): %xtra%
msgbox % dstring
;%
msgbox % dstring . " more info"  ;%

