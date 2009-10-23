;#include COM.ahk
startCOM:
{
COM_init()
return
}

sendByCOM:
{
COM_init()
Rcom := COM_CreateObject("RCOMServerLib.StatConnector")
if Rcom <> 0 
{
	; inputbox , cmd , Command?
	; cmd := COM_Ansi4Unicode(clipboard)
	; COM_Unicode2Ansi(cmd, clipboard)
	; msgbox %cmd%
	COM_invoke(Rcom, "EvaluateNoReturn", clipboard)
}
else msgbox, Could not find RCOMServerLib
COM_term()
Return
}
stopCOM:
{
COM_term()
return
}