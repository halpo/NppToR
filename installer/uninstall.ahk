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

; msgbox %A_StartMenuCommon%
; msgbox %A_StartupCommon%
; msgbox %A_StartMenu%
; msgbox %A_Startup%



if A_IsCompiled
{
msgbox ,4,Uninstall NppToR?, This will uninstall all copies of NppToR, including all settings. Uninstall?
ifmsgbox No
  ExitApp
  
;kill any current running copy
process, close, NppToR.exe
if %errorlevel%
	winwaitclose ahk_pid %errorlevel%

inifile = %A_ScriptDir%\npptor.ini
iniRead, Global, %inifile%, install, global, 0
if Global
  gosub RunAsAdministrator

if A_IsAdmin
{
FileDelete %A_StartupCommon%\NppToR*
FileDelete %A_StartMenuCommon%\Programs\NppToR\*
FileRemoveDir %A_StartMenuCommon%\Programs\NppToR
}
FileDelete %A_Startup%\NppToR*
FileDelete %A_StartMenu%\Programs\NppToR\*
FileRemoveDir %A_StartMenu%\Programs\NppToR
; FileDelete %A_StartMenuCommon%\NppToR\License.txt.lnk
; FileDelete %A_StartMenuCommon%\NppToR\NppToR.lnk
; FileDelete %A_StartMenuCommon%\NppToR\Website.lnk
; FileDelete %A_StartMenu%\NppToR\NppToR.lnk
; FileDelete %A_StartMenu%\NppToR\Website.lnk

FileSetAttrib , -R, %A_ScriptDir%\NppToR.exe
FileDelete %A_ScriptDir%\*

msgbox %A_ScriptFullPath%
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