; NppToR Instal Script
; (c) Andrew Redd
#NOENV
#SingleInstance
SetWorkingDir %A_ScriptDir%

msgbox , 4, Install NppToR?,This will install NppToR onto your system.  This will install to the default notepad++ directories.  Some modifications require administrator provilages. If you do not have administrator privilages or are not doing a standard install do not proceed. Is it ok to continue?
ifMsgBox Yes
{
RegRead, AppData, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders, AppData
nppData = %AppData%\Notepad++
IfNotExist %nppData%
	fileSelectFolder , nppData,,,"Please select the Notepad++ data directory"

RegRead, Notepadpath, HKEY_LOCAL_MACHINE, SOFTWARE\Notepad++
apiFolder = %Notepadpath%\Plugins\APIs
IfNotExist %apiFolder%
	fileSelectFolder , apiFolder,,,"Please select the Notepad++ api directory"

FileCopy %A_ScriptDir%\R.xml, %apiFolder%\R.xml, 1
if ErrorLevel
	msgbox , 64, No Code Completion, R.api could not be copied into the Notepad++ api folder. Code Completion will not be available

IfNotExist %nppData%\userDefineLang.xml
{
	FileCopy %A_ScriprDir%\userDefineLang.xml, %nppData%\userDefineLang.xml
	ifNotExist %nppData%\userDefineLang.xml
		msgbox , 64, No Syntax Highlighting, Could not copy syntax highlighting file (userDefineLang.xml) to the Notepad++ data directory. Syntax Highlighting will not be available.
} 
else 
{
	ifNotExist %nppData%\Backup
		FileCreateDir, %AppData%\Notepad++\Backup
	Filecopy , %AppData%\Notepad++\userDefineLang.xml, %AppData%\Notepad++\Backup\userDefineLang-%A_YYYY%-%A_MM%-%A_DD%.xml
	FileRead , UDL, %AppData%\Notepad++\userDefineLang.xml
	msgstr:=substr(UDL, 1, 100)
	msgbox %msgstr%
	FileRead , R_lang, %A_ScriptDir%\userDefineLang.xml
	foundpos := RegExMatch(UDL, "<UserLang name=""R"".*>")
	msgbox ,,, %foundpos%
	if foundpos<>""
	{
		posstart := RegExMatch (R_lang, "<UserLang name=""R"".*>")
		posend := InStr(R_Lang, "</UserLang>",, posstart)
		posend += 11
		R_LangPart
		msgstr:=substr( %R_lang_Part%, 1, 100)
		msgbox ,,%pos%,%msgStr%
		;RegExReplace UDL
	}
	else
	{
	}
}

}