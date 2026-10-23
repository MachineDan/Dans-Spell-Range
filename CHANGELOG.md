# Changelog

## Unreleased

### Added
- **Keybind Shadow Size** option: set how far the shadow sits from the keybind text, from 0 (no shadow) to 4 pixels. Also `/dsr shadow <0-4>`.

### Fixed
- Turning off **Tint whole spell icon red** now gives tinted icons their normal color right away, instead of leaving them red until you hover them.
- A red-tinted icon no longer loses its tint while still out of range when the ability's usability changes, for example when your mana changes.
- When the red tint comes off an ability you don't have the mana for, its icon now turns Blizzard's out-of-mana blue instead of grey.

## 1.0.0 (2026-10-23)

First release of **Dan's Spell Range**: thicker, bolder action bar keybinds that are easy to read at a glance.

### Features
- **Thick, bold keybinds:** a thick outline and a drop shadow on keybind numbers, bright white when in range and red when out of range.
- **Bigger keybinds:** set the keybind font size from 8 to 22.
- **Optional red icon tint:** tint the whole spell icon red when out of range. Icons go back to their normal colors (including grey for unusable and blue for out of mana) when you're in range again.
- **Optional background box:** a dark box behind keybind numbers for extra contrast on bright icons, with adjustable darkness.
- **Instant updates** when you change target and when you enter or leave combat.
- An options page in **Esc → Options → AddOns → Dan's Spell Range** (or `/dsr`), and `/dsr help` for all commands.
