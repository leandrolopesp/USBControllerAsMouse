/*
    Utility Functions for AutoHotkey v2

    Range(min, max)
    Mid(val, lower, upper)
    RemoveToolTip()
*/

#SingleInstance
#Requires AutoHotkey v2.0
/*
    Range(min, max)
        Creates and returns an array containing all integer values from min to max (inclusive).
        Parameters:
            min - The starting integer value.
            max - The ending integer value.
        Returns:
            Array of integers from min to max.
*/
Range(min, max) {
    ; I actually don't understand the Loop function in AHK v2 and I use Range to avoid it.
    ; Is that a bad practice? I don't know.
    
    arr := Array(max - min + 1)
    idx := min
    while (idx <= max) {
        arr.Push(idx)
        idx++
    }
    return arr
}

/*
    Mid(val, lower, upper)
        Clamps a value between a lower and upper bound.
        Parameters:
            val   - The value to clamp.
            lower - The minimum allowed value.
            upper - The maximum allowed value.
        Returns:
            The clamped value.
*/
Mid(val, lower, upper) { ; Name also stolen from Pico8.
    ; Clamp the value between lower and upper bounds 
    return Min(Max(val, lower), upper)
}

/* 
    You know what this does. You read the name.
*/
RemoveToolTip(){
    ;It removes the thing that starts with Tool and ends with...
    ;you have to guess the rest.
    ToolTip
}