;***
; starup.ahk
; NppToR: R in Notepad++
; by Andrew Redd 2008 <aredd@stat.tamu.edu>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
;
; This file is includes the startup items for NppToR programs.
;*
#NOENV
#SINGLEINSTANCE ignore
AUTOTRIM OFF
sendmode event

version = 1.4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CMD line Parameters
Loop, %0%  ; For each parameter:
{
    param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
	startup = false
    ;MsgBox, 0,, Parameter number %A_Index% is %param%.
	if param = -startup
		startup = true
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INI file paramters
inifile = %A_ScriptDir%\npptor.ini
IniRead ,Rguiexe, %inifile%, executables, R,""
IniRead ,Rcmdparms, %inifile%, executables, Rcmdparms,""
IniRead ,Nppexe, %inifile%, executables, Npp,""

if nppexe=""
{
	regread, nppdir, hkey_local_machine, software\notepad++
	nppexe = %nppdir%\notepad++.exe
}
if NOT startup
{
	run %nppexe%
}

menu, tray, add ; separator
Menu, tray, add, About, MakeAboutDialog  ; Creates a new menu item.
return

MakeAboutDialog:
{
;Gui, -AlwaysOnTop -SysMenu +Owner ; +Owner avoids a taskbar button.
Gui, Add, Picture,,NppToR.png
Gui, Add, Text,, 
(
NppToR
by Andrew Redd
(c)2008
version %version%
use of this program or source files are governed by the MIT lisence. See License.txt.
)
Gui, Add, Text,, 
(
This package enable syntax highlighting, code folding and autocompletion in notepad++.  This specific utility enables passing code from Notepad++ to the RGui.  

The following are the keyboard shortcuts.

	F8: Passes a line or a selection to R.
	Ctrl+F8: Passes the entire file to R.
	Ctrl+Alt+F8: Saves then evaluates the current script in batch mode then opens the results in notepad++.

)
Gui, Add, Button, Default, OK
Gui, Show, , NppToR by Andrew Redd  ; NoActivate avoids deactivating the currently active window.
}
return
ButtonOK:
GuiClose:
GuiEscape:
Gui destroy
return

CheckForNewLine(var)
{
found := regexmatch( var, "m`a)`n$")
if found=0
	var = %var% `r`n
return %var%
}



