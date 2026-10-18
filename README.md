<div align="center">

<img src="Screenshots/emote-compass-wheel.png" alt="The emote wheel" width="300">

# 🎭 Emotes Compass

A radial emotes wheel on one key that mimics the one from the controller UI.

![WoW Forever](https://img.shields.io/badge/WoW-Forever%201.60.1-f8b700?logo=battledotnet&logoColor=white)
![Interface 16001](https://img.shields.io/badge/Interface-16001-0070dd)
[![CurseForge Page](https://img.shields.io/badge/-CurseForge%20Page-f16436?logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/emotes-compass)
![Lua 5.1](https://img.shields.io/badge/Lua-5.1-2c2d72?logo=lua&logoColor=white)

</div>


## 📦 Install

Download the zip from the [latest release](../../releases/latest) and extract the `EmotesCompass` folder into `World of Warcraft/_<version>_/Interface/AddOns/`.

It is also on [CurseForge](https://www.curseforge.com/wow/addons/emotes-compass).

## 🎮 Usage

Hold `G` to open the wheel under the cursor, point at a wedge and release the key. Left click also picks an emote. Right click or Escape cancels. You can rebind the key in the game's keybinds list.

- `/ec` opens the options.
- `/ec edit` opens the wheel editor.
- `/ec show` opens the wheel and keeps it open until you pick an emote or cancel.

### 🎨 Customize the wheel

Drag an emote from the list onto a wedge to assign it. Drag between wedges to swap them, or drag a wedge off the wheel to clear it. Click an emote to try it.

![The wheel editor](Screenshots/emote-compass-customize.png)

### ⚙️ Options

The options page is under Esc > Options > AddOns. It shows the bound key, opens the editor, and can show a small button that opens the wheel on click. While the button is shown, the key is disabled. You can drag the button, lock its position and resize it.

![The options page](Screenshots/emote-compass-settings.PNG)

![The wheel button](Screenshots/emote-compass-icon.png)

## 🛠️ Stack

The addon is plain Lua with a few XML files and no external libraries.

- The wheel reuses the art and geometry of Blizzard's gamepad radial menu.
- The emote list is built at runtime from the game's `EMOTE<n>_TOKEN` and `EMOTE<n>_CMD1` globals. Labels come from the client's translated slash commands, so they follow the game language. Icons are picked by hand in `Data/EmoteData.lua`.
- The options page uses the Settings API, with one XML template for the checkbox hint.
- The editor list uses `WowScrollBoxList` and a data provider.
- The wheel layout and button settings are saved in the account-wide `EmotesCompassDB`.
- The interface text is translated into 10 languages in `Core/Locale.lua`.

```
Core/    constants, text, helpers, saved data, emote catalog
Data/    icon for each emote
UI/      wheel view, popup, editor, wheel button, options
Init.lua key binding, slash commands, startup
```
