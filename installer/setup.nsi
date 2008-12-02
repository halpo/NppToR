;Product Info
Name "NppToR" ;Define your own software name here
!define PRODUCT "NppToR" ;Define your own software name here
!define VERSION "1.5" ;Define your own software version here

; Script create for version 2.0rc1/final (from 12.jan.04) with GUI NSIS (c) by Dirk Paehl. Thank you for use my program

 !include "MUI.nsh"

 
;--------------------------------
;Configuration
 
   OutFile "setup.exe"

  ;Folder selection page
   InstallDir "$APPDATA\${PRODUCT}"

;Remember install folder
;InstallDirRegKey HKCU "Software\${PRODUCT}" ""

;--------------------------------
;Pages
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

 !define MUI_ABORTWARNING

 
;--------------------------------
 ;Language
 
  !insertmacro MUI_LANGUAGE "ENGLISH"
;--------------------------------

     
Section "section_1" section_1
SetOutPath "$INSTDIR"
FILE "..\iniparameters.txt"
FILE "..\License.txt"
FILE "..\NppToR.exe"
FILE "..\npptor.ini"
FILE "..\Readme.txt"
;FILE "..\Install.txt"
;FILE "..\NppToR.ahk"
;FILE "..\Changelog.txt"
;SetOutPath "$INSTDIR\icons"
;FILE "..\icons\NppToR.png"
;FILE "..\icons\NppToR.ico"
SetOutPath "$APPDATA\Notepad++"
FILE "..\syntax\UserDefineLang.xml"
SectionEnd

Section Shortcuts
CreateDirectory "$SMPROGRAMS\NppToR"
  WriteIniStr "$INSTDIR\NppToR.url" "InternetShortcut" "URL" "http://npptor.sourceforge.net"
  CreateShortCut "$SMPROGRAMS\NppToR\NppToR.lnk" "$INSTDIR\NppToR.url" "" "$INSTDIR\NppToR.url" 0
  CreateShortCut "$SMPROGRAMS\NppToR\NppToR.lnk" "$INSTDIR\NppToR.exe" "" "$INSTDIR\NppToR.exe" 0
  CreateShortCut "$SMPROGRAMS\Startup\NppToR.lnk" "$INSTDIR\NppToR.exe" "-startup" "$INSTDIR\NppToR.exe" 0
SectionEnd

Section Uninstaller
  CreateShortCut "$SMPROGRAMS\NppToR\Uninstall.lnk" "$INSTDIR\uninst.exe" "" "$INSTDIR\uninst.exe" 0
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NppToR" "DisplayName" "${PRODUCT} ${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NppToR" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NppToR" "URLInfoAbout" "http://npptor.sourceforge.net"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NppToR" "Publisher" "Andrew Redd"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NppToR" "UninstallString" "$INSTDIR\Uninst.exe"
  WriteRegStr HKCU "Software\${PRODUCT}" "" $INSTDIR
  WriteUninstaller "$INSTDIR\Uninst.exe"
 
 
SectionEnd
 
 
Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer.."
FunctionEnd
  
Function un.onInit 
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd
 
Section "Uninstall" 
 
  Delete "$INSTDIR\*.*" 
   
  Delete "$SMPROGRAMS\NppToR\*.*"
  RMDir "$SMPROGRAMS\NppToR"
  ; DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\NppToR"
  ; DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\NppToR"
  RMDir "$INSTDIR"
             
SectionEnd
               
   
;eof
