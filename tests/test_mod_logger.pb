; 2021/02/15 | PureBasic 5.73 LTS x86
; ******************************************************************************
; *                                                                            *
; *                     Test File for Logger Window Module                     *
; *                                                                            *
; *                               v.0.0.5-ALPHA                                *
; *                                                                            *
; ******************************************************************************
; Copyright (C) 2019-2021 by Tristano Ajmone. Released under MIT License.
; ------------------------------------------------------------------------------

CompilerIf Not #PB_Compiler_Debugger ; /// RUN ME FROM PB-IDE WITH DEBUGGER! ///
  CompilerError "Run this program from the IDE with Deubgger enabled!"
CompilerEndIf

XIncludeFile "..\mod_logger.pbi"
Declare AssertTest(test_desc.s, expected, obtained)
Declare ConfirmationWindow(ConfirmationType = 0)

#Failure = #False
#Success = #True

Enumeration ConfirmationType
  #CloseLogger
  #ClearLogger
EndEnumeration

cntErr = 0
cntTests = 0
;- /// TEST BEGIN ///

res= logger::PPrint(~"Try logging text to inexistent log.")
AssertTest("PPrint() without logger", #Failure, res)

res= logger::CloseLogger()
AssertTest("CloseLogger() with inexistent log", #Failure, res)

res= logger::OpenLogger("Log #1")
AssertTest("Create new logger", #Success, res)

res= logger::OpenLogger("Log #2")
AssertTest("Try creating a second logger", #Failure, res)

res= logger::PPrint(~"Logging some text to Logger #1.\nMultiple lines accepted.")
AssertTest("PPrint() on current logger", #Success, res)

res= logger::TSPrint(~"Logging time-stamped text to Logger #1.\nMultiple lines accepted.")
AssertTest("TSPrint() on current logger", #Success, res)

ConfirmationWindow(#ClearLogger)
res= logger::ClearLogger()
AssertTest("ClearLogger()", #Success, res)

ConfirmationWindow()
res= logger::CloseLogger()
AssertTest("CloseLogger()", #Success, res)

res= logger::OpenLogger("Log #2")
AssertTest("Create new logger", #Success, res)

res= logger::PPrint(~"Logging some text to Logger #2.")
AssertTest("PPrint() on current logger", #Success, res)

ConfirmationWindow()
res= logger::CloseLogger()
AssertTest("CloseLogger()", #Success, res)


;- /// TEST END ///

Debug LSet("", 80, "~")
If cntErr
  stats.s = Str(cntErr) +"/"+ Str(cntTests)
  Debug "** FAILURE ** Errors encountered: "+ stats +"."
  MessageRequester("** FAILURE **",
                   "Failed tests: "+ stats + ~".\n\nClick OK To End the test.",
                   #PB_MessageRequester_Error)
Else
  stats.s = " ("+ Str(cntTests) +"/"+ Str(cntTests) +")."
  Debug "!! SUCCESS !!! All tests passed without errors"+ stats
  MessageRequester("SUCCESS",
                   ~"All tests passed"+ stats + ~"\n\nClick OK To End the test.",
                   #PB_MessageRequester_Ok)
EndIf
End

;- /// Helper Procedures ///

Procedure AssertTest(test_desc.s, expected, obtained)
  ; ----------------------------------------------------------------------------
  ; Check that the result of a test are as expected, print a report for the
  ; test and keep track of the tests stats.
  ; ----------------------------------------------------------------------------
  Shared cntErr, cntTests
  cntTests +1
  Debug LSet("", 80, "-")
  Debug "TEST: "+ test_desc
  Debug "Expected result: "+ Str(expected)
  Debug "Obtained result: "+ Str(obtained)
  If expected = obtained
    Debug "PASSED"
  Else
    Debug "FAILED"
    cntErr +1
  EndIf
EndProcedure

Procedure ConfirmationWindow(ConfirmationType = #CloseLogger)
  ; ----------------------------------------------------------------------------
  ; Prompt user for confirmation before a log-destructive operation is about to
  ; be called, to allow visual inspection of the logs before destruction.
  ; ----------------------------------------------------------------------------
  Select ConfirmationType
    Case #CloseLogger:
      operation$ = " close "
    Case #ClearLogger:
      operation$ = " clear "
  EndSelect
  
  MessageRequester("WAITING",
                   "The next test will"+ operation$ +~"the logger window.\n\n"+
                   "Click OK To Continue.", #PB_MessageRequester_Ok)
  
EndProcedure

; /// EOF ///
