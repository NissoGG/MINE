# MINE - Materials In Everyone's Inventory

MINE tracks crafting materials for World of Warcraft Forever. The addon manifest retains this project's WoW Forever interface target (`16001`); the package script uses that target and does not offer other WoW versions.

## Inventory views

Use `/mine` to open or close the window.

- **Character** lists materials in the current character's bags.
- **Characters** lets you select one saved character and view its bag and bank snapshots; the sample profile is available here too.
- **Account** totals those saved snapshots, shows which characters have each material, and includes the scanned guild bank.
- **Shared** lists material snapshots received from other MINE users.

Use the category dropdown to show one category or all materials. Materials are grouped into the profession skill ranges **1-75**, **75-150**, **150-225**, and **225-300**, then by category. Enchanting materials are grouped into dust, essences, shards, and crystals; items within each group are ordered from common to rarer quality. Preview materials use their curated progression tier; other tracked materials are assigned an approximate range from their item level, since many materials are used by recipes across multiple skill ranges. **Characters** selects one saved character; **Account** shows the saved character inventories together, with each character and bank kept distinct. Each item displays its icon and rarity-colored name; hover over the icon for the item tooltip. Materials bought from vendors (for example, tailoring thread) are omitted from the list. Other trade goods are scanned regardless of bind status, so bind-on-pickup crafting materials are included.

The **Characters** tab includes a **Material Preview** profile with representative Vanilla Classic materials, including enchanting and elemental essences. It is display-only sample data: it does not affect account totals, saved characters, or shared snapshots. The [Wowhead Classic trade-goods database](https://www.wowhead.com/classic/items/trade-goods) is used as a reference; later-expansion materials such as Cobalt and Saronite are not included in the preview.

Personal bank contents are recorded when the bank is opened. Guild-bank tabs are scanned while the guild bank is open, and their material totals appear in the **Account** view. Guild-bank data is stored for the current guild and cleared when MINE detects that the character leaves or changes guild. MINE cannot inspect a character who has not logged in and scanned their inventory, and account totals are limited to characters sharing this addon's saved variables.

## Sharing

MINE shares the current character's bag and last-scanned bank counts on entering the world and when logging out (including `/reload`), and also provides a **Share** button for an immediate update. A party or raid is used when available, otherwise the guild channel is used. Only online MINE users listening to that channel receive the snapshot; WoW addons cannot inspect another player's inventory or deliver data to offline users. Addon messages are paced to avoid flooding chat.

## Research and design choices

The character inventory and bank overview follows the use case of [Altoholic](https://github.com/wotlk-cloud/Altoholic), while bank-aware inventory handling is informed by [BankStack](https://github.com/kemayo/wow-bankstack). MINE keeps its implementation dependency-free and uses SavedVariables for per-character snapshots. Bag scans are coalesced after inventory events rather than run continuously, and outgoing snapshot packets are paced. These projects target other WoW clients; their code is not copied, and their compatibility with WoW Forever is not assumed.

## Install and package

Run:

```powershell
.\package.ps1
```

The install-ready archive is written to `dist\MINE-0.10.0.zip` and versioned with the source so it is available from the repository. Extract it into the WoW Forever `Interface\AddOns` folder so the addon files are under `Interface\AddOns\MINE`.
