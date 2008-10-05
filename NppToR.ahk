; NppToR: R in Notepad++
; by Andrew Redd 2008 <aredd@stat.tamu.edu>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
#NOENV
#SINGLEINSTANCE ignore
AUTOTRIM OFF
sendmode event

#IfWinActive ahk_class Notepad++
F8:: ;run line or selection
oldclipboard = %clipboard%
clipboard = ""
sendevent ^c
if clipboard = ""
{
	sendevent {home}+{down}^c{right}
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

#IfWinActive ahk_class Notepad++
^F8:: ; Run All
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
		dir := getCurrFileDir()
		setworkingdir %dir%
		RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
		run %Rdir%\bin\Rgui.exe -q,dir,,RprocID
		winwait ,R Console,,1
	}
}
 
getCurrFileDir()
{
WinGetActiveTitle, title
splitpath, title,,outdir
stringleft firstchar, outdir, 1
if firstchar = "*" 
currdir = substr(outdir,2) 
else 
currdir=%outdir%
return currdir
}
CheckForNewLine(var)
{
found := regexmatch( var, "m`a)`n$")
if found=0
	var = %var% `r`n
return %var%
}
