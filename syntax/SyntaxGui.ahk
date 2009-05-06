
makeSyntaxGui:
{
	GUI, 3:Add, TEXT,,R Syntax/Keyword Extraction Options
	GUI, 3:Add, CHECKBOX, vchkBase, Include all base packages?
	GUI, 3:Add, CHECKBOX, vchkRecommended, Include all recommended packages?
	GUI, 3:Add, CHECKBOX, vchkOther checked, Include all non-high priority packages?
	GUI, 3:Add, CHECKBOX, vchkRetain checked, Retain previous keywords (including customizations)?
	GUI, 3:Add, TEXT,,Include packages (separate with commas)
	GUI, 3:Add, EDIT, r3 w300 veditInclude
	GUI, 3:Add, TEXT,,Exclude packages
	GUI, 3:Add, EDIT, r3 w300 veditExclude
	Gui, 3:Add, Button, Default gButtonGoSyntax, GO
	return
}
showSyntaxGui:
{
	GUI, 3:Show, , Syntax Generation - NppToR
	return
}
ButtonGoSyntax:
{
	GUI, 3:SUBMIT
	ifwinexist ahk_class Notepad++
	{
		msgbox ,4,Close Notepad++, Notepad++ must be closed to generate the syntax files.  Continue?
		ifmsgbox no 
			return
		winclose,,,15
	}
	
	runsyntaxcmd = %A_ScriptDir%\GenerateSyntaxFiles.exe --rhome="%Rhome%" --npp-config="%NppConfig%"
	if (chkBase = 1)
		runsyntaxcmd .= " --do-base"
	if (chkRecommended = 1) 
		runsyntaxcmd .= " --do-recommended"
	if (chkOther = 0) 
		runsyntaxcmd .= " --no-other-packages"
	if (chkRetain = 0) 
		runsyntaxcmd .= " --no-retain"
	if (editInclude <> "")
	{
		StringReplace, varInclude, editInclude, "`r`n", ALL
		runsyntaxcmd .= " --include=""" . editInclude . """"
	}
	if (editExclude <> "")
	{
		StringReplace, varExclude, editExclude, "`r`n", ALL
		runsyntaxcmd .= " --exclude=""" . varExclude . """"
	}
	RUNWAIT ,%runsyntaxcmd%
	run %Nppexe%
}
