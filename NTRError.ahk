; NppToR: R in Notepad++
; by Andrew Redd 2011 <halpo@users.sourceforge.net>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
; 
; This file contains Error and debugging handling strings and functions.

; debugging string
dstring = NppToR/%A_ScriptName%[%A_ThisLabel%%A_ThisFunc%]:%A_LineNumber%(EL=%ErrorLevel%):

;{ Error Strings
;
; each error message must have a title and body.
NTRErrorList := Object()
NTRErrorList[100] := Object("title", "Test", "body", "Test Message.")
NTRErrorList[101] := Object("title", "PuTTY not found", "body", "PuTTY was not found.  Launch PuTTY and start R on remote server.")
;{ NppToR.ahk errors start at 500
NTRErrorList[500] := Object("title", "test", "body", "test error")
NTRErrorList[501] := Object("title", "Saving Settings", "body", "Error creating settings directory. Setting might not be saved between sessions")
NTRErrorList[502] := Object("title", "Rcmd.exe not found", "body", "Rcmd.exe could not be found. Aborting batch evaluation.")
NTRErrorList[503] := Object("title", "Rgui.exe not found", "body", "Could not find the Rgui.exe file. Spawning R processes will not work.  R must be started manually.  After R has been started, passing commands should work as normal.")
NTRErrorList[504] := Object("title", "Could not find Rcmd.exe", "body", "Could not find the Rcmd.exe file for creating autocompletion list.  Please fix the R home directory in the setting and rerun from the menu.")
;}
;{ Notepad++Interface.ahk errors start at 600
NTRErrorList[601] := Object("title", "Could not retrieve text", "body", "NppToR was able to find Notepad++ but for an unknown reason was unable to retrieve text.")
NTRErrorList[602] := Object("title", "Open Process", "body", "Error in OpenProcess call to open Notepad++")
NTRErrorList[603] := Object("title", "VirtualAllocEx", "body", "Error in VirtualAllocEx")
NTRErrorList[604] := Object("title", "SendMessage Error", "body", "")
;}
;{ RInterface.ahk errors start at 700
NTRErrorList[701] := Object("title", "R in MDI Mode", "body", "R in running in MDI mode. Please switch to SDI mode for this utility to work.")
NTRErrorList[702] := Object("title", "Could not find R", "body", "Could not start or find R. Please check you installation or start R manually.")
NTRErrorList[1] := Object("title", "", "body", "")
;}
;{ General Message start at 800
NTRErrorList[801] := Object("title", "Function Deprecated", "body", "This function is deprecated please report")
;}
;} ;; End Error Strings ;;;

; Print error dialog messages
; 
; NTRError exits any current running thread after printing an error message.
NTRError(Num, xtra="")
{
  global NTRErrorList
  body  := NTRErrorList[(Num)]["body"]
  msgbox 16, Error(%Num%): %title%, %body%`n %xtra%
  exit
}

; Print informative messages
; 
; Evaluation continues after message printed.
NTRMsg(Num, xtra="")
{
  global NTRErrorList
  title := NTRErrorList[(Num)]["title"]
  body  := NTRErrorList[(Num)]["body"]
  msgbox 32, Message(%Num%): %title%, %body%`n %xtra%
  return
}