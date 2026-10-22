# SpellRange

A lightweight World of Warcraft addon (Classic Era / Vanilla / Retail) that enhances action bar range indicators with high-contrast keybind text, pure font shadows, optional whole-icon red tinting, and an in-game options menu.

## Features

- **Blizzard Options Menu Integration**: Accessible directly in the game's **Options -> AddOns -> SpellRange** menu (or via `/SpellRangeIndicator`, `/sri`, or `/sr`).
- **Full Icon Red Tint**: Option to tint the entire spell icon red when out of range (like *tullaRange* / *RedRange*). Restores normal icon colors instantly when back in range, when untargeting, or when targeting friendly units.
- **Thick Keybind Numbers with Font Shadow**: Bold font styled with `THICKOUTLINE` and a clean drop shadow (`1.5, -1.5`).
- **Optional Background Box**: An optional dark rectangular backing box behind keybind numbers for players who want extra contrast over bright/white spell icons (with adjustable opacity).
- **Instant Target Refresh**: Updates range status immediately on `PLAYER_TARGET_CHANGED`.

## Slash Commands

You can use `/SpellRangeIndicator`, `/sri`, `/spellrange`, or `/sr`:

| Command | Description |
| :--- | :--- |
| **`/SpellRangeIndicator`** (or **`/sri`**, **`/sr`**) | Opens the SpellRange settings in the game Options menu |
| `/sr tint` | Toggles full spell icon red tinting on/off |
| `/sr box` | Toggles the optional dark background box behind keybind numbers |
| `/sr size <8-22>` | Changes keybind font size (default: `13`) |
| `/sr reset` | Resets all settings to defaults |
