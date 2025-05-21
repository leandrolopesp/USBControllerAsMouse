/*
    mapping.ahk
    -----------
    This module provides functions for interactively mapping joystick buttons to specific functions.
    It allows users to configure joystick button mappings and save them to Config.ini file.

    Functions:
    - MapButtonsInteractive(mappingKeys, section, file)
    - WaitForJoystickButton()

*/

#SingleInstance
#Requires AutoHotkey v2.0

;=============== BUTTON MAPPING CONFIGURATION ===============

/*
    MapButtonsInteractive(mappingKeys, section, file)
    ------------------------------------------------
    Prompts the user to interactively map joystick buttons to specified functions.
    For each key in mappingKeys, displays a tooltip asking the user to press a joystick button,
    waits for the button press, and saves the mapping to the Config.ini file.
    
    Parameters:
        mappingKeys (Array) - List of function names to map to joystick buttons.
        section (String)    - INI file section name to store the mappings.
        file (String)       - Path to the INI file for saving the mappings.

    Returns:
        Map - A map of function names to joystick button numbers.
*/
MapButtonsInteractive(mappingKeys, section, file) {
    mapping := Map() 
    for index, key in mappingKeys {
        ToolTip("Press the button for function: " key)
        value := WaitForJoystickButton()
        mapping[key] := value
        IniWrite(value, file, section, key)
        Sleep(500)
    }
    RemoveToolTip()
    return mapping
}


/*
 WaitForJoystickButton()
    -----------------------
    Waits for the user to press any joystick button (1 to 32) and returns the button number.
    Uses the global variable 'joyNumber' to determine which joystick to monitor.

    Returns:
        Integer - The number of the joystick button that was pressed.
*/
WaitForJoystickButton() {
    global joyNumber
    pressed := ""
    Loop {
        for i in Range(1, 32) {
            if GetKeyState(joyNumber . "Joy" . i, "P") {
                pressed := i
                break
            }
        }
        if (pressed != "")
            break
        Sleep 10
    }
    return pressed
}
