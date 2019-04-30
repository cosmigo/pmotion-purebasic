; v.0.0.1-ALPHA | 2019/04/30 | PureBasic 5.70 LTS x86
; ******************************************************************************
; *                                                                            *
; *                        Plugin Logger Window Module                         *
; *                                                                            *
; *                         for Cosmigo Pro Motion NG                          *
; *                                                                            *
; ******************************************************************************
; Copyright (C) by Tristano Ajmone, 2019. Released under MIT License.
; ------------------------------------------------------------------------------

; This module provides file I/O plugins with a logger Window that can be used to
; debug internal states and events during plugin development. The module exposes
; a few simple procedure to control the logger and print text to it.

; ------------------------------------------------------------------------------
DeclareModule logger
  Declare.i CreateLogWindow( WinTitle$ = "Plugin Logger" )
  Declare.i AddToLog( text$ )
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
  
  Procedure.i CreateLogWindow(WinTitle$ = "Plugin Logger")
    Shared WinInfo
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
  
    
  Procedure.i AddToLog(logtxt.s)
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
