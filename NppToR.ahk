; NppToR: R in Notepad++
; by Andrew Redd 2011 <halpo@users.sourceforge.net>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
;{ Header Declarations
#NOENV
#SINGLEINSTANCE force ;ignore
#MaxThreads 10

; Head includes
; must be here to define error codes.
; more includes at end of script
#include %A_ScriptDir%\NTRError.ahk

AUTOTRIM OFF
sendmode event
DetectHiddenWindows Off  ;needs to stay off to allow vista to find the appropriate window.
SetTitleMatchMode, 1
SetTitleMatchMode, Fast

#include %A_ScriptDir%\VERSION
year = 2013

NppToRHeadingFont = Comic Sans MS
NppToRTextFont = Georgia

if (A_PtrSize = 8)
    ahk_arch := "64-bit"
else ; if (A_PtrSize = 4)
    ahk_arch := "32-bit"

if (A_IsUnicode)
    ahk_encoding = Unicode
else
    ahk_encoding = Ascii

;{ Global Variables
F_NppGetCurrDir := Func("NppGetCurrDir") 
dstring = NppToR/%A_ScriptName%[%A_ThisLabel%%A_ThisFunc%]:%A_LineNumber%(EL=%ErrorLevel%):
;}
;}
;{ Begin Initial execution code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OutputDebug , NppToR:Starting NppToR version %VERSION% (%year%) running under AHK version %A_AhkVersion% %ahk_encoding% %ahk_arch%`n

; set environment variable for spawned R processes
EnvSet, R_PROFILE_USER, %A_ScriptDir%\Rprofile

;{ Read CMD line Parameters
Loop, %0%  ; For each parameter:
{
  param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
  OutputDebug NppToR:CMD:Received parameter '%param%' `n
  if dorhome {
    Rhome = %param%
    dorhome =
  } else if donppexe {
    nppexe = %param%
    donppexe =
  } else if donppconfig {
    nppconfig = %param%
    donppconfig =
  } else if param = -startup
    startup = 1
  else if param = -add-auto-complete
    doAAC = 1
  else if param = -no-ini
    noIni = 0
  else if param = -rhome
    dorhome = 1
  else if param = -npp
    donppexe = 1 
  else if param = -config
    donppconfig = 1
}
OutputDebug NppToR:CMD:startup=%startup% doAAC=%doAAC% `n
OutputDebug NppToR:CMD:Rhome=%Rhome% `n
;} End Read CMD line.

;{ ini settings
    inifile = %A_ScriptDir%\npptor.ini
    iniRead, Global, %inifile%, install, global, 0 ;0=false

    OutputDebug NppToR:Init:Global=%global% `n
    if(Global)
    {
      ifNotExist %A_AppData%\NppToR
      {
        OutputDebug NppToR:Init:%A_AppData%\NppToR does not exist, creating `n
        FileCreateDir %A_AppData%\NppToR
        if ErrorLevel
        {
          NTRMsg(501)
          ;ExitApp
        }
      }
      inifile = %A_AppData%\NppToR\npptor.ini
      FileInstall , npptor_defaults.ini , %inifile% , 0
    }
    gosub startupini
;}

if doAAC
{
  OutputDebug NppToR:Init:Doing AAC `n
  gosub generateRxml
  exit
}

;{ Make Interface
gosub makeMenus  
gosub makeHotkeys
gosub readQuickKeys

gosub makeCounter
gosub MakeAboutDialog
gosub makeIniGui
;}

if  not startup
{
  OutputDebug NppToR:Init:Running Notepad++ `n
  run %nppexe%
}
OutputDebug NppToR:Init: Finished`n
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;} End Executable potion
;{ Begin function declarations
;{ run functions
runline:
{
    outputdebug % dstring . "entered`n" ;%
    gosub NppGetLineOrSelection
    if clipboard <>
        Rpaste(F_NppGetCurrDir)
    else
        ClipRestore(Rpastewait)
    outputdebug % dstring . "exiting`n" ;%
    return
}
runall:
{
    outputdebug % dstring . "entered`n" ;%
    gosub NppGetAll
    Rpaste(F_NppGetCurrDir)
    return
}
runSilent:
{
  outputdebug % dstring . "entered`n" ;%
  RGetOrStart(F_NppGetCurrDir)
  gosub NppGetLineOrSelection
  gosub sendSilent
  return
}
runtocursor:
{
    gosub NppGetToPoint
    Rpaste(F_NppGetCurrDir)
    return
}
runbatch:
{
  outputdebug % dstring . "entered`n" ;%
  DetectHiddenWindows On
  NppSave()
  dir := NppGetCurrDir()
  SetWorkingDir %dir%
  rcmd := RGetCMD()
  if rcmd=
  {
    NTRError(502)
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
    outputdebug % dstring . "entered`n" ;%
    ClipSave()
    gosub NppGetLineOrSelection
    found := regexmatch(clipboard, "^[\w.]+\b", match)
    if found
    {
        clipboard = ?%match%`n
        Rpaste(F_NppGetCurrDir)
    } else {
        ClipRestore(0)
    }
    return
}
;} ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;{ Putty interface functions
puttypaste:
{  
  WinGet nppID, ID, A          ; save current window ID to return here later
  IfWinExist , ahk_class PuTTY
  {
    if clipboard<>""
    {
      gosub CheckForNewLine
      ;ControlClick , x4 y30,,, right
      controlSend , ahk_parent, +{Ins}
      PostMessage , 0x200 /* WM_MOUSEMOVE */
    }
    WinActivate ahk_id %nppID%    ; go back to the original window
    ClipRestore(Rpastewait)
  } else NTRMsg(101)
  return
}
puttyLineOrSelection:
{
  ClipSave()
  gosub NppGetLineOrSelection
  gosub puttypaste
  return
}
puttyRunAll:
{
  ClipSave()
  gosub NppGetAll
  gosub puttypaste
  return
}
;} ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;{ About
MakeAboutDialog:
{
outputdebug % dstring . "entered`n" ;%
;Gui, -AlwaysOnTop -SysMenu +Owner ; +Owner avoids a taskbar button.
Gui, 2:Add, Picture, x6 y10 w70 h70 , %A_ScriptDir%\icons\NppToR.png
Gui, 2:Font, S14 CDefault, %NppToRHeadingFont%
Gui, 2:Add, Text,x+10 ys , NppToR ~ About
Gui, 2:Font, S8 CDefault, %NppToRTextFont%
Gui, 2:Add, Text,, 
(
by Andrew Redd
(c)%year%
version %VERSION%
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
;{
Gui , 2:Show,,NpptoR by Andrew Redd
return
ButtonOK2:
GuiClose2:
GuiEscape2:
Gui 2:hide
return ;}
;}
;{ INI file parameters
IniGet:
{
  OutputDebug NppToR:ini:IniGet:entering `n
  ;executables
  IniRead ,iniRhome,         %inifile%, executables, R                ,
  IniRead ,iniRcmdparms,     %inifile%, executables, Rcmdparms        ,
  IniRead ,iniNppHome,       %inifile%, executables, Npp              ,
  IniRead ,iniNppConfig,     %inifile%, executables, NppConfig        ,
  ;hotkeys
  IniRead ,passlinekey,      %inifile%, hotkeys,     passline         , F8
  IniRead ,passfilekey,      %inifile%, hotkeys,     passfile         , ^F8
  IniRead ,passtopointkey,   %inifile%, hotkeys,     evaltocursor     , +F8
  IniRead ,batchrunkey,      %inifile%, hotkeys,     batchrun         , ^!F8
  IniRead ,bysourcekey,      %inifile%, hotkeys,     bysource         , ^+F8
  ;silent                                                             
  IniRead ,enablesilent,     %inifile%, silent,      enablesilent     , 0
  IniRead ,silentkey,        %inifile%, silent,      silentkey        , !F8
  ;putty                                                              
  IniRead ,activateputty,    %inifile%, putty,       activateputty    , 0
  IniRead ,puttylinekey,     %inifile%, putty,       puttyline        , F9
  IniRead ,puttyfilekey,     %inifile%, putty,       puttyfile        , ^F9
  ;controls                                                           
  IniRead ,Rpastewait,       %inifile%, controls,    Rpastewait       , 50
  IniRead ,Rrunwait,         %inifile%, controls,    Rrunwait         , 10
  IniRead ,restoreclipboard, %inifile%, controls,    restoreclipboard , 1
  IniRead ,appendnewline,    %inifile%, controls,    appendnewline    , 1
  IniRead ,pref32,           %inifile%, controls,    pref32           , 0
  ; Runtime control
  IniRead ,ignoreaac,        %inifile%, controls,    ignoreaac        , 0
  debug=
  ;no return continues by design.
}
iniDistill:
{ ; continues from IniGet
  OutputDebug NppToR:ini:iniDistill:entering `n
  ;{ checks: restoreclipboard, appendnewline, enablesilent, activateputty
  if restoreclipboard = false
    restoreclipboard = 0
  if appendnewline = false
    appendnewline = 0
  if enablesilent = false
    enablesilent = 0
  if activateputty = false
    activateputty = 0
  ;} end checks
  ;{ nppdir
  if (ininpphome="ERROR") || (ininpphome="")
  {
    ; regread, nppdir, hkey_local_machine, software\notepad++
    nppdir := findInReg("SOFTWARE\Notepad++")
  }
  else
    nppdir := replaceEnvVariables(iniNppHome)
  OutputDebug NppToR: iniDistill: nppdir = %nppdir%
  ;} end nppdir
  ;{ nppexe
  nppexe = %nppdir%\notepad++.exe
  OutputDebug NppToR: iniDistill: nppexe = %nppexe%
  ;} end nppexe
  ;{ nppconfig
  if (ininppconfig="ERROR") || (ininppconfig="")
  {
    envget, appdata, appdata
    nppconfig = %APPDATA%\notepad++
  }
  else
    nppconfig := replaceEnvVariables(ininppconfig)
  OutputDebug NppToR: iniDistill: nppconfig = %nppconfig%
  ;} end nppconfig
  ;{ Rhome
  if (iniRhome="ERROR") || (iniRhome="")
  {  
    Rhome := findRhome()
  }
  else 
    Rhome := replaceEnvVariables(iniRhome)
  OutputDebug NppToR: iniDistill: Rhome = %Rhome%
  ;} end Rhome
  ;{ Rguiexe
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
      OutputDebug NppToR:iniDistill:Find R Gui: Rguiexe=%Rguiexe% `n
      NTRMsg(503)
      ;ExitApp
    }
  OutputDebug NppToR: iniDistill: Rguiexe = %Rguiexe%
  ;} end Rguiexe
  ;{ Rcmdparms
    if iniRcmdParms <> ERROR
        Rcmdparms := iniRcmdParms
    else
        Rcmdparms =
    OutputDebug NppToR: iniDistill: Rcmdparms = %Rcmdparms%
  ;}
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

  stringreplace,string,string,`%language`%, %a_language%  ;the system's default language, which is one of these 4-digit codes.
  stringreplace,string,string,`%username`%,%a_username%  ;the logon name of the user who launched this script.
  stringreplace,string,string,`%windir`%,%a_windir%  ;the windows directory. for example: c:\windows
  stringreplace,string,string,`%programfiles`%,%a_programfiles%   ;the program files directory (e.g. c:\program files). in v1.0.43.08+, the a_ prefix may be omitted, which helps ease the transition to #noenv.
  stringreplace,string,string,`%appdata`%,%a_appdata% ;[v1.0.43.09+]  the full path and name of the folder containing the current user's application-specific data. for example: c:\documents and settings\username\application data
  stringreplace,string,string,`%appdatacommon`%,%a_appdatacommon% ;[v1.0.43.09+]  the full path and name of the folder containing the all-users application-specific data.
  stringreplace,string,string,`%desktop`%,%a_desktop%  ;the full path and name of the folder containing the current user's desktop files.
  stringreplace,string,string,`%desktopcommon`%,%a_desktopcommon%  ;the full path and name of the folder containing the all-users desktop files.
  stringreplace,string,string,`%startmenu`%,%a_startmenu%  ;the full path and name of the current user's start menu folder.
  stringreplace,string,string,`%startmenucommon`%,%a_startmenucommon%  ;the full path and name of the all-users start menu folder.
  stringreplace,string,string,`%programs`%,%a_programs%  ;the full path and name of the programs folder in the current user's start menu.
  stringreplace,string,string,`%programscommon`%,%a_programscommon%  ;the full path and name of the programs folder in the all-users start menu.
  stringreplace,string,string,`%startup`%,%a_startup%  ;the full path and name of the startup folder in the current user's start menu.
  stringreplace,string,string,`%startupcommon`%,%a_startupcommon%  ;the full path and name of the startup folder in the all-users start menu.
  stringreplace,string,string,`%mydocuments`%,%a_mydocuments%  ;the full path and name of the current user's "my documents" folder. unlike most of the similar variables, if the folder is the root of a drive, the final backslash is not included. for example, it would contain m: rather than m:\
  
  return string
}

startupini: ;{
OutputDebug NppToR:Startup:startupini `n
gosub iniget
return ;}
;} End ini parameters
;{ Interface ;;;;;;;;;;;;;;;;;;;
ExitWithCOM: ;{
gosub stopCOM
NppToRExit:
ExitAPP
return ;}

makeMenus:
{
    OutputDebug NppToR:makeMenues:Entering `n
    ;menu functions
    Menu, tray, add ; separator
    Menu, tray, add, Show Simulations, showCounter
    Menu, tray, add, Start Notepad++, NppRun
    Menu, tray, add, Reset R working directory, RUpdateWD
    Menu, tray, add ; separator
    Menu, tray, add, Add R Auto Completion (Requires Admin), generateRxml
    Menu, tray, add ; separator
    Menu, tray, add, Edit Quick Keys, EditQuickKeys
    Menu, tray, add, Refresh Quick Keys, readQuickKeys
    Menu, tray, add ; separator
    Menu, tray, add, Settings, ShowIniGui
    Menu, tray, add, About, ShowAbout 
    OutputDebug NppToR:makeMenues:leaving `n
    return
}
makeHotkeys:
{
    OutputDebug NppToR:makeHotkeys:entering `n
    if NOT makeglobal
      hotkey , IfWinActive, ahk_class Notepad++
    #MaxThreadsPerHotkey 10
    hotkey ,%passlinekey%,runline, On
    hotkey ,%passfilekey%,runall, On
    hotkey ,%passtopointkey%,runtocursor, On
    #MaxThreadsPerHotkey 100
    hotkey ,%batchrunkey%,runbatch, On
    hotkey ,%bysourcekey%, sendSource, On

    if activateputty
    {
        OutputDebug NppToR:makeHotkeys:putty line=%puttylinekey%, file=%puttyfilekey% `n
        #MaxThreadsPerHotkey 10
        hotkey , %puttylinekey% , puttyLineOrSelection, On
        hotkey , %puttyfilekey% , puttyRunAll, On
    }
    if enablesilent
    {
        OutputDebug NppToR:makeHotkeys:silentKey=%silentkey% `n
        gosub startCOM
        hotkey , %silentkey% , runSilent, On
    }
    OutputDebug NppToR:makeHotkeys:leaving `n
    return
}
undoHotkeys:
{
    OutputDebug NppToR:undoHotkeys:entering `n
    hotkey, %passlinekey%    , runline              , Off
    hotkey, %passfilekey%    , runall               , Off
    hotkey, %passtopointkey% , runtocursor          , Off
    hotkey, %batchrunkey%    , runbatch             , Off
    hotkey, %puttylinekey%   , puttyLineOrSelection , Off
    hotkey, %puttyfilekey%   , puttyRunAll          , Off
    hotkey, %silentkey%      , runSilent            , Off
    OutputDebug NppToR:undoHotkeys:leaving `n 
    return
}
;} End Interface section
;{ Other Utilities
generateRxml: ; do auto-complete
{
  OutputDebug NppToR:generateRxml:entering `n
  Rscript := RGetRscript() 
  IfExist %Rscript%
  {
    ifWinExist ahk_class Notepad++
    {
      winGet , NppPID, PID
      CurrNppExePath := GetModuleFileNameEx( NppPID )
      StringReplace, NppPluginsAPI, CurrNppExePath, notepad++.exe, plugins\APIs, All
      msgbox ,4,Continue?, To update the auto-completion database Notepad++ must be closed.  It will be restarted. Auto-completion must also be turned on from within Notepad++ (Setting > Preferences > Backup/Auto-Completion). Save your work now, now before continuing. Continue?
      ifmsgbox Yes
        winkill
      ifmsgbox No
        return
    }
    if NppPluginsAPI=
    {
        NppPluginsAPI = %NppDir%\plugins\APIs
    }
    params  = /C %Rscript% "%A_ScriptDir%\autocomplete.r"
    command = CMD 
    OutputDebug NppToR:generateRxml:command="%command%" `n
    OutputDebug NppToR:generateRxml:params="%params%" `n
    DllCall("shell32\ShellExecuteA"
        ,uint, 0 ;hwnd a handle to the owner window (null implies not associated with a window)
        ,str, "RunAs"  ;operation
        ,str, command ;File
        ,str, params ;Parameters
        ,str, NppPluginsAPI ;lpDirectory
        ,int, 1)  ; Last parameter: SW_SHOWNORMAL = 1
    winwait, %command%,,1
    winwaitclose, %command%,,500
    OutputDebug NppToR:generateRxml:Restarting Notepad++ `n
    Run %CurrNppExePath%
  }
  else
  {
    NTRError(504)
  }
  OutputDebug NppToR:generateRxml:leaving`n
  return
}
cmdCapture(cmd)
{
  ClipSave()  
  clipboard = 
  runwait %comspec% /c "%cmd% |clip"
  rtn := clipboard
  ClipRestore(0)
  return rtn  
}
findInPath(string)
{
  path := cmdCapture("where " . string)
}
findRHome()
{
  if Rhome = ; 1. check RHOME variable
  { 
    EnvGet , Rhome, RHOME
    if Rhome <>
    {
        OutputDebug NppToR:findRHome: found by RHOME variable
        return Rhome
    }
  }
  if Rhome = ; 2. check path
  {
    Rscriptexe = findInPath("Rcript.exe")
    if Rscriptexe <>
    {
      cmd = %Rscriptexe% --vanilla -e "cat(R.home())"
      Rhome := cmdCapture(cmd)
    }
    if Rhome <>
    {
        OutputDebug NppToR:findRHome: found in path
        return Rhome
    }
  }
  if Rhome = ; 3. check registry
  {
    Rhome:=findInReg("SOFTWARE\R-core\R", "InstallPath")
    if Rhome <>
    {
        OutputDebug NppToR:findRHome: found in registry
        return Rhome
    } else {
        OutputDebug NppToR:findRHome: not found in registry.  Rdir="%Rdir%", Rhome="%Rhome%", errorlevel=%errorlevel%
        if errorlevel
            OutputDebug NppToR:findRHome: last error= %A_LastError%
    }
  }
  if Rhome = ; 4. check assumed locations find most recent.
  {
    curfiletime = 0
    ifExist C:\Program Files (x86)\R
      Loop , C:\Program Files (x86)\R\* , 2, 0
      {
        FileGetTime , filetime, %A_LoopFileFullPath%, C
        if(filetime>curtime)
        {
          curtime := filetime
          Rhome= %A_LoopFileFullPath%
        }
      }
    ifExist C:\Program Files\R
      Loop , C:\Program Files\R\* , 2, 0
      {
        FileGetTime , filetime, %A_LoopFileFullPath%, C
        if(filetime>curtime)
        {
          curtime := filetime
          Rhome= %A_LoopFileFullPath%
        }
      }
    if Rhome <>
    {
        OutputDebug NppToR:findRHome: found by assumed locations
        return Rhome
    }
  }
  return
}
RUpdateWD:
{
	RSetWD(NppGetCurrDir(), F_NppGetCurrDir)
    return
}
sendSource:
{
    RSendSource(NppGetFullPath(), F_NppGetCurrDir)
    return
}
findInReg(subkey, node="", root="HKEY_LOCAL_MACHINE")
{
    OutputDebug NppToR:findInReg: finding %root%\%subkey%\%node%
    if (A_PtrSize = 4 and A_Is64bitOS)
        SetRegView 64
    RegRead, value, %root%, %subkey%, %node%
    if(value="" and A_Is64bitOS)
    {
        OutputDebug NppToR:findInReg: searching with 32-bit registry view
        SetRegView 32
        RegRead, value, %root%, %subkey%, %node%
    }
    SetRegView default
    if errorlevel
        OutputDebug NppToR:findInReg: last error= %A_LastError%

    OutputDebug NppToR:findInReg: found %root%\%subkey%\%node%=%value%
    return value
}
;} End Utils 
;} End Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;{ Self Install
selfinstall:
{
    INSTALLDIR = %A_ScriptDir%
    ;{ Icons
        OutputDebug NppToR:SelfInstall: Icons`n
        ifnotexist %INSTALLDIR%\Icons
            filecreatedir %INSTALLDIR%\Icons
        FILEINSTALL , icons\NppToR.png, %INSTALLDIR%\Icons\NppToR.png, 1
    ;}
    ;{ Other Executables
        OutputDebug NppToR:SelfInstall:OtherExecutables`n
        FILEINSTALL, build\NppEditR.exe , %INSTALLDIR%\NppEditR.exe  , 1
        FILEINSTALL, build\uninstall.exe, %INSTALLDIR%\uninstall.exe , 1
        FILEINSTALL, License.txt        , %INSTALLDIR%\License.txt   , 0
        FILEINSTALL, autocomplete.r     , %INSTALLDIR%\autocomplete.r, 0
        IniWrite, http://npptor.sourceforge.net, %INSTALLDIR%\npptor.url, InternetShortcut, URL
    ;}
    ;{ ini settings
        if %InstallDir% <> %A_AppData%\NppToR
            iniWrite , %Global%, %INSTALLDIR%\npptor.ini, install, global
    ;}
    ;{ do Rprofile
        OutputDebug NppToR:Install:Writing RProfile`n
        RprofileText = ;{
(
  message("\nThis is a session spawned by NppToR.\n\n")
  if(file.exists(".Rprofile"))source(".Rprofile")  else 
  if(file.exists(path.expand("~/Rprofile"))) source(path.expand("~/Rprofile"))
  if(file.exists(path.expand("~/.Rprofile"))) source(path.expand("~/.Rprofile"))
  if(file.exists(path.expand("~/Rprofile.R"))) source(path.expand("~/Rprofile.R"))
)  ;}
        IfExist %INSTALLDIR%\Rprofile
            FileDelete %INSTALLDIR%\Rprofile
        FileAppend , %RprofileText% , %INSTALLDIR%\Rprofile
        optstring = options(editor="%INSTALLDIR%NppEditR.exe")
        StringReplace options, optstring, \ , \\ , All
        FileAppend , `n%options%`n , %INSTALLDIR%\Rprofile
    ;}
    gosub ACSimple
    ;{ Set to Run
        npptorstartup = "%INSTALLDIR%\NppToR.exe"
        RunAsStdUser(npptorstartup, "-startup")
        ExitApp
    ;}
    return
}
ACSimple: ; Depends on NppToR Config Directory, and assumes admin if needed.
{
    if NppDir<>
    {            
        if NppPluginsAPI=
            NppPluginsAPI = %NppDir%\plugins\APIs
        FILEINSTALL, build\R.xml , %NppPluginsAPI%\R.xml, 0
    }
    return
}    
;} end self install
;{ Includes
#include %A_ScriptDir%\Notepad++Interface.ahk
#include %A_ScriptDir%\RInterface.ahk
#include %A_ScriptDir%\counter\counter.ahk
#include %A_ScriptDir%\iniGUI\inigui.ahk
#include %A_ScriptDir%\QuickKeys.ahk
#include %A_ScriptDir%\Installer\scheduler.ahk
;} End Includes
