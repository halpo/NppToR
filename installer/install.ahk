;
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
#SINGLEINSTANCE force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On
#include %A_ScriptDir%\..\NTRError.ahk
; Command line
silent = 0
go = 0
addStartup = 1
Loop, %0%  ; For each parameter:
{
  param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
  OutputDebug NppToR:Install:Parameter Provided ``%param%`` `n
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
  else if param = -no-ac
      noAC = 1
	else 
  {
    Loop %param%, 1
      InstallDir = %A_LoopFileFullPath%
    OutputDebug NppToR:Install:Given install path is %InstallDir% `n
  }
}

if silent
{
  OutputDebug NppToR:Install: Doing Silent Install (Global=%Global%)`n
	if InstallDir = 
	{
		if A_IsAdmin {
			InstallDir= %A_ProgramFile%\NppToR\
      Global=1
		} else {
      InstallDir= %A_APPDATA%\NppToR\
    }
	}
	gosub doinstall
	exitapp
}
if go
{
  OutputDebug NppToR:Install: Received the go-ahead parameter.
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

; Tooltip  declarations
InstallDir_TT := "Where to install?"
addStartup_TT := "A link will be put in the startup folder of the start menu."
Global_TT := "settings will be maintained for each user individually."
ACCheck_TT := "Autocompletion files can be installed later from the system tray icon.  Notepad++ will need to be closed if open."
Install_TT := "Yes press it! Install me!"
Cancel_TT := "You really want to press the button to your left instead of me."

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
© 2012 Andrew Redd 
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
GUI	,ADD, CHECKBOX, xs w450 vGlobal gdoGlobalCheck,Install for all users? (Administrator rights required)
if A_IsAdmin
	GuiControl,, Global, 1
else 
	GuiControl,, Global, 0
GUI	,ADD, CHECKBOX, xs w450 vACCheck gdoACCheck,Install Autocompletion file.
GUI ,ADD, PROGRESS, wp h20 cBlue vInstallProgress
GUI ,ADD, BUTTON,section X+-155 Y+5 w75 gSubmit default vInstall,&Install
GUI ,ADD, BUTTON,gDoCancel xp+80 w75 vCancel, &Cancel
GUI ,ADD, StatusBar
OnMessage(0x200, "WM_MOUSEMOVE")

if Global {
  GUICONTROL , ENABLE, ACCheck
  if NOT noAC
    guiControl ,, ACCheck, 1
} else {
  GUICONTROL , DISABLE, ACCheck
}
GUI SHOW
return
}

DoCancel:
GuiClose:
ExitApp

doGlobalCheck:
{
  OutputDebug NppToR:Install:doGlobalCheck
	Gui Submit, NoHide 
	if Global
	{
		if InstallDir = %A_APPDATA%\NppToR\
			GUICONTROL ,,InstallDir, %A_ProgramFiles%\NppToR\
    GUICONTROL , ENABLE, ACCheck
    GUICONTROL , , ACCheck, 1
	}
	else
	{
		if InstallDir = %A_ProgramFiles%\NppToR\
			GUICONTROL ,,InstallDir, %A_APPDATA%\NppToR\
    GUICONTROL , DISABLE, ACCheck
    GUICONTROL , , ACCheck, 0
	}
	return
}
doACCheck:
{
  outputdebug NppToR:Install:doACCcheck:ACCheck=%ACCheck%`n
  return
}
doBrowse:
{
  OutputDebug NppToR:Install:doBrowse
	FileSelectFolder, IFolder , *%A_APPDATA%\NppToR\,3,Select Install Directory
	if IFolder <>
		GUICONTROL ,,InstallDir, %IFolder%
	return
} 

Submit:
{
  OutputDebug NppToR:Install:Submit
	GUI Submit, NoHide
	GUICONTROL ,Disable, InstallDir
	GUICONTROL ,Disable, addStartup
	GUICONTROL ,Disable, BtnInstall
	GUICONTROL ,Disable, BtnCancel
	GUICONTROL ,Disable, Global
	GUICONTROL ,Disable, Install
	GUICONTROL ,Disable, Cancel
	GUICONTROL ,Disable, Browse
	GUICONTROL ,Disable, ACCheck
	if Global
	{
		if not A_IsAdmin
		{
			SB_SetText("Restarting with admin privileges")
      params = -go -global
			if !addStartup
				params = %params% -no-startup
			if !ACCheck
				params = %params% -no-ac
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
  OutputDebug NppToR:Install:doinstall: Starting Install.`n
	;kill any current running copy
  SB_SetText("Closing any running NppToR Instances.")
	process, close, NppToR.exe
	if %errorlevel%
		winwaitclose ahk_pid %errorlevel%
	GuiControl,, InstallProgress, +10
  
	;install section
	ifnotexist %INSTALLDIR%
	{
    OutputDebug NppToR:Install:Creating install Directory (%INSTALLDIR%)`n
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
  OutputDebug NppToR:Install:Installing NppToR.exe `n
  SB_SetText("Installing NppToR.exe")
	FILEINSTALL , ..\build\NppToR.exe, %INSTALLDIR%\NppToR.exe, 1
	if %errorlevel%
	{
		if silent
			exitapp
		msgbox  64, Install Error, NppToR.exe could not be copied. Aborting
		exitapp
	}
  
  ;icons
  OutputDebug NppToR:Install:Installing icons `n
  SB_SetText("Installing icons")
  ifnotexist %INSTALLDIR%\Icons
	{
		filecreatedir %INSTALLDIR%\Icons
  }
  FILEINSTALL , ..\icons\NppToR.png, %INSTALLDIR%\Icons\NppToR.png,1
  
	if Global
	{
    OutputDebug NppToR:Install:Setting Global Parameters`n
    SB_SetText("Setting global parameters")
		iniWrite , %Global%, %INSTALLDIR%\npptor.ini, install, global
		FileSetAttrib , +R, %INSTALLDIR%\NppToR.exe
	}
	else
  {
    OutputDebug NppToR:Install:Setting File attributes`n
    SB_SetText("Setting file attributes")
		FileSetAttrib , -R, %INSTALLDIR%\NppToR.exe
	}
  OutputDebug NppToR:Install:installing NppEditR.exe`n
  SB_SetText("Installing NppEditR.exe")
  FILEINSTALL , ..\build\NppEditR.exe, %INSTALLDIR%\NppEditR.exe,1
  OutputDebug NppToR:Install:Writing URL Shortcut`n
  SB_SetText("Writing URL Shortcut")
	IniWrite, http://npptor.sourceforge.net, %INSTALLDIR%\npptor.url, InternetShortcut, URL 
	
  OutputDebug NppToR:Install:Copying uninstall.exe`n
  SB_SetText("Copying uninstall.exe")
	FILEINSTALL , ..\build\uninstall.exe, %INSTALLDIR%\uninstall.exe, 1

	;Documentation files
  OutputDebug NppToR:Install:Copying documentation`n
  SB_SetText("Copying documentation")  
	FILEINSTALL ,..\License.txt,%INSTALLDIR%\License.txt,0
		
	;Supporting R scripts
  OutputDebug NppToR:Install:Copying suport scripts`n
  SB_SetText("Copying suport scripts")  
	FILEINSTALL ,..\make_R_xml.r,%INSTALLDIR%\make_R_xml.r,0
	if !silent
		GuiControl,, InstallProgress, +10

	;set R options to work with NppToR
	;do Rprofile
  OutputDebug NppToR:Install:Writing RProfile`n
  SB_SetText("Writing RProfile")  
RprofileText = 
(
  message("\nThis is a session spawned by NppToR.\n\n")
  if(file.exists(".Rprofile"))source(".Rprofile")  else 
  if(file.exists(path.expand("~/Rprofile"))) source(path.expand("~/Rprofile"))
  if(file.exists(path.expand("~/.Rprofile"))) source(path.expand("~/.Rprofile"))
  if(file.exists(path.expand("~/Rprofile.R"))) source(path.expand("~/Rprofile.R"))
)
  IfExist %INSTALLDIR%\Rprofile
    FileDelete %INSTALLDIR%\Rprofile
  FileAppend , %RprofileText% , %INSTALLDIR%\Rprofile
  optstring = options(editor="%INSTALLDIR%NppEditR.exe")
  StringReplace options, optstring, \ , \\ , All
	FileAppend , `n%options%`n , %INSTALLDIR%\Rprofile
	
	if !silent
		GuiControl,, InstallProgress, +10

	;start menu entries
  OutputDebug NppToR:Install:start menu entries
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
	
  ;AutoCompletion
  gosub addAC

	GuiControl,, InstallProgress, +20
	;runinstalled NppToR
	if !silent
	{
    OutputDebug NppToR:Install:Registering task
		SB_SetText("Registering task to run NppToR")
    npptorstartup = "%INSTALLDIR%\NppToR.exe"
    RunAsStdUser(npptorstartup, "-startup")
		SB_SetText("Installation Finished.")
		if Global
			msgbox 0, Installation Finished, NppToR has been successfully setup on this computer.,10
		else
			msgbox 0, Installation Finished, NppToR has been successfully setup for your user profile.,10
	}
  OutputDebug NppToR:Install:doinstall: Install Finished.`n
	ExitApp
	return
}
AddAC:
{
  OutputDebug NppToR:Install:AddAC:ACCheck=%ACCheck% `n
  if silent
    return
	if Global AND ACCheck
	{
    OutputDebug NppToR:Install:Adding Auto-Completion
    SB_SetText("Adding auto-completion files to Notepad++")
    outputdebug % dstring . "`n" ;%
		RUN , %INSTALLDIR%\NppToR.exe -add-auto-complete,,,OutputVarPID
    outputdebug % dstring . "`n" ;%
		WinWait ahk_pid %OutputVarPID%
		winwaitclose ahk_pid %OutputVarPID%
		FileDelete %INSTALLDIR%\make_r_xml.r.Rout
	}
	else
  {
    SB_SetText("")
    ; msgbox ,0, No Auto-Completion., The auto-completion database has not been generated as that might require administrator privileges.  That can be performed from the NppToR menu., 30
  }
  return
}
WM_MOUSEMOVE()
{
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
    CurrControl := A_GuiControl
    ;outputdebug NppToR:Install:Current Control is %CurrControl%.`n
    If (CurrControl <> PrevControl and not InStr(CurrControl, " ") and not InStr(CurrControl, "+"))
    {
        ToolTip  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 1000
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    OutputDebug Tooltip names is:%CurrControl%_TT `n
    OutputDebug % "Tooltip is:" . %CurrControl%_TT . "`n" ;%
    ToolTip % %CurrControl%_TT  ;% The leading percent sign tell it to use an expression.
    SetTimer, RemoveToolTip, 7000
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return
}

#include %A_ScriptDir%\scheduler.ahk