; NppToR: R in Notepad++
; by Andrew Redd 2008 <aredd@stat.tamu.edu>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php

#NOENV
#SINGLEINSTANCE ignore
AUTOTRIM OFF
sendmode event

version = 1.4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin Initial execution code

;;;;;;;;;;;;;;;;;;;;
;CMD line Parameters
Loop, %0%  ; For each parameter:
{
    param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
	startup = false
	if param = -startup
		startup = true
}

;;;;;;;;;;;;;;;;;;;
;INI file paramters
inifile = %A_ScriptDir%\npptor.ini
;executables
IniRead ,Rguiexe, %inifile%, executables, R,""
IniRead ,Rcmdparms, %inifile%, executables, Rcmdparms,""
IniRead ,Nppexe, %inifile%, executables, Npp,""
;hotkeys
IniRead ,passlinekey, %inifile%, hotkeys, passline,F8
IniRead ,passfilekey, %inifile%, hotkeys, passfile,^F8
IniRead ,batchrunkey, %inifile%, hotkeys, batchrun,^!F8
;putty
IniRead ,activateputty, %inifile%, putty, activateputty, false
IniRead ,puttylinekey, %inifile%, putty, puttyline, F9
IniRead ,puttyfilekey, %inifile%, putty, puttyfile, ^F9
;controls
IniRead ,Rpastewait, %inifile%, controls, Rpastewait, 50
IniRead ,Rrunwait, %inifile%, controls, Rrunwait, 10
IniRead ,restoreclipboard, %inifile%, controls, restoreclipboard, true

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;assign hotkeys dynamically
hotkey , IfWinActive, ahk_class Notepad++
hotkey ,%passlinekey%,runline
hotkey ,%passfilekey%,runall
hotkey ,%batchrunkey%,runbatch
if activateputty=true
{
	hotkey , %puttylinekey% , puttyLineOrSelection
	hotkey , %puttyfilekey% , puttyRunAll
}
return
;End Executable potion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin function declarations

;run line or selection ;;;;;;;;;;;;;;;;;;;;;;;;
runline:
{
gosub NppGetLineOrSelection
gosub Rpaste
return
}
; Run All ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

runall:
{
gosub NppGetAll
gosub Rpaste
return
}
; Run in R CMD BATCH ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
runbatch:
{
	WinMenuSelectItem ,A,,File,Save
	getCurrNppFileDir(file, dir, ext, Name)
	SetWorkingDir %dir%
	RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
	runwait %Rdir%\bin\Rcmd.exe BATCH -q "%dir%\%file%" ,dir,min,RprocID
	run %NppDir%\Notepad++.exe "%dir%\%Name%.Rout"
return
}
Rpaste:
{
	if clipboard<>""
	{
		WinGet nppID, ID, A          ; save current window ID to return here later
		RprocID:=getOrStartR()
		if ErrorLevel
		{
			IfWinExist , RGui
				msgbox , 16 ,R in MDI Mode, R in running in MDI mode. Please switch to SDI mode for this utility to work.
			else
				msgbox , 16 ,Could not find R, Could nor start or find R. Please check you installation or start R manually.
			return
		}
		WinMenuSelectItem ,ahk_pid %RprocID%,,Edit,paste
		WinActivate ahk_id %nppID%    ; go back to the original window if moved
	}
	sleep %Rpastewait%
	if restoreclipboard=true
	{
		clipboard = %oldclipboard%
	}
	return
}
getOrStartR()
{
	IfWinExist ,R Console
	{
		;WinActivate ; ahk_class RGui
		WinGet RprocID, PID ;,A
		return RprocID
	} 
	else
	{
		global Rguiexe
		global Rcmdparms
		getCurrNppFileDir(File,dir)
		setworkingdir %dir%
		if Rguiexe=""
		{	
			RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
			Rguiexe = %Rdir%\bin\Rgui.exe
		}
		run %Rguiexe% %RcmdParms%,dir,,RprocID
		winwait ,R Console,,%Rrunwait%
		WinGet RprocID, PID ;,A
		return RprocID
	}
}
getCurrNppFileDir(ByRef file="", ByRef dir="", ByRef ext="", ByRef NameNoExt="", ByRef Drive="")
{
	; WinGetActiveTitle, title
	; stringleft firstchar, title, 1
	; if firstchar = *
		; StringTrimLeft title, title, 1
	; StringTrimRight title, title, 12
	ocb = %clipboard%
	WinMenuSelectItem ,A,,Edit,Copy Current full file path to Clipboard
	splitpath, clipboard,file,dir, ext, NameNoExt, Drive
	clipboard = %ocb%
	return dir
}
puttypaste:
{	
	WinGet nppID, ID, A          ; save current window ID to return here later
	IfWinExist , ahk_class PuTTY
	if clipboard<>""
	{
		ControlClick , x4 y30,,, right
	}
	WinActivate ahk_id %nppID%    ; go back to the original window
	if restoreclipboard=true
	{
		clipboard = %oldclipboard%
	}
	return
}
puttyLineOrSelection:
{
	gosub NppGetLineOrSelection
	gosub puttypaste
	return
}
puttyRunAll:
{
	gosub NppGetAll
	gosub puttypaste
	return
}
NppGetLineOrSelection:
{
	oldclipboard = %clipboard%
	clipboard = ""
	WinMenuSelectItem ,A,,Edit,Copy
	sendevent {right}
	if clipboard = ""
	{
		sendevent {end}{home 2}+{down}
		WinMenuSelectItem ,A,,Edit,Copy
		sendevent {right}
		if clipboard<>"" 
			clipboard := CheckForNewLine( clipboard )
	}
	return
}
NppGetAll:
{
oldclipboard = %clipboard%
WinMenuSelectItem ,A,,Edit,Select All
WinMenuSelectItem ,A,,Edit,Copy
sendevent {right}
return
}
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

The following are the keyboard shortcuts (can be modified in the npptor.ini file).

	%passlinekey%: Passes a line or a selection to R.
	%passfilekey%: Passes the entire file to R.
	%batchrunkey%: Saves then evaluates the current script in batch mode then opens the results in notepad++.

(#=Win,!=Alt,^=Control,+=Shift)
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
