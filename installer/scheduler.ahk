#SINGLEINSTANCE force ;ignore
;; Ref: http://msdn.microsoft.com/en-us/library/aa383602(v:=vs.85).aspx
;; Taken from http://www.autohotkey.com/forum/topic65768.html
 
; testscript = %A_ScriptDir%\testadmin.ahk
; msgbox %testscript%
; RunAsStdUser(testscript)  
; gosub runasAdministrator
; Exit  

if NOT A_IsAdmin
  msgbox Do not have admin privileges
ExitApp

  
RunAsStdUser(program, args="")
{
if NOT A_IsAdmin
{
  RUN %program% %args%
  return
}

;; ACTION: Defines the type of actions that a task can perform.
  TASK_ACTION_EXEC           := 0
  TASK_ACTION_COM_HANDLER    := 5
  TASK_ACTION_SEND_EMAIL     := 6
  TASK_ACTION_SHOW_MESSAGE   := 7
 
;; COMPATIBILITY: Defines what versions of Task Scheduler or the AT command that the task is compatible with.
  TASK_COMPATIBILITY_AT   := 0
  TASK_COMPATIBILITY_V1   := 1
  TASK_COMPATIBILITY_V2   := 2 
 
;; TASK_CREATION: Defines how the Task Scheduler service creates updates or disables the task.
  TASK_VALIDATE_ONLY                  := 0x1
  TASK_CREATE                         := 0x2
  TASK_UPDATE                         := 0x4
  TASK_CREATE_OR_UPDATE               := 0x6
  TASK_DISABLE                        := 0x8
  TASK_DONT_ADD_PRINCIPAL_ACE         := 0x10
  TASK_IGNORE_REGISTRATION_TRIGGERS   := 0x20 
 
;; TASK_ENUM_FLAGS: Defines how the Task Scheduler enumerates through registered tasks.
  TASK_ENUM_HIDDEN   := 0x1
 
;; TASK_INSTANCES: Defines how the Task Scheduler handles existing instances of the task when it starts a new instance of the task.
  TASK_INSTANCES_PARALLEL        := 0
  TASK_INSTANCES_QUEUE           := 1
  TASK_INSTANCES_IGNORE_NEW      := 2
  TASK_INSTANCES_STOP_EXISTING   := 3  
 
;; TASK_LOGON: Defines what logon technique is required to run a task.
  TASK_LOGON_NONE                            := 0
  TASK_LOGON_PASSWORD                        := 1
  TASK_LOGON_S4U                             := 2
  TASK_LOGON_INTERACTIVE_TOKEN               := 3
  TASK_LOGON_GROUP                           := 4
  TASK_LOGON_SERVICE_ACCOUNT                 := 5
  TASK_LOGON_INTERACTIVE_TOKEN_OR_PASSWORD   := 6
 
;; TASK_RUN: Defines how a task is run.
  TASK_RUN_NO_FLAGS              := 0x0
  TASK_RUN_AS_SELF               := 0x1
  TASK_RUN_IGNORE_CONSTRAINTS    := 0x2
  TASK_RUN_USE_SESSION_ID        := 0x4
  TASK_RUN_USER_SID              := 0x 
  
;; TASK_RUNLEVEL: Defines LUA elevation flags that specify with what privilege level the task will be run.
  TASK_RUNLEVEL_LUA       := 0
  TASK_RUNLEVEL_HIGHEST   := 1 
 
;; TASK_STATE: Defines the different states that a registered task can be in.
  TASK_STATE_UNKNOWN    := 0
  TASK_STATE_DISABLED   := 1
  TASK_STATE_QUEUED     := 2
  TASK_STATE_READY      := 3
  TASK_STATE_RUNNING    := 4 
 
;; TASK_TRIGGER_TYPE2: Defines the type of triggers that can be used by tasks.
  TASK_TRIGGER_EVENT                  := 0
  TASK_TRIGGER_TIME                   := 1
  TASK_TRIGGER_DAILY                  := 2
  TASK_TRIGGER_WEEKLY                 := 3
  TASK_TRIGGER_MONTHLY                := 4
  TASK_TRIGGER_MONTHLYDOW             := 5
  TASK_TRIGGER_IDLE                   := 6
  TASK_TRIGGER_REGISTRATION           := 7
  TASK_TRIGGER_BOOT                   := 8
  TASK_TRIGGER_LOGON                  := 9
  TASK_TRIGGER_SESSION_STATE_CHANGE   := 11
;------------------------------------------------------------------
; This sample schedules a task to start notepad.exe 30 seconds
; from the time the task is registered.
; Requires AutoHotkey_L
;------------------------------------------------------------------

TriggerType        := TASK_TRIGGER_REGISTRATION    ; specifies a time-based trigger.
ActionTypeExec     := TASK_ACTION_EXEC             ; specifies an executable action.
LogonType          := TASK_LOGON_INTERACTIVE_TOKEN ; Set the logon type to interactive logon
TaskCreateOrUpdate := TASK_CREATE_OR_UPDATE

;********************************************************
; Create the TaskService object.
service := ComObjCreate("Schedule.Service")
service.Connect()

;********************************************************
; Get a folder to create a task definition in. 
rootFolder := service.GetFolder("\")

; The taskDefinition variable is the TaskDefinition object.
; The flags parameter is 0 because it is not supported.
taskDefinition := service.NewTask(0) 

;********************************************************
; Define information about the task.

; Set the registration info for the task by 
; creating the RegistrationInfo object.
regInfo := taskDefinition.RegistrationInfo
regInfo.Description := "Start R Now"
regInfo.Author := "NppToR"

;********************************************************
; Set the principal for the task
principal := taskDefinition.Principal
principal.LogonType := LogonType  ; Set the logon type to interactive logon


; Set the task setting info for the Task Scheduler by
; creating a TaskSettings object.
settings := taskDefinition.Settings
settings.Enabled := True
settings.StartWhenAvailable := True
settings.DisallowStartIfOnBatteries  := false
settings.StopIfGoingOnBatteries   := false
settings.DeleteExpiredTaskAfter := ""
settings.AllowHardTerminate := true
settings.RestartInterval := "PT1M"
settings.RestartCount := 10
settings.MultipleInstances  := TASK_INSTANCES_STOP_EXISTING
settings.Hidden := False
settings.DeleteExpiredTaskAfter := "P1D"

;********************************************************
; Create a time-based trigger.
triggers := taskDefinition.Triggers
trigger := triggers.Create(TriggerType)

; Trigger variables that define when the trigger is active.
startTime += 0, Seconds  ;start time = now
FormatTime,startTime,%startTime%,yyyy-MM-ddTHH`:mm`:ss

endTime += 30, Minutes  ;end time = 5 minutes from now
FormatTime,endTime,%endTime%,yyyy-MM-ddTHH`:mm`:ss

trigger.StartBoundary := startTime
trigger.EndBoundary := endTime
; trigger.ExecutionTimeLimit := "P1M"    ;twelve months should be sufficient
trigger.Id := "NppToRTrigger"
trigger.Enabled := True

;***********************************************************
; Create the action for the task to execute.

; Add an action to the task to run notepad.exe.
Action := taskDefinition.Actions.Create( ActionTypeExec )
Action.Path := Program
Action.Arguments := args

;***********************************************************
; Register (create) the task.
rootFolder.RegisterTaskDefinition("NppToR", taskDefinition, TaskCreateOrUpdate ,"","", TASK_LOGON_INTERACTIVE_TOKEN)

; MsgBox % "Task submitted.`nstartTime :" . startTime . "`nendTime :" . endTime  ;%

return
}

RunAsAdministrator:
ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
if not A_IsAdmin
{
    If A_IsCompiled {
      outputdebug %A_ScriptName%[%A_ThisLabel%%A_ThisFunc%]:%A_LineNumber%(EL=%ErrorLevel%): restarting w/ Admin(compiled) %A_ScriptFullPath% 
      DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
    } Else {
      outputdebug %A_ScriptName%[%A_ThisLabel%%A_ThisFunc%]:%A_LineNumber%(EL=%ErrorLevel%): restarting w/ Admin(uncompiled) %A_ScriptFullPath% 
      DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
    }
    ExitApp
}
return
