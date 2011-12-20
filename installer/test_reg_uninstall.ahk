#include %A_ScriptDir%\..\NTRError.ahk

gosub RunAsAdministrator
outputdebug % dstring . "isAdmin=" . A_IsAdmin
;%

installpath = C:\Program Files (x86)\NppToR
Path := installpath
registerUnistaller(Path, "1.0.0")

outputdebug % dstring . "exiting app"
;%
ExitApp

registerUnistaller(BasePath, Version, uexename="uninstaller.exe")
{
  global dstring
  outputdebug % dstring . "entering; Uninstall Path=" . BasePath
  ;%
  UPath = %BasePath%\%uexename%
  outputdebug % dstring . "entering; Uninstall Path=" . UPath
  ;%
  IPath = %BasePath%\NppToR.exe
  NTRKey = Software\Microsoft\Windows\CurrentVersion\Uninstall\NppToR
  RegWrite , REG_SZ   , HKEY_LOCAL_MACHINE, %NTRKey%, DisplayName, NppToR
  RegWrite , REG_SZ   , HKEY_LOCAL_MACHINE, %NTRKey%, DisplayIcon, %IPath%
  RegWrite , REG_SZ   , HKEY_LOCAL_MACHINE, %NTRKey%, DisplayVersion, %Version%
  RegWrite , REG_SZ   , HKEY_LOCAL_MACHINE, %NTRKey%, UnistallString, %UPath%
  RegRead  , regstring, HKEY_LOCAL_MACHINE, %NTRKey%, UnistallString
  outputdebug % dstring . "exiting; registry reads: " . regstring
  ;%
  return
}
#include %A_ScriptDir%\..\_reg64.ahk
#include %A_ScriptDir%\scheduler.ahk
