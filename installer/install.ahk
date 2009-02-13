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
RegRead, startup, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, Startup
RegRead, start_menu_base, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, Programs
stringreplace start_menu,start_menu_base, `%USERPROFILE`%, %USERPROFILE%
stringreplace HOME,personalfolder, `%USERPROFILE`%, %USERPROFILE%

;Gui Creation
Gui, +OwnDialogs
GUI ,ADD, PIC,, %A_ScriptDir%\..\icons\NppToR.png
GUI ,FONT, s14 bold
GUI ,ADD, TEXT,ym,NppToR Install
GUI ,FONT, s10 normal
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
GUI	,ADD, CHECKBOX,wp vdoRconsole checked,Add/Edit User Rconsole to make use of SDI(required by NppToR)
GUI	,ADD, CHECKBOX,wp vdoRprofile checked,Add/Edit User Rprofile to make Notepad++ the editor for editing initiated from R.
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
if doRprofile
{
	optstring = options(editor="%INSTALLDIR%NppEditsR.exe")`n
	StringReplace options, optstring, \ , / , All
	fileappend , %options% , %INSTALLDIR%\Rprofile
}
if doRconsole
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
RUNWAIT ,%INSTALLDIR%\GenerateSyntaxFiles.exe "%Rdir%" "%NppConfig%"
GuiControl,, InstallProgress, +50 

;runinstalled NppToR
if restart_npp = true
	RUN ,%INSTALLDIR%\NppToR.exe
else
	RUN ,%INSTALLDIR%\NppToR.exe -startup
ExitApp
msgbox 0, Installation Finished, NppToR has been successfully setup for you user profile.
return

DoCancel:
GuiClose:
ExitApp
