;													┏━━━━━━━━━━━━━━━━━━┓
;													┃ LIVE WINDOWS 3.0 ┃
;╔══════════════════════════════════════════════════╧══════════════════╧══════════════════════════════════════════════════╗
;║					Script to monitior a window or section of a window (such as a progress bar, or video) 				  ║
;║										in a resizable live preview window (thumbnail)									  ║
;╟────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╢
;║            THIS IS AN UPDATE (IN TERMS OF FUNCTIONALITY) TO THE UPDATED LIVEWINDOWS AHK SCRIPT BY KYF                  ║
;║                https://autohotkey.com/board/topic/71692-an-updated-livewindows-which-can-also-show-video/              ║
;║ WHICH TAKES ADVANTAGE OF WINDOWS VISTA/7 AEROPEAK. THE SCRIPT RELIES ON THUMBNAIL.AHK, A GREAT SCRIPT BY RELMAUL.ESEL, ║
;║                                https://autohotkey.com/board/topic/65854-aero-thumbnails/                               ║
;║                                 IT ALSO TAKES ADVANTAGE OF WINDRAG.AHK BY NICKSTOKES,                                  ║
;║                                https://www.autohotkey.com/boards/viewtopic.php?t=57703. 								  ║
;╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
;														┏━━━━━━━━━━┓
;														┃ KEYBINDS ┃
;╔══════════════════════════════════════════════════════╧══════════╧══════════════════════════════════════════════════════╗
;║ 				WIN + SHIFT + W                                     CREATE THUMBNAIL OF WHOLE WINDOW 					  ║
;║ 				WIN + SHIFT + LEFT MOUSE                            DEFINE REGION TO CREATE THUMBNAIL					  ║
;║ 				WIN + SHIFT + TAB                                   CLOSE ALL ACTIVE THUMBNAILS							  ║
;║ 				CTRL + ALT + LEFT MOUSE (ON THUMBNAIL)              DRAG THUMBNAIL AROUND SCREEN						  ║
;║ 				CTRL + ALT + RIGHT MOUSE (ON THUMBNAIL)             RESIZE THUMBNAIL									  ║
;║				CTRL + ALT + MOUSE WHEEL (ON THUMBNAIL)             CHANGE OPACITY BY 1%								  ║
;║				CTRL + ALT + SHIFT + MOUSE WHEEL (ON THUMBNAIL)     CHANGE OPACITY BY 5%								  ║
;╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

; initializing the script:
#SingleInstance force
#NoEnv
#KeyHistory 0
#Persistent
SetWorkingDir %A_ScriptDir%
#include Thumbnails.ahk
#Include windrag.ahk
CoordMode, Mouse ; Required
CoordMode,ToolTip,Screen
; Initialize variables
global guiShown := false
global opacity := 255
global opacityPercent := 100

#IfWinActive
; initializing hotkeys
Hotkey, $#+w, watchWindow
Hotkey, $#+LButton , start_defining_region
Hotkey, $#+tab, guiClose
#If MouseIsOver("ahk_class AutoHotkeyGUI")
{
    $^!WheelUp::opacityUp()
    $^!+WheelUp::opacityUp()
    $^!WheelDown::opacityDown()
    $^!+WheelDown::opacityDown()
    $^!LButton::WindowMouseDragMove()
    $^!RButton::WindowMouseDragResize()
}
return
#If
    ; Hotkey, $^T, TooltipDisplay

;--------------------------------------------------------------------------------------------

watchWindow:
    Gui, Destroy
    Thumbnail_Destroy(thumbID)
    guiShown := false
    opacity := 255
    opacityPercent := 100
    WinGetClass, class, A ; get ahk_id of foreground window
    targetName = ahk_class %class% ; get target window id
    WinGetPos, , , Rwidth, Rheight, A
    start_x := 0
    start_y := 0
    sleep, 500 

    ThumbWidth := 400
    ThumbHeight := 400
    thumbID := mainCode(targetName,ThumbWidth,ThumbHeight,start_x,start_y,Rwidth,Rheight)
    guiShown := true
    WinGet, id, list,Live Thumbnail,,
    Loop, %id%
    {
        this_id := id%A_Index%
        WinActivate, ahk_id %this_id%
        WinGetClass, this_class, ahk_id %this_id%
        WinGetTitle, this_title, ahk_id %this_id%
        IfMsgBox, NO, break
        WinSet, Style, -0xC40000 , A
        ; WinSet, Style, +0x840000 , A
    }
return

start_defining_region:
    Gui, Destroy
    Thumbnail_Hide(thumbID)
    Thumbnail_Destroy(thumbID)
    guiShown := false
    CoordMode, Mouse, Relative ; relative to window not screen
    ; MouseGetPos, start_x, start_y ; start position of mouse
    LetUserSelectRect(start_x, start_y, current_x, current_y)
    ;     ; SetTimer end_defining_region, 200 ; check every 50ms for mouseup

    ; Return

    ; end_defining_region:

    ; get the region dimensions
    ; MouseGetPos, current_x, current_y 
    Rheight := abs(current_y - start_y)
    Rwidth := abs(current_x - start_x)

    WinGetPos, win_x, win_y, , , A

    P_x := start_x + win_x
    P_y := start_y + win_y

    if (current_x < start_x)
        P_x := current_x + win_x

    if (current_y < start_y)
        P_y := current_y + win_y

    ; draw a box to show what is being defined
    ; Progress, B1 CWffdddd CTff5555 ZH0 fs13 W%Rwidth% H%Rheight% x%P_x% y%P_y%, , ,getMyRegion
    ; WinSet, Transparent, 110, getMyRegion

    ; if mouse not released then loop through above code...
    ; If GetKeyState("LButton", "P")
    ;     Return

    ;...otherwise, stop defining region, and start thumbnail ------------------------------->
    ; SetTimer end_defining_region, OFF

    Progress, off

    MouseGetPos, end_x, end_y
    if (end_x < start_x)
        start_x := end_x

    if (end_y < start_y)
        start_y := end_y

    WinGetClass, class, A ; get ahk_id of foreground window

    targetName = ahk_class %class% ; get target window id

    sleep, 500
    ThumbWidth := Rwidth
    ThumbHeight := Rheight
    thumbID := mainCode(targetName,ThumbWidth,ThumbHeight,start_x,start_y,Rwidth,Rheight)
    guiShown := true
    opacity := 255
    opacityPercent := 100
    WinGet, id, list,Live Thumbnail,,
    Loop, %id%
    {
        this_id := id%A_Index%
        WinActivate, ahk_id %this_id%
        WinGetClass, this_class, ahk_id %this_id%
        WinGetTitle, this_title, ahk_id %this_id%
        ; MsgBox 0x40004,, % "Visiting All Windows`n" a_index " of " id _
        . "`nahk_id " this_id "`nahk_class " this_class "`ntitlle " this_title "`n`nContinue?"
        IfMsgBox, NO, break
        WinSet, Style, -0xC00000, A

    }
return

mainCode(targetName,windowWidth,windowHeight,RegionX,RegionY,RegionW,RegionH)
{
    ; get the handles:
    Gui +LastFound
    hDestination := WinExist() ; ... to our GUI...
    hSource := WinExist(targetName) ;

    ; creating the thumbnail:
    hThumb := Thumbnail_Create(hDestination, hSource) ; you must get the return value here!
    ; getting the source window dimensions:
    Thumbnail_GetSourceSize(hThumb, width, height)

    ;-- make sure ratio is correct
    CorrectRatio := RegionW / RegionH
    testWidth := windowHeight * CorrectRatio
    if (windowWidth < testWidth)
    {
        windowHeight := windowWidth / CorrectRatio
    }
    ;  else
    ;  {
    ;     windowWidth := testWidth
    ;  }

    ; then setting its region:
    Thumbnail_SetRegion(hThumb, 0, 0 , windowWidth, windowHeight, RegionX , RegionY ,RegionW, RegionH)

    ; now some GUI stuff:
    Gui +AlwaysOnTop +ToolWindow +Resize 

    ; Now we can show it:
    Thumbnail_Show(hThumb) ; but it is not visible now...
    Gui Show, w%windowWidth% h%windowHeight%, Live Thumbnail ; ... until we show the GUI

    OnMessage(0x201, "WM_LBUTTONDOWN")

return hThumb
}

GuiSize:
    ;if ErrorLevel = 1  ; The window has been minimized.  No action needed.
    ;  return

    Thumbnail_Destroy(thumbID)
    ThumbWidth := A_GuiWidth
    ThumbHeight := A_GuiHeight
    thumbID := mainCode(targetName,ThumbWidth,ThumbHeight,start_x,start_y,Rwidth,Rheight)
return

;----------------------------------------------------------------------

GuiClose: ; in case the GUI is closed:
    Thumbnail_Hide(thumbID)
    Thumbnail_Destroy(thumbID) ; free the resources
    guiShown := false
    ; Reload
    opacity := 255
    opacityPercent := 100
    Goto, restart
return

WM_LBUTTONDOWN(wParam, lParam)
{
    mX := lParam & 0xFFFF
    mY := lParam >> 16
    SendClickThrough(mX,mY)
}

SendClickThrough(mX,mY)
{
    global 

    convertedX := Round((mX / ThumbWidth)*Rwidth + start_x)
    convertedY := Round((mY / ThumbHeight)*Rheight + start_y)
    ;msgBox, x%convertedX% y%convertedY%, %targetName%
    ControlClick, x%convertedX% y%convertedY%, %targetName%,,,, NA
    ;  sleep, 250
    ;  ControlClick, x%convertedX% y%convertedY%, %targetName%,,,, NA u
}

; Fuck math
opacityUp() {
    if (guiShown){
        if (opacityPercent <= 100) {
            GetKeyState, state, Shift
            if (state = "D") {
                if (opacityPercent + 5 >= 99) {
                    opacityPercent := 100
                } else {
                    opacityPercent := opacityPercent + 5
                }
            } else {
                if (opacityPercent + 1 >= 99) {
                    opacityPercent := 100
                } else {
                    opacityPercent := opacityPercent + 1
                }
            }
            opacity := (opacityPercent / 100) * 255
            ToolTip Opacity: %opacityPercent%`%
            WinSet, Transparent, %opacity%, ahk_class AutoHotkeyGUI
            settimer, cleartt, -1000
        } else {
            ToolTip Opacity: %opacityPercent%`%
            settimer, cleartt, -1000
        }
    }
}
Return

opacityDown() {
    if (guiShown){
        if (opacityPercent >= 1) {
            GetKeyState, state, Shift
            if (state = "D") {
                if (opacityPercent - 5 <= 0) {
                    opacityPercent := 1
                } else {
                    opacityPercent := opacityPercent - 5
                }
            } else {
                if (opacityPercent - 1 <= 0) {
                    opacityPercent := 1
                } else {
                    opacityPercent := opacityPercent - 1
                }
            }
            opacity := (opacityPercent / 100) * 255
            ToolTip Opacity: %opacityPercent%`%
            WinSet, Transparent, %opacity%, ahk_class AutoHotkeyGUI
            settimer, cleartt, -1000
        } else {
            ToolTip Opacity: %opacityPercent%`%
            settimer, cleartt, -1000
        }
    }
}
Return

LetUserSelectRect(ByRef X1, ByRef Y1, ByRef X2, ByRef Y2)
{
    static r := 3
    ; Create the "selection rectangle" GUIs (one for each edge).
    Loop 4 {
        Gui, %A_Index%: -Caption +ToolWindow +AlwaysOnTop
        Gui, %A_Index%: Color, Red
    }
    ; Disable LButton.
    Hotkey, *LButton, lusr_return, On
    ; Wait for user to press LButton.
    KeyWait, LButton, D
    ; Get initial coordinates.
    MouseGetPos, xorigin, yorigin
    ; Set timer for updating the selection rectangle.
    SetTimer, lusr_update, 10
    ; Wait for user to release LButton.
    KeyWait, LButton
    ; Re-enable LButton.
    Hotkey, *LButton, Off
    ; Disable timer.
    SetTimer, lusr_update, Off
    ; Destroy "selection rectangle" GUIs.
    Loop 4
        Gui, %A_Index%: Destroy
return

lusr_update:
    MouseGetPos, x, y
    if (x = xlast && y = ylast)
        ; Mouse hasn't moved so there's nothing to do.
return
if (x < xorigin)
    x1 := x, x2 := xorigin
else x2 := x, x1 := xorigin
    if (y < yorigin)
    y1 := y, y2 := yorigin
else y2 := y, y1 := yorigin
    ; Update the "selection rectangle".
Gui, 1:Show, % "NA X" x1 " Y" y1 " W" x2-x1 " H" r
Gui, 2:Show, % "NA X" x1 " Y" y2-r " W" x2-x1 " H" r
Gui, 3:Show, % "NA X" x1 " Y" y1 " W" r " H" y2-y1
Gui, 4:Show, % "NA X" x2-r " Y" y1 " W" r " H" y2-y1
lusr_return:
return
}

cleartt:
    tooltip
return

MouseIsOver(vWinTitle:="", vWinText:="", vExcludeTitle:="", vExcludeText:="")
{
    MouseGetPos,,, hWnd
return WinExist(vWinTitle (vWinTitle=""?"":" ") "ahk_id " hWnd, vWinText, vExcludeTitle, vExcludeText)
}

restart:
    Gui, Destroy
    Thumbnail_Destroy(thumbID)
    guiShown := false
return