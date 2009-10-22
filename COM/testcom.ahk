
#include COM.ahk

COM_init()
myR := COM_CreateObject("RCOMServerLib.StatConnector")
if myR <> 0 
{
	msgbox %myR%
	inputbox, command, Command to execute, Enter Command 
	COM_invoke(myR, "EvaluateNoReturn", command)
}
else msgbox, Could not find RCOMServerLib
COM_term()
