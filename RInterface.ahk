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
    outputdebug % "NppToR/RInterface.ahk[Rpaste]:entering(clip = " . substr(clipboard, 1, 25) . ".`n" ;%
    WinGet currID, ID, A          ; save current window ID to return here later
    RprocID:=RGetOrStart(GetCurrDir)
    outputdebug % "NppToR/RInterface.ahk[Rpaste]:RprocID=" . RprocID  . ".`n" ;%
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
  outputdebug % "NppToR/RInterface.ahk[RGetOrStart]: Entering.`n" ;%
  SetTitleMatchMode, RegEx
  SetTitleMatchMode, Fast
	IfWinExist ,ahk_class Rgui,,(Graphics),
	{
        outputdebug % "NppToR/RInterface.ahk[RGetOrStart]: found R Console.`n" ;%
		;WinActivate ; 
		WinGet RprocID, ID ;,A
        outputdebug % "NppToR/RInterface.ahk[RGetOrStart]:exiting, RprocID=" . RprocID  . ".`n" ;%
		return RprocID
	} 
  else IfWinExist ,R Console (64-bit)
	{
        outputdebug % "NppToR/RInterface.ahk[RGetOrStart]: found R Console (64-bit).`n" ;%
		;WinActivate ; ahk_class RGui
		WinGet RprocID, ID ;,A
        outputdebug % "NppToR/RInterface.ahk[RGetOrStart]: exiting RprocID=" . RprocID  . ".`n" ;%
		return RprocID
	} 
	else  ; No Compatile R Gui found.
	{
        outputdebug % "NppToR/RInterface.ahk[RGetOrStart]: R not found.`n" ;%
		global Rguiexe
		global Rcmdparms
        dir := GetCurrDir.()
        outputdebug % "NppToR/RInterface.ahk[RGetOrStart]: dir='"  . dir . "'`n" ;%
        setworkingdir %dir%
        EnvSet , R_ENVIRON_USER, %scriptdir%
        outputdebug % "NppToR/RInterface.ahk[RGetOrStart]: Starting R(" . Rguiexe . " --sdi " . RcmdParms . ").`n" ;%
        run %Rguiexe% --sdi %RcmdParms% --sdi,dir,,RprocID
        ClipNoRestore()
        winwait ,R Console,, %Rrunwait%
        WinGet RprocID, ID ;,A
        outputdebug % "NppToR/RInterface.ahk[RGetOrStart]:Exiting, RprocID=" . RprocID . "`n" ;%
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
    outputdebug % "NppToR/RInterface.ahk[CheckForNewLine]:entering(clip tail = " . substr(clipboard, 1, 25) . ".`n" ;%
	;Transform, var, Unicode
    var := clipboard
	if var <>
	{
		stringright , right, var, 1 	;for long strings
		found := regexmatch( right, "[`r`n]")
		if !found
		{
            outputdebug % "NppToR/RInterface.ahk[CheckForNewLine]: not found`n" ;%
            clipboard :=  var . "`r`n"
		}
    }
    outputdebug % "NppToR/RInterface.ahk[CheckForNewLine]:Leaving(clip tail = " . substr(clipboard, 1, 25) . ".`n" ;%
    return
}
RSendEsc(GetCurrDir)
{   
    ; TODO
    outputdebug % "NppToR/RInterface.ahk[RSendEsc]"
    WinGet currID, ID, A          ; save current window ID to return here later
    RprocID:=RGetOrStart(GetCurrDir)
    outputdebug % "NppToR/RInterface.ahk[RSendEsc]:RprocID=" . RprocID  . ".`n" ;%
    if ErrorLevel
    {
        IfWinExist , RGui
            NTRError(701)
        else
            NTRError(702)
        return
    }
    WinActivate ahk_id %RProcID%    ; go back to the original window if moved
    SendInput {Esc}
    WinActivate ahk_id %currID%    ; go back to the original window if moved
	return    
}
;} ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;{ Includes
#include %A_ScriptDir%\COM\com4NppToR.ahk
#include %A_ScriptDir%\COM\COM.ahk
#include %A_ScriptDir%\clip.ahk
;}
