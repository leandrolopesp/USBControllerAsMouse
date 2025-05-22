# USB Controller as Mouse Script 

<img src="images/logo.png" alt="Logo" width="200">

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

There are currently no known issues.
If you have any trouble, there is the `Test/ControllerTest.ahk` script. This script is a copy of [AutoHotKey test script](https://www.autohotkey.com/docs/v2/scripts/index.htm#ControllerTest).

### Default Mapping (for 8BitDo M30)

I use the 8BitDo M30, so the button names reflect my personal mapping. You can always remap them in a way that works better for you.

- D-Pad: Move cursor
- A: Left click
- B: Right click
- C: Increase speed (2x)
- Z: Turbo (3x)
- LB: Middle Click. Enables scroll mode (with D-Pad)
- RB: Precision mode (20% speed)
- Start: Center cursor on another monitor
- Select (-): Restarts Script
- Home (<3): Exit script
- X: Show some status
- Y: Center cursor on current monitor (with D-Pad for quadrant)
</br><img src="images/quadrants.png" alt="quadrants" width="600"></br>

## License

This work is licensed under a [Creative Commons Attribution-NonCommercial 4.0 International License](https://www.creativecommons.org/licenses/by-nc/4.0/deed.en).  
[![CC BY-NC 4.0](https://licensebuttons.net/l/by-nc/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc/4.0/)  

You are free to share, adapt but **do not use it for commercial purposes**.

## Contributing

Contributions are welcome! Feel free to open issues or pull requests with improvements, fixes, or suggestions.

## TO DOs or not TO DOs

- Improve cursor movement for joysticks using an analog stick.
- GUI to configure default speed, multipliers, the slowmode and deadzone.
    - Add Invert Axis option for cursor movement and scrolling.
PowerToys:
- Call Michael Clayton's Mouse Jump (Fancy Mouse). That is such a nice feature...
- Test if it works with the Mouse Without Boarders.

## Acknowledgments

Special thanks to Windows 11 for consistently failing to recognize my mouse (mice, actually) after hibernation. 
