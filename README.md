# SpellRange

See at a glance which abilities can reach your target: action bar keybinds turn red when your target is out of range.

SpellRange doesn't replace your action bars. It restyles the keybind numbers on Blizzard's own action buttons
so they're easy to read, and colors them by range.

## Features

- **Red keybinds when out of range:** the keybind number on an action button turns red when your target
  is out of range, and white again when it's in range.
- **Optional red icon tint:** tint the whole spell icon red when out of range, like *tullaRange* or *RedRange*.
  Icons go back to their normal colors (including grey for unusable and blue for out of mana)
  when you're in range again, untarget, or target a friendly unit.
- **Bold, readable keybinds:** a thick outline and a drop shadow on keybind numbers,
  with an adjustable font size (8–22).
- **Optional background box:** a dark box behind keybind numbers for extra contrast on bright icons,
  with adjustable darkness.
- **Instant updates** when you change target and when you enter or leave combat.

## Installation

1. Download **`SpellRange-x.y.z.zip`** from the [latest release](https://github.com/MachineDan/SpellRange/releases/latest)
   (not the "Source code" downloads, and not **Code → Download ZIP**).
2. Open the zip and drag the **`SpellRange`** folder inside it into your AddOns folder, for example
   `World of Warcraft\_classic_era_\Interface\AddOns\`. You should end up with `AddOns\SpellRange\SpellRange.toc`.
3. Restart the game or type `/reload`.

Or install it through the CurseForge app, which does all of this for you.

## Usage

Open the options with `/sr`, or from **Esc → Options → AddOns → SpellRange**. Changes apply right away.

| Option | What it does |
| --- | --- |
| **Tint whole spell icon red** | Color the entire icon red when out of range, not just the keybind (off by default) |
| **Thick keybind numbers** | Thick outline on keybind numbers (on by default) |
| **Dark background box** | A dark box behind keybind numbers (off by default) |
| **Keybind Font Size** | 8 to 22 (default 13) |
| **Background Box Darkness** | How dark the box is (default 65%) |
| **Defaults** | Reset every option |

### Slash commands

`/sr`, `/sri`, `/spellrange` and `/spellrangeindicator` all work.

| Command | What it does |
| --- | --- |
| `/sr` | Open the options |
| `/sr tint [on\|off]` | Tint whole spell icons red when out of range (toggles if you leave out on/off) |
| `/sr box [on\|off]` | Show the dark box behind keybind numbers (toggles if you leave out on/off) |
| `/sr size <8-22>` | Keybind font size |
| `/sr reset` | Reset all settings to defaults |
| `/sr help` | List all commands in chat |

## Good to know

- **Range is checked against your target.** With no target, or a dead one, keybinds stay white.
  Abilities with no range, like self buffs, never turn red.
- **Blizzard's action bars only:** SpellRange styles the default action bars.
  Action bar addons that create their own buttons, like Bartender4, aren't affected.

## Compatibility

Developed for the WoW **1.60** client. The `.toc` also lists Classic Era (1.15).

## License

[MIT](LICENSE)
