
; read replacements
readQuickKeys:
{
	ifWinExist ahk_class Notepad++
	ifWinExist
	QuickKeysFile = %A_ScriptDir%\quickkeys.txt
	if(Global)
	{
		ifNotExist %QuickKeysFile%
			QuickKeysFile = %A_AppData%\NppToR\quickkeys.txt
	}
	ifNotExist %QuickKeysFile%
		gosub makeQuickKeyTxt
  
  QK_CMDS := Object()
  QK_Index=0
	Loop, Read, %QuickKeysFile%
	{
		StringLeft, first, A_LoopReadLine,1
		if first = `;
		  continue
    if A_LoopReadLine=
      continue
		StringSplit, _QK_Line_, A_LoopReadLine, =, %A_Space%%A_Tab%
    QK_CMDS[_QK_LINE_1]:= _QK_LINE_2
    hotkey, %_QK_LINE_1%, doQuickKey


    continue ;early stop below is old code 
	}
	ifWinExist 
return
}
doQuickKey:
{
	Key = %A_ThisHotkey%
  cmd := QK_CMDS[key]
  ifinstring ,cmd,$word$ 
  {
    word := NppGetWord()
    StringReplace, cmd, cmd, $word$, %word%, All
  }
  ifinstring ,cmd,$line$
  {
    ;TODO
  }
	oldclipboard := ClipboardAll
	clipboard = %cmd%`r`n
  errorlevel:=0
  gosub Rpaste
	if restoreclipboard
	{
		sleep %Rpastewait%
		clipboard := oldclipboard
	}
return



	oldappendnewline = %appendnewline%
	appendnewline = 
	oldclipboard := ClipboardAll
  msgbox ,0, Word, %word%
;	gosub NppGetLineOrSelection
;	line = %clipboard%


return
	loop
	{
msgbox % _QK_%A_Index%_1
		if _QK_%A_Index%_1 <>
		{
			if _QK_%A_Index%_1 = %Key%
			{
				tmp = % _QK_%A_Index%_2
				StringReplace, cmd, tmp, $word$, %word%
				tmp = %cmd%
				clipboard = %cmd%`r`n
msgbox, 64, QuickText, %cmd%
				gosub Rpaste
			}
		}
		else
			break
	}
	appendnewline = %oldappendnewline%
return
}	

editQuickKeys:
{
Run %Nppexe% %QuickKeysFile%
return
}
makeQuickKeyTxt:
{
	fileInstall, quickkeys.txt, %QuickKeysFile%
return
}