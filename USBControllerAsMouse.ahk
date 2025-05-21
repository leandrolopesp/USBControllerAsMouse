/*
    USB Controller as Mouse Script
    ==============================

    Author: Leandro Lopes Pereira
    Date: 2025-05-20

    Description:
        This AutoHotkey v2 script enables the use of a USB game controller (such as the 8BitDo M30)
        as a mouse on Windows. It supports DPI-aware cursor movement, smooth scrolling, and screen-centering
        features. Button mappings can be customized via an interactive setup or a config.ini file.

    Features:
        - Cursor movement using D-Pad (X/Y axes)
        - Adjustable speed: precision (RB), 2x (C), 3x (Z), 6x (C+Z)
        - Center cursor on current or other monitor (Y, Start)
        - Smooth horizontal/vertical scrolling (LB + D-Pad)
        - Left/Right mouse click (A/B)
        - Show script status (X)
        - Exit script (Home)
        - Multi-monitor support
        - DPI scaling awareness

    Usage:
        1. Run the script with the controller connected via USB.
        2. If config.ini exists, button mappings are loaded automatically.
        3. If not, an interactive mapping process will start.
        4. Use the mapped buttons to control the mouse and access features.

    Button Mapping (Default for 8BitDo M30):
        - D-Pad: Move cursor
        - A: Left click
        - B: Right click
        - X: Show status
        - Y: Center cursor on current monitor (with D-Pad for quadrant)
        - C: Speed boost (2x)
        - Z: Turbo speed (3x)
        - RB: Precision mode (20% speed)
        - LB: Enable scrolling mode (with D-Pad)
        - Start: Center cursor on other monitor
        - Home: Exit script
        - Select: Restart script

    Configuration:
        - Button mappings are stored in config.ini under the [Mapping] section.
        - To remap buttons, delete config.ini and restart the script.

    Dependencies:
        - Requires AutoHotkey v2
        - Heavy use of Windows API functions
        - Includes modules: joystick.ahk, mapping.ahk, movement.ahk, utils.ahk

    Notes:
        - Only works with USB-connected controllers.
        - Ensure the controller is recognized by Windows before running the script.
        - Drink water
        - Take breaks
        - Don't forget to stretch
        - Don't forget to eat
        - Don't forget to sleep
        - Don't forget to breathe
        - Give love

    Hotkeys:
        - Esc: Exit script immediately
*/



; ============= MY BUTTON MAPPING CONFIGURATION =============

;The M30:
;
;   - LB --------____________________------- RB -
;  |     Up                                      |
; |Left    Right        Start         X   Y   Z   |
;  |   Down       Turbo Select Home   A   B   C  |
;   |___________/-------------------\___________/
;
;Yes, my drawing is terrible but ＼（〇_ｏ）／
;
;Turbo button is not programmable
;
;I found convenient to use A and B for left and right click, respectively.
;The C and Z buttons are used to increase the speed of the cursor 2x and 3x respectively.
;The LB button is used along with D-Pad to scroll the screen.
;The X button is used to show the status of the script.
;The Y button is used to center the cursor on the current monitor.
;The RB button is used to decrease the speed of the cursor to 20% of the base speed for precision.
;The Start button is used to center the cursor on the other monitor.
;The Home button is used to exit the script.
;The Select button is not used.
 

#SingleInstance
#Requires AutoHotkey v2

#Include modules/joystick.ahk
#Include modules/mapping.ahk
#Include modules/movement.ahk
#Include modules/utils.ahk

SetWorkingDir(A_ScriptDir)


; ================= INITIAL SETUP ==================
CoordMode("Mouse", "Screen")

; Change these values to suit your needs
baseSpeed        := 10
boostMultiplier  := 2    ; C  Button
turboZMultiplier := 3    ; Z  Button
slowRMultiplier  := 0.2  ; Rb Button
scrollSpeed      := 1    ; 1 notch per pulse
deadzone         := 5    ; The deadzone for the joystick. This is the minimum distance from the center of the joystick

; These are not necessary to change. Don't touch them unless you know what you're doing.
; I wouldn't touch them all

; Configuration file
configFile     := "config.ini"
mappingSection := "Mapping"


;Controller Button Mapping:
mappingkeys := ["click(a)", 
                "right click(b)",
                "speed 2x(c)",
                "tooltip(x)",
                "center(y)",
                "speed 3x(z)",
                "scroll(lb)",
                "slow(rb)",
                "change monitor(start)",
                "exit(home)",
                "restart(select)"] 

joyNumber := DetectJoyNumber()
joyName   := ""
speed     := 0 

configExists := FileExist(configFile)

; loads button mapping from Config.INI file
buttonMap := Map(
    "up", "Y-",
    "down", "Y+",
    "left", "X-",
    "right", "X+"
)
if (configExists) {
    for key in mappingKeys {
        val := IniRead(configFile, mappingSection, key, "")
        if (val = "") {
            configExists := false
            break
        }
        buttonMap[key] := val
    }
}

if (!configExists) {
    ToolTip "Button mapping configuration not found or is incomplete. Initiating interactive mapping."
    Sleep(5000)
    RemoveToolTip()
    buttonMap := MapButtonsInteractive(mappingKeys, mappingSection, configFile)
}



; ================== MAIN PROGRAM ==================
; ======== gentlemen, start yout engines! ==========
; === vrroom! ===> 🚙 🚙 🚙  🚙 🚙 🚙🚙        🚗

SetTimer(MainControlLoop, 10) ; each 
return

; =============== MAIN CONTROL LOOP ===============

/*  MainControlLoop()
    -----------------
    Main control loop that handles the joystick input and mouse movement.
    It checks for button presses and performs actions accordingly.
*/


MainControlLoop(){
    global speed, baseSpeed, boostMultiplier, turboZMultiplier,slowRMultiplier
    global currentX, currentY
 
 
    ; Moves cursor (only if not scrolling)
    if !(btn("scroll(lb)")) {
        ; Existing speed calculation code
        speed := baseSpeed * GetDPIScalingFactor() ; The Dots Per Inch scaling factor
        speed *= (btn("Speed 2x(c)") ? boostMultiplier    : 1)
        speed *= (btn("Speed 3x(z)") ? turboZMultiplier   : 1)
        speed *= (btn("Slow(rb)")    ? 1/slowRMultiplier  : 1)
        
        ; DPI-Aware Movement
        deltaX := (btn("right") + btn("left")) * speed 
        deltaY := (btn("down")  + btn("up"))   * speed

        MouseGetPos(&currentX, &currentY)
        newX := currentX + deltaX
        newY := currentY + deltaY
        
        ; Multi-monitor boundaries
        VirtualLeft   := SysGet(76) ;SM_XVIRTUALSCREEN
        VirtualWidth  := SysGet(78) ;SM_CXVIRTUALSCREEN
        VirtualTop    := SysGet(77) ;SM_YVIRTUALSCREEN
        VirtualHeight := SysGet(79) ;SM_CYVIRTUALSCREEN
        
        newX := Mid(newX, VirtualLeft, VirtualLeft + VirtualWidth  - 1)
        newY := Mid(newY, VirtualTop,  VirtualTop  + VirtualHeight - 1)
        
        DllCall("SetCursorPos", "int", newX, "int", newY)
    }

    ;Click Buttons
    HandleMouseClick("Left",  btn("Click(a)"))
    HandleMouseClick("Right", btn("Right Click(b)")) 

    HandleMouseScrollClick("Middle", btn("Scroll(Lb)"))

    ; Other buttons
    if (btn("Tooltip(x)")) 
       ShowToolTipStatus()
    else if (btn("Center(y)")) {
        ToolTip ("Center")
        CenterOnCurrentMonitor()
        SetTimer(RemoveToolTip, -500)
    }
    else if (btn("Change Monitor(start)")) {
        ToolTip ("Center on other monitor")
        CenterOnOtherMonitor()
        sleep 500
        SetTimer(RemoveToolTip, -3000)
    }
    else if(btn("Exit(home)")) {
        Exit     
    }
    else if(btn("restart(select)")) {
        ToolTip ("Restarting...")
        Sleep(500)
        RemoveToolTip()
        Reload
    }
}

Exit(){
    Tooltip "Bye!"
    Sleep(5000)
    ExitApp
}

Esc::{
    Exit
}



