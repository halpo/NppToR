#include COM.ahk

COM_init()
Rcom := COM_CreateObject("RCOMServerLib.StatConnector")
if Rcom <> 0 
{
	;inputbox , cmd , Command?
	; cmd := SubStr(clipboard,1)
	cmd := RegExReplace(clipboard, "im)\R+", "`;")
	cmd2 = `{ %cmd% `}
	msgbox ,,cmd2,%cmd2%
	COM_invoke(Rcom, "EvaluateNoReturn", cmd2)
}
else msgbox, Could not find RCOMServerLib
COM_term()

ExitApp
;x=x+1



