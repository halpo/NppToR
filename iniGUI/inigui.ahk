makeIniGui:
{
OutputDebug NppToR:inigui:MakeIniGui:entering
Gui, 4:Add , Picture     , x6 y10 w70 h70    , %A_ScriptDir%\icons\NppToR.png
Gui, 4:Font, S14 CDefault, %NppToRHeadingFont%
Gui, 4:Add , Text        , x86 y10 w370 h30  , NppToR ~ Settings and Options
Gui, 4:Font, S8 CDefault , %NppToRTextFont%
Gui, 4:Add , Text        , x86 y50 w370 h70  , Here you can configure your NppToR to work as you like. Leave entries blank to use defaults or to read from the system.  Use portable variables such as `%Drive`% or `%NppToRDir`% to make locations dynamic.
Gui, 4:Add , GroupBox    , x16 y120 w440 h150, Executables and Paths
  Gui, 4:Add, Text    ,    x26  y140 w120 h30                     , R Home
  Gui, 4:Add, Edit    ,    x146 y140 w250 h20 vguitxtRhome        , (read from registry)
  Gui, 4:Add, Button  ,  x396 y140 w50  h20 gguibtnBrowseRhome    , Browse
  Gui, 4:Add, Text    ,    x26  y170 w120 h30                     , R cmd line parameters
  Gui, 4:Add, Edit    ,    x146 y170 w300 h20 vguitxtRcmdparms    , 
  Gui, 4:Add, Text    ,    x26  y200 w120 h30                     , Notepad++ Home
  Gui, 4:Add, Edit    ,  x146 y200 w250 h20 vguitxtNppHome        , (read from registry)
  Gui, 4:Add, Button  ,  x396 y200 w50  h20 gguibtnBrowseNppExe   , Browse
  Gui, 4:Add, Text    ,    x26  y230 w120 h30                     , Notepad++ Config Directory
  Gui, 4:Add, Edit    ,    x146 y230 w250 h20 vguitxtNppConfig    , `%APPDATA`%\Notepad++
  Gui, 4:Add, Button  ,  x396 y230 w50  h20 gguibtnBrowseNppConfig, Browse
Gui  , 4:Add, GroupBox,     x16  y280 w210 h170                   , Hotkeys
  Gui, 4:Add, Text,  x26  y300 w130 h30                   , Pass line
  Gui, 4:Add, Edit,  x156 y300 w60  h20 Vguitxtpassline   , passline
  Gui, 4:Add, Text,  x26  y330 w130 h30                   , Pass entire file at once
  Gui, 4:Add, Edit,  x156 y330 w60  h20 Vguitxtpassfile   , passfile
  Gui, 4:Add, Text,  x26  y360 w130 h30                   , Pass to point of cursor
  Gui, 4:Add, Edit,  x156 y360 w60  h20 Vguitxtpasstopoint, passtopoint
  Gui, 4:Add, Text,  x26  y390 w130 h30                   , Batch process file
  Gui, 4:Add, Edit,  x156 y390 w60  h20 Vguitxtbatchrun   , batchrun
  Gui, 4:Add, Text,   x26 y420 w130 h30                   , Pass by source
  Gui, 4:Add, Edit,   x156 y420 w60 h20  Vguitxtbysource  , 
Gui, 4:Add, GroupBox,   x236 y280 w220 h170 , Extra setting
  Gui, 4:Add, CheckBox, x246 y300 w190 h20 vguichkactivateputty, Enable Putty HotKeys
  Gui, 4:Add, Text    ,  x246 y320 w140 h20                    , Pass line
  Gui, 4:Add, Edit    ,  x386 y320 w60  h20 Vguitxtputtyline   , putty line
  Gui, 4:Add, Text    ,  x246 y350 w140 h20                    , Pass entire file at once
  Gui, 4:Add, Edit    ,  x386 y350 w60  h20 Vguitxtputtyfile   , putty file
  Gui, 4:Add, CheckBox, x246 y375 w200 h20 Vguichkenablesilent , Enable Silent Transfer
  Gui, 4:Add, Text    , x246 y395 w140 h20                     , Silent Transfer Hotkey
  Gui, 4:Add, Edit    , x386 y395 w60 h20 Vguitxtsilentkey     , 
  ;Gui, 4:Add, Text,   x246 y420 w130 h30                 , R help
  ;Gui, 4:Add, Edit,   x386 y420 w60 h20  Vguitxtrhelp   , 
Gui, 4:Add, GroupBox,    x16  y460 w440 h153 , Performance Settings
  Gui, 4:Add, Text    ,  x26  y480 w350 h20                       , Milliseconds to wait time before restoring clipboard
  Gui, 4:Add, Edit    ,  x386 y480 w60  h20 Vguitxtrpastewait     , RPasteWait
  Gui, 4:Add, Text    ,  x26  y510 w350 h20                       , Maximum wait time in seconds for R to load
  Gui, 4:Add, Edit    ,  x386 y510 w60  h20 Vguitxtrrunwait       , RRunWait
  Gui, 4:Add, CheckBox, x26  y530 w420 h30 vguichkrestoreclipboard, Restore clipboard after pasting code into R
  Gui, 4:Add, CheckBox, x26  y555 w420 h30 vguichkappendnewline   , Append new line to passed commands
  Gui, 4:Add, CheckBox, x26  y580 w420 h30 vguichkpref32          , Prefer 32-bit R over 64-bit
Gui, 4:Add, Text  ,    x16  y620 w230 h30 , Hotkey Symbols: #=Win`, !=Alt`, ^=Control`, +=Shift
Gui, 4:Add, Button,    x356 y620 w100 h30 gCancel, Cancel
Gui, 4:Add, Button,    x256 y620 w100 h30 gguiIniSave, Save
return
}
showIniGui:
{
OutputDebug NppToR:inigui:showIniGui:entering
gosub IniGet

guiControl,4:, guitxtpassline, %passlinekey%
guiControl,4:, guitxtpassfile, %passfilekey%
guiControl,4:, guitxtpasstopoint, %passtopointkey%
guiControl,4:, guitxtbatchrun, %batchrunkey%
guiControl,4:, guitxtbysource, %bysourcekey%
;guiControl,4:, guitxtrhelp, %rhelpkey%
if activateputty
  guiControl,4:, guichkactivateputty, 1
else 
  guiControl,4:, guichkactivateputty, 0
guiControl,4:, guitxtputtyline, %puttylinekey%
guiControl,4:, guitxtputtyfile, %puttyfilekey%
guiControl,4:, guitxtrpastewait, %rpastewait%
guiControl,4:, guitxtrrunwait, %rrunwait%
if enablesilent
  guiControl,4:, guichkenablesilent, 1
else 
  guiControl,4:, guichkenablesilent, 0
guiControl,4:, guitxtsilentkey, %silentkey%
if restoreclipboard
  guiControl,4:, guichkrestoreclipboard, 1
else 
  guiControl,4:, guichkrestoreclipboard, 0
if appendnewline
  guiControl,4:, guichkappendnewline, 1
else
  guiControl,4:, guichkappendnewline, 0
if pref32
  guiControl,4:, guichkpref32, 1
else
  guiControl,4:, guichkpref32, 0
  
if (iniRhome="Error") || (iniRhome="")
  guicontrol,4:, guitxtRhome, (read from registry)
else
  guicontrol,4:, guitxtRhome, %iniRhome%
if (iniRcmdparms="Error") || (iniRcmdparms="")
  guicontrol,4:, guitxtRcmdparms, 
else
  guicontrol,4:, guitxtRcmdparms, %iniRcmdparms%
if (iniNppExe="Error") || (iniNppExe="")
  guicontrol,4:, guitxtNppHome, (read from registry)
else
  guicontrol,4:, guitxtNppHome, %iniNppHome%
  
if (iniNppConfig="Error") || (iniNppConfig="")
  guiControl,4:, guitxtNppConfig, `%AppData`%\Notepad++
else
  guiControl,4:, guitxtNppConfig, %iniNppConfig%

Gui, 4:Show, , NppToR: Settings
Return
}
guibtnBrowseRhome:
{
  OutputDebug NppToR:inigui:guibtnBrowseRhome:entering
  FileSelectFolder, filegetRhome, *::{20d04fe0-3aea-1069-a2d8-08002b30309d},0, Select R Home folder (the folder bin is in not the bin folder itself)  ; My Computer.
  if NOT ErrorLevel
    guiControl, 4:, guitxtRhome, %filegetRhome%
  return
}
guibtnBrowseNppExe:
{
  OutputDebug NppToR:inigui:guibtnBrowseNppExe:entering
  FileSelectFile , filegetNppExe, 3 , *::{20d04fe0-3aea-1069-a2d8-08002b30309d}, Select the Notepad++ Executable to use., *.exe
  if NOT ErrorLevel
    guiControl, 4:, guitxtNppExe, %filegetNppExe%
  return
}
guibtnBrowseNppConfig:
{
  OutputDebug NppToR:inigui:guibtnBrowseNppConfig:entering
  FileSelectFolder, filegetNppConfig, *::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 0, Select Notepad++ Home Folder  ; My Computer.
  if NOT ErrorLevel
    guiControl, 4:, guitxtNppConfig, %filegetNppConfig%
  return
}
guiIniSave:
{
OutputDebug NppToR:iniGUI:guiIniSave:entering `n
gui 4:Submit
gosub undoHotkeys

guiControlGet , passlinekey     , 4:, guitxtpassline
guiControlGet , passfilekey     , 4:, guitxtpassfile
guiControlGet , passtopointkey  , 4:, guitxtpasstopoint
guiControlGet , batchrunkey     , 4:, guitxtbatchrun
guiControlGet , bysourcekey     , 4:, guitxtbysource
guiControlGet , activateputty   , 4:, guichkactivateputty
guiControlGet , puttylinekey    , 4:, guitxtputtyline
guiControlGet , puttyfilekey    , 4:, guitxtputtyfile
guiControlGet , rpastewait      , 4:, guitxtrpastewait
guiControlGet , rrunwait        , 4:, guitxtrrunwait
guiControlGet , silentkey       , 4:, guitxtsilentkey
guiControlGet , restoreclipboard, 4:, guichkrestoreclipboard
guiControlGet , appendnewline   , 4:, guichkappendnewline
guiControlGet , pref32          , 4:, guichkpref32
guiControlGet , enablesilent    , 4:, guichkenablesilent
 
guiControlGet , iniRhome        ,4: , guitxtRhome
if(iniRhome="(read from registry)")
  iniRhome=

guicontrolget ,iniRcmdparms      ,4:, guitxtRcmdparms

guicontrolget ,iniNppHome,4:, guitxtNppHome, %iniNppHome%
if(iniNppHome="(read from registry)")
  iniNppHome=

guiControlGet , iniNppConfig,4:, guitxtNppConfig, %iniNppConfig%
if(iniNppConfig="`%AppData`%\Notepad++")
  iniNppConfig =

gosub iniWriteSettingsToFile
gosub iniDistill
gosub makeHotkeys
return
}
iniWriteSettingsToFile:
{
OutputDebug NppToR:iniGUI:iniWriteSettingsToFile: Writing ini settings to %inifile% `n
;executables
iniWrite , %iniRhome%      , %inifile%, executables, R
iniWrite , %iniRcmdparms%  , %inifile%, executables, Rcmdparms
iniWrite , %iniNppHome%    , %inifile%, executables, Npp
iniWrite , %iniNppConfig%  , %inifile%, executables, NppConfig
;hotkeys   
iniWrite , %passlinekey%   , %inifile%, hotkeys    , passline
iniWrite , %passfilekey%   , %inifile%, hotkeys    , passfile
iniWrite , %passtopointkey%, %inifile%, hotkeys    , evaltocursor
iniWrite , %batchrunkey%   , %inifile%, hotkeys    , batchrun
iniWrite , %bysourcekey%   , %inifile%, hotkeys    , bysource
;iniWrite ,%rhelpkey%,    %inifile%, hotkeys, rhelp
;putty
iniWrite , %activateputty%, %inifile% , putty, activateputty
iniWrite , %puttylinekey% ,  %inifile%, putty, puttyline
iniWrite , %puttyfilekey% ,  %inifile%, putty, puttyfile
;silent
iniWrite , %enablesilent%, %inifile%, silent, enablesilent
iniWrite , %silentkey%   , %inifile%, silent, silentkey
;controls
iniWrite , %Rpastewait%      , %inifile%, controls, Rpastewait
iniWrite , %Rrunwait%        , %inifile%, controls, Rrunwait
iniWrite , %restoreclipboard%, %inifile%, controls, restoreclipboard
iniWrite , %appendnewline%   , %inifile%, controls, appendnewline
iniWrite , %pref32%          , %inifile%, controls, pref32

return
}
