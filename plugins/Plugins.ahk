﻿/* 
Purpose       : Main #Include script for all Lintalist plugins.
Version       : 1.0

See "readme-howto.txt" for more information.
*/

;---------------------------------------------------------------
; do not remove/edit anything between these lines

ReadPluginSettings:
Loop, %A_ScriptDir%\plugins\*.ahk
	{
	 If (A_LoopFileName = "plugins.ahk")
	 	Continue
	 ClipCommand .= "[[" SubStr(A_LoopFileName,1,StrLen(A_LoopFileName)-4) "|"
	}
StringTrimRight, ClipCommand, ClipCommand, 1
StringReplace, ClipCommandRE, ClipCommand, [, \[, All ; for RE later in ProcessText routine
; MsgBox % Clipcommand ":" ClipCommandRE ; debug only
Return

;----------------------------------------------------------------
; Do not change the order of these default includes below:

#Include %A_ScriptDir%\plugins\snippet.ahk     ; Chaining snippets
#Include %A_ScriptDir%\plugins\input.ahk       ; Get user input
#Include %A_ScriptDir%\plugins\datetime.ahk    ; Insert date & time
#Include %A_ScriptDir%\plugins\selected.ahk    ; Cut currently selected text 
#Include %A_ScriptDir%\plugins\choice.ahk      ; Choose from a list
#Include %A_ScriptDir%\plugins\file.ahk        ; Include file
#Include %A_ScriptDir%\plugins\calendar.ahk    ; Calendar 
#Include %A_ScriptDir%\plugins\counter.ahk     ; Counters
#Include %A_ScriptDir%\plugins\calc.ahk        ; Math
#Include %A_ScriptDir%\plugins\c.ahk           ; Character plugin
#Include %A_ScriptDir%\plugins\split.ahk       ; Split plugin
#Include %A_ScriptDir%\plugins\SplitRepeat.ahk ; Split plugin
#Include %A_ScriptDir%\plugins\Random.ahk      ; Random plugin
;#Include %A_ScriptDir%\plugins\enc.ahk         ; Enc(rypt) plugin (decode)
#Include %A_ScriptDir%\plugins\ClipSelExFunc.ahk

; JJ ADD BEGIN
; Standard for Lintalist for math:
#Include %A_ScriptDir%\plugins\Math.ahk
#Include %A_ScriptDir%\plugins\Underline.ahk
; JJ ADD END
;----------------------------------------------------------------
; See readme-howto.txt for further info on how to write a plugin.
; Simply add the new plugin script as include below and reload Lintalist
; Don't forget to post on the forum if you do!

; #Include %A_ScriptDir%\plugins\filename.ahk
