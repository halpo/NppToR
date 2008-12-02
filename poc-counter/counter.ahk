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



Gui, -AlwaysOnTop -SysMenu -Caption; +Owner avoids a taskbar button.
Gui, Add, text, section ,Progress 1
Gui, Add, Progress, ys w100 h15 cBlue vMyProgress -smooth
Gui, Add, Button, Default, Close
Gui, Show, x1111 y800
loop 10
{
Guicontrol,, MyProgress, +10
gosub addproc
Gui ,Show, AutoSize
sleep 1000
}

return

addProc:
gui ,Add, pic, section gProcKill, %A_ScriptDir%\stop.png
GUI ,Add, text, ys, File Name
return

ProcKill:
msgbox killing...
return

ButtonClose:
GuiClose:
GuiEscape:
ExitApp
return

F10::
ExitApp
return

^F10::
Gui, Add, text,, more text
Gui, Show, AutoSize
return
