;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

CustomColor = 123456  ; Can be any RGB color (it will be made transparent below).

makeCounter:
{
Gui, +AlwaysOnTop +toolWindow +LastFound
GUI, Color, %customColor%
GUI, Margin, x5 y5
GUI, Font, S10 bold
GUI, Add, text, section ,NppToR - Active Simulations
GUI, Font, norm s8
GUI, Add, Button, x+10 ys vBtnKill c%CustomColor%, Kill Simulation
Gui, Add, Button, Default x ys, Hide
GUI, Add, ListView, section xs r5 w330 vProcList gListViewClick, PID|LongTime|Start|Where|File
;WinSet, TransColor, %CustomColor% 200
WinSet, Transparent, 200
return
}
showCounter:
{
	GUI Show
	return
}
ListViewClick:
{
if A_GuiEvent = DoubleClick
{
    LV_GetText(PID, A_EventInfo,1)
    LV_GetText(LongTime, A_EventInfo, 2)
    LV_GetText(File, A_EventInfo, 5)
	CurrTime = %A_NOW%
	ENVSUB CurrTime, LongTime, seconds
	Seconds := Mod(CurrTime,60)
	Minutes := Floor(Mod(CurrTime,60*60)/60)
	Hours	:= Floor(Mod(CurrTime,60*60*24)/24)
	Days	:= Floor(CurrTime/(60*60*24))
	CurrTime := ((days>0) ? (A_Space . days . " days") : ("")) . ((hours>0) ? (A_Space . Hours . " hours") : ("")) . ((minutes>0) ? (A_SPACE . minutes . " minutes") : ("")) . ((seconds>0) ? (A_SPACE . seconds . " seconds") : (""))
    ToolTip Simulation(PID:%PID%) for file "%File%" has been running for%CurrTime%.
	SetTimer, RemoveToolTip, 2500
}
return
}
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
lv_modifyCol(1,"N 0") 	; hide PID column
lv_modifyCol(2,"N 0") 	; hide long time column
GUI , show,NoActivate
return
}

ButtonKillSimulation:
{
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
}
ProcKill(row, PID)
{
winkill ahk_pid %PID%
;lv_delete(row)
RemoveProc(PID)
return
}

RemoveProc(PID)
{
Loop % LV_GetCount() ;%
{
    LV_GetText(rowPID, A_Index, 1)
    if(rowPID = PID)
    {
		lv_delete( A_Index )  ; Select each row whose first field contains the filter-text.
		if not LV_GetCount()
			GUI hide
		break
	}
}
return
}


ButtonHide:
GUI Hide
return

; ButtonClose:
; GuiClose:
; GuiEscape:
; GUI hide
; return
