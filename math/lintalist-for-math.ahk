

MathPreamble:
CoordMode, Mouse, Client
CoordMode, Pixel, Client
BlockInput SendAndMouse
MathHelperSnippet := ""
Return



MathHelperHotkeys:
; Set up snippet helper hotkeys
If (MathSnippetHelperHotkey <> "")
  Hotkey, %MathSnippetHelperHotkey%, MathSnippetHelperStart
If (MathSnippetHelperHotkey <> "")
  Hotkey, %MathImageHelperHotkey%, MathImageHelperStart
Return




MathOtherHotkeys:
; Setup general hotkeys
If (MathReloadAllHotkey <> "")
	Hotkey, %MathReloadAllHotkey%, MathReloadAllBundles
If (MathPastePureHotkey <> "")
	Hotkey, %MathPastePureHotkey%, MathPastePureText

; Setup Maple hotkeys
Hotkey, IfWinActive, - Maple ahk_class SunAwtFrame
If (MathYellowBGHotkey <> "")
	Hotkey, %MathYellowBGHotkey%, MathSetTextBackgroundColor
If (MathOrangeTextHotkey <> "")
	Hotkey, %MathOrangeTextHotkey%, MathSetTextColorToOrange
If (MathRedTextHotkey <> "")
	Hotkey, %MathRedTextHotkey%, MathSetTextColorToRed
If (MathSetUpHotkey <> "")
	Hotkey, %MathSetUpHotkey%, MathSetUpCommenting
Hotkey, IfWinActive
Return





MathHandleDeleteKey()
{
  ControlGetFocus, ControlInFocus
  If(ControlInFocus = "Edit1")
  {
    Send, {Delete}
    return true
  }
  return false
}







#IfWinActive, Lintalist snippet editor ahk_class AutoHotkeyGUI
; ctrl+u: Tilføj understregning til markering, når der redigeres i Lintalist snippet editor.
^u::InsertPluginPlaceholderOrWrapSelectedText("Underline", "u")

; ctrl+l: Tilføj link-tag til markering, når der redigeres i Lintalist snippet editor.
^l::InsertPluginPlaceholderOrWrapSelectedText("Link", "l")
#IfWinActive

InsertPluginPlaceholderOrWrapSelectedText(NameOfThisPluginForPasting, KeyOfThisPluginForPasting) 
{
  ControlGetFocus, ComponentCurrentlyWithFocus
  If Not (ComponentCurrentlyWithFocus = "Edit2")
  {
    Send, ^%KeyOfThisPluginForPasting%
    Return
  }
  ClipSaved := ClipboardAll
  Clipboard:=""
  Send, ^c
  Sleep 150
  Clipboard = [[%NameOfThisPluginForPasting%=%Clipboard%]]
  Send, ^v
  Sleep, 150
  Send, {LEFT}{LEFT}
  Clipboard := ClipSaved
  ClipSaved =
  Return
}









; Indsæt udklipsholderen som ren tekst (hvilket afhjælper noget formateringsbøvl i Maple)
MathPastePureText:
Clip0 = %ClipBoardAll%
ClipBoard = %ClipBoard%
SendInput ^v
Sleep 150                      ; Don't change clipboard while it is pasted! (Sleep > 0)
ClipBoard = %Clip0%
VarSetCapacity(Clip0, 0)
Return





; Genindlæs Lintalist med alle bundles indlæst
MathReloadAllBundles:
If (LoadAll = 0)
		{
		 LoadAll=1
		 Menu, tray, Check, &Load All Bundles
		 Try
			{
			 Menu, file, Check, &Load All Bundles
			}
		 Catch
			{
			 ;
			}
		}
	 Lock = 0
	 GuiControl, 1: ,Lock, 0
		LoadBundle()
	 UpdateLVColWidth()
	 Gosub, SetStatusBar
	 ShowPreview(PreviewSection)
	 Loop, parse, MenuName_HitList, |
		{
		 StringSplit, MenuText, A_LoopField, % Chr(5) ; %
		 Menu, file, UnCheck, &%MenuText1%
		}
Reload
Return





; Giv tekstmarkeringen gul baggrundsfarve i Maple
MathSetTextBackgroundColor:
SendEvent !r{Right}h
WinWaitActive, Select a Color, , 3
SendEvent {TAB 26}{Space}
SendEvent {ALT DOWN}o{ALT UP}
Return


; Giv tekstmarkeringen halvgennemsigtig orange farve i Maple
MathSetTextColorToOrange:
SendEvent !r{Right}c
WinWaitActive, Select a Color, , 3
SendEvent {TAB 33}{Space}
SendEvent {ALT DOWN}o{ALT UP}
Return


; Giv tekstmarkeringen en rød farve i Maple
MathSetTextColorToRed:
SendEvent, !r{Right}c
WinWaitActive, Select a Color, , 3
SendEvent, {TAB 16}{Space}
SendEvent, {ALT DOWN}o{ALT UP}
Return


; Kopier markeret tekst og guide i tilblivelsen af ny hotstring
MathSnippetHelperStart:
ClipSet("c",1,SendMethod)
GoSub, GUIStart
WinWaitActive, ahk_class AutoHotkeyGUI, , 3
If ErrorLevel
{
	Gui, 1:Destroy
	Return
}
MathHelperSnippet := ClipSet("g",1,SendMethod)
GoSub, EditF7
Return




MathImageHelperStart:
MathImageHelperUUID := CreateUUID() 
MathImageHelperFolder := A_ScriptDir . "\bundles\clips\"
MathImageHelperFile := MathImageHelperFolder . MathImageHelperUUID . ".clip"
IfNotExist, %MathImageHelperFolder%
  FileCreateDir, %MathImageHelperFolder%
If Not (Winclip.Save(MathImageHelperFile))
{
  MsgBox % "Lintalist for Math kunne ikke finde et billede i udklipsholderen. (Denne genvejstast opretter et billede i en snippet, hvis der er et billede i udklipsholderen, som programmet kan genkende.)"
  Return
}

GoSub, GUIStart
WinWaitActive, ahk_class AutoHotkeyGUI, , 3
If ErrorLevel
{
	Gui, 1:Destroy
	Return
}
MathHelperSnippet := "[[MathClip=" . MathImageHelperUUID . "]]"
GoSub, EditF7
Return



CreateUUID()
{
    VarSetCapacity(puuid, 16, 0)
    if !(DllCall("rpcrt4.dll\UuidCreate", "ptr", &puuid))
        if !(DllCall("rpcrt4.dll\UuidToString", "ptr", &puuid, "uint*", suuid))
            return StrGet(suuid), DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)
    return ""
}



; Giv Maple Input rød farve, zoom til 100 % og udfold alle sektioner.
MathSetUpCommenting:
SendEvent {ALT DOWN}rs{ALT UP}
WinWaitActive, Style Management, , 3
SendEvent {TAB}Maple Input{TAB 3}{Enter}
WinWaitActive, Character Style, , 3
SendEvent {SHIFT DOWN}{TAB 3}{SHIFT UP}{Enter}
GetClientSize(WinExist(), w, h)
;~ MsgBox, Width: %w%`nHeight: %h% ; for debugging
Sleep, 250
ImageSearch, FoundX, FoundY, 0, 0, w, h, *5 %A_ScriptDir%\icons\img-col.png
if(ErrorLevel <> 0)
	MsgBox, Fejl %ErrorLevel%
FoundX := FoundX + 3
FoundY := FoundY + 3
Click, %FoundX%, %FoundY%
SendEvent {Sleep 30}{TAB}{Enter}
WinWaitActive, Style Management, , 3
SendEvent {TAB}{Enter}
Sleep, 150
SendEvent, {ALT DOWN}vie{ALT UP}{CTRL DOWN}2{CTRL UP}
Return	


; Få bredde (w) og højde (h) af det givne vindue (hwnd)
GetClientSize(hwnd, ByRef w, ByRef h)
{
  VarSetCapacity(rc, 16)
  DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
  w := NumGet(rc, 8, "int")
  h := NumGet(rc, 12, "int")
}


isMathPaste()
{
  global Text1
  if (MathImagePaste(Text1))
    return true

  if isMaple()
  {
    Gosub, MathPaste
    OmniSearch:=0
    Typed:=""
    return true
  }
  else If isHTMLorRTFCompatible()
  {
    pasteHTML_RTF_Text()
    OmniSearch:=0
    Typed:=""
    return true
  }
  else
    Gosub, NotMathPaste
  return false
}




; Tjek om der pastes til Maple
isMaple()
{
  global ActiveWindowTitle, ActiveWindowClass
  isMaple := true
  IfNotInString, ActiveWindowTitle, - Maple
    isMaple := false
  if (ActiveWindowClass <> "SunAwtFrame")
    isMaple := false
  IfInString, Text1, [[image= ; don't use Maple handling for images
    isMaple := false
  Return isMaple
}


; Tjek om der pastes til Word, PDF XChangeViewer eller Adobe Acrobat
isHTMLorRTFCompatible()
{
  global ActiveWindowClass, ActiveWindowProcessName
  isHTMLorRTFCompatible := false
  if (ActiveWindowProcessName = "PDFXEdit.exe") ; PDF-XChange Editor (only support RTF and TEXT - no links)
	  isHTMLorRTFCompatible := true
  ; else if (ActiveWindowClass = "DSUI:PDFXCViewer") ; PDF-XChange Viewer (only supports TEXT)
  ;  isHTMLorRTFCompatible := true
  else if (ActiveWindowClass = "AcrobatSDIWindow") ; Adobe Acrobat (no links)
    isHTMLorRTFCompatible := true
  else if (ActiveWindowProcessName = "WINWORD.EXE") ; Microsoft Word
    isHTMLorRTFCompatible := true
  else if (ActiveWindowClass = "WordPadClass") ; WordPad
    isHTMLorRTFCompatible := true
  return isHTMLorRTFCompatible
}


pasteHTML_RTF_Text()
{
  global WinClip, Clip
  WinClip.Snap(Clip0)
  ;Clip := "æøå is [[Underline=??]] and [[Link=http://dr.dk]] and [[Math=x^t+2{right}+2x]] and [[C=Space|10]]."
  
  ; Fjern symboler som kun giver mening i Maple
  StringReplace, Clip, Clip, `^`^, `^, All
  ;StringReplace, Clip, Clip, `{right`}, , All   ; handled below
  StringReplace, Clip, Clip, %A_Tab%, ``t, All
  StringReplace, Clip, Clip, `;, ```;, All
  
  Clip := RegExReplace(Clip, "iU)\[\[Math=(.*)\]\]",  "$1")
  Clip := RegExReplace(Clip, "iU)\^(.*){right}",  "^($1)")
  StringReplace, Clip, Clip, `{right`}, , All
  
  ClipHTML := SubStr(Clip, 1)
  ClipHTML := RegExReplace(ClipHTML, "iU)\[\[Link=(.*)\]\]", "<a href=""$1"">$1</a>")
  ClipHTML := RegExReplace(ClipHTML, "iU)\[\[Underline=(.*)\]\]",  "<u>$1</u>")
  StringReplace, ClipHTML, ClipHTML, `n, <br>, All
  ClipHTML := "<span style=""color:red"">" . ClipHTML . "</span>"
  
  ClipRTF := SubStr(Clip, 1)
  ClipRTF := RegExReplace(ClipRTF, "iU)\[\[Link=(.*)\]\]", "{{\field{\*\fldinst{HYPERLINK $1 }}{\fldrslt{$1\ul0\cf0}}}}")
  ClipRTF := RegExReplace(ClipRTF, "iU)\[\[Underline=(.*)\]\]",  "\ul $1\ulnone ")
  StringReplace, ClipRTF, ClipRTF, `r, , All
  StringReplace, ClipRTF, ClipRTF, `n, \line` , All
  ClipRTF := "{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1030{\colortbl;\red255\green0\blue0\;}\cf1 " . ClipRTF . "}"
  
  ClipTEXT := SubStr(Clip, 1)
  ClipTEXT := RegExReplace(ClipTEXT, "iU)\[\[Link=(.*)\]\]", "$1")
  ClipTEXT := RegExReplace(ClipTEXT, "iU)\[\[Underline=(.*)\]\]",  "$1")  
  
  processClipText(ClipHTML)
  processClipText(ClipRTF)
  processClipText(ClipTEXT)
  
  WinClip.SetHTML(ClipHTML)
  WinClip.SetText(ClipTEXT)
  WinClip.SetRTF(ClipRTF)
  
  Sleep, 150
  Send, ^v
  Sleep, 150
  WinClip.Restore(Clip0)
}

processClipText(ByRef SpecialClip)
{
  global
  Clip := SpecialClip
  Gosub, ProcessText
  SpecialClip := SubStr(Clip, 1)
}


; Lintalist for Math-specfik paste procedure
MathPaste:
; Lav udskiftninger fra plugins (vigtigt at det sker inden "Gosub, ProcessText")
StringReplace, Clip, Clip, `^, {hatchar}, All
Clip := RegExReplace(Clip, "iU)\[\[Underline=([^\]]*)\]\]",  "^u$1^u")
Clip := RegExReplace(Clip, "iU)\[\[Math=([^\]]*)\]\]",  "^r$1^m")
Clip := RegExReplace(Clip, "iU)\[\[Link=([^\]]*)\]\]", "<<<<Link=$1>>>>")

;~ MsgBox, %Clip% ; for debugging
Clip0 = %ClipBoardAll% ; store clipboard
Gosub, ProcessText ; to support all plugins except for rtf, md, image, html, and clipboard with formatting/case change
;MsgBox, %Clip% ; for debugging

; Foretag udskiftninger af specielle tegn, så send-kommandoen fungerer som forventet
StringReplace, Clip, Clip, ``, ````, All  ; Do this replacement first to avoid interfering with the others below.
StringReplace, Clip, Clip, `r`n, ``r, All  ; Using `r works better than `n in MS Word, etc.
StringReplace, Clip, Clip, `n, ``r, All
;StringReplace, Clip, Clip, `^, {ASC 0094}, All  ; {ASC 0094}, All ; handled below instead
StringReplace, Clip, Clip, {right}, {right}, All  ; {ASC 0094}, All
StringReplace, Clip, Clip, `!, {!}, All
StringReplace, Clip, Clip, `+, {+}, All
StringReplace, Clip, Clip, `#, {#}, All
StringReplace, Clip, Clip, ``r, `^`+j`^m, All
;~ While(SubStr(Clip, StrLen(Clip)-4) = "^+j^m")
  ;~ StringTrimRight, Clip, Clip, 5

If (InStr(Clip, "<<<<Link="))
{
  ClipCopy := SubStr(Clip, 1)
  KeyWait Alt, L, T5
  If ErrorLevel
  {
    Return
  }
  Loop
  {
    If(RegExMatch(ClipCopy, "OiU)\<\<\<\<Link=([^>>>>]*)>>>>", SubPat)) {
      Clip := Substr(ClipCopy, 1, SubPat.Pos(0) - 1)
      Gosub, MathSendInput
      ClipCopy := Substr(ClipCopy, SubPat.Pos(0) + SubPat.Len(0))
      textWithURL := SubPat.Value(1)
      Gosub, insertLinkMaple
    }
    If Not RegExMatch(ClipCopy, "OiU)\<\<\<\<Link=([^>>>>]*)>>>>") {
      Clip := "" . ClipCopy
      Break  
    }
  }
}
Gosub, MathSendInput
ClipBoard = %Clip0% ; restore clipboard
Text1=
Text2=
Clip=
ClipCopy=
SupPat=
textWithURL=
VarSetCapacity(Clip0, 0)
Return



MathSendInput:
;MsgBox, %Clip% ; for debugging
Send, ^m
If (InStr(Clip, "{hatchar}"))
{
  ClipArray := StrSplit(Clip, "{hatchar}")
  LastClip := ClipArray.Pop()
  for index, element in ClipArray
  {
    SendInput, %element%
    SendInput, +{^}
    Sleep, 150
  }
  SendInput, %LastClip%
  LastClip=
  ClipArray=
}
Else {
  SendInput, %Clip%
}
Return



NotMathPaste:
; Fjern symboler som kun giver mening i Maple
StringReplace, Clip, Clip, `^`^, `^, All
StringReplace, Clip, Clip, %A_Tab%, ``t, All
StringReplace, Clip, Clip, `;, ```;, All

Clip := RegExReplace(Clip, "iU)\[\[Math=(.*)\]\]",  "$1")
Clip := RegExReplace(Clip, "iU)\^(.*){right}",  "^($1)")
StringReplace, Clip, Clip, `{right`}, , All

Clip := RegExReplace(Clip, "iU)\[\[Link=([^\]]*)\]\]", "$1")
Return




insertLinkMaple:
Send, ^t
Sleep, 50
SendEvent, {ALT DOWN}ihh{ALT UP}
Sleep, 50
Send, {ENTER}
WinWaitActive, Hyperlink Properties, , 1
if ErrorLevel
{
	MsgBox, Fejl.
  Return
}
else
{
	Winclip.Paste(textWithURL)
  Sleep, 50
	SendEvent, {TAB 3}
  Sleep, 50
	Winclip.Paste(textWithURL)
	Send, {ENTER}
}
Sleep, 150
Return

/**
 * Paste clip if plugin substring present
 * @param {String} Text1 Snippet text
 * @return true if image was pasted, otherwise false 
 */
MathImagePaste(ByRef Text1)
{
  If (InStr(Text1, "[[MathClip="))
  {
    If(RegExMatch(Text1, "OiU)\[\[MathClip=([^\]]*)\]\]", SubPat)) {
      WinClip.Snap(Clip0)
      If(WinClip.Load(A_ScriptDir . "\bundles\clips\" . SubPat.Value(1) ".clip"))
      {
        Sleep, 150
        Send, ^v
        Sleep, 150
      }
      WinClip.Restore(Clip0)
      Return 1
    }
  }
  Else
    Return 0
}
