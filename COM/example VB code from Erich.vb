
 Set My_R = CreateObject("RCOMServerLib.StatConnector",MyServerName)
   If Err.Number <> 0 Then
	   StartForegroundProcess
	   FailedAttempts = 0
	   Do
		   WaitMilliSec StartupDelay * 1000
		   Set My_R = CreateObject("RCOMServerLib.StatConnector", MyServerName)
		   FailedAttempts = FailedAttempts + 1
		   StartupDelay = StartupDelay * 2
	   Loop Until Err.Number = 0 Or FailedAttempts > 6
   End If
   If Err.Number <> 0 Then
	   PrintToDebugView "Problem creating object RCOMServerLib.StatConnector"
   Else
	   PrintToDebugView "Created object RCOMServerLib.StatConnector"
   End If


Private Sub StartForegroundProcess()
   Dim RPath, cmdString As String
   Dim ProfileName As String
   Dim RExcelPath, CurrPath As String
   Dim ProcHandle As Long
   RPath = RHomeFromReg()
   RExcelPath = ThisWorkbook.Path
   CurrPath = CurDir()
   ChDir RExcelPath
   cmdString = RPath & "\bin\RGui.exe --sdi " & RGuiCommandLineOptions & " "
   If UseInternet2() Then cmdString = cmdString & " --internet2"
   On Error Resume Next
   If GetRGuiVisibleState() Then
       ProcHandle = Shell(cmdString, vbNormalFocus)
   Else
       If RGuiTotallyHidden Then
           ProcHandle = Shell(cmdString, vbHide)
       Else
           ProcHandle = Shell(cmdString, vbMinimizedFocus)
       End If
   End If
   ' Debug.Print procHandle
   ChDir CurrPath
   If Err.Number <> 0 Then
       DispError
       '        Err.Raise 1011
       ErrorRaise 1011, "RExcel.RServer", "Error starting R foreground process"
   End If
End Sub