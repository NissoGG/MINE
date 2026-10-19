# MINE - Materials In Everyone's Inventory

MINE is a World of Warcraft addon project for finding crafting materials in player inventories. The initial version scans the local character's bags and totals trade goods by item.

## Current scope

Version 0.1.0 lists material stacks from the player's backpack and equipped bags. Type `/mine` to open or close the window. It updates as bag contents change and as item data becomes available.

WoW addons cannot inspect another player's bags directly. Showing materials from other players will require those players to run MINE and explicitly share their inventory data, for example through the in-game addon messaging system. That group-sharing feature is not included in this initial version.

## Install and package

Build a ZIP with the interface version reported by your WoW client:

```powershell
.\package.ps1 -InterfaceVersion 16001
```

The install-ready archive is written to `dist\MINE-<version>.zip`. Extract it into the game's `Interface\AddOns` folder so the addon files are under `Interface\AddOns\MINE`.
