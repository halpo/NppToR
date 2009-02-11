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

GUI ,ADD, PIC,, %A_ScriptDir%\..\icons\NppToR.png
GUI ,FONT, s14 bold
GUI ,ADD, TEXT,ym,NppToR Install
GUI ,FONT, s10 normal
GUI ,ADD, TEXT,,
(
© 2009 Andrew Redd 
Use Govorned by MIT license (See License.txt)
)
GUI ,ADD, TEXT, xs, R install directory (read from registry if left blank, do not include \bin\)
GUI ,ADD, EDIT, wp vRdir
GUI ,ADD, TEXT, wp, Notepad++ config directory (defaults to `%APPDATA`%\Notepad++)
GUI ,ADD, EDIT, wp vNppdir 
GUI	,ADD, CHECKBOX,wp vdoRconsole checked,Add/Edit User Rconsole to make use of SDI(required by NppToR)
GUI	,ADD, CHECKBOX,wp vdoRprofile checked,Add/Edit User Rprofile to make Notepad++ the editor for editing initiated from R.
GUI ,SUBMIT 
GUI ,ADD,BUTTON,X+-75 Y+5 w75 gdoinstall,&Install
GUI SHOW
return

doinstall:
GUI Submit, NoHide
msgbox youclicked do install
msgbox %Rdir%
msgbox %Nppdir%
exitapp
return
RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath


GuiClose:
ExitApp
