; NppToR: R in Notepad++
; by Andrew Redd 2008 <aredd@stat.tamu.edu>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php

#include startup.ahk

;run line or selection ;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class Notepad++
F8:: 
oldclipboard = %clipboard%
clipboard = ""
sendevent ^c
if clipboard = ""
{
	sendevent {end}{home 2}+{down}^c{right}
	if clipboard<>"" 
		clipboard := CheckForNewLine( clipboard )
}
if clipboard<>""
{
	WinGet nppID, ID, A          ; save current window ID to return here later
	getOrStartR()
	if ErrorLevel
	{
		IfWinExist , RGui
			msgbox , 16 ,R in MDI Mode, R in running in MDI mode. Please switch to SDI mode for this utility to work.
		else
			msgbox , 16 ,Could not find R, Could nor start or find R. Please check you installation or start R manually.
		return
	}
	;; this ias an alternative way of doing it but seems to be slightly slower than the implimented version
	; code = %clipboard% ;RegExReplace(, "\r\n", "`n")
	; stringreplace, code, code, `r`n,`r, All
	; sendinput %code% ;^v
	sendevent ^v
	WinActivate ahk_id %nppID%    ; go back to the original window
}
clipboard = %oldclipboard%
return

; Run All ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class Notepad++
^F8:: 
oldclipboard = %clipboard%
sendevent ^a^c^{end}
if clipboard<>""
{
	WinGet nppID, ID, A          ; save current window ID to return here later
	getOrStartR()
	if ErrorLevel
	{
		msgbox errorlevel
		IfWinExist , Rgui
			msgbox ,16,R in running in MDI mode. Please switch to SDI mode for this utility to work.
		else
			msgbox ,16, Could nor start or find R.
		return
	}
	clipboard := CheckForNewLine( clipboard )
	sendevent ^v
	WinActivate ahk_id %nppID%    ; go back to the original window
}
clipboard = %oldclipboard%
return

; Run in R CMD BATCH ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class Notepad++
^!F8::
	sendevent ^s
	getCurrNppFileDir(file, dir, ext, Name)
	SetWorkingDir %dir%
	RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
	;msgbox %Rdir%\bin\Rcmd.exe BATCH -q "%dir%\%file%"
	runwait %Rdir%\bin\Rcmd.exe BATCH -q "%dir%\%file%" ,dir,min,RprocID
	run %NppDir%\Notepad++.exe "%dir%\%Name%.Rout"
return


getOrStartR()
{
	IfWinExist ,R Console
	{
		WinActivate ; ahk_class RGui
		WinGet RprocID, ID, A
		return RprocID
	} 
	else
	{
		getCurrNppFileDir(File,dir)
		setworkingdir %dir%
		RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
		run %Rdir%\bin\Rgui.exe -q,dir,,RprocID
		winwait ,R Console,,5
	}
}
getCurrNppFileDir(ByRef file="", ByRef dir="", ByRef ext="", ByRef NameNoExt="", ByRef Drive="")
{
WinGetActiveTitle, title
stringleft firstchar, title, 1
if firstchar = *
	StringTrimLeft title, title, 1
StringTrimRight title, title, 12
splitpath, title,file,dir, ext, NameNoExt, Drive
return dir
}
