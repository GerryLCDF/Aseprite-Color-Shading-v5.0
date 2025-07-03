# Aseprite Color Shading v5.0

This script for [Aseprite](https://www.aseprite.org/) opens a dynamic color selection window with relevant gradient and hue options, helping you to easily create palettes and shade variations.

## Credits and Origins

This work is based on previous contributions:

- Version 1.0–2.0 by [Dominick John](https://github.com/dominickjohn/aseprite/tree/master) and [David Capello](https://aseprite.org/).
- Version 3.0 by [yashar98](https://github.com/yashar98/aseprite/tree/main).
- Version 3.1 by [Daeyangae](https://github.com/Daeyangae/aseprite).
- Version 4.0 by [Manuel Hoelzl](https://github.com/hoelzlmanuel/aseprite-color-shading).

This version maintains previously introduced functionalities while adding additional improvements.

## Installation

1. Download the script file (e.g. `Color Shading v4.0.lua`).
2. Open Aseprite and go to **File -> Scripts -> Open Scripts Folder** to open the scripts directory.
3. Copy the script file into Aseprite’s scripts folder.
4. Restart Aseprite if necessary.

## Usage

1. In Aseprite, go to **File -> Scripts -> Color Shading v4.0** to run the script.
2. A window with different color sections and palette generation options will appear.

### Features:

- **Base:** Clicking on one of the base colors will recalculate the rest of the shades and nuances based on that color.
- **"Get" Button:** Updates the base colors using the current foreground (FG) and background (BG) colors, and regenerates the shades.
- **Left Click on a Color:** Sets that color as the FG.
- **Right Click on a Color:** Sets that color as the BG.
- **Middle Click on a Color:** Toggles between FG/BG depending on which was last changed (if "auto pick" is enabled), and regenerates all shades based on the new color.
  
### Advanced Controls:

- **Temperature (Dark/Light):** Adjusts warm/cool hue shifts for dark and light shades, respectively.
- **Intensity:** Adds a saturation gradient to the shade swatches.
- **Peak:** Adds a lightness gradient to the shades, affecting how much brighter the lighter swatches become.
- **Sway:** Adjusts how strongly the set temperatures influence the resulting colors.
- **Slots:** Changes the number of generated color swatches.

## Notes

- Make sure you have the latest version of Aseprite for script compatibility.
- This script is intended for pixel artists and designers who need tools to quickly generate palettes and color gradients.

<img width="363" alt="Color Shading v5.0" src="shadow/img/op1EN">

## 🌐 Other languages

- 🇫🇷 [French Version](shadow/README/README-FR.md)
- 🇪🇸 [Spanish Version](shadow/README/README-ES.md)
- 🇯🇵 [Japanese Version](shadow/README/README-JA.md)
- 🇵🇹 [Portuguese Version](shadow/README/README-PT.md)
