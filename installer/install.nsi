; NppToR: R in Notepad++
; by Andrew Redd 2008 <aredd@stat.tamu.edu>
; use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php



outFile "NppToR_Setup.exe"
RequestExecutionLevel admin
InstallDir "$PROGRAMFILES\NppToR"

Var "CONFIGDIR"
Var "NPPAPIDIR"
Var "NPPUDLDIR"

Section "Install" Install
	ClearErrors
	ReadRegStr $NPPAPIDIR  HKLM "SOFTWARE\Notepad++"
	IfErrors 0 +2
	MessageBox MB_ICONEXCLAMATION|MB_OK "Unable to read from the registry" IDOK end

	StrCopy $CONFIGDIR "$APPDATA\NppToR"
	

	CreateDirectory $INSTDIR
	setOutPath $INSTDIR
	File "..\NpptoR.exe"
	File "..\Readme.txt"
	File "..\Changelog.txt"
	File "..\License.txt"
	File "..\iniparameters.txt"

	CreateDirectory $CONFIGDIR
	setOutPath $CONFIGDIR
	File "..\npptor.ini"

    createShortCut "$SMPROGRAMS\NppToR.lnk" "$INSTDIR"
	
	WriteUninstaller "$INSTDIR\Uninst.exe"
SectionEnd
Section "Uninstall"

     StrCpy $Info "User variables test uninstalled successfully."
     Delete "$INSTDIR\Uninst.exe"


     RmDir $INSTDIR
SectionEnd
Function un.OnUninstSuccess

     HideWindow
     MessageBox MB_OK "$Info"
     
FunctionEnd