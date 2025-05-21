/*
    joystick.ahk

    This module provides functions for joystick detection and button/axis state checking in AutoHotkey v2.

    Functions:

    - DetectJoyNumber()
    - btn(buttonName)
    - HandleMouseClick(button, action)
    - HandleMouseScrollClick(button, action)

    Globals required:
        - buttonMap: Map of button names to button numbers
        - joyNumber: The currently active joystick number
        - deadzone: Deadzone threshold for axis movement
*/

#SingleInstance
#Requires AutoHotkey v2.0

; Define configurable constants
DOUBLE_CLICK_THRESHOLD := 400   ; Configurable double-click detection threshold (in milliseconds)
SHORT_PRESS_DURATION   := 300   ; Duration in milliseconds for a short press

clickState     := Map()         ; Stores the state for each mouse button

; =============== JOYSTICK DETECTION FUNCTION ===============
/*
    DetectJoyNumber()
        Detects the first joystick with a button pressed and returns its index number.
*/
DetectJoyNumber() {
    ToolTip("Please hold any button on your joystick to select it.")
    
    global joyName

    detected := 0
    ; Loop until a joystick with the Start button pressed is detected
    while (!detected) {
        for index in Range(1,16) {
            ; Get the physical state of Joy12 for the current joystick index
            for button in Range(1,32){
                state := GetKeyState(index . "Joy" . button, "P")
                if (state = 1) {

                    joyName := GetKeyState("JoyName")
                    if (joyName = "")
                        joyName := "Unknown"
                    
                    Tooltip "Joystick Name: " . joyName

                    detected := index
                    break 
                }
            }
        }
        Sleep 10
    }
    
    RemoveToolTip()
    ToolTip("Joystick " detected " detected. " . joyName . " is now active.")
    
    SetTimer(RemoveToolTip, -3000)
    return detected
}


; =============== JOYSTICK CHECK FUNCTION ===============

/*
    btn(buttonName)
        Checks the state of a specified button or D-Pad direction on the active joystick.
        Supports D-Pad directions ("up", "down", "left", "right") and mapped button names.
        Returns:
            - For D-Pad: -1 (negative direction), 0 (neutral), or 1 (positive direction)
            - For buttons: true if pressed, false otherwise
        Exits the application if the controller is disconnected or if an invalid button name is provided.
*/
btn(buttonName) {
    global buttonMap, joyNumber, deadzone
    
    buttonName := StrLower(buttonName)
    
    ; D-Pad
    if (RegExMatch(buttonName, "i)^(up|down|left|right)$")){ ;oooh regex. What a showoff!

        mappingVal := ""
        if (buttonName = "up")
            mappingVal := "Y-"
        else if (buttonName = "down")
            mappingVal := "Y+"
        else if (buttonName = "left")
            mappingVal := "X-"
        else if (buttonName = "right")
            mappingVal := "X+"
        
        axis := SubStr(mappingVal, 1, 1)       ; "X" or "Y"
        direction := SubStr(mappingVal, 2)     ; "-" or "+"

        JoyAxis := joyNumber . "Joy" . axis
        axisVal := GetKeyState(JoyAxis)

        if (axisVal = "") {
            MsgBox("Controller disconnected. Exiting...")
            Exit
        }

        ;-1 for negative, 0 for neutral, 1 for positive
        return (direction = "-") ? (axisVal < 50 - deadzone ? -1 : 0)
                                 : (axisVal > 50 + deadzone ?  1 : 0)
    }
    
    ; Button check
    if (!buttonMap.Has(buttonName)) {
        MsgBox "Invalid button name: " . buttonName
        return false
    }

    val := buttonMap[buttonName]
    if (IsNumber(val)) {
        JoyBtn := joyNumber . "Joy" . val
        state := GetKeyState(JoyBtn, "P")
        if (state = "") {
            MsgBox("Controller disconnected. Exiting...")
            Exit
        }
        return (state = 1)
    } else {
        MsgBox "Mapping for " . buttonName . " is invalid!"
        return false
    }
}

/*
    HandleMouseClick(button, action)
        Handles mouse click events for a specified button.
        Supports single, double-click and drag actions.

        Parameters:
            - button: The mouse button to handle
            - action: The action to perform (1 for press, 0 for release).
*/
HandleMouseClick(button, action) {
    
    ; Initialize variable for the button if not already set
    if !clickState.Has(button) 
        clickState[button] := Map("clicking", false, 
                                  "startTime", 0, 
                                  "count", 0, 
                                  "lastTime", 0)

    state := clickState[button]  ; Retrieve the state of the specified button

    if (action) {  ; When button is pressed
        if !state["clicking"] {
            state["startTime"] := A_TickCount  ; Store the timestamp of the press
            state["clicking"] := true
            Click "Down " button  ; Press the mouse button
        }
    } else {  ; When button is released
        if state["clicking"] {
            clickDuration := A_TickCount - state["startTime"]  ; Compute press duration

            if (clickDuration < SHORT_PRESS_DURATION) {  ; Short press (potential single or double click)
                state["count"] += 1
                if (state["count"] = 2 and A_TickCount - state["lastTime"] < DOUBLE_CLICK_THRESHOLD) {
                    Click button  ; Perform a double-click
                    state["count"] := 0
                } else {
                    Click "Up " button  ; Release the mouse button
                    state["lastTime"] := A_TickCount
                }
            } else {
                Click "Up " button  ; Release button after a drag action
            }
        }
        state["clicking"] := false
    }
}

/*
    HandleMouseScrollClick(button, action)
        Handles mouse scroll and middle mouse button events for a specified button.
        Supports middle clicking and scrolling in different directions based on D-PAd button presses.

        Parameters:
            - button: The mouse button to handle
            - action: The action to perform (1 for press, 0 for release).
*/
HandleMouseScrollClick(button, action) {
    
    ; Initialize variable for the button if not already set
    if !clickState.Has(button) 
        clickState[button] := Map("clicking", false, 
                                  "startTime", 0, 
                                  "count", 0, 
                                  "lastTime", 0, 
                                  "scrollMode", false)

    state := clickState[button]  ; Retrieve the state of the specified button

    if (action) {  ; When button is pressed
        if !state["clicking"] {
            state["startTime"] := A_TickCount  ; Store press timestamp
            state["clicking"] := true
            state["scrollMode"] := false
        }

        ; Activate scroll mode if held longer than 300ms
        if (A_TickCount - state["startTime"] > SHORT_PRESS_DURATION) 
            state["scrollMode"] := true

        ; Perform scrolling only in scroll mode
        if (state["scrollMode"]) {
            if (btn("left")) 
                SendInput("{WheelLeft " . scrollSpeed . "}")            
            else if (btn("right"))
                SendInput("{WheelRight " . scrollSpeed . "}")

            if (btn("up"))
                SendInput("{WheelUp " . scrollSpeed . "}")
            else if (btn("down"))
                SendInput("{WheelDown " . scrollSpeed . "}")
       }

    } else {  ; When button is released
        if state["clicking"] {
            clickDuration := A_TickCount - state["startTime"]

            if (clickDuration < SHORT_PRESS_DURATION and !state["scrollMode"])   ; Quick press → Middle Click
                Click "Middle"            
        }
        state["clicking"] := false
        state["scrollMode"] := false  ; Reset scroll state
    }
}