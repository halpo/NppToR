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

;kill any current running copy
process, close, NppToR.exe
if %errorlevel%
	winwaitclose ahk_pid %errorlevel%

inifile = %A_ScriptDir%\npptor.ini
iniRead, Global, %inifile%, install, global, false
if Global
{
	if not A_IsAdmin
	{
		DllCall("shell32\ShellExecuteA"
			, uint, 0
			, str, "RunAs"
			, str, A_ScriptFullPath
			, str, ""
			, str, A_WorkingDir
			, int, 1)  ; Last parameter: SW_SHOWNORMAL = 1
		ExitApp
	}
	FileDelete %A_StartupCommon%\NppToR.lnk
	FileDelete %A_StartMenuCommon%\NppToR\License.txt.lnk
	FileDelete %A_StartMenuCommon%\NppToR\NppToR.lnk
	FileDelete %A_StartMenuCommon%\NppToR\Website.lnk
	FileRemoveDir %A_StartMenuCommon%\NppToR
}
else
{
	FileDelete %A_StartupCommon%\NppToR.lnk
	FileDelete %A_StartMenuCommon%\NppToR\License.txt.lnk
	FileDelete %A_StartMenuCommon%\NppToR\NppToR.lnk
	FileDelete %A_StartMenuCommon%\NppToR\Website.lnk
	FileRemoveDir %A_StartMenu%\NppToR
}

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
ExitApp




