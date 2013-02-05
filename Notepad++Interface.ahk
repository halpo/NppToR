; NppToR: R in Notepad++
; by Andrew Redd 2011 <halpo@users.sourceforge.net>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
;; Notepad++ interface functions

;{ Int Messages
NppGetByMessageInt(NPPM)
{
WinGet , pidNpp, PID, ahk_class Notepad++
hProc := DllCall("OpenProcess"
    , "Uint", 0x38
    , "int", 0
    , "Uint", pidNpp)
if ErrorLevel || A_Last_Error
{
  NTRError(602, A_LastError=%A_LastError%`r`nErrorLevel=%ErrorLevel%)
}

pRB := DllCall("VirtualAllocEx"
    , "Uint", hProc
    , "Uint", 0
    , "Uint", 8       ; not sure why 8 is the magic number here but it appears that it is.
    , "Uint", 0x1000
    , "Uint", 0x4)
if ErrorLevel || A_Last_Error
{
  NTRError(603, ErrorLevel = %ErrorLevel%`r`nA_LastError = %A_LastError%)
}

SendMessage %NPPM%,, pRB,, ahk_pid %pidNpp%
if ErrorLevel<>1
{
msg=
(
ErrorLevel = %ErrorLevel%
NPPM= %NPPM%
)
  NTRError(604, msg)
}

VarSetCapacity(bread,8,32)
;VarSetCapacity(rtn, SIZE,32)
DllCall("ReadProcessMemory"
    ,"Uptr", hProc
    ,"Uptr", pRB
    ,"Uint*", rtn
    ,"Uint", 1
    ,"Uint*", bread)
if ErrorLevel
{
  bread2:=NumGet(bread)
  outputdebug % dstring . "bread=" . bread2  . "`n" ;%
}
DllCall("VirtualFreeEx"
    , "Uint", hProc
    , "Uint", pRB
    , "Uint", 0
    , "Uint", 0x8000)
DllCall("CloseHandle", "Uint", hProc)
ErrorLevel=0
return rtn
}
NppGetCurrView()
{
  view := NppGetByMessageInt(0x7EC)+1
  return view
}
NppGetByMessage(NPPM, SIZE)
{
; NPPM := 0xFBA
; SIZE := t_size(2048)
WinGet , pidNpp, PID, ahk_class Notepad++
hProc := DllCall("OpenProcess"
    , "Uint", 0x38
    , "int", 0
    , "Uint", pidNpp)
if ErrorLevel || A_Last_Error
{
  NTRError(602, A_LastError=%A_LastError%`r`nErrorLevel=%ErrorLevel%)
}

pRB := DllCall("VirtualAllocEx"
    , "Uint", hProc
    , "Uint", 0
    , "Uint", SIZE
    , "Uint", 0x1000
    , "Uint", 0x4)
if ErrorLevel || A_Last_Error
{
  NTRError(603, ErrorLevel = %ErrorLevel%`r`nA_LastError = %A_LastError%)
}

SendMessage %NPPM%, SIZE, pRB,, ahk_pid %pidNpp%
if ErrorLevel <> 1
{
  msg=
(
ErrorLevel = %ErrorLevel%
NPPM= %NPPM%
)
  NTRError(604, msg)
}

VarSetCapacity(bread,8,32)
VarSetCapacity(rtn, SIZE,32)
DllCall("ReadProcessMemory"
    ,"Uint", hProc
    ,"Uint", pRB
    ,"str", rtn
    ,"Uint", SIZE
    ,"Uint*", bread)
if ErrorLevel
{
  bread2:=NumGet(bread)
  outputdebug % dstring . "bread=" . bread2 . "`n" ;%
}
DllCall("VirtualFreeEx"
    , "Uint", hProc
    , "Uint", pRB
    , "Uint", 0
    , "Uint", 0x8000)
DllCall("CloseHandle", "Uint", hProc)
ErrorLevel=0
return rtn
}
NppGetWord()
{
WM_USER := 0x400
; NPPMSG := WM_USER+1000
NPPM_GETCURRENTWORD := WM_USER + 3000 + 6
WinGet , pidNpp, PID, ahk_class Notepad++
hProc := DllCall("OpenProcess"
    , "Uint", 0x38
    , "int", 0
    , "Uint", pidNpp)
if ErrorLevel || A_Last_Error
{
  NTRError(602, A_LastError=%A_LastError%`r`nErrorLevel=%ErrorLevel%)
}

pRB := DllCall("VirtualAllocEx"
    , "Uint", hProc
    , "Uint", 0
    , "Uint", 64
    , "Uint", 0x1000
    , "Uint", 0x4)
if ErrorLevel || A_Last_Error
{
  NTRError(603, ErrorLevel = %ErrorLevel%`r`nA_LastError = %A_LastError%)
}

SendMessage %NPPM_GETCURRENTWORD%, 64, pRB,, ahk_pid %pidNpp%
if ErrorLevel <> 1
{
  msg=
(
ErrorLevel = %ErrorLevel%
NPPM_GETCURRENTWORD = %NPPM_GETCURRENTWORD%
)
  NTRError(604, %msg%)
}

VarSetCapacity(bread,8,32)
VarSetCapacity(word, 65,32)
DllCall("ReadProcessMemory"
    ,"Uint", hProc
    ,"Uint", pRB
    ,"str", word
    ,"Uint", 64
    ,"Uint*", bread)
bread2:=NumGet(bread)
if ErrorLevel
{
  outputdebug % dstring . "bread=" . bread2  . "`n" ;%
}
DllCall("VirtualFreeEx"
    , "Uint", hProc
    , "Uint", pRB
    , "Uint", 0
    , "Uint", 0x8000)
DllCall("CloseHandle", "Uint", hProc)
ErrorLevel=0
return word
}
;}
;{  File Path Manipulations
NppGetFullPath()
{
NPPM_GETFULLCURRENTPATH := 0xFB9
SIZE := t_size(2048)
dir := NppGetByMessage(NPPM_GETFULLCURRENTPATH, SIZE)
return dir
}
NppGetCurrDir()
{
NPPM_GETCURRENTDIRECTORY := 0xFBA
SIZE := t_size(2048)
dir := NppGetByMessage(NPPM_GETCURRENTDIRECTORY, SIZE)
return dir
}
NppGetFilename()
{
NPPM_GETFILENAME = 0xfbb
SIZE := t_size(260)
filename := NppGetByMessage(NPPM_GETFILENAME, SIZE)
return filename
}
NppGetNamepart()
{
NPPM_GETNAMEPART = 0xfbc
SIZE := t_size(260)
filename := NppGetByMessage(NPPM_GETNAMEPART, SIZE)
return filename
}
NppGetExtpart()
{
NPPM_GETEXTPART = 0xfbd
SIZE := t_size(260)
ext := NppGetByMessage(NPPM_GETEXTPART, SIZE)
return ext
}
;}
;{ Menu commands
NppMenuCmd(menuID)
{
;{ Notepad++ Menu Command IDs
; #define    IDM    40000
; #define    IDM_FILE    (IDM + 1000)
    ; #define    IDM_FILE_NEW                     (IDM_FILE + 1)
    ; #define    IDM_FILE_OPEN                    (IDM_FILE + 2)
    ; #define    IDM_FILE_CLOSE                   (IDM_FILE + 3)
    ; #define    IDM_FILE_CLOSEALL                (IDM_FILE + 4)
    ; #define    IDM_FILE_CLOSEALL_BUT_CURRENT    (IDM_FILE + 5)
    ; #define    IDM_FILE_SAVE                    (IDM_FILE + 6)
    ; #define    IDM_FILE_SAVEALL                 (IDM_FILE + 7)
    ; #define    IDM_FILE_SAVEAS                  (IDM_FILE + 8)
    ; #define    IDM_FILE_PRINT                   (IDM_FILE + 10)
    ; #define    IDM_FILE_PRINTNOW                1001
    ; #define    IDM_FILE_EXIT                    (IDM_FILE + 11)
    ; #define    IDM_FILE_LOADSESSION             (IDM_FILE + 12)
    ; #define    IDM_FILE_SAVESESSION             (IDM_FILE + 13)
    ; #define    IDM_FILE_RELOAD                  (IDM_FILE + 14)
    ; #define    IDM_FILE_SAVECOPYAS              (IDM_FILE + 15)
    ; #define    IDM_FILE_DELETE                  (IDM_FILE + 16)
    ; #define    IDM_FILE_RENAME                  (IDM_FILE + 17)
; #define    IDM_EDIT       (IDM + 2000)
    ; #define    IDM_EDIT_CUT                         (IDM_EDIT + 1)
    ; #define    IDM_EDIT_COPY                        (IDM_EDIT + 2)
    ; #define    IDM_EDIT_UNDO                        (IDM_EDIT + 3)
    ; #define    IDM_EDIT_REDO                        (IDM_EDIT + 4)
    ; #define    IDM_EDIT_PASTE                       (IDM_EDIT + 5)
    ; #define    IDM_EDIT_DELETE                      (IDM_EDIT + 6)
    ; #define    IDM_EDIT_SELECTALL                   (IDM_EDIT + 7)
;}
  WinGet , pidNpp, PID, ahk_class Notepad++
  SendMessage 0x818, 0, %menuID%,, ahk_pid %pidNpp%
  outputdebug % dstring . "exiting"  . "`n" ;%
  errorlevel:=0
  return
}
NppCopy()
{
  NppMenuCmd(42002)
  outputdebug % dstring . "exiting"  . "`n" ;%
  return
}
NppSelectAll()
{
  NppMenuCmd(42007)
  return
}
NppSave()
{
  NppMenuCmd(41006)
  return
}
NppSaveAll()
{
  NppMenuCmd(41007)
  return
}
;}
;{ Positioning
NppGetPosition()
{
; static SCI_GETCURRENTPOS := 2008
  WinGet , pidNpp, PID, ahk_class Notepad++
  NN := NppGetCurrView()
  SendMessage 2008, 0, 0, Scintilla%NN%, ahk_pid %pidNpp%
  if ErrorLevel<>FAIL
  {
  pos := ErrorLevel-1
  errorlevel:=0
  return (pos)
  }
  return
}
NppSetPosition(pos)
{
  NN := NppGetCurrView()
  WinGet , pidNpp, PID, ahk_class Notepad++
  ; SendMessage 2578, %pos%, 0, Scintilla1, ahk_pid %pidNpp%
  SendMessage 2141, %pos%, %pos%, Scintilla%NN%, ahk_pid %pidNpp%
  SendMessage 2142, %pos%, %pos%, Scintilla%NN%, ahk_pid %pidNpp%
  return
}
NppGetToPoint:
{
  WinGet , pidNpp, PID, ahk_class Notepad++
  pos := NppGetPosition()
  NN := NppGetCurrView()
  SendMessage 2141, 0, 0, Scintilla%NN%, ahk_pid %pidNpp%
  NppCopy()
  NppSetPosition(pos+1)
return
}
;}
;{ Get selection
NppNTextSelected()
{
static SCI_GETSELTEXT:=2161
WinGet , pidNpp, PID, ahk_class Notepad++
SendMessage %SCI_GETSELTEXT%, 0, 0, Scintilla1, ahk_pid %pidNpp%
if ErrorLevel<>FAIL
{
nChar := ErrorLevel-1
errorlevel:=0
return (nChar)
}
return
}
NppGetLine()
{
static NPPM_GETCURRENTLINE := 0xFC0
WinGet , pidNpp, PID, ahk_class Notepad++
SendMessage %SCI_GETSELTEXT%, 0, 0, Scintilla1, ahk_pid %pidNpp%

}
NppGetLineOrSelection:
{
    outputdebug % dstring . "entering"  . "`n" ;%
	ClipSave()
	clipboard = 
	NppCopy()
    clipwait 0.01
	if clipboard = 
	{
        outputdebug % dstring . "clipboard was empty"  . "`n" ;%
		sendevent {end}{home}{home}+{end}+{right}
        outputdebug % dstring . "post sendevent"  . "`n" ;%
		NppCopy()
        if errorlevel
            NTRError(601)
        outputdebug % dstring  . "`n" ;%
        clipwait 0.005
        outputdebug % dstring  . "`n" ;%
		sendevent {right}
	} 
	else sendevent {right}
    outputdebug % dstring . "exiting" . "`n" ;%
	return
}
NppRun:
{
	Run %Nppexe%
	return 
}
NppGetAll:
{
ClipSave()
pos := NppGetPosition() 
NppSelectAll()
NppCopy()
NppSetPosition(pos+1)
return
}
;}
;{ Notepad++ process info
NppGetRunningPath()
{
size := t_size(2048)
VarSetCapacity(path, size, 32)
WinGet , pidNpp, PID, ahk_class Notepad++
hProc := DllCall("GetModuleFileName"
    , "Uptr", pidNpp
    , "Uint", 0
    , "str", path
    , "Uint", size)
return path
}
NppGetVersion(ByRef major, ByRef minor, ByRef bug, ByRef build)
{	
	ifWinExist ahk_class Notepad++
	{
		winGet , NppPID, PID
		CurrNppExePath := GetModuleFileNameEx( NppPID )
		FileGetVersion , NppVersion, %CurrNppExePath%
		StringSplit, VersionNumbers, NppVersion , .
		major := VersionNumbers1
		minor := VersionNumbers2
		bug   := VersionNumbers3
		build := VersionNumbers4
	}
	return
}
;}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;{ Unicode Support
t_char() {
    return A_IsUnicode ? "UShort" : "Char"
}
t_size(char_count=1) {
    return A_IsUnicode ? char_count : char_count*2
}
;}
#include GetModuleFileName.ahk
#include NTRError.ahk
#include clip.ahk