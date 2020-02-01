; ******************************************************************************
; *                                                                            *
; *                         Fake File I/O Plugin DLL                           *
; *                                                                            *
; *                         for Cosmigo Pro Motion NG                          *
; *                                                                            *
; ******************************************************************************
#VERSION = "v0.0.7" ; ALPHA | 2019/05/09 | PureBasic 5.70 LTS x86

; Copyright (C) by Tristano Ajmone, 2019. Released under MIT License.
; ------------------------------------------------------------------------------
; STATUS: INCOMPLETE...
; ------------------------------------------------------------------------------
; A proof of concept plugin to allow monitoring how and when plugin functions
; are called. It creates a sticky window where it logs the plugin functions
; called, and provides some debug information about the passed paramenters and
; returned values.
; 
;  It simulates an IMAGE EXPORT plugin, but it won't actually save anything to
; disk.
; ------------------------------------------------------------------------------
; NOTE: Will only simulate write support initially! for to simulate read it will
;       have to pass data to PM, even if fake. See TODOs at end of file.
; ******************************************************************************
; *                                                                            *
;-                           PLUGIN SETUP & SETTINGS
; *                                                                            *
;{******************************************************************************

XIncludeFile "..\..\..\mod_logger.pbi"
; ------------------------------------------------------------------------------
;- Plugin Settings                                
; ------------------------------------------------------------------------------
#PLUGIN_SUPPORTS_ANIMATION       = #False ; #True
#PLUGIN_SUPPORTS_PALETTE_EXTRACT = #True
#PLUGIN_SUPPORTS_READ            = #False
#PLUGIN_SUPPORTS_WRITE           = #True
#PLUGIN_SUPPORTS_WRITE_TRUECOLOR = #True
#PLUGIN_INTERFACE_VERSION_USED   = 1 ; (only version supported)

; ------------------------------------------------------------------------------
;- Global Strings
; ------------------------------------------------------------------------------
; Strings that need to be returned from the plugin DLL procedures to Pro Motion
; (via pointers) must be defined as globals.

Global PLUGIN_ERROR_MSG$ = #Empty$
Global FILE_TYPE_ID$ = "purebasic.fake"
Global FILE_BOX_DESCRIPTION$ = "FAKE - PureBASIC"
Global FILE_EXTENSION$ = "fake"
; ------------------------------------------------------------------------------
;- Sharable Variables (input)
; ------------------------------------------------------------------------------
FileName$ = #Empty$ ; Full path to the selected file.

; ==============================================================================
;-                                Useful Helpers                                
;{==============================================================================
#Success = #True
#Failure = #False

Procedure.s Bool2Str(boolval) ; Convert boolean value to true/false string
  If boolval
    ProcedureReturn "true"
  Else
    ProcedureReturn "false"
  EndIf
EndProcedure
; ------------------------------------------------------------------------------
; Error Macros
; ------------------------------------------------------------------------------
Macro resetError
  PLUGIN_ERROR_MSG$ = #Empty$
EndMacro

Macro setError( errString )
  PLUGIN_ERROR_MSG$ = errString
EndMacro

Macro Hexify(number,digits=8)
  "$" + RSet(Hex(number), digits, "0")
EndMacro

; ------------------------------------------------------------------------------
; C++ Types
; ------------------------------------------------------------------------------
; Custom types, macros and other helpers to simplify reading C++ API interfacing.

; Boolean
Macro boolean
  i  
EndMacro

; String Pointer (x86)
Macro strpointer
  i  
EndMacro

; Pointer (x86)
Macro pointer
  i  
EndMacro

Macro int32
  l  
EndMacro

;}==============================================================================
;-                                  DLL Setup                                   
;{==============================================================================

; ------------------------------------------------------------------------------
; OS and Bitness Checks
; ------------------------------------------------------------------------------
CompilerIf #PB_Compiler_OS <> #PB_OS_Windows Or
           #PB_Compiler_Processor <> #PB_Processor_x86 Or
           #PB_Compiler_ExecutableFormat <> #PB_Compiler_DLL Or
           #PB_Compiler_Thread = #True
  CompilerError "WRONG COMPILER SETTINGS! Must be Windows DLL for x86 (32 bit) not threadsafe"
CompilerEndIf

; ------------------------------------------------------------------------------
;- Procedures Declaration (Plugin)
; ------------------------------------------------------------------------------
; Initialization:
DeclareDLL.boolean      initialize(*language, *version.Unicode, *animation.Ascii)
DeclareDLL              setProgressCallback( *progressCallback )

; Plugin Info:
DeclareDLL.strpointer   getFileExtension()
DeclareDLL.strpointer   getFileTypeId()
DeclareDLL.strpointer   getFileBoxDescription()

; Plugin Capabilities:
DeclareDLL.boolean      isReadSupported()
DeclareDLL.boolean      isWriteSupported()
DeclareDLL.boolean      isWriteTrueColorSupported()
DeclareDLL.boolean      canExtractPalette()

; Process Control:
DeclareDLL.strpointer   getErrorMessage()
DeclareDLL              setFilename( *filename_pnt )
DeclareDLL.boolean      loadBasicData()
DeclareDLL              finishProcessing()
DeclareDLL.boolean      canHandle()

; File Load Procedures:
DeclareDLL.boolean      isAlphaEnabled()
DeclareDLL.int32        getWidth()
DeclareDLL.int32        getHeight()
DeclareDLL.int32        getImageCount()
DeclareDLL.pointer      getRgbPalette()
DeclareDLL.int32        getTransparentColor()
DeclareDLL.boolean      loadNextImage()

; File Save Procedures:
DeclareDLL.boolean      beginWrite()
DeclareDLL.boolean      writeNextImage()

; ------------------------------------------------------------------------------
;- Procedures Declaration (Custom)
; ------------------------------------------------------------------------------

;}

;}******************************************************************************
; *                                                                            *
;-                            PLUGIN DLL PROCEDURES                             
; *                                                                            *
;{******************************************************************************
; These are the mandatory DLL procedures required by every file I/O plugin.
; Pro Motion expects them to be exported with these exact names.

;- /// Plugin Initialization ///

ProcedureDLL.boolean initialize(*language, *version.Unicode, *animation.Ascii)
  resetError ; -> This procedure can set error!
  
  *version\u = #PLUGIN_INTERFACE_VERSION_USED
  *animation\a = #PLUGIN_SUPPORTS_ANIMATION
  
  UILang$ = Chr(PeekA(*language)) + Chr(PeekA(*language +1))
  
  If Not logger::OpenLogger("FAKE Puglin " + #VERSION)
    setError("FAKE Plugin failed to create log window!")
    ProcedureReturn #Failure
  EndIf
  
  Log$ = "initialize(*language, *version, *animation)" + #LF$ +
         "*language  <--  '" + UILang$ + "'" + #LF$ +
         "*version    --> " + Str(#PLUGIN_INTERFACE_VERSION_USED) + #LF$ +
         "*animation  --> " + Str(#PLUGIN_SUPPORTS_ANIMATION)
  
  logger::TSPrint(Log$)
  ProcedureReturn #Success
EndProcedure

Prototype ProtoProgressCallback( progress.int32 ) ; progress is int32

ProcedureDLL setProgressCallback( *progressCallback )
  progressCallback.ProtoProgressCallback = @*progressCallback
  CallBack$ = Hexify(*progressCallback)
  logger::TSPrint("setProgressCallback( " + CallBack$ +" )")
EndProcedure

;- /// Plugin Info ///

ProcedureDLL.strpointer getFileExtension()
  Log$ = "getFileExtension()" + #LF$ +
         ~"--> \"" + FILE_EXTENSION$ + ~"\""
  logger::TSPrint(Log$)
  ProcedureReturn @FILE_EXTENSION$
EndProcedure

ProcedureDLL.strpointer getFileTypeId()
  Log$ = "getFileTypeId()" + #LF$ +
         ~"--> \"" + FILE_TYPE_ID$ + ~"\""
  logger::TSPrint(Log$)
  ProcedureReturn @FILE_TYPE_ID$
EndProcedure

ProcedureDLL.strpointer getFileBoxDescription()
  Log$ = "getFileBoxDescription()" + #LF$ +
         ~"--> \"" + FILE_BOX_DESCRIPTION$ + ~"\""
  logger::TSPrint(Log$)
  ProcedureReturn @FILE_BOX_DESCRIPTION$
EndProcedure

;- /// Plugin Features Support Info ///

ProcedureDLL.boolean isReadSupported()
  Log$ = "isReadSupported()" + #LF$ +
         "--> " + Bool2Str(#PLUGIN_SUPPORTS_READ)
  logger::TSPrint(Log$)
  ProcedureReturn #PLUGIN_SUPPORTS_READ
EndProcedure

ProcedureDLL.boolean isWriteSupported()
  Log$ = "isWriteSupported()" + #LF$ +
         "--> " + Bool2Str(#PLUGIN_SUPPORTS_WRITE)
  logger::TSPrint(Log$)
  ProcedureReturn #PLUGIN_SUPPORTS_WRITE
EndProcedure

ProcedureDLL.boolean isWriteTrueColorSupported()
  Log$ = "isWriteTrueColorSupported()" + #LF$ +
         "--> " + Bool2Str(#PLUGIN_SUPPORTS_WRITE_TRUECOLOR)
  logger::TSPrint(Log$)
  ProcedureReturn #PLUGIN_SUPPORTS_WRITE_TRUECOLOR
EndProcedure

ProcedureDLL.boolean canExtractPalette()
  Log$ = "canExtractPalette()" + #LF$ +
         "--> " + Bool2Str(#PLUGIN_SUPPORTS_PALETTE_EXTRACT)
  logger::TSPrint(Log$)
  ProcedureReturn #PLUGIN_SUPPORTS_PALETTE_EXTRACT
EndProcedure

;- /// Image Processing Control ///

ProcedureDLL.strpointer getErrorMessage()
  Log$ = "getErrorMessage()" + #LF$ +
         "--> " 
  If PLUGIN_ERROR_MSG$ <> #Empty$
    logger::TSPrint(Log$ + ~"\"" + PLUGIN_ERROR_MSG$ + ~"\"")
    ProcedureReturn @PLUGIN_ERROR_MSG$
  Else
    logger::TSPrint(Log$ + ~"\"\" (no error)")
    ProcedureReturn #Null
  EndIf
EndProcedure

ProcedureDLL setFilename( *filename_pnt )
  Shared FileName$
  NewFileName$ = PeekS( *filename_pnt )
  Log$ = "setFilename( " + Hexify(*filename_pnt) + " )" + #LF$ +
         ~"*filename_pnt <-- \"" + NewFileName$ + ~"\"" + #LF$ +
         "FILE: " + GetFilePart(NewFileName$)
  If NewFileName$ <> FileName$
    If FileName$ <> ""
      Log$ + #LF$ + "(target file changed)" + #LF$ +
             "PREV FILE: " + GetFilePart(FileName$)
    EndIf
  Else
    Log$ + #LF$ + "(same as before)"
  EndIf
  FileName$ = NewFileName$
  logger::TSPrint(Log$)
EndProcedure

ProcedureDLL.boolean loadBasicData()
  resetError ; -> This procedure can set error!
  logger::TSPrint("loadBasicData()")
  ProcedureReturn #Success ; Fake succcess
EndProcedure

ProcedureDLL finishProcessing()
  logger::TSPrint("finishProcessing()")
EndProcedure

ProcedureDLL.boolean canHandle() ; Returns: #Success/#Failure
  resetError                     ; -> This procedure can set error!
  logger::TSPrint("canHandle()")
  ProcedureReturn #True 
EndProcedure

;- /// File Load Procedures ///

ProcedureDLL.boolean isAlphaEnabled()
  logger::TSPrint("isAlphaEnabled()")
  ProcedureReturn #False
EndProcedure


ProcedureDLL.int32 getWidth()
  logger::TSPrint("getWidth()")
  ProcedureReturn 64 ; -> Assume a 64x64 pixel image
EndProcedure

ProcedureDLL.int32 getHeight()
  logger::TSPrint("getHeight()")
  ProcedureReturn 64 ; -> Assume a 64x64 pixel image
EndProcedure

ProcedureDLL.int32 getImageCount() ; -> returns: int32
  resetError                       ; -> This procedure can set error!
  logger::TSPrint("getImageCount()")
  ProcedureReturn 1
EndProcedure

ProcedureDLL.pointer getRgbPalette()
  ; We don't have a palette to handle over! (need to create a fake one)
  logger::TSPrint("getRgbPalette()")
  ProcedureReturn #Null
EndProcedure

ProcedureDLL.int32 getTransparentColor() ; -> returns: int32
  logger::TSPrint("getTransparentColor()")
  ProcedureReturn -1                     ; -> No trasparent color
EndProcedure

ProcedureDLL.boolean loadNextImage()
  resetError ; -> This procedure can set error!
             ; We currently don't support this
  logger::TSPrint(~"loadNextImage()\nSET ERROR!")
  setError("PROCEDURE UNIMPLEMENTED: loadNextImage()")
  ProcedureReturn #Failure
EndProcedure

;- /// File Save Procedures ///

ProcedureDLL.boolean beginWrite()
  resetError ; -> This procedure can set error!
  logger::TSPrint("beginWrite()")
  ProcedureReturn #Success ; Fake succcess
EndProcedure

ProcedureDLL.boolean writeNextImage()
  resetError ; -> This procedure can set error!
  logger::TSPrint("writeNextImage()")
  ProcedureReturn #Success ; Fake succcess
EndProcedure

;}******************************************************************************
; *                                                                            *
;-                          PLUGIN INTERNAL PROCEDURES                          
; *                                                                            *
;{******************************************************************************
; These are some internal procedures to support the plugin DLL interface.

;}******************************************************************************
; *                                                                            *
;-                                 PLUGIN TODOS                                 
; *                                                                            *
;{******************************************************************************

; ==============================================================================
;                          IMPLEMENTATION FIX/COMPLETE                          
; ==============================================================================
; Some pending chores that must be fixed before first Beta is ready:

; [x] OpenLogger():
;     [x] If the editor gadget couldn't be created, the window should be closed
;         and the plugin made aware of the problem.
; [x] TSPrint() & PPrint():
;     [x] If the Log Window couldn't be created, the procedure shouldn't attempt
;         to update the editor gadget.

; ==============================================================================
;                                ADD NEW FEATURES                               
; ==============================================================================
; Areas in which the plugin could be improved:
; 
; ** CUSTOMIZE VIA OPTIONS FILE **
;
;    Default values and plugin setting could be controlled via an external file
;    (.ini or JSON) to allow experimenting with IMAGE/ANIMATION plugins,
;    simulate setting errors, and tweaking values.
; 
; ** FAKE IMAGE LOADING **
; 
;    In order to test with LOAD plugins I need to implement some procedures that
;    procedurally generate fake images and palettes to pass to PM. These could
;    be just a plain color filling, or I could hardcode the raw binary data of a
;    sample image.

;}
; /// EOF ///
