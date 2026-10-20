# MINE - Materials In Everyone's Inventory

MINE tracks crafting materials for World of Warcraft Forever. The addon manifest retains this project's WoW Forever interface target (`16001`); the package script uses that target and does not offer other WoW versions.

## Inventory views

Use `/mine` to open or close the window.

- **Character** lists materials in the current character's bags.
- **Characters** lists saved bag and bank snapshots for each character that has logged in with MINE.
- **Account** totals those saved snapshots and shows which characters have each material.
- **Shared** lists material snapshots received from other MINE users.

Materials are grouped by profession-friendly categories (cloth, leather, metal and stone, herbs, enchanting, gems, elemental, parts, and other trade goods). Within each category, higher item levels appear first. The scan includes trade goods regardless of bind status, so bind-on-pickup crafting materials are included.

Bank contents are recorded when the bank is opened. MINE cannot inspect a character who has not logged in and scanned their inventory, and account totals are limited to characters sharing this addon's saved variables.

## Sharing

MINE shares the current character's bag and last-scanned bank counts on entering the world and when logging out (including `/reload`), and also provides a **Share** button for an immediate update. A party or raid is used when available, otherwise the guild channel is used. Only online MINE users listening to that channel receive the snapshot; WoW addons cannot inspect another player's inventory or deliver data to offline users. Addon messages are paced to avoid flooding chat.

## Research and design choices

The character inventory and bank overview follows the use case of [Altoholic](https://github.com/wotlk-cloud/Altoholic), while bank-aware inventory handling is informed by [BankStack](https://github.com/kemayo/wow-bankstack). MINE keeps its implementation dependency-free and uses SavedVariables for per-character snapshots. Bag scans are coalesced after inventory events rather than run continuously, and outgoing snapshot packets are paced. These projects target other WoW clients; their code is not copied, and their compatibility with WoW Forever is not assumed.

## Install and package

Run:

```powershell
.\package.ps1
```

The install-ready archive is written to `dist\MINE-0.3.0.zip` and versioned with the source so it is available from the repository. Extract it into the WoW Forever `Interface\AddOns` folder so the addon files are under `Interface\AddOns\MINE`.
