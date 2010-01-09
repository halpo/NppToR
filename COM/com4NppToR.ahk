;#include COM.ahk
startCOM:
{
COM_init()
return
}
stopCOM:
{
COM_term()
return
}
sendByCOM:
{
	gosub startCOM
	Rcom := COM_CreateObject("RCOMServerLib.StatConnector")
	if Rcom <> 0 
	{
		cmd := RegExReplace(clipboard, "im)\R+", "`;")
		cmd2 = `{ %cmd% `}
		COM_invoke(Rcom, "EvaluateNoReturn", cmd2)
	}
	else msgbox, Could not find RCOMServerLib
	gosub stopCOM
	Return
}
