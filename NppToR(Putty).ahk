;***
; NppToR(putty): R in Notepad++
; by Andrew Redd 2008 <aredd@stat.tamu.edu>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
;
; This is a special version of the NppToR that works with putty which is assumed to 
; be running an R process on a remote machine.
;*
#include startup.ahk
WM_PASTE = 0x302

;run line or selection ;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class Notepad++
F9:: 
gosub puttyLineOrSelection
return

#IfWinActive ahk_class Notepad++
^F9:: 
gosub puttyRunAll
return

puttypaste:
{	IfWinExist , ahk_class PuTTY
	{
		winactivate
		mousegetpos ,x,y
		mouseclick right, 4, 30
		mousemove ,x,y
	}
return
}

puttyLineOrSelection:
{
	oldclipboard = %clipboard%
	clipboard = ""
	sendevent ^c
	if clipboard = ""
	{
		sendevent {end}{home 2}+{down}^c{right}
		if clipboard<>"" 
			clipboard := CheckForNewLine( clipboard )
	}
	if clipboard<>""
	{
		WinGet nppID, ID, A          ; save current window ID to return here later
		gosub puttypaste
		WinActivate ahk_id %nppID%    ; go back to the original window
	}
	clipboard = %oldclipboard%
	return
}

puttyRunAll:
{
oldclipboard = %clipboard%
sendevent ^a^c^{end}
if clipboard<>""
{
	WinGet nppID, ID, A          ; save current window ID to return here later
	gosub puttypaste
	WinActivate ahk_id %nppID%    ; go back to the original window
}
clipboard = %oldclipboard%
}
return

