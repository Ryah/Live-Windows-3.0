;													┏━━━━━━━━━━━━━━━━━━┓
;													┃ LIVE WINDOWS 3.0 ┃
;╔══════════════════════════════════════════════════╧══════════════════╧══════════════════════════════════════════════════╗
;║					Script to monitor a window or section of a window (such as a progress bar, or video) 				  ║
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
; #include Thumbnails.ahk
; #Include windrag.ahk
CoordMode, Mouse ; Required
CoordMode,ToolTip,Screen
; Initialize variables
global guiShown := false
global opacity := 255
global opacityPercent := 100

; Making it not portable because someone told me to

; If the script is not elevated, relaunch as administrator and kill current instance:

full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try ; leads to having the script re-launching itself as administrator
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}
if !FileExist("%A_AppData%\LiveWindows\Bitch.ini") {
    FileCreateDir, %A_AppData%\LiveWindows
    IniWrite, bitch, %A_AppData%\LiveWindows\Bitch.ini, Bitch, Bitch
    if (ErrorLevel = 1) {
        MsgBox, The random ini file to prove a point wasn't able to be made. Program exiting.
        ExitApp
    }
}

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

/**************************************************************************************************************
title: Thumbnail functions
wrapped by maul.esel

Credits:
- skrommel for example how to show a thumbnail (http://www.autohotkey.com/forum/topic34318.html)
- RaptorOne & IsNull for correcting some mistakes in the code

NOTE:
*This requires Windows Vista or Windows7* (tested on Windows 7)
Quick-Tutorial:
To add a thumbnail to a gui, you must know the following:
- the hwnd / id of your gui
- the hwnd / id of the window to show
- the coordinates where to show the thumbnail
- the coordinates of the area to be shown
1. Create a thumbnail with Thumbnail_Create()
2. Set its regions with Thumbnail_SetRegion()
a. optionally query for the source windows width and height before with <Thumbnail_GetSourceSize()>
3. optionally set the opacity with <Thumbnail_SetOpacity()>
4. show the thumbnail with <Thumbnail_Show()>
***************************************************************************************************************
*/

/**************************************************************************************************************
Function: Thumbnail_Create()
creates a thumbnail relationship between two windows

params:
handle hDestination - the window that will show the thumbnail
handle hSource - the window whose thumbnail will be shown
returns:
handle hThumb - thumbnail id on success, false on failure

Remarks:
To get the Hwnds, you could use WinExist()
***************************************************************************************************************
*/
Thumbnail_Create(hDestination, hSource) {

    VarSetCapacity(thumbnail, 4, 0)
    if DllCall("dwmapi.dll\DwmRegisterThumbnail", "UInt", hDestination, "UInt", hSource, "UInt", &thumbnail)
        return false
return NumGet(thumbnail)
}

/**************************************************************************************************************
Function: Thumbnail_SetRegion()
defines dimensions of a previously created thumbnail

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
int xDest - the x-coordinate of the rendered thumbnail inside the destination window
int yDest - the y-coordinate of the rendered thumbnail inside the destination window
int wDest - the width of the rendered thumbnail inside the destination window
int hDest - the height of the rendered thumbnail inside the destination window
int xSource - the x-coordinate of the area that will be shown inside the thumbnail
int ySource - the y-coordinate of the area that will be shown inside the thumbnail
int wSource - the width of the area that will be shown inside the thumbnail
int hSource - the height of the area that will be shown inside the thumbnail
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_SetRegion(hThumb, xDest, yDest, wDest, hDest, xSource, ySource, wSource, hSource) {
    dwFlags := 0x00000001 | 0x00000002

    VarSetCapacity(dskThumbProps, 45, 0)

    NumPut(dwFlags, dskThumbProps, 0, "UInt")
    NumPut(xDest, dskThumbProps, 4, "Int")
    NumPut(yDest, dskThumbProps, 8, "Int")
    NumPut(wDest+xDest, dskThumbProps, 12, "Int")
    NumPut(hDest+yDest, dskThumbProps, 16, "Int")

    NumPut(xSource, dskThumbProps, 20, "Int")
    NumPut(ySource, dskThumbProps, 24, "Int")
    NumPut(wSource+xSource, dskThumbProps, 28, "Int")
    NumPut(hSource+ySource, dskThumbProps, 32, "Int")

return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", "UInt", hThumb, "UInt", &dskThumbProps) ? false : true
}

/**************************************************************************************************************
Function: Thumbnail_Show()
shows a previously created and sized thumbnail

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_Show(hThumb) {
    static dwFlags := 0x00000008, fVisible := 1

    VarSetCapacity(dskThumbProps, 45, 0)
    NumPut(dwFlags, dskThumbProps, 0, "UInt")
    NumPut(fVisible, dskThumbProps, 37, "Int")

return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", "UInt", hThumb, "UInt", &dskThumbProps) ? false : true
}

/**************************************************************************************************************
Function: Thumbnail_Hide()
hides a thumbnail. It can be shown again without recreating

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_Hide(hThumb) {
    static dwFlags := 0x00000008, fVisible := 0

    VarSetCapacity(dskThumbProps, 45, 0)
    NumPut(dwFlags, dskThumbProps, 0, "Uint")
    NumPut(fVisible, dskThumbProps, 37, "Int")
return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", "UInt", hThumb, "UInt", &dskThumbProps) ? false : true
}

/**************************************************************************************************************
Function: Thumbnail_Destroy()
destroys a thumbnail relationship

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_Destroy(hThumb) {
return DllCall("dwmapi.dll\DwmUnregisterThumbnail", "UInt", hThumb) ? false : true
}

/**************************************************************************************************************
Function: Thumbnail_GetSourceSize()
gets the width and height of the source window - can be used with <Thumbnail_SetRegion()>

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
ByRef int width - receives the width of the window
ByRef int height - receives the height of the window
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_GetSourceSize(hThumb, ByRef width, ByRef height) {
    VarSetCapacity(Size, 8, 0)
    if DllCall("dwmapi.dll\DwmQueryThumbnailSourceSize", "Uint", hThumb, "Uint", &Size)
        return false
    width := NumGet(&Size + 0, 0, "int")
    height := NumGet(&Size + 0, 4, "int")
return true
}

/**************************************************************************************************************
Function: Thumbnail_SetOpacity()
sets the current opacity level

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
int opacity - the opacity level from 0 to 255 (will wrap to the other end if invalid)
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_SetOpacity(hThumb, opacity) {
    static dwFlags := 0x00000004

    VarSetCapacity(dskThumbProps, 45, 0)
    NumPut(dwFlags, dskThumbProps, 0, "UInt")
    NumPut(opacity, dskThumbProps, 36, "UChar")
return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", "Uint", hThumb, "UInt", &dskThumbProps) ? false : true
}

/**************************************************************************************************************
section: example
This example sctript shows a thumbnail of your desktop in a GUI
(start code)
; initializing the script:
#SingleInstance force
#NoEnv
#KeyHistory 0
SetWorkingDir %A_ScriptDir%
#include Thumbnail.ahk

; get the handles:
Gui +LastFound
hDestination := WinExist() ; ... to our GUI...
hSource := WinExist("ahk_class Progman") ; ... and to the desktop

; creating the thumbnail:
hThumb := Thumbnail_Create(hDestination, hSource) ; you must get the return value here!

; getting the source window dimensions:
Thumbnail_GetSourceSize(hThumb, width, height)

; then setting its region:
Thumbnail_SetRegion(hThumb, 25, 25 ; x and y in the GUI
, 400, 350 ; display dimensions
, 0, 0 ; source area coordinates
, width, height) ; the values from Thumbnail_GetSourceSize()

; now some GUI stuff:
Gui +AlwaysOnTop +ToolWindow
Gui Add, Button, gHideShow x0 y0, Hide / Show

; Now we can show it:
Thumbnail_Show(hThumb) ; but it is not visible now...
Gui Show, w450 h400 ; ... until we show the GUI

; even now we can set the transparency:
Thumbnail_SetOpacity(hThumb, 200)

return

GuiClose: ; in case the GUI is closed:
Thumbnail_Destroy(hThumb) ; free the resources
ExitApp

HideShow: ; in case the button is clicked:
if hidden
Thumbnail_Show(hThumb)
else
Thumbnail_Hide(hThumb)

hidden := !hidden
return
(end)
***************************************************************************************************************
*/

/** 
;  	File: WinDrag.ahk
; 	Author: 	nickstokes
; 	Forum:		https://www.autohotkey.com/boards/viewtopic.php?t=57703
; 				https://www.autohotkey.com/boards/viewtopic.php?f=5&t=48520&p=216669

Example usage, add the following three lines to your AHK script:

#Include windrag.ahk
^!LButton::WindowMouseDragMove()
^!RButton::WindowMouseDragResize()

* While holding down ctrl+alt, left click anywhere on a window and drag to move.
* While holding down ctrl+alt, right click any outer quadrant of a window and
  drag to resize, or near the center of a window to move. The system icons will
  show where you're going.

*/

;    +---------------------+
;    |   Set/Reset cursor  |
;    +---------------------+
; from: https://autohotkey.com/board/topic/32608-changing-the-system-cursor/

; Parameter 1 is file path or cursor name, e.g. IDC_SIZEALL. If this is omitted it will hide the cursor.
;   IDC_ARROW     IDC_UPARROW      IDC_SIZENESW      IDC_NO
;   IDC_IBEAM     IDC_SIZE         IDC_SIZEWE        IDC_HAND
;   IDC_WAIT      IDC_ICON         IDC_SIZENS        IDC_APPSTARTING
;   IDC_CROSS     IDC_SIZENWSE     IDC_SIZEALL       IDC_HELP
;
; Parameters 2 and 3 are the desired width and height of cursor. Omit these to use the default size, e.g. loading a 48x48 cursor will display as 48x48.
;
SetSystemCursor( Cursor = "", cx = 0, cy = 0 )
{
    BlankCursor := 0, SystemCursor := 0, FileCursor := 0 ; init

    SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
    ,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
    ,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
    ,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP

    If Cursor = ; empty, so create blank cursor 
    {
        VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )
        BlankCursor = 1 ; flag for later
    }
    Else If SubStr( Cursor,1,4 ) = "IDC_" ; load system cursor
    {
        Loop, Parse, SystemCursors, `,
        {
            CursorName := SubStr( A_Loopfield, 6, 15 ) ; get the cursor name, no trailing space with substr
            CursorID := SubStr( A_Loopfield, 1, 5 ) ; get the cursor id
            SystemCursor = 1
            If ( CursorName = Cursor )
            {
                CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )	
                Break					
            }
        }	
        If CursorHandle = ; invalid cursor name given
        {
            Msgbox,, SetCursor, Error: Invalid cursor name
            CursorHandle = Error
        }
    }	
    Else If FileExist( Cursor )
    {
        SplitPath, Cursor,,, Ext ; auto-detect type
        If Ext = ico 
            uType := 0x1	
        Else If Ext in cur,ani
            uType := 0x2		
        Else ; invalid file ext
        {
            Msgbox,, SetCursor, Error: Invalid file type
            CursorHandle = Error
        }		
        FileCursor = 1
    }
    Else
    {	
        Msgbox,, SetCursor, Error: Invalid file path or cursor name
        CursorHandle = Error ; raise for later
    }
    If CursorHandle != Error 
    {
        Loop, Parse, SystemCursors, `,
        {
            If BlankCursor = 1 
            {
                Type = BlankCursor
                %Type%%A_Index% := DllCall( "CreateCursor"
                , Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
                CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
                DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
            }			
            Else If SystemCursor = 1
            {
                Type = SystemCursor
                CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )	
                %Type%%A_Index% := DllCall( "CopyImage"
                , Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0 )		
                CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
                DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
            }
            Else If FileCursor = 1
            {
                Type = FileCursor
                %Type%%A_Index% := DllCall( "LoadImageA"
                , UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10 ) 
                DllCall( "SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5 ) )			
            } 
        }
    }	
}

RestoreCursors()
{
    SPI_SETCURSORS := 0x57
    DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
}

;          +-----------------------------------------+
;          |          SetWindowPosNoFlicker          |
;          +-----------------------------------------+
SetWindowPosNoFlicker(handle, wx, wy, ww, wh)
{

    ;WinMove ahk_id %handle%,, wx, wy, ww, wh

    DllCall("user32\SetWindowPos"
    , "Ptr", handle
    , "Ptr", 0
    , "Int", wx
    , "Int", wy
    , "Int", ww
    , "Int", wh
    , "UInt", 0)
    ; 0x4000	= SWP_ASYNCWINDOWPOS
    ; 0x2000	= SWP_DEFERERASE
    ; 0x400		= SWP_NOSENDCHANGING
    ; 0x200		= SWP_NOOWNERZORDER
    ; 0x100		= SWP_NOCOPYBITS
    ; 0x10		= SWP_NOACTIVATE
    ; 0x8			= SWP_NOREDRAW
    ; 0x4			= SWP_NOZORDER

    ;DllCall("user32\RedrawWindow"
    ; , "Ptr", handle
    ; , "Ptr", 0
    ; , "Ptr", 0
    ;, "UInt", 0x0100)  ;RDW_INVALIDATE | RDW_UPDATENOW

  /*
   RDW_INVALIDATE          0x0001
   RDW_INTERNALPAINT       0x0002
   RDW_ERASE               0x0004
  
   RDW_VALIDATE            0x0008
   RDW_NOINTERNALPAINT     0x0010
   RDW_NOERASE             0x0020
  
   RDW_NOCHILDREN          0x0040
   RDW_ALLCHILDREN         0x0080
  
   RDW_UPDATENOW           0x0100
   RDW_ERASENOW            0x0200
  
   RDW_FRAME               0x0400
   RDW_NOFRAME             0x0800
    */

}

;          +--------------------------------------------+
;          |             WindowMouseDragMove            |
;          +--------------------------------------------+

/**
@brief Drag windows around following mouse while pressing left click

For example, assign to ctrl+alt while mouse drag

@code
^!LButton::WindowMouseDragMove()
@endcode

@todo `WindowMouseDragMove` Left click is hardcoded. Customize to any given key.

@remark based on: https://autohotkey.com/board/topic/25106-altlbutton-window-dragging/ 
Fixed a few things here and there
*/
WindowMouseDragMove()
{
    MouseButton := DetermineMouseButton()

    CoordMode, Mouse, Screen
    MouseGetPos, x0, y0, window_id
    WinGet, window_minmax, MinMax, ahk_id %window_id%
    WinGetPos, wx, wy, ww, wh, ahk_id %window_id%

    ; Return if the window is maximized or minimized
    if window_minmax <> 0 
    {
        return
    }
    init := 1
    SetWinDelay, 0
    while(GetKeyState(MouseButton, "P"))
    {
        MouseGetPos, x, y

        if( x == x0 && y == y0 ) {
            continue
        }

        if( init == 1 ) {
            SetSystemCursor( "IDC_SIZEALL" )
            init := 0
        }

        wx += x - x0
        wy += y - y0
        x0 := x
        y0 := y

        WinMove ahk_id %window_id%,, wx, wy
    }
    SetWinDelay, -1
    RestoreCursors()
return
}

;          +--------------------------------------------+
;          |             WindowMouseDragResize          |
;          +--------------------------------------------+

/**
@brief Resize windows from anywhere within the window, without having to aim the edges or corners 
 following mouse while right-click press

For example:

@code
^!RButton::WindowMouseDragResize()
@endcode

Initial mouse move determines which corner to drag for resize.
Use in combination with WindowMouseDragMove for best effect.

@todo `WindowMouseDragResize` Right-click is hardcoded. Customize to any given key.
@todo `WindowMouseDragResize` Inverted option as an argument for corner-selection logic.

@remark based on: https://autohotkey.com/board/topic/25106-altlbutton-window-dragging/ 
Fixed a few things here and there
*/

WindowMouseDragResize0()
{
    MouseButton := DetermineMouseButton()
    CoordMode, Mouse, Screen
    MouseGetPos, mx0, my0, window_id
    WinGetPos, wx, wy, ww, wh, ahk_id %window_id%
    WinGet, window_minmax, MinMax, ahk_id %window_id%

    ; menu-resize based solution - 
    ; https://autohotkey.com/boards/viewtopic.php?f=5&t=48520&p=216844#p216844
    ; WinMenuSelectItem, ahk_id %window_id%,,0&, Size
    ; return

    SetWinDelay, 0

    ; Resore if maximized
    if (window_minmax > 0)
    {
        WinRestore ahk_id %window_id%

        ; Restore the window if maximized or minimized and set the position as seen
        ; badeffect ; WinMove ahk_id %window_id%, , wx, wy, ww, wh
    }

    ; window-menu ; mx := mx0
    ; window-menu ; my := my0
    ; window-menu ; while(mx == mx0 || my == my0) {
    ; window-menu ;    Sleep 10
    ; window-menu ;    MouseGetPos, mx, my
    ; window-menu ; }
    ; window-menu ; 
    ; window-menu ; ; 0x0112 WM_SYSCOMMAND
    ; window-menu ; ; 0xF000 SC_SIZE
    ; window-menu ; PostMessage,  0x0112, 0xF000, 0, , ahk_id %window_id%
    ; window-menu ; if( ErrorLevel != 0 ) {
    ; window-menu ;    return
    ; window-menu ; }

    firstDeltaX := "init"
    firstDeltaY := "init"
    cursorInit := 1
    while(GetKeyState(MouseButton,"P")) { 
        ; resize the window based on cursor position
        MouseGetPos, mx, my
        if(mx == mx0 && my == my0) {
            continue
        }

        if( firstDeltaX == "init" && mx-mx0 <> 0 ) {
            firstDeltaX := mx-mx0
        }
        if( firstDeltaY == "init" && my-my0 <> 0 ) {
            firstDeltaY := my-my0
        }
        if( cursorInit == 1 && firstDeltaX != "init" && firstDeltaY != "init") {
            SetSystemCursor( firstDeltaX*firstDeltaY>0 ? "IDC_SIZENWSE" : "IDC_SIZENESW" )
            cursorInit := 0
        }

        deltaX := mx - mx0
        deltaY := my - my0

        if(firstDeltaX<0) {
            ww += deltaX
        }
        else {
            wx += deltaX
            ww -= deltaX
        }
        if(firstDeltaY<0) {
            wh += deltaY
        }
        else {
            wy += deltaY
            wh -= deltaY
        }

        mx0 := mx
        my0 := my

        WinMove ahk_id %window_id%,, wx, wy, ww, wh
    }
    RestoreCursors()
return
}

;          +--------------------------------------------+
;          |             WindowMouseDragResize          |
;          +--------------------------------------------+

/**
@brief Resize windows from anywhere within the window, without having to aim the edges or corners 
 following mouse while right-click press

For example:

@code
^!RButton::WindowMouseDragResize()
@endcode

Initial mouse move determines which corner to drag for resize.
Use in combination with WindowMouseDragMove for best effect.

@todo `WindowMouseDragResize` Right-click is hardcoded. Customize to any given key.
@todo `WindowMouseDragResize` Inverted option as an argument for corner-selection logic.

@remark based on: https://autohotkey.com/board/topic/25106-altlbutton-window-dragging/ 
Fixed a few things here and there
*/

WindowMouseDragResize()
{
    MouseButton := DetermineMouseButton()
    ; determine corner drag if mouse is this many percent points away from the center
    cornerTolerance := 20
    CoordMode, Mouse, Screen
    MouseGetPos, mx0, my0, window_id
    WinGetPos, wx, wy, ww, wh, ahk_id %window_id%
    WinGet, window_minmax, MinMax, ahk_id %window_id%

    ; menu-resize based solution - 
    ; https://autohotkey.com/boards/viewtopic.php?f=5&t=48520&p=216844#p216844
    ; WinMenuSelectItem, ahk_id %window_id%,,0&, Size
    ; return

    SetWinDelay, 0

    ; Restore if maximized [??]
    if (window_minmax > 0)
    {
        WinRestore ahk_id %window_id%
    }

    ; establish drag corner depending on which quadrant the mouse is
    wxCenter := wx+(ww/2)
    wyCenter := wy+(wh/2)
    xNoCornerZoneHalfSize := ww*(cornerTolerance/200.) ; 100 is for percent, 2 is for half
    yNoCornerZoneHalfSize := wh*(cornerTolerance/200.)
    wxLeftCorner := wxCenter - xNoCornerZoneHalfSize
    wxRightCorner := wxCenter + xNoCornerZoneHalfSize
    wyTopCorner := wyCenter - yNoCornerZoneHalfSize
    wyBottomCorner := wyCenter + yNoCornerZoneHalfSize

    xCorner := mx0 < wxLeftCorner ? -1 : mx0>wxRightCorner ? 1 : 0
    yCorner := my0 < wyTopCorner ? -1 : my0>wyBottomCorner ? 1 : 0
    ; OutputDebug % "slyutil: win " wx " " wy " " ww " " wh
    ; OutputDebug % "slyutil: mouse " mx0 " " my0
    ; OutputDebug, slyutil: wxCenter %wxCenter% wyCenter %wyCenter%  xNoCornerZoneHalfSize %xNoCornerZoneHalfSize% yNoCornerZoneHalfSize %yNoCornerZoneHalfSize%
    ; OutputDebug, slyutil: xCorner %xCorner% yCorner %yCorner%

    if( xCorner*yCorner>0 )
        SetSystemCursor("IDC_SIZENWSE")
    else if (xCorner*yCorner<0)
        SetSystemCursor("IDC_SIZENESW")
    else
    {
        if(xCorner==0 && yCorner == 0)
            SetSystemCursor("IDC_SIZEALL")
        else
            SetSystemCursor( xCorner==0 ? "IDC_SIZENS" : "IDC_SIZEWE")
    }

    ;SendMessage 0x0B, 1, , ,  ahk_id %window_id%
    ;SendMessage, 0x231, 0, 0,, ahk_id %window_id%	; WM_ENTERSIZEMOVE

    while(GetKeyState(MouseButton,"P")) { 
        MouseGetPos, mx, my
        if(mx == mx0 && my == my0) {
            continue
        }

        deltaX := mx - mx0
        deltaY := my - my0

        if(xCorner == 0 && yCorner == 0) {
            ; move
            wx += mx - mx0
            wy += my - my0
        }
        else if(xCorner>0)
            ww += deltaX
        else if(xCorner<0)
        {
            wx += deltaX
            ww -= deltaX
        }
        if(yCorner>0)
            wh += deltaY
        else if(yCorner<0)
        {
            wy += deltaY
            wh -= deltaY
        }

        mx0 := mx
        my0 := my

        SetWindowPosNoFlicker(window_id, wx, wy, ww, wh)
    }
    ;SendMessage 0x0B, 0, , ,  ahk_id %window_id%
    ;SendMessage, 0x232, 0, 0,, ahk_id %window_id%	; WM_EXITSIZEMOVE
    RestoreCursors()
return
}

DetermineMouseButton() {
    ; Author: 	Cyberklabauter
    ; Forum:   https://www.autohotkey.com/boards/viewtopic.php?f=6&t=57703&p=378638#p378638
    If (InStr(a_thisHotkey, "LButton"))
        return "LButton"	
    If (InStr(a_thisHotkey, "MButton"))
        return "MButton"	
    If (InStr(a_thisHotkey, "RButton"))
        return "RButton"	
    If (InStr(a_thisHotkey, "XButton1"))
        return "XButton1"	
    If (InStr(a_thisHotkey, "XButton2"))
        return "XButton2"	
}