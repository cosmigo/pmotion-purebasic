; "pmotion_file-io_barebones.pb" v0.0.3 | 2021/02/15    | PureBasic 5.73 LTS x86
; ******************************************************************************
; *                                                                            *
; *                             Cosmigo Pro Motion                             *
; *                                                                            *
; *              File I/O Plugin Interface (bare-bones template)               *
; *                                                                            *
; ******************************************************************************
; Copyright (C) 2019-2021 by Tristano Ajmone, MIT License.
; https://github.com/cosmigo/pmotion-purebasic
; ------------------------------------------------------------------------------
#PLUGIN_SUPPORTS_ANIMATION       = #False
#PLUGIN_SUPPORTS_PALETTE_EXTRACT = #False
#PLUGIN_SUPPORTS_READ            = #False
#PLUGIN_SUPPORTS_WRITE           = #False
#PLUGIN_SUPPORTS_WRITE_TRUECOLOR = #False

Global FILE_TYPE_ID$ = "your.plugin.unique.id"
Global FILE_BOX_DESCRIPTION$ = "EXT Description"
Global FILE_EXTENSION$ = "ext"

#PLUGIN_INTERFACE_VERSION_USED = 1

#Success = #True : #Failure = #False

Global PLUGIN_ERROR_MSG$ = #Empty$

Macro setError( errString )
  PLUGIN_ERROR_MSG$ = errString
EndMacro

Macro resetError
  PLUGIN_ERROR_MSG$ = #Empty$
EndMacro

UILang$   = #Empty$ ; PMNG user interface locale (2 chars ISO language code)
FileName$ = #Empty$ ; Full path to the selected file.

Structure ImageDataStruct
  Width.l
  Height.l
  Frames.l
  TranspColorIndex.l
  AlphaEnabled.i
EndStructure

ImageData.ImageDataStruct

Procedure resetImageData()
  Shared ImageData
  With ImageData
    \Height = -1
    \Width  = -1
    \Frames = -1
    \TranspColorIndex = -1
    \AlphaEnabled = #False
  EndWith
EndProcedure

;-/// DLL Procs -> All Plugins ///

ProcedureDLL.i initialize(*language, *version.Unicode, *animation.Ascii)
  resetError
  *version\u   = #PLUGIN_INTERFACE_VERSION_USED
  *animation\a = #PLUGIN_SUPPORTS_ANIMATION
  Shared UILang$
  UILang$ = Chr(PeekA(*language)) + Chr(PeekA(*language +1))
  ; >>> Your code here >>>>>>>>>>>>>>>
  ; Do whatever you need to...
  
  ; In case of error:
  ;     setError("Why failed...")
  ;     ProcedureReturn #Failure
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
  ProcedureReturn #Success
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

ProcedureDLL finishProcessing()
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Close file, free memory, and other wrap-up chores...
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure

;-/// DLL Procs -> Import Plugins ///

ProcedureDLL.i canHandle()
  resetError
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Establish if the plugin can handle the selected file...
  
  ; In case of error:
  ;     setError("Why failed...")
  ;     ProcedureReturn #Failure
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
  ProcedureReturn #Success
EndProcedure

ProcedureDLL.i loadBasicData()
  resetError
  Shared ImageData
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Extract basic graphics data information from the target file, such as its
  ; dimensions, color palette, etc. and update the ImageData structured var:
  ;
  ;     With ImageData
  ;       \Width  =           ; pixels width
  ;       \Height =           ; pixels height
  ;       \Frames =           ; number of frames (or -1 on failure)
  ;       \TranspColorIndex = ; index of transp. color (or -1 if none)
  ;       \AlphaEnabled =     ; #True/#False
  ;     EndWith
  
  ; In case of error:
  ;     setError("Why failed...")
  ;     ProcedureReturn #Failure
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
  ProcedureReturn #Success
EndProcedure

ProcedureDLL.l getImageCount()
  Shared ImageData
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
  ProcedureReturn ImageData\Frames
EndProcedure

ProcedureDLL.i getRgbPalette()
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Return a pointer to the extracted RGB palette or #Null if palette extraction
  ; is not supported.
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
EndProcedure

ProcedureDLL.i loadNextImage(*colorFrame,
                             *colorFramePalette,
                             *alphaFrame,
                             *alphaFramePalette,
                             delayMs.u)
  resetError
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Load the image/frame in memory and set the pointers of the parameters
  ; accordingly ...
  
  ; In case of error:
  ;     setError("Why failed...")
  ;     ProcedureReturn #Failure
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
  ProcedureReturn #Success
EndProcedure

;-/// DLL Procs -> Export Plugins ///

ProcedureDLL.i beginWrite(width.l,
                          height.l,
                          transparentColor.l,
                          alphaEnabled.i,
                          numberOfFrames.l)
  resetError
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Do something...
  
  ; In case of error:
  ;     setError("Why failed...")
  ;     ProcedureReturn #Failure
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
  ProcedureReturn #Success
EndProcedure

ProcedureDLL.i writeNextImage(*colorFrame,
                              *colorFramePalette,
                              *alphaFrame,
                              *alphaFramePalette,
                              *rgba,
                              delayMs.u)
  resetError
  ; >>> Your code here >>>>>>>>>>>>>>>
  
  ; Get the image/frame data from the parameters pointers and do what you have
  ; to do with it ...
  
  ; In case of error:
  ;     setError("Why failed...")
  ;     ProcedureReturn #Failure
  
  ; <<< Your code ends <<<<<<<<<<<<<<<
  ProcedureReturn #Success
EndProcedure

; ==============================================================================
;-/// HARD-CODED STUFF /// No need to edit what follows...
; ==============================================================================
; DLL Procs -> All Plugins

Prototype ProtoProgressCallback( progress.l )
Global progressCallback.ProtoProgressCallback

ProcedureDLL setProgressCallback( *progressCallback )
  progressCallback = *progressCallback
EndProcedure

ProcedureDLL.i getFileExtension()
  ProcedureReturn @FILE_EXTENSION$
EndProcedure

ProcedureDLL.i getFileTypeId()
  ProcedureReturn @FILE_TYPE_ID$
EndProcedure

ProcedureDLL.i getFileBoxDescription()
  ProcedureReturn @FILE_BOX_DESCRIPTION$
EndProcedure

ProcedureDLL.i isReadSupported()
  ProcedureReturn #PLUGIN_SUPPORTS_READ
EndProcedure

ProcedureDLL.i isWriteSupported()
  ProcedureReturn #PLUGIN_SUPPORTS_WRITE
EndProcedure

ProcedureDLL.i isWriteTrueColorSupported()
  ProcedureReturn #PLUGIN_SUPPORTS_WRITE_TRUECOLOR
EndProcedure

ProcedureDLL.i canExtractPalette()
  ProcedureReturn #PLUGIN_SUPPORTS_PALETTE_EXTRACT
EndProcedure

ProcedureDLL.i getErrorMessage()
  If PLUGIN_ERROR_MSG$ <> #Empty$
    ProcedureReturn @PLUGIN_ERROR_MSG$
  Else
    ProcedureReturn #Null
  EndIf
EndProcedure

; DLL Procs -> Import Plugins

ProcedureDLL.i isAlphaEnabled()
  Shared ImageData
  ProcedureReturn ImageData\AlphaEnabled
EndProcedure

ProcedureDLL.l getWidth()
  Shared ImageData
  ProcedureReturn ImageData\Width
EndProcedure

ProcedureDLL.l getHeight()
  Shared ImageData
  ProcedureReturn ImageData\Height
EndProcedure

ProcedureDLL.l getTransparentColor()
  Shared ImageData
  ProcedureReturn ImageData\TranspColorIndex
EndProcedure

;-/// Check Compiler Settings ///
CompilerIf #PB_Compiler_OS <> #PB_OS_Windows Or
           #PB_Compiler_Processor <> #PB_Processor_x86 Or
           #PB_Compiler_ExecutableFormat <> #PB_Compiler_DLL Or
           #PB_Compiler_Thread = #True
  CompilerError "WRONG COMPILER SETTINGS! Must be Windows DLL for x86 (32 bit) not threadsafe"
CompilerEndIf

; EOF ;
