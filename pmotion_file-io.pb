; "pmotion_file-io.pb"                                 DRAFT v0.0.3 | 2021/02/15
; ******************************************************************************
; *                                                                            *
; *                             Cosmigo Pro Motion                             *
; *                                                                            *
; *                         File I/O Plugin Interface                          *
; *                                                                            *
; ******************************************************************************

#PLUGIN_PB_VER = 573   ; PureBasic 5.73 LTS x86

; Copyright (C) 2019-2021 by Tristano Ajmone, MIT License.
; https://github.com/cosmigo/pmotion-purebasic
; ------------------------------------------------------------------------------
; STATUS: NOT FULLY TESTED IN REAL CASE SCENARIOS.
; ******************************************************************************
; *                                                                            *
;-                                 PLUGIN SETUP
; *                                                                            *
;{******************************************************************************

; ------------------------------------------------------------------------------
;- Plugin Settings
; ------------------------------------------------------------------------------
#PLUGIN_SUPPORTS_ANIMATION       = #False ; or #True
#PLUGIN_SUPPORTS_PALETTE_EXTRACT = #False ; or #True
#PLUGIN_SUPPORTS_READ            = #False ; or #True
#PLUGIN_SUPPORTS_WRITE           = #False ; or #True
#PLUGIN_SUPPORTS_WRITE_TRUECOLOR = #False ; or #True

Global FILE_TYPE_ID$ = "your.plugin.id"  ; A unique identifier of the plugin
Global FILE_BOX_DESCRIPTION$ = "xxx etc" ; Extensions description (for UI)
Global FILE_EXTENSION$ = "xxx"           ; File extension (without dot)

; ------------------------------------------------------------------------------
; Hard-Coded Plugin Settings
; ------------------------------------------------------------------------------
; Plugin interface internal settings (for maintainers of the PB interface only).

; At the moment there is only version "1" of the file plugin interface:
#PLUGIN_INTERFACE_VERSION_USED = 1
; ------------------------------------------------------------------------------
;- Check Compiler Settings
; ------------------------------------------------------------------------------
CompilerIf #PB_Compiler_OS <> #PB_OS_Windows Or
           #PB_Compiler_Processor <> #PB_Processor_x86 Or
           #PB_Compiler_ExecutableFormat <> #PB_Compiler_DLL Or
           #PB_Compiler_Thread = #True
  CompilerError "WRONG COMPILER SETTINGS! Must be Windows DLL for x86 (32 bit) not threadsafe"
CompilerEndIf

CompilerIf #PB_Compiler_Version <> #PLUGIN_PB_VER
  CompilerWarning ~"This plugin was tested only on PureBasic "+ #PLUGIN_PB_VER + "."
CompilerEndIf
; ------------------------------------------------------------------------------
;- Global Strings for PMNG
; ------------------------------------------------------------------------------
; Strings that need to be returned from the plugin DLL procedures to Pro Motion
; (via pointers) must be defined as globals.

Global PLUGIN_ERROR_MSG$ = #Empty$

; ==============================================================================
;-                                Useful Helpers
;{==============================================================================
#Success = #True
#Failure = #False
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

Macro uint16
  u
EndMacro
; ------------------------------------------------------------------------------
; Error Macros
; ------------------------------------------------------------------------------
Macro resetError
  PLUGIN_ERROR_MSG$ = #Empty$
EndMacro

Macro setError( errString )
  PLUGIN_ERROR_MSG$ = errString
EndMacro

;}==============================================================================
;-                                  DLL Setup
; ==============================================================================

; ------------------------------------------------------------------------------
;- Sharable Variables (for internal use)
; ------------------------------------------------------------------------------
; These variables are handled transparently by the plugin interface template,
; which takes care of setting their values based on the transactions with Pro
; Motion. They can be accessed by the user via the Shared keyword if/when he/she
; needs them in his/her code.

UILang$   = #Empty$ ; PMNG user interface locale (2 chars ISO language code)
FileName$ = #Empty$ ; Full path to the selected file.

; This structure and the corresponding ImageData var are provided by the plugin
; interface template as a convenient way to handle image/frames data across
; procedures by sharing a single variable on demand.

; Also, the template is designed to implicitly handle ImageData in some plugin
; native procedures, thus lifting from the plugin author the burden of having to
; write any code in them — e.g. getWidth(), getHeight(), and others.

; But the plugin author ** MUST ALWAYS ** update ImageData with any acquired
; info about the images/frames being processed.

Structure ImageDataStruct
  Width.int32
  Height.int32
  Frames.int32
  TranspColorIndex.int32
  AlphaEnabled.boolean
EndStructure

ImageData.ImageDataStruct

; See also resetImageData() for a quick way to reset ImageData values.

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
DeclareDLL.boolean      loadNextImage(*colorFrame,
                                      *colorFramePalette,
                                      *alphaFrame,
                                      *alphaFramePalette,
                                      delayMs.uint16)

; File Save Procedures:
DeclareDLL.boolean      beginWrite(width.int32,
                                   height.int32,
                                   transparentColor.int32,
                                   alphaEnabled.boolean,
                                   numberOfFrames.int32)
DeclareDLL.boolean      writeNextImage(*colorFrame,
                                       *colorFramePalette,
                                       *alphaFrame,
                                       *alphaFramePalette,
                                       *rgba,
                                       delayMs.uint16)

; ------------------------------------------------------------------------------
;- Procedures Declaration (Interface Helpers)
; ------------------------------------------------------------------------------
Declare resetImageData()

;}******************************************************************************
; *                                                                            *
;-                            PLUGIN DLL PROCEDURES
; *                                                                            *
;{******************************************************************************
; These are the mandatory DLL procedures required by every file I/O plugin.
; Pro Motion expects them to be exported with these exact names and signature.

; Even if you plug-in doesn't use some of these procedures (because it only
; supports import or export) you still need to define all of them, otherwise the
; plugin will fail the initialization test as "invalid" and will be ignored.

; Some procedures don't require any custom code from the plugin author (they can
; handle the call via the available data and settings) while others require the
; plugin author to add code, as indicated by the comments in the procedure body.

; Below is a reference table with all the mandatory DLL procedures and whether
; they need custom code additions, and if they can set error or not.

;   +-----------------------------+------------+---------------+
;   |     plugin DLL procedure    | your code? |  set error?   |
;   +-----------------------------+------------+---------------+
;   | beginWrite()                | needs code | can set error |
;   | canExtractPalette()         |            |               |
;   | canHandle()                 | needs code | can set error |
;   | finishProcessing()          | needs code |               |
;   | getErrorMessage()           |            |               |
;   | getFileBoxDescription()     |            |               |
;   | getFileExtension()          |            |               |
;   | getFileTypeId()             |            |               |
;   | getHeight()                 |            |               |
;   | getImageCount()             | needs code |               |
;   | getRgbPalette()             | needs code |               |
;   | getTransparentColor()       | needs code |               |
;   | getWidth()                  |            |               |
;   | initialize()                | needs code | can set error |
;   | isAlphaEnabled()            |            |               |
;   | isReadSupported()           |            |               |
;   | isWriteSupported()          |            |               |
;   | isWriteTrueColorSupported() |            |               |
;   | loadBasicData()             | needs code | can set error |
;   | loadNextImage()             | needs code | can set error |
;   | setFilename()               | needs code |               |
;   | setProgressCallback()       |            |               |
;   | writeNextImage()            | needs code | can set error |
;   +-----------------------------+------------+---------------+

;- /// Plugin Initialization ///

ProcedureDLL.boolean initialize(*language, *version.Unicode, *animation.Ascii)
  resetError ; -> This procedure can set error!
  *version\u   = #PLUGIN_INTERFACE_VERSION_USED
  *animation\a = #PLUGIN_SUPPORTS_ANIMATION
  Shared UILang$
  UILang$ = Chr(PeekA(*language)) + Chr(PeekA(*language +1))
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Do whatever you need to...
  
  ProcedureReturn #Success ; or #Failure + setError("Why failed...")
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure

Prototype ProtoProgressCallback( progress.int32 )
Global progressCallback.ProtoProgressCallback

ProcedureDLL setProgressCallback( *progressCallback )
  progressCallback = *progressCallback
EndProcedure

;- /// Plugin Info ///

ProcedureDLL.strpointer getFileExtension()
  ProcedureReturn @FILE_EXTENSION$
EndProcedure

ProcedureDLL.strpointer getFileTypeId()
  ProcedureReturn @FILE_TYPE_ID$
EndProcedure

ProcedureDLL.strpointer getFileBoxDescription()
  ProcedureReturn @FILE_BOX_DESCRIPTION$
EndProcedure

;- /// Plugin Features Support Info ///

ProcedureDLL.boolean isReadSupported()
  ProcedureReturn #PLUGIN_SUPPORTS_READ
EndProcedure

ProcedureDLL.boolean isWriteSupported()
  ProcedureReturn #PLUGIN_SUPPORTS_WRITE
EndProcedure

ProcedureDLL.boolean isWriteTrueColorSupported()
  ProcedureReturn #PLUGIN_SUPPORTS_WRITE_TRUECOLOR
EndProcedure

ProcedureDLL.boolean canExtractPalette()
  ProcedureReturn #PLUGIN_SUPPORTS_PALETTE_EXTRACT
EndProcedure

;- /// Image Processing Control ///

ProcedureDLL.strpointer getErrorMessage()
  If PLUGIN_ERROR_MSG$ <> #Empty$
    ProcedureReturn @PLUGIN_ERROR_MSG$
  Else
    ProcedureReturn #Null
  EndIf
EndProcedure

ProcedureDLL setFilename( *filename_pnt )
  Shared FileName$
  NewFileName$ = PeekS( *filename_pnt )
  If NewFileName$ <> FileName$
    ; >>> Your code here >>>>>>>>>>>>>>>
    
    ; A new file was selected ...
    
    ; <<< Your code ends <<<<<<<<<<<<<<<
  EndIf
  FileName$ = NewFileName$
EndProcedure

ProcedureDLL.boolean loadBasicData()
  resetError ; -> This procedure can set error!
  Shared ImageData
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Extract basic graphics data information from the target file, such as its
  ; dimensions, color palette, etc. and update the ImageData structured var:
  
  ; With ImageData
  ;   \Width  =           ; pixels width
  ;   \Height =           ; pixels height
  ;   \Frames =           ; number of frames (or -1 on failure)
  ;   \TranspColorIndex = ; index of transp. color (or -1 if none)
  ;   \AlphaEnabled =     ; #True/#False
  ; EndWith
  
  ProcedureReturn #Success ; or #Failure + setError("Why failed...")
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure

ProcedureDLL finishProcessing()
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Close file, free memory, and other wrap-up chores...
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure

ProcedureDLL.boolean canHandle()
  resetError ; -> This procedure can set error!
  
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Establish if the plugin can handle the selected file...
  
  ProcedureReturn #True ; or #False + setError("Why can't handle...")
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure

;- /// File Load Procedures ///

; The next five procedures rely on you having correctly updated the ImageData
; structured variable during loadBasicData(), and will not require you to add
; any code to them.

ProcedureDLL.boolean isAlphaEnabled()
  Shared ImageData
  ProcedureReturn ImageData\AlphaEnabled
EndProcedure

ProcedureDLL.int32 getWidth()
  Shared ImageData
  ProcedureReturn ImageData\Width
EndProcedure

ProcedureDLL.int32 getHeight()
  Shared ImageData
  ProcedureReturn ImageData\Height
EndProcedure

ProcedureDLL.int32 getTransparentColor()
  Shared ImageData
  ProcedureReturn ImageData\TranspColorIndex
EndProcedure

ProcedureDLL.int32 getImageCount()
  Shared ImageData
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
  ProcedureReturn ImageData\Frames
EndProcedure

ProcedureDLL.pointer getRgbPalette()
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Return a pointer to the extracted RGB palette or #Null if palette extraction
  ; is not supported.
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure


ProcedureDLL.boolean loadNextImage(*colorFrame,
                                   *colorFramePalette,
                                   *alphaFrame,
                                   *alphaFramePalette,
                                   delayMs.uint16)
  resetError ; -> This procedure can set error!
  
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Load the image/frame in memory and set the pointers of the parameters
  ; accordingly ...
  
  ProcedureReturn #Success ; or #Failure + setError("Why failed...")
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure

;- /// File Save Procedures ///

ProcedureDLL.boolean beginWrite(width.int32,
                                height.int32,
                                transparentColor.int32,
                                alphaEnabled.boolean,
                                numberOfFrames.int32)
  resetError ; -> This procedure can set error!
  
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Do something...
  
  ProcedureReturn #Success ; or #Failure + setError("Why failed...")
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure

ProcedureDLL.boolean writeNextImage(*colorFrame,
                                    *colorFramePalette,
                                    *alphaFrame,
                                    *alphaFramePalette,
                                    *rgba,
                                    delayMs.uint16)
  resetError ; -> This procedure can set error!
  
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Get the image/frame data from the parameters pointers and do what you have
  ; to do with it ...
  
  ProcedureReturn #Success ; or #Failure + setError("Why failed...")
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure

;}******************************************************************************
; *                                                                            *
;-                         INTERFACE HELPER PROCEDURES
; *                                                                            *
;{******************************************************************************
; Some internal procedures provided by the interface template to support the
; plugin DLL interface.

Procedure resetImageData()
  ; ----------------------------------------------------------------------------
  ; Reset all values of ImageData structure to defaults.
  ; ----------------------------------------------------------------------------
  Shared ImageData
  With ImageData
    \Height = -1
    \Width  = -1
    \Frames = -1
    \TranspColorIndex = -1
    \AlphaEnabled = #False
  EndWith
EndProcedure

;}******************************************************************************
; *                                                                            *
;-                       YOUR INTERNAL PLUGIN PROCEDURES
; *                                                                            *
; ******************************************************************************
; Add below all your custom procedures that make your plugin unique...

; EOF ;
