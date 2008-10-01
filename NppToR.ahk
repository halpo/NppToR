; NppToR: R in Notepad++
; by Andrew Redd 2008 <aredd@stat.tamu.edu>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php

#IfWinActive ahk_class Notepad++
F8:: ;run line or selection
oldclipboard = %clipboard%
clipboard = ""
send ^c
if clipboard = ""
{
	send {home}+{down}^c{right}
}
if clipboard<>""
{
	WinGet nppID, ID, A          ; save current window ID to return here later
	if getOrStartR()=""
	{
		msgbox ,16, Could nor start R, A running R console could not be found, nor could R be started.
		return
	}
	send ^v
	WinActivate ahk_id %nppID%    ; go back to the original window
}
clipboard = %oldclipboard%
return

#IfWinActive ahk_class Notepad++
^F8:: ; Run All
oldclipboard = %clipboard%
send ^a^c{end}
if clipboard<>""
{
	WinGet nppID, ID, A          ; save current window ID to return here later
	if getOrStartR()=""
	{
		msgbox ,16, Could nor start R, A running R console could not be found, nor could R be started.
		return
	}
	send ^v
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
		sleep 60
		return RprocID=""
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
