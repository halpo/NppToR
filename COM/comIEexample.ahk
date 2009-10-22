
#Include COM.ahk
COM_Init()
pwb := COM_CreateObject("InternetExplorer.Application")
COM_Invoke(pwb,"Visible=", "True")
url := "http://www.google.com"
COM_invoke(pwb, "Navigate",url)
loop
      If (rdy:=COM_Invoke(pwb,"readyState") = 4)
         break
MsgBox, 262208, Done, Goodbye,5
COM_Invoke(pwb, "Quit")
COM_Term()