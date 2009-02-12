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

Fileappend ,test,testfile.txt

;environment variables
envget APPDATA, APPDATA
envget HOMEPATH, HOMEPATH
envget HOMEDRIVE, HOMEDRIVE
HOME = %HOMEDRIVE%%HOMEPATH%

RegRead, regRdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
RegRead, Startup, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurentVersion\Explorer\User Shell Folders\Startup, Startup
msgbox %Startup%

;Gui Creation
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
;executable files
FILEINSTALL ,..\NppToR.exe, %INSTALLDIR%\,1
FILEINSTALL ,..\NppEditsR\NppEditsR.exe, %INSTALLDIR%,1
FILEINSTALL ,..\syntax\GenerateSyntaxFiles.exe, %INSTALLDIR%,1
;FILEINSTALL ,uninstall.exe,%INSTALLDIR%,1
GuiControl,, InstallProgress, +10  ; Increase the current position by 20.

;setting files
FILEINSTALL ,..\npptor.ini, %INSTALLDIR%,0

;documentation files
FILEINSTALL ,..\iniparameters.txt,%INSTALLDIR%,0
FILEINSTALL ,..\License.txt,%INSTALLDIR%,0
GuiControl,, InstallProgress, +10  ; Increase the current position by 20.

;write ini settings
if Rdir<>regRdir
{
  IniWrite, Value, %INSTALLDIR%\npptor.ini, executables, Rhome 
}
if NppConfig<>%APPDATA%\Notepad++
{
  IniWrite, Value, %INSTALLDIR%\npptor.ini, executables, Npp 
}
GuiControl,, InstallProgress, +10  ; Increase the current position by 20.


;set R options to work with NppToR
if doRprofile
	fileappend ,options(editor="%INSTALLDIR%\NppEditsR.exe") ,%HOME%\Rprofile
if doRconsole
	fileappend ,MDI = no, %HOME%\Rconsole
GuiControl,, InstallProgress, +10  ; Increase the current position by 20.

if addStartup
	FileCreateShortcut, %INSTALLDIR%\NppToR.exe, %Startup%\NpptoR.lnk ,, -startup, Enables passing code from notepad++ to the R interpreter.
GuiControl,, InstallProgress, +10  ; Increase the current position by 20.
	
;generate syntax
ifwinexist ahk_class Notepad++
  winclose,,,15
RUNWAIT ,%INSTALLDIR%\GenerateSyntaxFiles.rb "%Rhome%" "%NppConfig%"
GuiControl,, InstallProgress, +50  ; Increase the current position by 20.

;runinstalled NppToR
RUN ,%INSTALLDIR%\NppToR.exe -startup
return

DoCancel:
GuiClose:
ExitApp
