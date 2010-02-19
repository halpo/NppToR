;
; Project:        NppToR
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Licence:        MIT
; Author:         Andrew Redd <halpo@users.sourceforge.net>
;
; Script Function:
;	This is part of NppToR. It facilitates using Notepad++ with R's edit functions.
;	This is a proof of concept the program needs to either be integrated or call into
;	the main program since that is were the variables for the Nppexe file are located.
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#NoTrayIcon  ; Prevents icon in system tray
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
settitlematchmode 2

winget ,RID, ID, A  ;Assume R is active window retrieve ahk_id 
in1 = %1%

inifile = npptor.ini
IniRead ,Nppexe, %inifile%, executables, Npp,%A_Space%
if nppexe=
{
	regread, nppdir, hkey_local_machine, software\notepad++
	nppexe = %nppdir%\notepad++.exe
}

run , "%nppexe%" "%in1%" 

Gui , +AlwaysOnTop +toolWindow +LastFound
GUI , Margin,, x0 y0
Gui , Add, button , vReturn default h50 w100, Return To R
WinSet, Transparent, 150
Gui , Show,,NppToR
return

ButtonReturnToR:
SplitPath, in1 , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
run , "%nppexe%" "%in1%" 
WinWait %OutFileName%
WinMenuSelectItem ,,,File,Save
WinMenuSelectItem ,,,File,Close
WinWaitClose %OutFileName%
WinActivate ahk_id %RID%
;continue on
GuiClose:
GuiEscape:
GUI destroy
ExitApp
return

