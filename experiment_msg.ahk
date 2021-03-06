#NOENV
#SINGLEINSTANCE force ;ignore
#MaxThreads 10

AUTOTRIM OFF
sendmode event
DetectHiddenWindows Off  ;needs to stay off to allow vista to find the appropriate window.

version = 2.6.0
year = 2010

NppToRHeadingFont = Comic Sans MS
NppToRTextFont = Georgia


word := NppGetWord()
hotkey ,^F1,printWord

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin Initial execution code

; set environment variable for spawned R processes
envset ,R_PROFILE_USER, %A_ScriptDir%\Rprofile

;;;;;;;;;;;;;;;;;;;;
;CMD line Parameters
Loop, %0%  ; For each parameter:
{
  param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
	if param = -startup
		startup = 1
	if param = -add-auto-complete
		doAAC = 1
}

;ini settings
inifile = %A_ScriptDir%\npptor.ini
iniRead, Global, %inifile%, install, global, 0 ;0=false


if(Global)
{
	ifNotExist %A_AppData%\NppToR
	{
		FileCreateDir %A_AppData%\NppToR
		if ErrorLevel
		{
			msgbox ,32,Error: Saving Settings, Error creating settings directory. Setting might not be saved between sessions.
			;ExitApp
		}
	}
	inifile = %A_AppData%\NppToR\npptor.ini
}

gosub startupini
if doAAC
{
 gosub generateRxml
 exitapp
}

gosub makeMenus	
gosub makeHotkeys
gosub readQuickKeys

gosub makeCounter
gosub MakeAboutDialog
gosub makeIniGui

if  not startup
{
	run %nppexe%
}
return
;End Executable potion

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin function declarations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; run functions
runline:
{
	gosub NppGetLineOrSelection
	gosub Rpaste
	return
}
runall:
{
	gosub NppGetAll
	gosub Rpaste
	return
}
runSilent:
{
	RGetOrStart()
	gosub NppGetLineOrSelection
	gosub sendSilent
	return
}
runtocursor:
{
gosub NppGetToPoint
gosub Rpaste
return
}
runbatch:
{
	DetectHiddenWindows On
	WinMenuSelectItem ,A,,File,Save
	NppGetCurrFileDir(file, dir, ext, Name)
	SetWorkingDir %dir%
	; RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
	rcmd := RGetCMD()
  if rcmd=
  {
    msgbox ,32, Error: Rcmd.exe not found., Rcmd.exe could not be found. Aborting batch evaluation.
    return
  }
		
	command = CMD /C %rcmd% BATCH -q "%file%"
	run %command%, %dir%, hide, RprocID
	WinWait ,ahk_pid %RprocID%,,.5
	addProc(RprocID,File, "Local")
	WinWaitClose ahk_pid %RprocID%
	run %nppexe% "%dir%\%Name%.Rout"
	removeProc(RprocID)
	DetectHiddenWindows Off
return
}
getRhelp:
{
	gosub NppGetLineOrSelection
	found := regexmatch(clipboard, "^[\w.]+\b",match)
	if found
	{
		clipboard = ?%match%`n
		gosub Rpaste
	} else {
		if restoreclipboard
		{
			clipboard := oldclipboard
		}
	}
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; R interface functions
Rpaste:
{
;	if clipboard<>
	; isblank := 
	; if !regExMatch(clipboard, "DS)^`s*$")
	{
		WinGet nppID, ID, A          ; save current window ID to return here later
		RprocID:=RGetOrStart()
		if ErrorLevel
		{
			IfWinExist , RGui
				msgbox , 16 ,R in MDI Mode, R in running in MDI mode. Please switch to SDI mode for this utility to work.
			else
				msgbox , 16 ,Could not find R, Could not start or find R. Please check you installation or start R manually.
			return
		}
		WinMenuSelectItem ,ahk_id %RprocID%,,2&,2& ;edit->paste
		;WinMenuSelectItem ,ahk_id %RprocID%,,file,Print...
		WinActivate ahk_id %nppID%    ; go back to the original window if moved
	} 
	if restoreclipboard
	{
		sleep %Rpastewait%
		clipboard := oldclipboard
	}
	return
}
RGetOrStart()
{
	IfWinExist ,R Console
	{
		;WinActivate ; ahk_class RGui
		WinGet RprocID, ID ;,A
		return RprocID
	} 
	else
	{
		global Rguiexe
		global Rcmdparms
		NppGetCurrFileDir(File,dir)
		setworkingdir %dir%
		EnvSet , R_ENVIRON_USER, %scriptdir%
		run %Rguiexe% %RcmdParms% --sdi,dir,,RprocID
		winwait ,R Console,, %Rrunwait%
		WinGet RprocID, ID ;,A
		return RprocID
	}
}
RGetCMD()
{
  global Rhome
  Rcmdexe = %Rhome%\bin\Rcmd.exe
  IfExist %Rcmdexe%
    return %Rcmdexe%
	else 
    Rcmdexe = %Rhome%\bin\x64\Rcmd.exe
	FE := FileExist(Rcmdexe)
	If (pref32) OR !(FE)
	{
    Rcmdexe = %Rhome%\bin\i386\Rcmd.exe
		FE := FileExist(Rcmdexe)
	}
	If FE
    return %Rcmdexe%
  else
    return
}
RGetRscript()
{
  global Rhome
  Rscriptexe = %Rhome%\bin\Rscript.exe
  IfExist %Rscriptexe%
    return %Rscriptexe%
	else 
    Rscriptexe = %Rhome%\bin\x64\Rscript.exe
	FE := FileExist(Rscriptexe)
	If (pref32) OR !(FE)
	{
    Rscriptexe = %Rhome%\bin\i386\Rscript.exe
		FE := FileExist(Rscriptexe)
	}
	If FE
    return %Rscriptexe%
  else
    return
}
RUpdateWD:
{
	oldclipboard := ClipboardAll
	WinActivate ahk_class Notepad++
	currdir:=NppGetCurrFileDir()
	StringReplace , wd, currdir, \, /, All 
	clipboard = setwd("%wd%")`n
	gosub Rpaste
	return
}
sendSilent:
{
	gosub sendByCOM
	if restoreclipboard
		sleep %Rpastewait%
		clipboard := oldclipboard
	return
}
sendSource:
{
	WinMenuSelectItem ,A,,File,Save
  oldclipboard = %clipboard%
  NppGetCurrFileDir(file, currdir, ext)
  StringReplace , wd, currdir, \, /, All 

  clipboard = source(file="%wd%/%file%")`n
  gosub Rpaste
	if restoreclipboard
		sleep %Rpastewait%
		clipboard := oldclipboard
return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Putty interface functions
puttypaste:
{	
	WinGet nppID, ID, A          ; save current window ID to return here later
	IfWinExist , ahk_class PuTTY
	{
		if clipboard<>""
		{
			ControlClick , x4 y30,,, right
		}
		WinActivate ahk_id %nppID%    ; go back to the original window
		if restoreclipboard
		{
			sleep %Rpastewait%
			clipboard := oldclipboard
		}
	} else msgbox ,16,PuTTY not found, PuTTY was not found.  Launch PuTTY and start R on remote server.
	return
}
puttyLineOrSelection:
{
	gosub NppGetLineOrSelection
	gosub puttypaste
	return
}
puttyRunAll:
{
	gosub NppGetAll
	gosub puttypaste
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Notepad++ interface functions
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
NppGetCurrFileDir(ByRef file="", ByRef dir="", ByRef ext="", ByRef NameNoExt="", ByRef Drive="")
{
	; WinGetActiveTitle, title
	; stringleft firstchar, title, 1
	; if firstchar = *
		; StringTrimLeft title, title, 1
	; StringTrimRight title, title, 12
	ocb = %clipboard%
	clipboard =
	NppGetVersion(major, minor, bug, build)
	if(major>=5)&&(minor>=4)
	{
		WinMenuSelectItem ,A,,2&,10&,1& ; Edit,Copy to Clipboard, Current full file path to Clipboard
	}
	else 
	{
		WinMenuSelectItem ,A,,2&,10& ; Edit,Copy Current full file path to Clipboard
	}
		
	clipwait
	splitpath, clipboard, file, dir, ext, NameNoExt, Drive
	clipboard = %ocb%
	return dir
}
NppGetLineOrSelection:
{
	oldclipboard := ClipboardAll
	clipboard = 
	WinMenuSelectItem ,A,,2&,5& ;Edit,Copy
	clipwait .1
	if clipboard = 
	{
		sendevent {end}{home 2}+{end}+{right}
		WinMenuSelectItem ,A,,2&,5& ;Edit,Copy
		clipwait 1
		sendevent {right}
	} 
	else sendevent {right}
	if appendnewline
		gosub CheckForNewLine
	return
}
NppRun:
{
	Run %Nppexe%
	return 
}
NppGetAll:
{
oldclipboard := ClipboardAll
WinMenuSelectItem ,A,,2&,8& ;Edit,Select All
WinMenuSelectItem ,A,,2&,5& ;Edit,Copy
sendevent {right}
gosub CheckForNewLine
return
}
NppGetToPoint:
{
oldclipboard := ClipboardAll
sendevent ^+{home}
WinMenuSelectItem ,A,,2&,5& ;Edit,Copy
sendevent {right}
		gosub CheckForNewLine
return
}
NppGetWord()
{
WM_USER := 0x400
NPPMSG := WM_USER+1000
NPPM_GETCURRENTWORD := WM_USER + 3000 + 6
NPPM_GETNBOPENFILES := NPPMSG + 7
NPPM_GETCURRENTSCINTILLA := NPPMSG + 4
WM_COPYDATA := 0x4A

WinGet , pidNpp, PID, ahk_class Notepad++
msgbox ,0,pidNpp,%pidNpp%
hProc := DllCall("OpenProcess"
    , "Uint", 0x38
    , "int", 0
    , "Uint", pidNpp)
if ErrorLevel || A_Last_Error
{
  msgbox ,0,A_LastError,%A_LastError%
  msgbox ,0,ErrorLevel,%ErrorLevel%
}
else
  msgbox ,0,hProc,%hProc%

pRB := DllCall("VirtualAllocEx"
    , "Uint", hProc
    , "Uint", 0
    , "Uint", 64
    , "Uint", 0x1000
    , "Uint", 0x4)
if ErrorLevel || A_Last_Error
{
  msgbox ,0,VirtualAllocEx ErrorLevel,%ErrorLevel%
  msgbox ,0,VirtualAllocEX A_LastError,%A_LastError%
}
VarSetCapacity(bread,8,32)
msg=Hello World
; DllCall("WriteProcessMemory"
    ; ,"Uint", hProc
    ; ,"Uint", pRB
    ; ,"Uint", &msg
    ; ,"Uint", 12
    ; ,"Uint", &bread)
; msgbox ,0,Write err level, %ErrorLevel%
; bread2:=NumGet(bread)
; msgbox ,0,bread,%bread2%

SendMessage %NPPM_GETCURRENTWORD%, 64, pRB,, ahk_pid %pidNpp%
if ErrorLevel
{
  msg=
(
ErrorLevel = %ErrorLevel%
NPPM_GETCURRENTWORD = %NPPM_GETCURRENTWORD%
)
  msgbox ,0,SendMessage Error, %msg%
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
  msgbox ,0, ReadProcessMemory ErrorLevel, %ErrorLevel%
  msgbox ,0,bread,%bread2%
}
msgbox ,0,word,%word%
DllCall("VirtualFreeEx"
    , "Uint", hProc
    , "Uint", pRB
    , "Uint", 0
    , "Uint", 0x8000)
DllCall("CloseHandle", "Uint", hProc)
return word
}
printWord:
{
word:=NppGetWord()
return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MakeAboutDialog:
{
;Gui, -AlwaysOnTop -SysMenu +Owner ; +Owner avoids a taskbar button.
Gui, 2:Add, Picture,,icons\NppToR.png
Gui, 2:Font, S14 CDefault, %NppToRHeadingFont%
Gui, 2:Add, Text,x+10 ys , NppToR ~ About
Gui, 2:Font, S8 CDefault, %NppToRTextFont%
Gui, 2:Add, Text,, 
(
by Andrew Redd
(c)%year%
version %version%
use of this program or source files are governed by the MIT license. See License.txt.
)
Gui, 2:Add, Text,, 
(
This utility enables passing code from Notepad++ to the R Gui Window.  

The following are the keyboard shortcuts (can be modified from the setting in the main menu).

	%passlinekey%: Passes a line or a selection to R.
	%passfilekey%: Passes the entire file to R.
	%passtopointkey%: Evaluates the file to the point of the cursor.
	%batchrunkey%: Saves then evaluates the current script in batch mode then opens the results in notepad++.

(#=Win,!=Alt,^=Control,+=Shift)
)
Gui, 2:Add, Button, Default gButtonOK2, OK
;Gui, 2:Show, , NppToR by Andrew Redd  ; NoActivate avoids deactivating the currently active window.
return
}
ShowAbout:
Gui , 2:Show,,NpptoR by Andrew Redd
return
ButtonOK2:
GuiClose2:
GuiEscape2:
Gui 2:hide
return

CheckForNewLine:
{
	;Transform, var, Unicode
	if var <>
	{
		stringright , right, var, 1 	;for long strings
		found := regexmatch( right, "[`r`n]")
		if !found
		{
			;Transform, clipboard, Unicode, %var%`r`n
      clipboard = %var%`r`n
		}	; var = %var% `n
	}
return
}
;;;;;;;;;;;;;;;;;;;
;INI file paramters
IniGet:
{
	;executables
	IniRead ,iniRhome,      %inifile%, executables, R,
	IniRead ,iniRcmdparms,  %inifile%, executables, Rcmdparms,
	IniRead ,iniNppexe,     %inifile%, executables, Npp,
	IniRead ,iniNppConfig,  %inifile%, executables, NppConfig,
	;hotkeys
	IniRead ,passlinekey,    %inifile%, hotkeys, passline,F8
	IniRead ,passfilekey,    %inifile%, hotkeys, passfile,^F8
	IniRead ,passtopointkey, %inifile%, hotkeys, evaltocursor, +F8
	IniRead ,batchrunkey,    %inifile%, hotkeys, batchrun,^!F8
	;IniRead ,Rhelpkey,       %inifile%, hotkeys, rhelp,^F1
	IniRead ,bysourcekey,    %inifile%, hotkeys, bysource, ^+F8
	;silent
	IniRead ,enablesilent,   %inifile%, silent, enablesilent, 0
	IniRead ,silentkey,      %inifile%, silent, silentkey, !F8
	;putty
	IniRead ,activateputty, %inifile%, putty, activateputty, 0
	IniRead ,puttylinekey,  %inifile%, putty, puttyline, F9
	IniRead ,puttyfilekey,  %inifile%, putty, puttyfile, ^F9
	;controls
	IniRead ,Rpastewait,       %inifile%, controls, Rpastewait, 50
	IniRead ,Rrunwait,         %inifile%, controls, Rrunwait, 10
	IniRead ,restoreclipboard, %inifile%, controls, restoreclipboard, 1
	IniRead ,appendnewline,    %inifile%, controls, appendnewline, 1
	IniRead ,pref32,           %inifile%, controls, pref32, 0
	debug=
	;no return continues by design.
}
iniDistill:
{
	if restoreclipboard = false
		restoreclipboard = 0
	if appendnewline = false
		appendnewline = 0
	if enablesilent = false
		enablesilent = 0
	if activateputty = false
		activateputty = 0
		

	if (ininpphome="ERROR") || (ininpphome="")
	{
		; regread, nppdir, hkey_local_machine, software\notepad++
		RegRead, nppdir, HKEY_LOCAL_MACHINE, SOFTWARE\Notepad++
		if nppdir= 
			nppdir := RegRead64("HKEY_LOCAL_MACHINE", "SOFTWARE\Notepad++")
	}
	else
		nppdir := replaceEnvVariables(ininppexe)
	nppexe = %nppdir%\notepad++.exe

		
	if (ininppconfig="ERROR") || (ininppconfig="")
	{
		envget, appdata, appdata
		nppconfig = %APPDATA%\notepad++
	}
	else
		nppconfig := replaceEnvVariables(ininppconfig)
		
	if (iniRhome="ERROR") || (iniRhome="")
	{	
		RegRead, Rdir, HKEY_LOCAL_MACHINE, SOFTWARE\R-core\R, InstallPath
		Rhome= %Rdir%
		if Rdir= 
			Rdir := RegRead64("HKEY_LOCAL_MACHINE", "SOFTWARE\R-core\R", "InstallPath")
		Rhome= %Rdir%
	}
	else 
		Rhome := replaceEnvVariables(iniRhome)
	
	if (iniRcmdparms="ERROR")
		Rcmdparms=
	else 
		Rcmdparms = %iniRcmdparms%
	
	If Rhome =
		FE = 0
	else
		FE := FileExist (Rhome)
	If !(FE)
	{
		curfiletime = 0
		Loop , C:\Program Files\R\* , 2, 0
		{
			FileGetTime , filetime, %A_LoopFileFullPath%, C
			if(filetime>curtime)
			{
				curtime := filetime
				Rhome= %A_LoopFileFullPath%
			}
		}
	}
	If Rhome =
		FE = 0
	else
		FE := FileExist (Rhome)
	If !(FE)
	{
		IfExist C:\Program Files (x86)
		{
			IfExist C:\Program Files(x86)\R
			{
				curfiletime = 0
				Loop C:\Program Files(x86)\R\*
				{
					FileGetTime , filetime, %A_LoopFileFullPath%, C
					if(curtime=  || filetime>curtime)
					{
						curtime := filetime
						Rhome:= A_LoopFileFullPath
					}
				}
			}
		}
	}
	
	IfExist %Rhome%\bin\Rgui.exe
		Rguiexe = %Rhome%\bin\Rgui.exe
	else 
	Rguiexe = %Rhome%\bin\x64\Rgui.exe
	FE := FileExist(Rguiexe)
	If (pref32) OR !(FE)
		Rguiexe = %Rhome%\bin\i386\Rgui.exe
		FE := FileExist(Rguiexe)
		If NOT FE
		{
			msgBox ,32, Error: Rgui.exe not found, Could not find the Rgui.exe file. Spawning R processes will not work.  R must be started manually.  After R has been started, passing commands should work as normal.
			;ExitApp
		}
	return
}
replaceEnvVariables(string)
{
	envget ,a_allusersprofile, allusersprofile
	envget ,a_commonprogramfiles, commonprogramfiles
	envget ,a_homedrive, homedrive
	envget ,a_homepath, homepath
	envget ,a_localappdata, localappdata
	envget ,a_logonserver, logonserver
	envget ,a_programdata, programdata
	envget ,a_public, public
	envget ,a_systemdrive, systemdrive
	envget ,a_systemroot, systemroot
	envget a_userdomain, userdomain
	envget a_userprofile, userprofile
	tmp:=a_temp
	splitpath, a_scriptdir,,cdir,,,cdrive

	stringreplace,string,string,`%npptordir`%,%cdir%
	stringreplace,string,string,`%drive`%,%cdrive%

	stringreplace,string,string,`%allusersprofile`%,%a_allusersprofile%
	stringreplace,string,string,`%commonprogramfiles`%,%a_commonprogramfiles%
	stringreplace,string,string,`%computername`%,%a_computername%
	stringreplace,string,string,`%homedrive`%,%a_homedrive%
	stringreplace,string,string,`%homepath`%,%a_homepath%
	stringreplace,string,string,`%localappdata`%,%a_localappdata%
	stringreplace,string,string,`%logonserver`%,%a_logonserver%
	stringreplace,string,string,`%programdata`%,%a_programdata%
	stringreplace,string,string,`%public`%,%a_public%
	stringreplace,string,string,`%systemdrive`%,%a_systemdrive%
	stringreplace,string,string,`%systemroot`%,%a_systemroot%
	stringreplace,string,string,`%temp`%,%a_temp%
	stringreplace,string,string,`%tmp`%,%a_tmp%
	stringreplace,string,string,`%userdomain`%,%a_userdomain%
	stringreplace,string,string,`%userprofile`%,%a_userprofile%

	stringreplace,string,string,`%language`%, %a_language%	;the system's default language, which is one of these 4-digit codes.
	stringreplace,string,string,`%username`%,%a_username%	;the logon name of the user who launched this script.
	stringreplace,string,string,`%windir`%,%a_windir%	;the windows directory. for example: c:\windows
	stringreplace,string,string,`%programfiles`%,%a_programfiles% 	;the program files directory (e.g. c:\program files). in v1.0.43.08+, the a_ prefix may be omitted, which helps ease the transition to #noenv.
	stringreplace,string,string,`%appdata`%,%a_appdata% ;[v1.0.43.09+]	the full path and name of the folder containing the current user's application-specific data. for example: c:\documents and settings\username\application data
	stringreplace,string,string,`%appdatacommon`%,%a_appdatacommon% ;[v1.0.43.09+]	the full path and name of the folder containing the all-users application-specific data.
	stringreplace,string,string,`%desktop`%,%a_desktop%	;the full path and name of the folder containing the current user's desktop files.
	stringreplace,string,string,`%desktopcommon`%,%a_desktopcommon%	;the full path and name of the folder containing the all-users desktop files.
	stringreplace,string,string,`%startmenu`%,%a_startmenu%	;the full path and name of the current user's start menu folder.
	stringreplace,string,string,`%startmenucommon`%,%a_startmenucommon%	;the full path and name of the all-users start menu folder.
	stringreplace,string,string,`%programs`%,%a_programs%	;the full path and name of the programs folder in the current user's start menu.
	stringreplace,string,string,`%programscommon`%,%a_programscommon%	;the full path and name of the programs folder in the all-users start menu.
	stringreplace,string,string,`%startup`%,%a_startup%	;the full path and name of the startup folder in the current user's start menu.
	stringreplace,string,string,`%startupcommon`%,%a_startupcommon%	;the full path and name of the startup folder in the all-users start menu.
	stringreplace,string,string,`%mydocuments`%,%a_mydocuments%	;the full path and name of the current user's "my documents" folder. unlike most of the similar variables, if the folder is the root of a drive, the final backslash is not included. for example, it would contain m: rather than m:\
	
	return string
}

startupini:
gosub iniget
return

ExitWithCOM:
gosub stopCOM
NppToRExit:
ExitAPP
return

;;;;;;;;;;;;;;;;;;;;
makeMenus:
{
;menu functions
menu, tray, add ; separator
menu, tray, add, Show Simulations, showCounter
menu, tray, add, Start Notepad++, NppRun
menu, tray, add, Reset R working directory, RUpdateWD
menu, tray, add ; separator
menu, tray, add, Add R Auto Completion (Requires Admin), generateRxml
menu, tray, add ; separator
menu, tray, add, Edit Quick Keys, EditQuickKeys
menu, tray, add, Refresh Quick Keys, readQuickKeys
menu, tray, add ; separator
Menu, tray, add, Settings, ShowIniGui
Menu, tray, add, About, ShowAbout 
return
}
makeHotkeys:
{
if NOT makeglobal
	hotkey , IfWinActive, ahk_class Notepad++
#MaxThreadsPerHotkey 10
hotkey ,%passlinekey%,runline, On
hotkey ,%passfilekey%,runall, On
hotkey ,%passtopointkey%,runtocursor, On
;hotkey ,%rhelpkey%, getRhelp, On
#MaxThreadsPerHotkey 100
hotkey ,%batchrunkey%,runbatch, On
hotkey ,%bysourcekey%, sendSource, On

;; TESING CODE
;;;;;;;;;;;;;;

if activateputty
{
	#MaxThreadsPerHotkey 10
	hotkey , %puttylinekey% , puttyLineOrSelection, On
	hotkey , %puttyfilekey% , puttyRunAll, On
}
if enablesilent
{
	gosub startCOM
	hotkey , %silentkey% , runSilent, On
}
return
}
undoHotkeys:
{
	hotkey ,%passlinekey%,runline, Off
	hotkey ,%passfilekey%,runall, Off
	hotkey ,%passtopointkey%,runtocursor, Off
	hotkey ,%rhelpkey%, getRhelp, Off
	hotkey ,%batchrunkey%,runbatch, Off
	hotkey , %puttylinekey% , puttyLineOrSelection, Off
	hotkey , %puttyfilekey% , puttyRunAll, Off
	hotkey , %silentkey% , runSilent, Off
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generateRxml:
{
	Rscript := RGetRscript() 
  IfExist %Rscript%
  {
    ifWinExist ahk_class Notepad++
    {
      winGet , NppPID, PID
      CurrNppExePath := GetModuleFileNameEx( NppPID )
      StringReplace, NppPlugins, CurrNppExePath, notepad++.exe, plugins\APIs, All
      msgbox ,4,Continue?, To update the auto-completion database Notepad++ must be closed.  It will be restarted. Auto-completion must also be turned on from within Notepad++ (Setting > Preferences > Backup/Auto-Completion). Save your work now, now before continuing. Continue?
      ifmsgbox Yes
        winkill
      ifmsgbox No
        return
    } 
    if NppPlugins=
    {
      NppPlugins = %NppDir%\plugins\APIs
    }
    params  = /C %Rscript% "%A_ScriptDir%\make_R_xml.r"
    command = CMD 
    DllCall("shell32\ShellExecuteA"
      ,uint, 0 ;hwnd a handle to the owner window (null implies not associated with a window)
      ,str, "RunAs"  ;operation
      ,str, command ;File
      ,str, params ;Parameters
      ,str, NppPlugins ;lpDirectory
      ,int, 1)  ; Last parameter: SW_SHOWNORMAL = 1
    SetTitleMatchMode, 1
    winwait, %command%,,1
    winwaitclose, %command%,,500
    Run %CurrNppExePath%
  }
  else
  {
    msgbox ,48, Could not find Rcmd.exe, Could not find the Rcmd.exe file for creating autocompletion list.  Please fix the R home directory in the setting and rerun from the menu., 30
  }
  return
}

; Includes
#include %A_ScriptDir%\counter\counter.ahk
#include %A_ScriptDir%\iniGUI\inigui.ahk
#include %A_ScriptDir%\GetModuleFileName.ahk
#include %A_ScriptDir%\COM\com4NppToR.ahk
#include %A_ScriptDir%\COM\COM.ahk
#include %A_ScriptDir%\_reg64.ahk
#include %A_ScriptDir%\QuickKeys.ahk