; NppToR Instal Script
; (c) Andrew Redd
#NOENV
#SingleInstance
SetWorkingDir %A_ScriptDir%

msgbox , 4, Install NppToR?,This will install NppToR onto your system.  This will install to the default notepad++ directories.  Some modifications require administrator provilages. If you do not have administrator privilages or are not doing a standard install do not proceed. Is it ok to continue?
ifMsgBox Yes
{

RegRead, Notepadpath, HKEY_LOCAL_MACHINE, SOFTWARE\Notepad++
if ErrorLevel
{
	msgbox ,16, Notepad++ not found, A Notepad++ instalation was not found on your machine.  Please install Notepad++ by downloading from from http://http://notepad-plus.sourceforge.net or else follow the manual install instructions found in install.txt.
	exit
}
apiFolder = %Notepadpath%\Plugins\APIs
RegRead, AppData, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders, AppData
nppData = %AppData%\Notepad++
NppToRDir = %AppData%\NppToR
backup = %NppToRDir%\Backup

ifNotExist %NppToRDir%
	FileCreateDir , %NppToRDir%
ifNotExist %backup%
	FileCreateDir , %backup%


;copy to NppToR install Directory
FileCopy %A_ScriptDir%\Readme.txt , %NppToRDir%\Readme.txt , 1
FileCopy %A_ScriptDir%\License.txt , %NppToRDir%\License.txt , 1
FileCopy %A_ScriptDir%\Install.txt , %NppToRDir%\Install.txt , 1
FileCopy %A_ScriptDir%\Changelog.txt , %NppToRDir%\Changelog.txt , 1
FileCopy %A_ScriptDir%\NppToR.ahk , %NppToRDir%\NppToR.ahk , 1
FileCopy %A_ScriptDir%\NppToR.exe , %NppToRDir%\NppToR.exe , 1

msgbox 4,Add To Startup?,  Would you like NppToR to run at startup?
ifMsgbox Yes
{
	FileCreateShortCut , %NppToRDir%\NppToR.exe , %A_UserProfile%\Start Menu\Programs\Startup\NppToR.lnk
	msgBox %errorlevel%
}
	
FileCopy %A_ScriptDir%\R.xml, %apiFolder%\R.xml, 1
if ErrorLevel
	msgbox , 64, No Code Completion, R.api could not be copied into the Notepad++ api folder. Code Completion will not be available.

IfNotExist %nppData%\userDefineLang.xml
	FileCopy %A_ScriprDir%\userDefineLang.xml, %nppData%\userDefineLang.xml
else 
{
	Filecopy , %AppData%\Notepad++\userDefineLang.xml, %backup%\userDefineLang-%A_YYYY%-%A_MM%-%A_DD%.xml
	FileRead , UDL, %AppData%\Notepad++\userDefineLang.xml
	FileRead , R_lang, %A_ScriptDir%\userDefineLang.xml
	RegExMatch(R_lang, "s)<UserLang name=""R"".*?</UserLang>", NewLang)
	foundR := RegExMatch(UDL, "s)<UserLang name=""R"".*?</UserLang>")
	if foundR
	{
		RegExReplace(UDL, "s)<UserLang name=""R"".*?</UserLang>", %NewLang%`r`n</NotepadPlus>,count,1)
	} else {
		RegExReplace(UDL, "</NotepadPlus>", %NewLang%`r`n</NotepadPlus>,count,1)
	}
	filedelete %nppData%\userDefineLang.xml
	fileappend , %UDL%, %nppData%\userDefineLang.xml
}
}