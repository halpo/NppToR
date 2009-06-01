;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#NoTrayIcon
DetectHiddenWindows, On

;kill any current running copy
process, close, NpptoR.exe
if %errorlevel%
	winwaitclose ahk_pid %errorlevel%

;environment variables
envget APPDATA, APPDATA
envget HOMEPATH, HOMEPATH
envget HOMEDRIVE, HOMEDRIVE
envget USERPROFILE, USERPROFILE

RegRead, regRdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
RegRead, personalfolder, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, Personal
RegRead, startup_base, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, Startup
RegRead, start_menu_base, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, Programs
stringreplace startup,startup_base, `%USERPROFILE`%, %USERPROFILE%
stringreplace start_menu,start_menu_base, `%USERPROFILE`%, %USERPROFILE%
stringreplace HOME,personalfolder, `%USERPROFILE`%, %USERPROFILE%

;Gui Creation
Gui, +OwnDialogs
GUI ,ADD, PIC,, %A_ScriptDir%\..\icons\NppToR.png
GUI ,FONT, s14 bold Comic Sans MS
GUI ,ADD, TEXT,ym,NppToR ~ Install
GUI ,FONT, s10 normal Georgia
GUI ,ADD, TEXT,,
(
© 2009 Andrew Redd 
Use Govorned by MIT license (See License.txt)
)


GUI ,ADD, TEXT, xs w500, Install Directory
GUI ,ADD, EDIT, wp vInstallDir
GUICONTROL ,,InstallDir, %APPDATA%\NppToR\
GUI ,ADD, TEXT, xs wp, R home directory (do not include \bin\)
GUI ,ADD, EDIT, wp vRdir
GUICONTROL ,,Rdir,%regRdir%
GUI ,ADD, TEXT, wp, Notepad++ config directory (defaults to `%APPDATA`%\Notepad++)
GUI ,ADD, EDIT, wp vNppConfig 
GUICONTROL ,,NppConfig, %APPDATA%\Notepad++\
; GUI	,ADD, CHECKBOX,wp vdoRconsole checked,Add/Edit User Rconsole to make use of SDI(required by NppToR)
; GUI	,ADD, CHECKBOX,wp vdoRprofile checked,Add/Edit User Rprofile to make Notepad++ the editor for editing initiated from R.
GUI	,ADD, CHECKBOX,wp vchkSyntax checked, Extract keywords for non-priority keywords from R-packages.
GUI	,ADD, CHECKBOX,wp vaddStartup checked,launch at startup?.
GUI ,ADD, PROGRESS, wp h20 cBlue vInstallProgress
GUI ,ADD,BUTTON,section X+-155 Y+5 w75 gdoinstall default,&Install
GUI ,ADD,BUTTON,gDoCancel xp+80 w75, &Cancel


GUI SHOW
return

doinstall:
GUI Submit, NoHide
GUICONTROL ,Disable, InstallDir
GUICONTROL ,Disable, Rdir
GUICONTROL ,Disable, NppConfig
GUICONTROL ,Disable, doRconsole
GUICONTROL ,Disable, doRprofile
GUICONTROL ,Disable, chkSyntax
GUICONTROL ,Disable, addStartup
GUICONTROL ,Disable, BtnInstall
GUICONTROL ,Disable, BtnCancel

;install section
ifnotexist %INSTALLDIR%
	filecreatedir %INSTALLDIR%
;executable files
FILEINSTALL ,..\NppToR.exe, %INSTALLDIR%\NppToR.exe,1
if %errorlevel%
	msgbox  2 ,NppToR.exe could not be copied. Continue?,Could not be copied
ifmsgbox abort
	exitapp
FILEINSTALL ,..\NppEditsR\NppEditR.exe, %INSTALLDIR%\NppEditR.exe,1
FILEINSTALL ,..\syntax\GenerateSyntaxFiles.exe, %INSTALLDIR%\GenerateSyntaxFiles.exe,1
IniWrite, http://npptor.sourceforge.net, %INSTALLDIR%\npptor.url, InternetShortcut, URL 
;FILEINSTALL ,uninstall.exe,%INSTALLDIR%,1
GuiControl,, InstallProgress, +10

;setting files
FILEINSTALL ,..\npptor.ini, %INSTALLDIR%\npptor.ini,0

;documentation files
FILEINSTALL ,..\iniparameters.txt,%INSTALLDIR%\iniparameters.txt,0
FILEINSTALL ,..\License.txt,%INSTALLDIR%\License.txt,0
GuiControl,, InstallProgress, +10

;write ini settings
if Rdir<>regRdir
  IniWrite, %Rdir%, %INSTALLDIR%\npptor.ini, executables, Rhome 

; if NppConfig<>%APPDATA%\Notepad++
; {
  ; IniWrite, Value, %INSTALLDIR%\npptor.ini, executables, Npp 
; }
GuiControl,, InstallProgress, +10


;set R options to work with NppToR
;if doRprofile
; {
	optstring = options(editor="%INSTALLDIR%NppEditR.exe")
	StringReplace options, optstring, \ , \\ , All
	ifExist %INSTALLDIR%\Rprofile
	{
		FileRead, RprofileOld, %INSTALLDIR%\Rprofile
		ifNotInString RprofileOld, %options%
			fileappend , %options%`n , %INSTALLDIR%\Rprofile
	} ELSE 
		fileappend , %options%`n , %INSTALLDIR%\Rprofile
; }
; if doRconsole
	ifExist %INSTALLDIR%\Rconsole
	{
		FileRead, RconsoleOld, %INSTALLDIR%\Rconsole
		ifNotInString RconsoleOld, MDI = no
		fileappend ,MDI = no`n, %INSTALLDIR%\Rconsole
	} ELSE
		fileappend ,MDI = no`n, %INSTALLDIR%\Rconsole
GuiControl,, InstallProgress, +10

;start menu entries
ifnotexist %start_menu%\NppToR
	filecreatedir %start_menu%\NppToR
FileCreateShortcut, %INSTALLDIR%\NppToR.exe, %start_menu%\NppToR\NpptoR.lnk ,,, Enables passing code from notepad++ to the R interpreter.
FileCreateShortcut, %INSTALLDIR%\License.txt, %start_menu%\NppToR\License.txt.lnk
FileCreateShortcut, %INSTALLDIR%\npptor.url, %start_menu%\NppToR\Website.lnk
if addStartup
	FileCreateShortcut, %INSTALLDIR%\NppToR.exe, %Startup%\NpptoR.lnk ,, -startup, Enables passing code from notepad++ to the R interpreter.
GuiControl,, InstallProgress, +10
	
;generate syntax
ifwinexist ahk_class Notepad++
{
	winclose,,,15
	restart_npp = true
} else restart_npp = false
if chkSyntax 
	RUNWAIT ,%INSTALLDIR%\GenerateSyntaxFiles.exe --rhome="%Rdir%" --npp-config="%NppConfig%",, UseErrorLevel
else 
	RUNWAIT ,%INSTALLDIR%\GenerateSyntaxFiles.exe -N --file=internal --rhome="%Rdir%" --npp-config="%NppConfig%",, UseErrorLevel
if ErrorLevel = 2
	msgbox ,48,Error: File not found, There were problems finding the R and Notepad++ folders, please check your settings and retry
else if ErrorLevel = 3 
	msgbox ,48,Error: Too many keywords, "The packages that you have installed result in too many keywords for Notepad to handle.  Please exclude some packages or narrow the packages list to only those you use regularly."
else if ErrorLevel
	msgbox ,48,Error: Generic, Sorry. There was an error I couldn't predict generating the syntax. Perhaps try again with different options.

GuiControl,, InstallProgress, +50 

;runinstalled NppToR
if %restart_npp%
	RUN ,%INSTALLDIR%\NppToR.exe
else
	RUN ,%INSTALLDIR%\NppToR.exe -startup
msgbox 0, Installation Finished, NppToR has been successfully setup for you user profile.,10
ExitApp
return

DoCancel:
GuiClose:
ExitApp
