#NOENV
#SINGLEINSTANCE force ;ignore
#MaxThreads 10
sendmode event
DetectHiddenWindows Off  ;needs to stay off to allow vista to find the appropriate window.
SetTitleMatchMode , 1
SetTitleMatchMode , Fast
AUTOTRIM OFF

msgbox % NppGetLine() ;%
msgbox % NppGetFullPath() ;%
msgbox % NppGetCurrDir() ;%
msgbox % NppGetFilename() ;%
msgbox % NppGetNamePart() ;%
msgbox % NppGetExtPart() ;%

; NppCopy()
; NppSelectAll()


; NPPM := 0x7EC
; msgbox % NppGetByMessageInt(NPPM) ;%
; msgbox % NppGetCurrView() ;%

; pos := NppGetPosition() ;%
; msgbox %pos% 
; NppSetPosition(pos+1)
; msgbox %ERRORLEVEL%

; gosub NppGetToPoint
; msgbox %errorlevel%
; msgbox %clipboard%
; gosub RPaste

gosub NppGetLineOrSelection


Exit
#include Notepad++Interface.ahk
#include RInterface.ahk