
; read replacements
readQuickKeys:
	ifWinExist ahk_class Notepad++
	ifWinExist
	QuickKeysFile = %A_ScriptDir%\quickkeys.txt
	if(Global)
	{
		ifNotExist %QuickKeysFile%
			QuickKeysFile = %A_AppData%\NppToR\quickkeys.txt
	}
	ifNotExist %QuickKeysFile%
		gosub createQuickKeyTxt
	Loop, Read, %QuickKeysFile%
	{
		StringLeft, first, A_LoopReadLine,1
		if first = `;
		  continue
		StringSplit, _QK_%A_Index%_ , A_LoopReadLine, =, %A_Space%%A_Tab%
		key = % _QK_%A_Index%_1
		hotkey, %key%, doQuickKey
	}
	ifWinExist 
return
doQuickKey:
{
	Key = %A_ThisHotkey%
; msgbox %Key%
	oldappendnewline = %appendnewline%
	appendnewline = 
	oldclipboard := ClipboardAll
	gosub NppGetWord
	word = %clipboard%
	gosub NppGetLineOrSelection
	line = %clipboard%
	loop
	{
		if _QK_%A_Index%_1 <>
		{
			if _QK_%A_Index%_1 = %Key%
			{
				tmp = % _QK_%A_Index%_2
				StringReplace, cmd, tmp, $word$, %word%
				tmp = %cmd%
				StringReplace, cmd, tmp, $line$, %line%
				clipboard = %cmd%
				if oldappendnewline 
					gosub CheckForNewLine
; msgbox, 64, QuickText, %cmd%
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
Run %Nppexe% %QuickKeysFile%
return

makeQuickKeyTxt:
	if(global)
		fileInstall, quickkeys.txt, %QuickKeysFile%
return
