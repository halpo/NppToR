; NppToR: R in Notepad++
; by Andrew Redd 2008 <halpo@users.sourceforge.net>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php

; #NOENV
#SINGLEINSTANCE force
#MaxThreads 10

AUTOTRIM OFF
sendmode event
DetectHiddenWindows Off  ;needs to stay off to allow vista to find the appropriate window.

version = 1.9.4 
debug = false
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin Initial execution code

;set environment variable for spawned R processes
envset ,R_PROFILE_USER, %A_ScriptDir%\Rprofile
envset ,R_USER, %A_ScriptDir%

;;;;;;;;;;;;;;;;;;;;
;CMD line Parameters
Loop, %0%  ; For each parameter:
{
    param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
	if param = -startup
		startup = true
}

;;;;;;;;;;;;;;;;;;;
;INI file paramters
inifile = %A_ScriptDir%\npptor.ini
;executables
IniRead ,Rhome, %inifile%, executables, R,
IniRead ,Rcmdparms, %inifile%, executables, Rcmdparms,
IniRead ,Nppexe, %inifile%, executables, Npp,
;hotkeys
IniRead ,passlinekey, %inifile%, hotkeys, passline,F8
IniRead ,passfilekey, %inifile%, hotkeys, passfile,^F8
IniRead ,passtopointkey, %inifile%, hotkeys, evaltocursor, +F8
IniRead ,batchrunkey, %inifile%, hotkeys, batchrun,^!F8
;putty
IniRead ,activateputty, %inifile%, putty, activateputty, false
IniRead ,puttylinekey, %inifile%, putty, puttyline, F9
IniRead ,puttyfilekey, %inifile%, putty, puttyfile, ^F9
;controls
IniRead ,Rpastewait, %inifile%, controls, Rpastewait, 50
IniRead ,Rrunwait, %inifile%, controls, Rrunwait, 10
IniRead ,restoreclipboard, %inifile%, controls, restoreclipboard, true
IniRead ,appendnewline, %inifile%, controls, appendnewline, true

if nppexe=ERROR
{
	regread, nppdir, hkey_local_machine, software\notepad++
	nppexe = %nppdir%\notepad++.exe
}
if Rhome=ERROR
{	
	RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
	Rhome = %Rdir%
}
Rguiexe = %Rhome%\bin\Rgui.exe
if  not startup
	run %nppexe%
if Rcmdparms=ERROR
	Rcmdparms=
;menu functions
menu, tray, add ; separator
menu, tray, add, Show Simulations, showCounter
menu, tray, add, Start Notepad++, RunNpp
menu, tray, add, Reset R working directory, UpdateRWD
menu, tray, add, Regenerate R Syntax files, showSyntaxGui
menu, tray, add ; separator
Menu, tray, add, About, ShowAbout  ; Creates a new menu item.

gosub makeCounter
gosub MakeAboutDialog
gosub makeSyntaxGui
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;assign hotkeys dynamically
if NOT makeglobal
	hotkey , IfWinActive, ahk_class Notepad++
#MaxThreadsPerHotkey 10
hotkey ,%passlinekey%,runline
hotkey ,%passfilekey%,runall
hotkey ,%passtopointkey%,runtocursor
#MaxThreadsPerHotkey 100
hotkey ,%batchrunkey%,runbatch
if activateputty=true
{
	#MaxThreadsPerHotkey 10
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
runtocursor:
{
gosub NppGetToPoint
gosub Rpaste
return
}
; Run in R CMD BATCH ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
runbatch:
{
	DetectHiddenWindows On
	WinMenuSelectItem ,A,,File,Save
	getCurrNppFileDir(file, dir, ext, Name)
	SetWorkingDir %dir%
	RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
	command = CMD /C %Rdir%\bin\Rcmd.exe BATCH -q "%file%"
	run %command%, %dir%, hide, RprocID
	WinWait ,ahk_pid %RprocID%,,.5
	addProc(RprocID,File, "Local")
	WinWaitClose ahk_pid %RprocID%
	run %nppexe% "%dir%\%Name%.Rout"
	removeProc(RprocID)
	DetectHiddenWindows Off
return
}
Rpaste:
{
;	if clipboard<>
	; isblank := 
	; msgbox %isblank%
	; msgbox %ERRRORLEVEL%
	if !regExMatch(clipboard, "DS)^`s*$")
	{
		WinGet nppID, ID, A          ; save current window ID to return here later
		RprocID:=getOrStartR()
		if ErrorLevel
		{
			IfWinExist , RGui
				msgbox , 16 ,R in MDI Mode, R in running in MDI mode. Please switch to SDI mode for this utility to work.
			else
				msgbox , 16 ,Could not find R, Could not start or find R. Please check you installation or start R manually.
			return
		}
		WinMenuSelectItem ,ahk_id %RprocID%,,2&,2& ;edit->paste
		;WinMenuSelectItem ,ahk_id %RprocID%,,file,Print...
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
		WinGet RprocID, ID ;,A
		return RprocID
	} 
	else
	{
		global Rguiexe
		global Rcmdparms
		getCurrNppFileDir(File,dir)
		setworkingdir %dir%
		run %Rguiexe% %RcmdParms%,dir,,RprocID
		winwait ,R Console,, %Rrunwait%
		WinGet RprocID, ID ;,A
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
	clipboard =
	WinMenuSelectItem ,A,,2&,10& ; Edit,Copy Current full file path to Clipboard
	clipwait
	splitpath, clipboard,file,dir, ext, NameNoExt, Drive
	clipboard = %ocb%
	return dir
}
puttypaste:
{	
	WinGet nppID, ID, A          ; save current window ID to return here later
	IfWinExist , ahk_class PuTTY
	{
		if clipboard<>""
		{
			ControlClick , x4 y30,,, right
		}
		WinActivate ahk_id %nppID%    ; go back to the original window
		if restoreclipboard=true
		{
			clipboard = %oldclipboard%
		}
	} else msgbox ,16,PuTTY not found, PuTTY was not found.  Launch PuTTY and start R on remote server.
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
	clipboard = 
	WinMenuSelectItem ,A,,2&,5& ;Edit,Copy
	clipwait .1
	if clipboard = 
	{
		sendevent {end}{home 2}+{end}+{right}
		WinMenuSelectItem ,A,,2&,5& ;Edit,Copy
		sendevent {right}
	} 
	else sendevent {right}
	if clipboard<>"" AND appendnewline
		clipboard := CheckForNewLine( clipboard )
	return
}
RunNpp:
{
	Run %Nppexe%
	return 
}
UpdateRWD:
{
	oldclipboard = %clipboard%
	WinActivate ahk_class Notepad++
	currdir:=getCurrNppFileDir()
	StringReplace , wd, currdir, \, /, All 
	clipboard = setwd("%wd%")`n
	gosub Rpaste
	return
}
NppGetAll:
{
oldclipboard = %clipboard%
WinMenuSelectItem ,A,,2&,8& ;Edit,Select All
WinMenuSelectItem ,A,,2&,5& ;Edit,Copy
sendevent {right}
clipboard := CheckForNewLine( clipboard )
return
}
NppGetToPoint:
{
oldclipboard = %clipboard%
sendevent ^+{home}
WinMenuSelectItem ,A,,2&,5& ;Edit,Copy
sendevent {right}
clipboard := CheckForNewLine( clipboard )
return
}

MakeAboutDialog:
{
;Gui, -AlwaysOnTop -SysMenu +Owner ; +Owner avoids a taskbar button.
Gui, 2:Add, Picture,,icons\NppToR.png
Gui, 2:Add, Text,, 
(
NppToR
by Andrew Redd
(c)2008
version %version%
use of this program or source files are governed by the MIT lisence. See License.txt.
)
Gui, 2:Add, Text,, 
(
This package enable syntax highlighting, code folding and autocompletion in notepad++.  This specific utility enables passing code from Notepad++ to the RGui.  

The following are the keyboard shortcuts (can be modified in the npptor.ini file).

	%passlinekey%: Passes a line or a selection to R.
	%passfilekey%: Passes the entire file to R.
	%passtopointkey%: Evaluates the file to the point of the cursor.
	%batchrunkey%: Saves then evaluates the current script in batch mode then opens the results in notepad++.

(#=Win,!=Alt,^=Control,+=Shift)
)
Gui, 2:Add, Button, Default gButtonOK2, OK
;Gui, 2:Show, , NppToR by Andrew Redd  ; NoActivate avoids deactivating the currently active window.
return
}
ShowAbout:
Gui , 2:Show,,NpptoR by Andrew Redd
return
ButtonOK2:
GuiClose2:
GuiEscape2:
Gui 2:hide
return

CheckForNewLine(var)
{
	if var <>
	{
	stringright , right, var, 1 	;for long strings
	found := regexmatch( right, "[`r`n]")
	if !found
		var = %var% `n
	}
	return %var%
}

DoSyntax:
ifwinexist ahk_class Notepad++
{
	msgbox ,4,Close Notepad++, Notepad++ must be closed to generate the syntax files.  Continue?
	ifmsgbox no 
		return
	winclose,,,15
}
RUNWAIT ,%A_ScriptDir%\GenerateSyntaxFiles.exe "%Rhome%" "%NppConfig%"
run %Nppexe%
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Includes
#include %A_ScriptDir%\counter\counter.ahk
#include %A_ScriptDir%\syntax\SyntaxGui.ahk

