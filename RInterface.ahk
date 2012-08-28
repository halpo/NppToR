;{ NppToR: R in Notepad++
; by Andrew Redd 2012 <halpo@users.sourceforge.net>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
;
; DESCRIPTION
; ===========
; Functions for interacting with R.
;
;}
;{ ; R interface functions
Rpaste(GetCurrDir)
{
    outputdebug % dstring . "entering"  . "`n" ;%
    WinGet currID, ID, A          ; save current window ID to return here later
    RprocID:=RGetOrStart(GetCurrDir)
    outputdebug % dstring . "RprocID=" . RprocID  . "`n" ;%
    if ErrorLevel
    {
        IfWinExist , RGui
            NTRError(701)
        else
            NTRError(702)
        return
    }
    gosub CheckForNewLine
    WinMenuSelectItem ,ahk_id %RprocID%,,2&,2& ;edit->paste
    WinActivate ahk_id %currID%    ; go back to the original window if moved
    ClipRestore(Rpastewait)
	return
}
RGetOrStart(GetCurrDir)
{
  outputdebug % dstring . "entering"  . "`n" ;%
  SetTitleMatchMode, 1
  SetTitleMatchMode, Fast
	IfWinExist ,R Console
	{
    outputdebug % dstring . "found R Console"  . "`n" ;%
		;WinActivate ; ahk_class RGui
		WinGet RprocID, ID ;,A
    outputdebug % dstring . "exiting, RprocID=" . RprocID  . "`n" ;%
		return RprocID
	} 
  else IfWinExist ,R Console (64-bit)
	{
    outputdebug % dstring . " found R Console (64-bit)"  . "`n" ;%
		;WinActivate ; ahk_class RGui
		WinGet RprocID, ID ;,A
    outputdebug % dstring . "exiting RprocID=" . RprocID  . "`n" ;%
		return RprocID
	} 
	else
	{
        outputdebug % dstring . "R not found"  . "`n" ;%
		global Rguiexe
		global Rcmdparms
        dir := GetCurrDir.()
        setworkingdir %dir%
        EnvSet , R_ENVIRON_USER, %scriptdir%
        outputdebug % dstring . "Starting R(" . Rguiexe . " --sdi " . RcmdParms . "`n" ;%
        run %Rguiexe% --sdi %RcmdParms% --sdi,dir,,RprocID
        winwait ,R Console,, %Rrunwait%
        WinGet RprocID, ID ;,A
        outputdebug % dstring . "Exiting, RprocID=" . RprocID . "`n" ;%
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
RSetWD(currdir, GetFullPath)
{
	WinActivate ahk_class Notepad++
	StringReplace , wd, currdir, \, /, All 
    ClipSave()
	clipboard = setwd("%wd%")`n
    Rpaste(GetFullPath)
	return
}
sendSilent:
{
	gosub sendByCOM
    ClipRestore(Rpastewait)
	return
}
RSendSource(fullpath, GetFullPath)
{
	WinMenuSelectItem ,A,,File,Save
    StringReplace , file, fullpath, \, /, All 

    ClipSave()
    clipboard = source(file="%file%")`n
    Rpaste(GetFullPath)
return
}
CheckForNewLine:
{
	;Transform, var, Unicode
    var := clipboard
	if var <>
	{
		stringright , right, var, 1 	;for long strings
		found := regexmatch( right, "[`r`n]")
		if !found
		{
            clipboard = %var%`r`n
		}
    }
    return
}
;} ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;{ Includes
#include %A_ScriptDir%\COM\com4NppToR.ahk
#include %A_ScriptDir%\COM\COM.ahk
#include %A_ScriptDir%\clip.ahk
;}
