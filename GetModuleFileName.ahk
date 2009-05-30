; ^F2::
 ; WinGet, PID, PID, A
 ; FullEXEPath := GetModuleFileNameEx( PID )
 ; FileGetVersion, Version, %FullEXEPath%
 ; MsgBox, 0, %Version%, %FullEXEPath%
; Return

GetModuleFileNameEx( p_pid ) ; by shimanov -  www.autohotkey.com/forum/viewtopic.php?t=9000
{
   if A_OSVersion in WIN_95,WIN_98,WIN_ME
   {
      MsgBox, This Windows version (%A_OSVersion%) is not supported.
	  ErrorLevel = 1
      return
   }

   h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid )
   if ( ErrorLevel or h_process = 0 )
      return

   name_size = 255
   VarSetCapacity( name, name_size )

   result := DllCall( "psapi.dll\GetModuleFileNameExA", "uint", h_process, "uint", 0, "str"
   , name, "uint", name_size )

   DllCall( "CloseHandle", h_process )

   return, name
}