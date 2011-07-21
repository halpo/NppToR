;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

; #NoTrayIcon
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On
if A_IsCompiled
{
;kill any current running copy
process, close, NppToR.exe
if %errorlevel%
	winwaitclose ahk_pid %errorlevel%

inifile = %A_ScriptDir%\npptor.ini
iniRead, Global, %inifile%, install, global, false
if Global
  gosub RunAsAdministrator
FileDelete %A_StartupCommon%\NppToR.lnk
FileDelete %A_StartMenuCommon%\NppToR\License.txt.lnk
FileDelete %A_StartMenuCommon%\NppToR\NppToR.lnk
FileDelete %A_StartMenuCommon%\NppToR\Website.lnk
FileRemoveDir %A_StartMenuCommon%\NppToR
FileDelete %A_StartupCommon%\NppToR.lnk
FileDelete %A_StartMenu%\NppToR\License.txt.lnk
FileDelete %A_StartMenu%\NppToR\NppToR.lnk
FileDelete %A_StartMenu%\NppToR\Website.lnk
FileRemoveDir %A_StartMenu%\NppToR


FileSetAttrib , -R, %A_ScriptDir%\NppToR.exe
FileDelete %A_ScriptDir%\*

tmpfile = %A_TEMP%\npptor-uninstall.bat
delscript = 
(
sleep 300
del /F /Q %A_ScriptFullPath%
rd /S /Q %A_ScriptDir%
del %tmpfile%
)

IfExist %tmpfile%
	FileDelete %tmpfile%
FileAppend , %delscript%, %tmpfile%
run %tmpfile%
}
else
{
  msgbox ,64, NppToR::Error Uncompiled uninstall, This uninstall script should never be run uncompiled.
}
ExitApp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\scheduler.ahk