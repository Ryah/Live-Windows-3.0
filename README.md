
# LIVE WINDOWS 3.0

An AutoHotKey Script to monitor a window or section of a window (such as a progress bar, or video) in a resizable live preview window (thumbnail)									  

This is an update to the [Updated LiveWindows AHK script by KYF](https://autohotkey.com/board/topic/71692-an-updated-livewindows-which-can-also-show-video/), which takes advantage of Windows Vista/7 aeropeak rather than taking a sequence of screen shots. This means the thumbnail is updated in real time, so you can draw a picture around an embedded video, then float that on top of another window... without any loss in framerate.

The script relies on [Thumbnail.ahk by maul.esel](https://autohotkey.com/board/topic/65854-aero-thumbnails/). 
It also takes advantage of [WinDrag.ahk by Nickstokes](https://www.autohotkey.com/boards/viewtopic.php?t=57703).

## Keybinds

| Keys          | Effect        |
| ------------- |:-------------:| 
| WIN + SHIFT + W                                  |   CREATE THUMBNAIL OF WHOLE WINDOW
| WIN + SHIFT + LEFT MOUSE                          |  DEFINE REGION TO CREATE THUMBNAIL		
| WIN + SHIFT + TAB                                 |  CLOSE ALL ACTIVE THUMBNAILS				
| CTRL + ALT + LEFT MOUSE (ON THUMBNAIL)            |  DRAG THUMBNAIL AROUND SCREEN			
| CTRL + ALT + RIGHT MOUSE (ON THUMBNAIL)           |  RESIZE THUMBNAIL						
| CTRL + ALT + MOUSE WHEEL (ON THUMBNAIL)           |  CHANGE OPACITY BY 1%					
| CTRL + ALT + SHIFT + MOUSE WHEEL (ON THUMBNAIL)   |  CHANGE OPACITY BY 5%			
