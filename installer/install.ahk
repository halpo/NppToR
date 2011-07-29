﻿;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#NoTrayIcon
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SINGLEINSTANCE force ;ignore
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On

; Command line
silent = 0
go = 0
addStartup = 1
Loop, %0%  ; For each parameter:
{
  param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
	if param = --silent
			silent = 1
	else if param = -silent
			silent = 1
	else if param = -s
			silent = 1
	else if param = -go
			go = 1
	else if param = -no-startup
			addStartup = 0
	else if param = -global
			Global = 1
	else 
		InstallDir = %param%
}

if silent
{
	if InstallDir = 
	{
		if A_IsAdmin
			InstallDir= %A_ProgramFile%\NppToR\
		else
			InstallDir= %A_APPDATA%\NppToR\
	}
	gosub doinstall
	exitapp
}
if go
{
	gosub CreateGui
	gosub Submit
}



	
;environment variables
; envget A_APPDATA, A_APPDATA
envget HOMEPATH, HOMEPATH
envget HOMEDRIVE, HOMEDRIVE
envget USERPROFILE, USERPROFILE

; RegRead, regRdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
RegRead, personalfolder, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, Personal
RegRead, startup_base, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, Startup
RegRead, start_menu_base, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, Programs
stringreplace startup,startup_base, `%USERPROFILE`%, %USERPROFILE%
stringreplace start_menu,start_menu_base, `%USERPROFILE`%, %USERPROFILE%
stringreplace HOME,personalfolder, `%USERPROFILE`%, %USERPROFILE%


CreateGui:
{
;Gui Creation
Gui, +OwnDialogs
GUI ,ADD, PIC,, %A_ScriptDir%\..\icons\NppToR.png
GUI ,FONT, s14 bold Comic Sans MS
GUI ,ADD, TEXT,ym,NppToR ~ Install
GUI ,FONT, s10 normal Georgia
GUI ,ADD, TEXT,,
(
© 2011 Andrew Redd 
Use Governed by MIT license (See License.txt)

)

GUI ,ADD, TEXT, xs w450, Install Directory
GUI ,ADD, EDIT, section wp-65 vInstallDir
GUI ,ADD, BUTTON, gdoBrowse x+5 w60 vBrowse, Browse
if InstallDir = 
{
	if A_IsAdmin
		GUICONTROL ,,InstallDir, %A_ProgramFiles%\NppToR\
	else
		GUICONTROL ,,InstallDir, %A_APPDATA%\NppToR\
}
else
	GUICONTROL ,,InstallDir, %InstallDir%
GUI	,ADD, CHECKBOX, xs w450 vaddStartup,launch at startup?.
if addStartup
	GuiControl,, addStartup, 1
else 
	GuiControl,, addStartup, 0
GUI	,ADD, CHECKBOX, xs w450 vGlobal gdoGlobalCheck,Install for all users? Will install to Program Files folder and will require admin priviledges.  Separate settings will be maintained for each user.
if A_IsAdmin
	GuiControl,, Global, 1
else 
	GuiControl,, Global, 0
GUI ,ADD, PROGRESS, wp h20 cBlue vInstallProgress
GUI ,ADD, BUTTON,section X+-155 Y+5 w75 gSubmit default vInstall,&Install
GUI ,ADD, BUTTON,gDoCancel xp+80 w75 vCancel, &Cancel
GUI ,ADD, StatusBar
GUI SHOW
return
}

DoCancel:
GuiClose:
ExitApp

doGlobalCheck:
{
	Gui Submit, NoHide 
	if Global
	{
		if InstallDir = %A_APPDATA%\NppToR\
			GUICONTROL ,,InstallDir, %A_ProgramFiles%\NppToR\
	}
	else
	{
		if InstallDir = %A_ProgramFiles%\NppToR\
			GUICONTROL ,,InstallDir, %A_APPDATA%\NppToR\
	}
	return
}

doBrowse:
{
	FileSelectFolder, IFolder , *%A_APPDATA%\NppToR\,3,Select Install Directory
	if IFolder <>
		GUICONTROL ,,InstallDir, %IFolder%
	return
} 

Submit:
{
	GUI Submit, NoHide
	GUICONTROL ,Disable, InstallDir
	GUICONTROL ,Disable, addStartup
	GUICONTROL ,Disable, BtnInstall
	GUICONTROL ,Disable, BtnCancel
	GUICONTROL ,Disable, Global
	GUICONTROL ,Disable, Install
	GUICONTROL ,Disable, Cancel
	GUICONTROL ,Disable, Browse
	if Global
	{
		if not A_IsAdmin
		{
			SB_SetText("Restarting with admin privileges")
      params = -go
			if !addStartup
				params = %params% -no-startup
			params = %params% "%InstallDir%\"
			; DllCall("shell32\ShellExecuteA"
				; , uint, 0
				; , str, "RunAs"
				; , str, A_ScriptFullPath
				; , str, params
				; , str, A_WorkingDir
				; , int, 1)  ; Last parameter: SW_SHOWNORMAL = 1
			; ExitApp
      gosub RunAsAdministrator  
    }
		else 
			gosub doinstall
	}
	else
		gosub doinstall
return
}
doinstall:
{
	;kill any current running copy
  SB_SetText("Closing any running NppToR Instances.")
	process, close, NppToR.exe
	if %errorlevel%
		winwaitclose ahk_pid %errorlevel%
	GuiControl,, InstallProgress, +10
  
	;install section
	ifnotexist %INSTALLDIR%
	{
    SB_SetText("Creating Install Directory")
		filecreatedir %INSTALLDIR%
		if %errorlevel%
		{
			if silent
				exitapp
			msgbox  64 ,Install Error, Could not create %INSTALLDIR%. Aborting
			exitapp
		}
	}
	else
	{
		IfExist %INSTALLDIR%\NppToR.exe
			FileSetAttrib , -R , %INSTALLDIR%\NppToR.exe	
	}
	;executable files
  SB_SetText("Installing NppToR.exe")
	FILEINSTALL ,..\NppToR.exe, %INSTALLDIR%\NppToR.exe,1
	if %errorlevel%
	{
		if silent
			exitapp
		msgbox  64 ,Install Error, NppToR.exe could not be copied. Aborting
		exitapp
	}
  
	if Global
	{
    SB_SetText("Setting global parameters")
		iniWrite , %Global%, %INSTALLDIR%\npptor.ini, install, global
		FileSetAttrib , +R, %INSTALLDIR%\NppToR.exe
	}
	else
  {
    SB_SetText("Setting file attributes")
		FileSetAttrib , -R, %INSTALLDIR%\NppToR.exe
	}
  SB_SetText("Installing NppEditR.exe")
  FILEINSTALL ,..\NppEditsR\NppEditR.exe, %INSTALLDIR%\NppEditR.exe,1
  SB_SetText("Writing URL Shortcut")
	IniWrite, http://npptor.sourceforge.net, %INSTALLDIR%\npptor.url, InternetShortcut, URL 
	
  SB_SetText("Copying uninstall.exe")
	FILEINSTALL ,uninstall.exe,%INSTALLDIR%\uninstall.exe,1
	;setting files
	;FILEINSTALL ,..\npptor.ini, %INSTALLDIR%\npptor.ini,0

	;documentation files
  SB_SetText("Copying documentation")  
	;FILEINSTALL ,..\iniparameters.txt,%INSTALLDIR%\iniparameters.txt,0
	FILEINSTALL ,..\License.txt,%INSTALLDIR%\License.txt,0
	;if !silent
		
	;Supporting R scripts
  SB_SetText("Copying suport scripts")  
	FILEINSTALL ,..\make_R_xml.r,%INSTALLDIR%\make_R_xml.r,0
	if !silent
		GuiControl,, InstallProgress, +10


	;set R options to work with NppToR
	;do Rprofile
  SB_SetText("Copying RProfile")  
	FILEINSTALL ,..\Rprofile.base.R, %INSTALLDIR%\Rprofile
		; optstring = options(editor="%INSTALLDIR%NppEditR.exe")
		; StringReplace options, optstring, \ , \\ , All
		; ifExist %INSTALLDIR%\Rprofile
		; {
			; FileRead, RprofileOld, %INSTALLDIR%\Rprofile
			; ifNotInString RprofileOld, %options%
				; fileappend , %options%`n , %INSTALLDIR%\Rprofile
		; } ELSE 
			; fileappend , %options%`n , %INSTALLDIR%\Rprofile
	
	if !silent
		GuiControl,, InstallProgress, +10

	;start menu entries
  SB_SetText("Setting up start menu entries")  
	SM := (Global)
		? A_StartMenuCommon
		: A_StartMenu
  SM = %SM%\Programs
	SU := (Global)
		? A_StartupCommon
		: A_Startup
	ifnotexist %SM%\NppToR
		filecreatedir %SM%\NppToR
	FileCreateShortcut, %INSTALLDIR%\NppToR.exe, %SM%\NppToR\NpptoR.lnk ,,, Enables passing code from notepad++ to the R interpreter.
	FileCreateShortcut, %INSTALLDIR%\License.txt, %SM%\NppToR\License.txt.lnk
	FileCreateShortcut, %INSTALLDIR%\npptor.url, %SM%\NppToR\Website.lnk
	FileCreateShortcut, %INSTALLDIR%\uninstall.exe, %SM%\NppToR\uninstall.lnk
	if addStartup
		FileCreateShortcut, %INSTALLDIR%\NppToR.exe, %SU%\NpptoR.lnk ,, -startup, Enables passing code from notepad++ to the R interpreter.
	if !silent
		GuiControl,, InstallProgress, +60
	
	if Global
	{
    SB_SetText("Adding auto-completion files to Notepad++")
    ping()
		RUN ,%INSTALLDIR%\NppToR.exe -add-auto-complete,,,OutputVarPID
    ping()
		WinWait ahk_pid %OutputVarPID%
		winwaitclose ahk_pid %OutputVarPID%
		FileDelete %INSTALLDIR%\make_r_xml.r.Rout
	}
	else
  {
    SB_SetText("")
    msgbox ,0, No Auto-Completion., The auto-completion database has not been generated as that might require administrator privileges.  That can be performed from the NppToR menu., 30
  }
	GuiControl,, InstallProgress, +20
	;runinstalled NppToR
	if !silent
	{
		SB_SetText("Registering task to run NppToR")
    npptorstartup = "%INSTALLDIR%NppToR.exe"
    RunAsStdUser(npptorstartup, "-startup")
		SB_SetText("Installation Finished.")
		if Global
			msgbox 0, Installation Finished, NppToR has been successfully setup on this computer.,10
		else
			msgbox 0, Installation Finished, NppToR has been successfully setup for your user profile.,10
	}
	ExitApp
	return
}

ping()
{
if A_IsCompiled
  return
static count=0
count := count+1
msgbox ,0, ping, %count% 
return
}

#include %A_ScriptDir%\scheduler.ahk