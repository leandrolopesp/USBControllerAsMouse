/*
    movement.ahk - Advanced Monitor and Mouse Utilities

    This module provides advanced functions for interacting with multiple monitors and mouse positioning in AutoHotkey v2.0 scripts.

    Functions:

    - GetDPIScalingFactor()
    - GetMonitorDimensions(x, y)
    - CenterOnCurrentMonitor()
    - GetMonitorAtPosition(x, y)
    - SortMonitorsByPosition(monitors)
    - CenterOnOtherMonitor()
    - ShowToolTipStatus()

    Dependencies:
        - Requires AutoHotkey v2.0
        - Uses DllCall for Windows API functions
        - Assumes existence of btn() function for D-Pad input and global variable 'speed'

    Note:
        These utilities are designed for multi-monitor setups and may require additional context or integration with other modules.
*/

#SingleInstance
#Requires AutoHotkey v2.0

; =============== ADVANCED FUNCTIONS ===============


/*
Calculates the DPI scaling factor for the monitor under the current mouse position.
        Returns: Float - The ratio of work area width to monitor width.
*/
GetDPIScalingFactor() {
    MouseGetPos(&x, &y)
    dimensions := GetMonitorDimensions(x, y)
    return dimensions.workWidth / dimensions.monitorWidth
}

/*
Retrieves the monitor and work area dimensions for the monitor containing the point (x, y).
        Params:
            x (Int): X coordinate.
            y (Int): Y coordinate.
        Returns: Object - { monitorWidth, workWidth }
*/
GetMonitorDimensions(x, y) {
    ; Get a handle to the monitor that contains the point (x, y)
    ; The point is packed into a 64-bit integer using (y << 32) | (x & 0xFFFFFFFF)
    ;https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfrompoint
    hMonitor := DllCall("MonitorFromPoint", "Int64", (y << 32) | (x & 0xFFFFFFFF), "UInt", 0, "Ptr")
    
    ; Allocate a buffer to hold the MONITORINFO structure.The MONITORINFO structure size is 40 bytes.
    monitorInfo := Buffer(40, 0)
    
    ; Set the first 4 bytes of the buffer to the size of the structure.
    ; This is required by GetMonitorInfo for proper initialization.
    NumPut("Int",40, monitorInfo, 0)
    
    ; Call GetMonitorInfo to retrieve monitor information into the buffer.
    if (!DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", monitorInfo.Ptr))
        MsgBox("GetMonitorInfo failed")

    ; Retrieve the left and right boundaries of the monitor.
    monitorLeft  := NumGet(monitorInfo, 4, "Int")
    monitorRight := NumGet(monitorInfo, 12, "Int")
    
    ; Retrieve the left and right boundaries of the work area.
    workLeft  := NumGet(monitorInfo, 20, "Int")
    workRight := NumGet(monitorInfo, 28, "Int")
    
    dimensions := { monitorWidth: monitorRight - monitorLeft, workWidth: workRight - workLeft }
      
    return dimensions
}

/*
Moves the mouse cursor to a calculated position within the work area of the current monitor,
        based on D-Pad button presses.
*/
CenterOnCurrentMonitor() {
    MouseGetPos(&x, &y)
    monitorIndex := GetMonitorAtPosition(x, y)

    ; Declare variables to receive the work area boundaries.
    WorkLeft := 0, WorkTop := 0, WorkRight := 0, WorkBottom := 0
    
    ; Get the working area of the monitor (excluding taskbar, etc.)
    MonitorGetWorkArea(monitorIndex, &WorkLeft, &WorkTop, &WorkRight, &WorkBottom)

    ; Calculate the center position of the monitor's work area.
    workWidth := WorkRight - WorkLeft
    workHeight := WorkBottom - WorkTop

    ; Calculate the new position based on the work area and the D-Pad button presses.
    hFactor := btn("right") + btn("left")   ; -1, 0 or 1
    vFactor := btn("down")  + btn("up")     ; -1, 0 or 1
    newX := WorkLeft + ((hFactor + 2) / 4) * workWidth
    newY := WorkTop  + ((vFactor + 2) / 4) * workHeight

    ; Move the mouse cursor to the center of the monitor.
    DllCall("SetCursorPos", "Int", newX, "Int", newY)
}

/*
Determines which monitor contains the point (x, y).
        Params:
            x (Int): X coordinate.
            y (Int): Y coordinate.
        Returns: Int - Index of the monitor.
*/
GetMonitorAtPosition(x, y) {
    monitors := []

    count := SysGet(80)
    
    ; Loop through each monitor index.
    for i in Range(1, count) {
        ; Get the work area of each monitor.
        ; The work area is the area available for applications, excluding the taskbar.
        l := 0, t := 0, r := 0, b := 0
        MonitorGetWorkArea(i, &l, &t, &r, &b)
        mon := { left: l, top: t, right: r, bottom: b }

        monitors.Push(mon)
    }
   
    ; Sort the monitors by their left coordinate (or another desired criterion).
    ; This function should receive the array and return it sorted.
    monitors := SortMonitorsByPosition(monitors)
    
    ; Loop over the sorted monitors to find which one contains the point (x, y).
    for index, mon in monitors {
        if (mid(x, mon.left, mon.right) == x and 
            mid(y, mon.top,  mon.bottom) == y)
            return index
    }

    return 1
}

/*
Sorts an array of monitor objects by their left coordinate.
        Params:
            monitors (Array): Array of monitor objects.
        Returns: Array - Sorted array of monitors.
*/
SortMonitorsByPosition(monitors) {
    ; Clone the input array to avoid modifying the original
    sorted := monitors.Clone()
    
    n := sorted.Length
    if (n < 2)
        return sorted

    for i in Range(2,n) {
        key := sorted[i]
        j := i - 1
        while (j >= 1 and sorted[j].left > key.left) {
            sorted[j + 1] := sorted[j]
            j--
        }
        sorted[j + 1] := key
    }

    return sorted
}

/*
Moves the mouse cursor to the center of the next monitor in the sorted order,
        wrapping around if necessary.
*/
CenterOnOtherMonitor() {
    MouseGetPos(&currX, &currY)
    currentIndex := GetMonitorAtPosition(currX, currY)
    total := SysGet(80)  ; SM_CMONITORS

    ; Creates a monitor array (with work area coordinates) and sorts it
    monitors := []

    Loop total{
        l := 0, t := 0, r := 0, b := 0
        MonitorGetWorkArea(A_Index, &l, &t, &r, &b)
        mon := { left: l, top: t, right: r, bottom: b }
        monitors.Push(mon)
    }
    sortedMonitors := SortMonitorsByPosition(monitors)
    
    ; Determines the target index based on the current index and total monitors
    ; If there is only 1 monitor, it stays on it.
    ; If there are 2 monitors, it alternates between them. 
    ; If there are more than 2, it goes to the next monitor in the order (with wrap-around) [never tested].
    if (total = 1)
        targetIndex := 1
    else if (total = 2)
        targetIndex := (currentIndex = 1) ? 2 : 1
    else
        targetIndex := (currentIndex < total) ? currentIndex + 1 : 1
    
    ; Get the target monitor's work area
    targetMon := sortedMonitors[targetIndex]
    centerX := targetMon.left + ((targetMon.right - targetMon.left) // 2)
    centerY := targetMon.top  + ((targetMon.bottom - targetMon.top) // 2)
    
    ; Move the mouse cursor to the center of the target monitor
    DllCall("SetCursorPos", "Int", centerX, "Int", centerY)
}

/*
Displays a tooltip with the current mouse position, speed, monitor width, work width,
        and DPI scaling factor. The tooltip is automatically removed after 3 seconds.
*/
ShowToolTipStatus() {
    global speed
    
    MouseGetPos(&x, &y)
    dimensions  := GetMonitorDimensions(x, y)
    scaleFactor := GetDPIScalingFactor()
    
    mWidth := dimensions.monitorWidth
    wWidth := dimensions.workWidth

    ToolTip(Format("Position: X={1} Y={2}`nCurrent Speed: {3}`nMonitor Width: {4}`nWork Width: {5}`nDPI Scale: {6}x", x, y, speed,mWidth, wWidth, scaleFactor))
    
    ; Clear the tooltip after 3000 milliseconds.
    SetTimer(RemoveToolTip, -3000)
}