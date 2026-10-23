<p align="center">
  <img src="media/dans-spell-range-logo.webp" alt="Dan's Spell Range logo" width="320">
</p>

# Dan's Spell Range

Thicker, bolder action bar keybinds, so you can see at a glance which abilities are out of range.

Blizzard already turns keybinds red when your target is out of range, but the numbers are small and thin.
Dan's Spell Range makes them thick and bold, lets you make them bigger, and can tint the whole spell icon red.
It restyles Blizzard's own action buttons rather than replacing your bars.

## Features

- **Thick, bold keybinds:** a thick outline and a drop shadow on keybind numbers,
  bright white when in range and red when out of range.
- **Bigger keybinds, bigger shadow:** set the keybind font size from 8 to 22,
  and the shadow size from 0 (none) to 4 pixels.
- **Optional red icon tint:** tint the whole spell icon red when out of range, like *tullaRange* or *RedRange*.
  Icons go back to their normal colors (including grey for unusable and blue for out of mana)
  when you're in range again, untarget, or target a friendly unit.
- **Optional background box:** a dark box behind keybind numbers for extra contrast on bright icons,
  with adjustable darkness.
- **Instant updates** when you change target and when you enter or leave combat.

## Installation

1. Download **`DansSpellRange-x.y.z.zip`** from the [latest release](https://github.com/MachineDan/Dans-Spell-Range/releases/latest)
   (not the "Source code" downloads, and not **Code → Download ZIP**).
2. Open the zip and drag the **`DansSpellRange`** folder inside it into your AddOns folder, for example
   `World of Warcraft\_classic_era_\Interface\AddOns\`. You should end up with `AddOns\DansSpellRange\DansSpellRange.toc`.
3. Restart the game or type `/reload`.

Or install it through the CurseForge app, which does all of this for you.

## Usage

Open the options with `/dsr`, or from **Esc → Options → AddOns → Dan's Spell Range**. Changes apply right away.

| Option | What it does |
| --- | --- |
| **Tint whole spell icon red** | Color the entire icon red when out of range, not just the keybind (off by default) |
| **Thick keybind numbers** | Thick outline on keybind numbers (on by default) |
| **Dark background box** | A dark box behind keybind numbers (off by default) |
| **Keybind Font Size** | 8 to 22 (default 13) |
| **Keybind Shadow Size** | How far the shadow sits from the text, 0 to 4 pixels; 0 turns it off (default 1.5) |
| **Background Box Darkness** | How dark the box is (default 65%) |
| **Defaults** | Reset every option |

### Slash commands

`/dsr` and `/dansspellrange` both work.

| Command | What it does |
| --- | --- |
| `/dsr` | Open the options |
| `/dsr tint [on\|off]` | Tint whole spell icons red when out of range (toggles if you leave out on/off) |
| `/dsr box [on\|off]` | Show the dark box behind keybind numbers (toggles if you leave out on/off) |
| `/dsr size <8-22>` | Keybind font size |
| `/dsr shadow <0-4>` | Keybind shadow size (0 turns it off) |
| `/dsr reset` | Reset all settings to defaults |
| `/dsr help` | List all commands in chat |

## Good to know

- **Range is checked against your target.** With no target, or a dead one, keybinds stay white.
  Abilities with no range, like self buffs, never turn red.
- **Blizzard's action bars only:** Dan's Spell Range styles the default action bars.
  Action bar addons that create their own buttons, like Bartender4, aren't affected.

## Compatibility

Developed for the WoW **1.60** client. The `.toc` also lists Classic Era (1.15).

## License

[MIT](LICENSE)
