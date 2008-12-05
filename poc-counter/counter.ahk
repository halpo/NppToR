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

Nproc = 0	;Hold number of processes
MaxProc = 5	; 

CustomColor = 123456  ; Can be any RGB color (it will be made transparent below).
Gui, +AlwaysOnTop +toolWindow +LastFound
GUI, Color, %customColor%
GUI, Margin, x5 y5
GUI, Font, S10 bold
Gui, Add, text, section ,NppToR - Active Simulations
GUI, Font, norm s8
GUI, Add, Button, x+10 ys vBtnKill c%CustomColor%, Kill Simulation
Gui, Add, Button, Default x ys, Hide
GUI, Add, ListView, section xs r5 w330 vProcList gListViewClick, PID|LongTime|Start|Where|File
; lv_Modify(0,N 0)
WinSet, TransColor, %CustomColor% 200
; WinSet, Transparent, 200
; GUI, Show, x1111 y800 NoActivate, NppToR - Simulations
; GUI, Hide

return

F10::
addProc(0,"This File","")
return

ListViewClick:
if A_GuiEvent = DoubleClick
{
    LV_GetText(PID, A_EventInfo,1)
    LV_GetText(LongTime, A_EventInfo, 2)
    LV_GetText(File, A_EventInfo, 5)
	CurrTime = %A_NOW%
	msgbox %CurrTime%
	msgbox %LongTime%
	ENVSUB CurrTime, LongTime, minutes
	msgbox %CurrTime%
    ToolTip Simulation(PID:%PID%) for file "%File%" has been running for %CurrTime% minutes.
	SetTimer, RemoveToolTip, 5000
}
return
RemoveToolTip:
{
SetTimer, RemoveToolTip, Off
ToolTip
return
}
addProc(PID,FileName, Where)
{
LongTime = %A_NOW%
FormatTime, TimeString,%Now%,Time
rtn := LV_Add("", PID,LongTime,TimeString,Where,FileName)
lv_modifyCol()
lv_modifyCol(1,"N 0") ; hide PID column
lv_modifyCol(2,"N 0") ; hide long time column
Gui ,show,NoActivate
return
}

ButtonKillSimulation:
Loop
{
    RowNumber := LV_GetNext(0)  ; Resume the search at the row after that found by the previous iteration.
    if not RowNumber  ; The above returned zero, so there are no more selected rows.
        break
    LV_GetText(PID, RowNumber,1)
    LV_GetText(where, RowNumber,4)
    LV_GetText(FileName, RowNumber,5)
	ProcKill(RowNumber, PID)
}
return

ProcKill(row, PID)
{
;winkill ahk_pid %PID%
lv_delete(row)
return
}


ButtonHide:
ButtonClose:
GuiClose:
GuiEscape:
GUI Hide
return

