**USB Controller as Mouse Script**

This AutoHotkey v2 script lets you use a USB controller as a mouse on Windows. It supports DPI-sensitive cursor movement, smooth scrolling with the D-Pad, and screen-centering features. Buttons can be configured interactively or via a `config.ini` file.

You can also use the official [ControllerMouse](https://www.autohotkey.com/docs/v2/scripts/index.htm#ControllerMouse) script which is much smarter than mine is and I just found out about it after I had already created this one.

## Features

- Cursor movement using the D-Pad (X/Y axes)
- Adjustable speed: precision (RB), 2x (C), 3x (Z), 6x (C+Z)
- Center cursor on current or other monitor (Y, Start)
- Smooth horizontal/vertical scrolling (LB + D-Pad)
- Left/right mouse click (A/B)
- Show script status (X)
- Exit script (Home)
- Multi-monitor support
- DPI sensitivity

## Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/) (or newer).
2. Double-click `USBControllerAsMouse.ahk` to run.

## Configuration

- On first run, the script will guide you to map the buttons.
- Mappings are saved in `config.ini`.
- To remap, delete `config.ini` and restart the script.

## Usage

1. Connect your controller via USB and run the script.
2. If `config.ini` exists, mappings will load automatically.
3. Otherwise, the interactive mapping process will start.
4. Use the mapped buttons to control the mouse and access features.

## Compatibility Information

This script does not support Bluetooth controllers.  
For Bluetooth compatibility, the program would need to locate Xinput DLLs in Windows, which this script does not do.  
I have only tested this script with the **8BitDo M30** and **DualShock 4 (DS4)** controllers.

## Known Issues

There are no known issues at this moment. 
If you have any trouble, there is the `Test/ControllerTest.ahk` script. This script is a copy of [AutoHotKey test script](https://www.autohotkey.com/docs/v2/scripts/index.htm#ControllerTest).

### Default Mapping (for 8BitDo M30)
 
 I have the 8BitDo M30 so the names of the button are how I mapped for myself. You always can remap the way your controller works better.

- D-Pad: Move cursor
- A: Left click
- B: Right click
- X: Show status
- Y: Center cursor on current monitor (with D-Pad for quadrant)
- C: Increase speed (2x)
- Z: Turbo (3x)
- LB: Middle Click. Enables scroll mode (with D-Pad)
- RB: Precision mode (20% speed)
- Start: Center cursor on another monitor
- Select (-): Restarts Script
- Home (<3): Exit script

## License

This work is licensed under a  
[![CC BY-NC 4.0](https://licensebuttons.net/l/by-nc/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc/4.0/)

## Contributing

Contributions are welcome! Feel free to open issues or pull requests with improvements, fixes, or suggestions.

## TO DOs or not TO DOs.

- Improve cursor movement when using any joystick with Analog stick.
- GUI to configure default speed, multipliers, the slowmode and deadzone.
    - Add Invert Axis option for cursor movement and scrolling.
PowerToys:
- Call Michael Clayton's Mouse Jump (Fancy Mouse). That is such a nice feature...
- Test if it works with the Mouse Without Boarders.

## Acknowledgments

Thanks to Windows 11 for not recognizing my mouse (mice, actually) after hibernation mode.
