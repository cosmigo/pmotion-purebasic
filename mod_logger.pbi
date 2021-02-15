; v.0.0.5-ALPHA | 2021/02/15 | PureBasic 5.73 LTS x86
; ******************************************************************************
; *                                                                            *
; *                        Plugin Logger Window Module                         *
; *                                                                            *
; *                         for Cosmigo Pro Motion NG                          *
; *                                                                            *
; ******************************************************************************
; Copyright (C) 2019-2021 by Tristano Ajmone. Released under MIT License.
; ------------------------------------------------------------------------------
; This module provides file I/O plugins with a logger window that can be used to
; debug internal states and events during plugin development. The module exposes
; a few simple procedure to control the logger and print text to it:
;
; +------------------------------+----------------------------------+
; |          procedure           |           description            |
; |------------------------------|----------------------------------|
; | logger::OpenLogger([title$]) | Open logger window.              |
; | logger::CloseLogger()        | Close logger window.             |
; | logger::ClearLogger()        | Clear log contents.              |
; | logger::PPrint(text$)        | Plain print text$ to log.        |
; | logger::TSPrint(text$)       | Print time-stamped text$ to log. |
; +------------------------------+----------------------------------+
;
; ------------------------------------------------------------------------------

DeclareModule logger
  Declare.i OpenLogger(WinTitle$="")
  Declare.i CloseLogger()
  Declare.i ClearLogger()
  Declare.i PPrint(text$)
  Declare.i TSPrint(text$)
  
  Structure loggerSettings
    WinTitle.s
    WinWidth.i
    WinHeight.i
  EndStructure
  
  Settings.loggerSettings
  
  ;- Log Window Settings: Overridable Defaults
  With Settings
    \WinTitle = "Plugin Logger"
    \WinWidth = 500
    \WinHeight = 300
  EndWith
  
EndDeclareModule

Module logger
  #Failure = #False
  #Success = #True
  
  Structure winInfoStruct
    WinID.i
    LogID.i
    ClearID.i
    CopyID.i
  EndStructure
  
  WinInfo.winInfoStruct
  
  Procedure LogWinResize()
    Shared WinInfo
    ThisID = EventWindow()
    ResizeGadget(WinInfo\LogID, #PB_Ignore, #PB_Ignore,
                 WindowWidth(ThisID)  -20,
                 WindowHeight(ThisID) -55)
    btnWidth = (WindowWidth(ThisID) -30)/2
    ResizeGadget(WinInfo\ClearID, 10,
                 WindowHeight(ThisID) -35,
                 btnWidth, #PB_Ignore)
    ResizeGadget(WinInfo\CopyID,
                 btnWidth +20,
                 WindowHeight(ThisID) -35,
                 btnWidth, #PB_Ignore)
  EndProcedure
  
  Procedure ButtonPressed()
    Shared WinInfo
    Select EventGadget()
      Case WinInfo\ClearID
        ClearLogger()
      Case WinInfo\CopyID
        SetClipboardText(GetGadgetText(WinInfo\LogID))
    EndSelect
  EndProcedure
  
  ;- Log Window Settings: Hard coded
  #LogWinMinWidth  = 250
  #LogWinMinHeigth = 150
  #LogWinFlags = #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget |
                 #PB_Window_SizeGadget | #PB_Window_BorderLess
  
  Procedure.i OpenLogger(WinTitle$="")
    ; --------------------------------------------------------------------------
    ; Creates the log window with title set to the parameter (if present) or
    ; to logger::Settings\WinTitle (if parameter is omitted).
    ; Returns 1 on success, or 0 for failure.
    ; NOTE: Only one logger window can be created per plugin.
    ; --------------------------------------------------------------------------
    Shared Settings, WinInfo
    
    If IsWindow(WinInfo\WinID) ; Prevent creating multiple logger windows!
      ProcedureReturn #Failure
    EndIf
    
    With Settings
      If WinTitle$ <> ""
        \WinTitle = WinTitle$
      EndIf
      WinInfo\WinID = OpenWindow(#PB_Any, 0, 0, \WinWidth, \WinHeight, \WinTitle, #LogWinFlags)   
      If Not WinInfo\WinID
        ProcedureReturn #Failure
      EndIf
    EndWith
    WindowBounds(WinInfo\WinID, #LogWinMinWidth, #LogWinMinHeigth, #PB_Ignore, #PB_Ignore)
    SmartWindowRefresh(WinInfo\WinID, #True)
    ; Make the window sticky, otherwise it will be hidden behind PM NG:
    StickyWindow(WinInfo\WinID, #True) ;
    
    If LoadFont(0, "Consolas", 10)
      SetGadgetFont(#PB_Default, FontID(0))
    EndIf
    
    With Settings
      WinInfo\LogID = EditorGadget(#PB_Any, 10, 10, \WinWidth -20, \WinHeight -55, #PB_Editor_ReadOnly)
      If Not WinInfo\LogID
        CloseWindow(WinInfo\WinID)
        ProcedureReturn #Failure
      EndIf
      BindEvent(#PB_Event_SizeWindow, @LogWinResize())
      
      btnWidth = (\WinWidth -30)/2
      
      WinInfo\ClearID = ButtonGadget(#PB_Any, 10, \WinHeight -35, btnWidth, 25, "CLEAR")
      BindGadgetEvent(WinInfo\ClearID, @ButtonPressed())
      
      WinInfo\CopyID = ButtonGadget(#PB_Any, btnWidth +20, \WinHeight -35, btnWidth, 25, "COPY")
      BindGadgetEvent(WinInfo\CopyID, @ButtonPressed())
      
    EndWith
    ProcedureReturn #Success
  EndProcedure
  
  Procedure.i CloseLogger()
    ; --------------------------------------------------------------------------
    ; Destroys the log window. Returns 1 on success, or 0 for failure.
    ; --------------------------------------------------------------------------
    Shared WinInfo, Settings
    
    If Not IsWindow(WinInfo\WinID)
      ProcedureReturn #Failure
    EndIf
    
    ; Preserve current window size on next OpenLogger() call:
    With Settings 
      \WinWidth = WindowWidth(WinInfo\WinID)
      \WinHeight = WindowHeight(WinInfo\WinID)
    EndWith
    
    CloseWindow(WinInfo\WinID)
    WinInfo\WinID = #NUL
    ProcedureReturn #Success
  EndProcedure
  
  Procedure.i ClearLogger()
    ; --------------------------------------------------------------------------
    ; Clears the log window. Returns 1 on success, or 0 for failure.
    ; --------------------------------------------------------------------------
    Shared WinInfo
    
    If Not IsWindow(WinInfo\WinID)
      ProcedureReturn #Failure
    EndIf
    
    ClearGadgetItems(WinInfo\LogID)
    ProcedureReturn #Success
  EndProcedure
  
  Procedure.i PPrint(logtxt.s)
    ; --------------------------------------------------------------------------
    ; Plain Print: Appends text of the parameter to the log window.
    ; Text is split across multiple lines if EOLs are encountered.
    ; Returns 1 on success, or 0 for failure.
    ; --------------------------------------------------------------------------
    Shared WinInfo
    If Not IsWindow(WinInfo\WinID)
      ProcedureReturn #Failure
    EndIf
    
    lines_cnt = CountString(logtxt, #LF$)
    
    For i = 1 To lines_cnt+1
      AddGadgetItem(WinInfo\LogID, -1, StringField(logtxt, i, #LF$))
    Next
    ProcedureReturn #Success
  EndProcedure
  
  Procedure.i TSPrint(logtxt.s)
    ; --------------------------------------------------------------------------
    ; Time-Stamped Print: Appends the timestamped text of the parameter to the
    ; log window as a 2-columns table with the timestamp on the left.
    ; Text is split across multiple lines if EOLs are encountered.
    ; Returns 1 on success, or 0 for failure.
    ; --------------------------------------------------------------------------
    Shared WinInfo
    If Not IsWindow(WinInfo\WinID)
      ProcedureReturn #Failure
    EndIf
    
    timestamp.s = FormatDate("%hh:%ii:%ss", Date())
    lines_cnt = CountString(logtxt, #LF$)
    
    AddGadgetItem(WinInfo\LogID, -1, timestamp + " | " + StringField(logtxt, 1, #LF$))
    For i = 2 To lines_cnt+1
      AddGadgetItem(WinInfo\LogID, -1, "         | | " + StringField(logtxt, i, #LF$))
    Next
    ProcedureReturn #Success
  EndProcedure
EndModule ; logger

; TODO: Add 'CLOSE' button, or enable close button in window Toolbar.
; TODO: When Logger win closes, store logger dimensions and position in logger::Setting.
; TODO: Add a new option that allows print procs to open the logger window if 
;       it's closed, instead of just failing silently. The default behaviour
;       should remain unchanged though.

; /// EOF ///
