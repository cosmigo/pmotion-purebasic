; v.0.0.2-ALPHA | 2019/05/09 | PureBasic 5.70 LTS x86
; ******************************************************************************
; *                                                                            *
; *                        Plugin Logger Window Module                         *
; *                                                                            *
; *                         for Cosmigo Pro Motion NG                          *
; *                                                                            *
; ******************************************************************************
; Copyright (C) by Tristano Ajmone, 2019. Released under MIT License.
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
  Declare.i OpenLogger(WinTitle$="Plugin Logger")
  Declare.i CloseLogger()
  Declare.i ClearLogger()
  Declare.i PPrint(text$)
  Declare.i TSPrint(text$)
EndDeclareModule

Module logger
  #Failure = #False
  #Success = #True
  
  Structure winInfoStruct
    WinID.i
    LogID.i
  EndStructure
  
  WinInfo.winInfoStruct
  
  Procedure LogWinResize()
    Shared WinInfo
    ResizeGadget(WinInfo\LogID, #PB_Ignore, #PB_Ignore,
                 WindowWidth(EventWindow())  -20,
                 WindowHeight(EventWindow()) -20)
  EndProcedure
  
  ; /// Log Window Defaults ///
  #LogWinW = 500
  #LogWinH = 300
  #LogWinFlags = #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget |
                 #PB_Window_SizeGadget | #PB_Window_BorderLess
  
  
  Procedure.i OpenLogger(WinTitle$ = "Plugin Logger")
    ; --------------------------------------------------------------------------
    ; Creates the log window with title set to the parameter.
    ; Returns 1 on success, or 0 for failure.
    ; NOTE: Only one logger window can be created per plugin.
    ; --------------------------------------------------------------------------
    Shared WinInfo
    
    If IsWindow(WinInfo\WinID) ; Prevent creating multiple logger windows!
      ProcedureReturn #Failure
    EndIf
    
    WinInfo\WinID = OpenWindow(#PB_Any, 0, 0, #LogWinW, #LogWinH, WinTitle$, #LogWinFlags)
    If Not WinInfo\WinID
      ProcedureReturn #Failure
    EndIf
    ; Make the window sticky, otherwise it will be hidden behind PM NG:
    StickyWindow(WinInfo\WinID, #True) ;
    If LoadFont(0, "Consolas", 10)
      SetGadgetFont(#PB_Default, FontID(0))
    EndIf
    
    WinInfo\LogID = EditorGadget(#PB_Any, 10, 10, #LogWinW -20, #LogWinH -20, #PB_Editor_ReadOnly)
    If Not WinInfo\LogID
      CloseWindow(WinInfo\WinID)
      ProcedureReturn #Failure
    EndIf
    BindEvent(#PB_Event_SizeWindow, @LogWinResize())
    ProcedureReturn #Success
  EndProcedure
  
  Procedure.i CloseLogger()
    ; --------------------------------------------------------------------------
    ; Destroys the log window. Returns 1 on success, or 0 for failure.
    ; --------------------------------------------------------------------------
    Shared WinInfo
    
    If Not IsWindow(WinInfo\WinID)
      ProcedureReturn #Failure
    EndIf
    
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

; /// EOF ///
