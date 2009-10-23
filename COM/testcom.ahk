#include COM.ahk

	COM_Unicode2Ansi(cmd, clipboard)
	msgbox %cmd%
  COM_Unicode4Ansi(cmd, clipboard)
	msgbox %cmd%
  COM_Ansi2Unicode(clipboard, cmd)
	msgbox %cmd%
  COM_Ansi4Unicode(cmd, clipboard)
	msgbox %cmd%	
ExitApp







COM_init()
Rcom := COM_CreateObject("RCOMServerLib.StatConnector")
if Rcom <> 0 
{
	inputbox , cmd , Command?
	COM_invoke(Rcom, "EvaluateNoReturn", cmd)
}
else msgbox, Could not find RCOMServerLib
COM_term()




