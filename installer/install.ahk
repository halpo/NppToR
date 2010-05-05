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
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On

; Command line
silent = 0
addStartup = 1
Loop, %0%  ; For each parameter:
{
  param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
	if param = --silent
		silent = 1
	if param = -silent
		silent = 1
	if param = -s
		silent = 1
	if param = -no-startup
		addStartup = 0
}

;kill any current running copy
process, close, NpptoR.exe
if %errorlevel%
	winwaitclose ahk_pid %errorlevel%

;environment variables
envget APPDATA, APPDATA
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

if !silent
{
;Gui Creation
Gui, +OwnDialogs
GUI ,ADD, PIC,, %A_ScriptDir%\..\icons\NppToR.png
GUI ,FONT, s14 bold Comic Sans MS
GUI ,ADD, TEXT,ym,NppToR ~ Install
GUI ,FONT, s10 normal Georgia
GUI ,ADD, TEXT,,
(
© 2010 Andrew Redd 
Use Govorned by MIT license (See License.txt)
)

GUI ,ADD, TEXT, xs w500, Install Directory
GUI ,ADD, EDIT, wp vInstallDir
GUICONTROL ,,InstallDir, %APPDATA%\NppToR\
GUICONTROL ,,NppConfig, %APPDATA%\Notepad++\
GUI	,ADD, CHECKBOX,wp vaddStartup checked,launch at startup?.
GUI ,ADD, PROGRESS, wp h20 cBlue vInstallProgress
GUI ,ADD,BUTTON,section X+-155 Y+5 w75 gdoinstall default,&Install
GUI ,ADD,BUTTON,gDoCancel xp+80 w75, &Cancel

GUI SHOW
}
else {
	NppConfig =  %APPDATA%\Notepad++\
	InstallDir= %APPDATA%\NppToR\
	gosub doinstall
}
return
 

doinstall:
if !silent
{
GUI Submit, NoHide
GUICONTROL ,Disable, InstallDir
GUICONTROL ,Disable, NppConfig
GUICONTROL ,Disable, addStartup
GUICONTROL ,Disable, BtnInstall
GUICONTROL ,Disable, BtnCancel
}
;install section
ifnotexist %INSTALLDIR%
	filecreatedir %INSTALLDIR%
;executable files
FILEINSTALL ,..\NppToR.exe, %INSTALLDIR%\NppToR.exe,1
if %errorlevel%
{
	if silent
		exitapp
	msgbox  2 ,NppToR.exe could not be copied. Continue?,Could not be copied
	ifmsgbox abort
		exitapp
}
FILEINSTALL ,..\NppEditsR\NppEditR.exe, %INSTALLDIR%\NppEditR.exe,1
FILEINSTALL ,..\syntax\GenerateSyntaxFiles.exe, %INSTALLDIR%\GenerateSyntaxFiles.exe,1
IniWrite, http://npptor.sourceforge.net, %INSTALLDIR%\npptor.url, InternetShortcut, URL 
;FILEINSTALL ,uninstall.exe,%INSTALLDIR%,1
if !silent
	GuiControl,, InstallProgress, +10

;setting files
FILEINSTALL ,..\npptor.ini, %INSTALLDIR%\npptor.ini,0

;documentation files
FILEINSTALL ,..\iniparameters.txt,%INSTALLDIR%\iniparameters.txt,0
FILEINSTALL ,..\License.txt,%INSTALLDIR%\License.txt,0
if !silent
	GuiControl,, InstallProgress, +10

;write ini settings
; if Rdir<>regRdir
  ; IniWrite, %Rdir%, %INSTALLDIR%\npptor.ini, executables, Rhome 

; if NppConfig<>%APPDATA%\Notepad++
; {
  ; IniWrite, Value, %INSTALLDIR%\npptor.ini, executables, Npp 
; }
if !silent
	GuiControl,, InstallProgress, +10


;set R options to work with NppToR
;do Rprofile
	optstring = options(editor="%INSTALLDIR%NppEditR.exe")
	StringReplace options, optstring, \ , \\ , All
	ifExist %INSTALLDIR%\Rprofile
	{
		FileRead, RprofileOld, %INSTALLDIR%\Rprofile
		ifNotInString RprofileOld, %options%
			fileappend , %options%`n , %INSTALLDIR%\Rprofile
	} ELSE 
		fileappend , %options%`n , %INSTALLDIR%\Rprofile

; do Rconsole
	ifExist %INSTALLDIR%\Rconsole
	{
		FileRead, RconsoleOld, %INSTALLDIR%\Rconsole
		ifNotInString RconsoleOld, MDI = no
		fileappend ,MDI = no`n, %INSTALLDIR%\Rconsole
	} ELSE
		fileappend ,MDI = no`n, %INSTALLDIR%\Rconsole
if !silent
	GuiControl,, InstallProgress, +10

;start menu entries
ifnotexist %start_menu%\NppToR
	filecreatedir %start_menu%\NppToR
FileCreateShortcut, %INSTALLDIR%\NppToR.exe, %start_menu%\NppToR\NpptoR.lnk ,,, Enables passing code from notepad++ to the R interpreter.
FileCreateShortcut, %INSTALLDIR%\License.txt, %start_menu%\NppToR\License.txt.lnk
FileCreateShortcut, %INSTALLDIR%\npptor.url, %start_menu%\NppToR\Website.lnk
if addStartup
	FileCreateShortcut, %INSTALLDIR%\NppToR.exe, %Startup%\NpptoR.lnk ,, -startup, Enables passing code from notepad++ to the R interpreter.
if !silent
	GuiControl,, InstallProgress, +60

;runinstalled NppToR
; if %restart_npp%
	; RUN ,%INSTALLDIR%\NppToR.exe
; else
if !silent
{
	RUN ,%INSTALLDIR%\NppToR.exe -startup
	msgbox 0, Installation Finished, NppToR has been successfully setup for your user profile.,10
}
ExitApp
return

DoCancel:
GuiClose:
ExitApp
