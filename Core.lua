local messagePrefix = "MINE"
local rowHeight = 22
local tradeGoodsType = GetItemClassInfo and GetItemClassInfo(7)
local chatInfoAPI = C_ChatInfo
local registerAddonMessagePrefix = RegisterAddonMessagePrefix or (chatInfoAPI and chatInfoAPI.RegisterAddonMessagePrefix)
local sendAddonMessage = SendAddonMessage or (chatInfoAPI and chatInfoAPI.SendAddonMessage)
local containerAPI = C_Container
local getContainerNumSlots = GetContainerNumSlots or (containerAPI and containerAPI.GetContainerNumSlots)
local getContainerItemLink = GetContainerItemLink or (containerAPI and containerAPI.GetContainerItemLink)
local getContainerItemInfo = GetContainerItemInfo or (containerAPI and containerAPI.GetContainerItemInfo)
local itemAPI = C_Item
local getItemInfo = GetItemInfo or (itemAPI and itemAPI.GetItemInfo)
local requestLoadItemDataByID = itemAPI and itemAPI.RequestLoadItemDataByID
local requestedItemData = {}
local categoryOrder = {
    "Cloth",
    "Leather",
    "Metal & Stone",
    "Herbs",
    "Enchanting",
    "Gems",
    "Elemental",
    "Parts",
    "Other"
}
local categoryBySubType = {
    ["Cloth"] = "Cloth",
    ["Leather"] = "Leather",
    ["Metal & Stone"] = "Metal & Stone",
    ["Metal"] = "Metal & Stone",
    ["Stone"] = "Metal & Stone",
    ["Herbs"] = "Herbs",
    ["Enchanting"] = "Enchanting",
    ["Gems"] = "Gems",
    ["Elemental"] = "Elemental",
    ["Parts"] = "Parts",
    ["Explosives"] = "Parts",
    ["Devices"] = "Parts"
}
local previewItems = {
    [2589] = { name = "Linen Cloth", count = 1, category = "Cloth", level = 1 },
    [2592] = { name = "Wool Cloth", count = 1, category = "Cloth", level = 2 },
    [4306] = { name = "Silk Cloth", count = 1, category = "Cloth", level = 3 },
    [4338] = { name = "Mageweave Cloth", count = 1, category = "Cloth", level = 4 },
    [14047] = { name = "Runecloth", count = 1, category = "Cloth", level = 5 },
    [2934] = { name = "Ruined Leather Scraps", count = 1, category = "Leather", level = 1 },
    [2318] = { name = "Light Leather", count = 1, category = "Leather", level = 2 },
    [2319] = { name = "Medium Leather", count = 1, category = "Leather", level = 3 },
    [4234] = { name = "Heavy Leather", count = 1, category = "Leather", level = 4 },
    [4304] = { name = "Thick Leather", count = 1, category = "Leather", level = 5 },
    [8170] = { name = "Rugged Leather", count = 1, category = "Leather", level = 6 },
    [2770] = { name = "Copper Ore", count = 1, category = "Metal & Stone", level = 1 },
    [2771] = { name = "Tin Ore", count = 1, category = "Metal & Stone", level = 2 },
    [2841] = { name = "Bronze Bar", count = 1, category = "Metal & Stone", level = 3 },
    [2772] = { name = "Iron Ore", count = 1, category = "Metal & Stone", level = 4 },
    [3858] = { name = "Mithril Ore", count = 1, category = "Metal & Stone", level = 5 },
    [10620] = { name = "Thorium Ore", count = 1, category = "Metal & Stone", level = 6 },
    [2447] = { name = "Peacebloom", count = 1, category = "Herbs", level = 1 },
    [765] = { name = "Silverleaf", count = 1, category = "Herbs", level = 1 },
    [785] = { name = "Mageroyal", count = 1, category = "Herbs", level = 2 },
    [2450] = { name = "Briarthorn", count = 1, category = "Herbs", level = 3 },
    [8838] = { name = "Sungrass", count = 1, category = "Herbs", level = 4 },
    [13463] = { name = "Dreamfoil", count = 1, category = "Herbs", level = 5 },
    [13466] = { name = "Plaguebloom", count = 1, category = "Herbs", level = 6 },
    [10940] = { name = "Strange Dust", count = 1, category = "Enchanting", level = 1 },
    [11083] = { name = "Soul Dust", count = 1, category = "Enchanting", level = 2 },
    [11137] = { name = "Vision Dust", count = 1, category = "Enchanting", level = 3 },
    [11176] = { name = "Dream Dust", count = 1, category = "Enchanting", level = 4 },
    [16204] = { name = "Illusion Dust", count = 1, category = "Enchanting", level = 5 },
    [774] = { name = "Malachite", count = 1, category = "Gems", level = 1 },
    [818] = { name = "Tigerseye", count = 1, category = "Gems", level = 1 },
    [1206] = { name = "Moss Agate", count = 1, category = "Gems", level = 2 },
    [7909] = { name = "Aquamarine", count = 1, category = "Gems", level = 3 },
    [7910] = { name = "Star Ruby", count = 1, category = "Gems", level = 4 },
    [12800] = { name = "Azerothian Diamond", count = 1, category = "Gems", level = 5 },
    [7067] = { name = "Elemental Earth", count = 1, category = "Elemental", level = 1 },
    [7068] = { name = "Elemental Fire", count = 1, category = "Elemental", level = 2 },
    [7070] = { name = "Elemental Water", count = 1, category = "Elemental", level = 3 },
    [7069] = { name = "Elemental Air", count = 1, category = "Elemental", level = 4 },
    [4371] = { name = "Bronze Tube", count = 1, category = "Parts", level = 2 },
    [4377] = { name = "Heavy Blasting Powder", count = 1, category = "Parts", level = 4 },
    [15992] = { name = "Dense Blasting Powder", count = 1, category = "Parts", level = 6 },
    [15994] = { name = "Thorium Widget", count = 1, category = "Parts", level = 6 },
    [17034] = { name = "Maple Seed", count = 1, category = "Other", level = 1 },
    [4291] = { name = "Silken Thread", count = 1, category = "Other", level = 3 },
    [14341] = { name = "Rune Thread", count = 1, category = "Other", level = 5 },
    [8171] = { name = "Rugged Hide", count = 1, category = "Leather", level = 6 }
}
local activeTab = "character"
local selectedCategory = "All"
local selectedCharacterKey = "preview"
local characterKey
local bankOpen = false
local guildBankOpen = false
local incomingTransfers = {}
local outgoingMessages = {}
local bagRefreshDelay
local guildBankRefreshDelay
local loginShareDelay
local guildCheckDelay
local queuedGuildTab
local guildTabQueryDelay
local sendCooldown = 0
local snapshotSequence = 0
local runtimeFrame = CreateFrame("Frame")
local RuntimeUpdate
local currentGuildName
local Refresh

local function GetItemCategory(itemType, itemSubType)
    if not itemType or (itemType ~= "Trade Goods" and itemType ~= tradeGoodsType) then
        return nil
    end
    return categoryBySubType[itemSubType] or "Other"
end

local function GetItemDetails(itemId, fallbackInfo)
    local name, itemLevel, itemType, itemSubType, quality, icon
    if getItemInfo then
        local info = { getItemInfo(itemId) }
        if type(info[1]) == "table" then
            local item = info[1]
            name = item.itemName or item.name
            itemLevel = item.itemLevel
            itemType = item.itemType
            itemSubType = item.itemSubType
            quality = item.itemQuality or item.quality
            icon = item.itemTexture or item.iconFileID or item.icon
        else
            name = info[1]
            quality = info[3]
            itemLevel = info[4]
            itemType = info[6]
            itemSubType = info[7]
            icon = info[10]
        end
    end
    if fallbackInfo then
        name = name or fallbackInfo.itemName
        itemType = itemType or fallbackInfo.itemType
        itemSubType = itemSubType or fallbackInfo.itemSubType
        quality = quality or fallbackInfo.quality
        icon = icon or fallbackInfo.iconFileID
    end
    return name, itemLevel, itemType, itemSubType, quality, icon
end

local function UpdateItemMetadata(itemId, item)
    local name, itemLevel, itemType, itemSubType, quality, icon = GetItemDetails(itemId)
    local category = GetItemCategory(itemType, itemSubType)
    if name then
        item.name = name
    end
    if category then
        item.category = category
        item.level = tonumber(itemLevel) or 0
    end
    item.quality = tonumber(quality) or item.quality
    item.icon = icon or item.icon
end

local function UpdateSharedItemMetadata(itemId)
    for _, shared in pairs(MINE_DB.shared) do
        local item = shared.items[itemId] or shared.items[tostring(itemId)]
        if item then
            UpdateItemMetadata(itemId, item)
        end
    end
end

local function GetCurrentGuildName()
    local guildName = GetGuildInfo and GetGuildInfo("player") or nil
    return guildName ~= "" and guildName or nil
end

local function ScanContainer(container)
    local items = {}
    local function scanBag(bag)
        for slot = 1, (getContainerNumSlots(bag) or 0) do
            local itemInfo, legacyCount = getContainerItemInfo(bag, slot)
            local link = getContainerItemLink(bag, slot)
            if not link and type(itemInfo) == "table" then
                link = itemInfo.hyperlink
            end
            if link or type(itemInfo) == "table" then
                local itemId = (link and tonumber(link:match("item:(%d+)")))
                    or (type(itemInfo) == "table" and itemInfo.itemID)
                local count = type(itemInfo) == "table" and itemInfo.stackCount or legacyCount
                local name, itemLevel, itemType, itemSubType, quality, icon
                if itemId then
                    name, itemLevel, itemType, itemSubType, quality, icon = GetItemDetails(itemId, itemInfo)
                end
                local category = GetItemCategory(itemType, itemSubType)
                if itemId and name and category then
                    local item = items[itemId]
                    if item then
                        item.count = item.count + (count or 1)
                    else
                        items[itemId] = {
                            name = name,
                            count = count or 1,
                            category = category,
                            level = tonumber(itemLevel) or 0,
                            quality = tonumber(quality) or 1,
                            icon = icon
                        }
                    end
                end
            end
        end
    end

    if container == "bags" then
        for bag = 0, NUM_BAG_SLOTS do
            scanBag(bag)
        end
    else
        scanBag(BANK_CONTAINER or -1)
        for bankBag = 1, (NUM_BANKBAGSLOTS or 0) do
            scanBag(NUM_BAG_SLOTS + bankBag)
        end
    end
    return items
end

local function GetCurrentCharacter()
    if not MINE_DB or not characterKey then
        return nil
    end
    return MINE_DB.characters[characterKey]
end

local function SaveCurrentCharacter()
    local character = GetCurrentCharacter()
    if character then
        character.items = ScanContainer("bags")
        character.lastUpdate = time()
    end
end

local function SaveBank()
    local character = GetCurrentCharacter()
    if character then
        character.bankItems = ScanContainer("bank")
        character.bankLastUpdate = time()
    end
end

local function ScanGuildBank()
    local guildBank = MINE_DB and MINE_DB.guildBank
    if not guildBankOpen or not guildBank or not currentGuildName
        or guildBank.guildName ~= currentGuildName or not GetNumGuildBankTabs
        or not GetGuildBankTabInfo or not GetGuildBankItemInfo or not GetGuildBankItemLink then
        return
    end

    local items = {}
    local tabCount = GetNumGuildBankTabs() or 0
    local slotCount = NUM_GUILDBANKSLOTS_PER_TAB or 98
    for tab = 1, tabCount do
        local _, _, isViewable = GetGuildBankTabInfo(tab)
        if isViewable ~= false then
            for slot = 1, slotCount do
                local _, count = GetGuildBankItemInfo(tab, slot)
                local link = GetGuildBankItemLink(tab, slot)
                if link and count and count > 0 then
                    local itemId = tonumber(link:match("item:(%d+)"))
                    local name, itemLevel, itemType, itemSubType, quality, icon
                    if itemId then
                        name, itemLevel, itemType, itemSubType, quality, icon = GetItemDetails(itemId)
                    end
                    local category = GetItemCategory(itemType, itemSubType)
                    if itemId and name and category then
                        local item = items[itemId]
                        if item then
                            item.count = item.count + count
                        else
                            items[itemId] = {
                                name = name,
                                count = count,
                                category = category,
                                level = tonumber(itemLevel) or 0,
                                quality = tonumber(quality) or 1,
                                icon = icon
                            }
                        end
                    end
                end
            end
        end
    end

    guildBank.items = items
    guildBank.lastUpdate = time()
end

local function UpdateGuildBankItemMetadata(itemId)
    local guildBank = MINE_DB and MINE_DB.guildBank
    local item = guildBank and guildBank.items
        and (guildBank.items[itemId] or guildBank.items[tostring(itemId)])
    if item then
        UpdateItemMetadata(itemId, item)
    end
end

local function UpdateCharacterItemMetadata(itemId)
    for _, character in pairs((MINE_DB and MINE_DB.characters) or {}) do
        for _, inventory in ipairs({ character.items or {}, character.bankItems or {} }) do
            local item = inventory[itemId] or inventory[tostring(itemId)]
            if item then
                UpdateItemMetadata(itemId, item)
            end
        end
    end
end

local function RefreshGuildMembership()
    local guildName = GetCurrentGuildName()
    local membershipChanged = guildName ~= currentGuildName
    currentGuildName = guildName
    local guildBankCleared = MINE_DB.guildBank and MINE_DB.guildBank.guildName ~= guildName
    if guildBankCleared then
        MINE_DB.guildBank = nil
    end
    if guildName and not MINE_DB.guildBank then
        MINE_DB.guildBank = { guildName = guildName, items = {} }
    end
    if membershipChanged or guildBankCleared then
        if guildBankOpen then
            guildBankOpen = false
            queuedGuildTab = nil
            guildTabQueryDelay = nil
        end
        if Refresh then
            Refresh()
        end
    end
end

local function MakeItemList(itemMap)
    local items = {}
    for itemId, item in pairs(itemMap or {}) do
        if selectedCategory == "All" or (item.category or "Other") == selectedCategory then
            local quality = tonumber(item.quality)
            local icon = item.icon
            if (not quality or not icon) and tonumber(itemId) then
                local _, _, _, _, itemQuality, itemIcon = GetItemDetails(tonumber(itemId))
                quality = quality or tonumber(itemQuality)
                icon = icon or itemIcon
                item.quality = quality
                item.icon = icon
                if (not quality or not icon) and requestLoadItemDataByID and not requestedItemData[itemId] then
                    requestLoadItemDataByID(tonumber(itemId))
                    requestedItemData[itemId] = true
                end
            end
            items[#items + 1] = {
                id = tonumber(itemId),
                name = item.name or ("Item " .. tostring(itemId)),
                count = tonumber(item.count) or 0,
                category = item.category or "Other",
                level = tonumber(item.level) or 0,
                quality = quality or 1,
                icon = icon
            }
        end
    end
    table.sort(items, function(left, right)
        if left.category ~= right.category then
            for _, category in ipairs(categoryOrder) do
                if left.category == category then
                    return true
                elseif right.category == category then
                    return false
                end
            end
        end
        if left.level ~= right.level then
            return left.level < right.level
        end
        return string.lower(left.name) < string.lower(right.name)
    end)
    return items
end

local function AddInventoryToTotals(totals, inventory, characterName)
    for itemId, item in pairs(inventory or {}) do
        local total = totals[itemId]
        if not total then
            totals[itemId] = {
                name = item.name,
                count = 0,
                category = item.category,
                level = item.level,
                quality = item.quality,
                icon = item.icon,
                owners = {}
            }
            total = totals[itemId]
        end
        total.count = total.count + (tonumber(item.count) or 0)
        if characterName then
            total.owners[#total.owners + 1] = characterName .. " x" .. tostring(item.count)
        end
    end
end

local function AddInventoryLines(lines, inventory, owner)
    local items = MakeItemList(inventory)
    local previousCategory
    for _, item in ipairs(items) do
        if item.category ~= previousCategory then
            lines[#lines + 1] = { kind = "header", text = item.category }
            previousCategory = item.category
        end
        local suffix = owner and ("  [" .. owner .. "]") or ""
        lines[#lines + 1] = {
            kind = "item",
            text = item.name .. "  x" .. item.count .. suffix,
            itemId = item.id,
            quality = item.quality,
            icon = item.icon
        }
    end
end

local function GetCharacterKeys()
    local keys = {}
    for key in pairs(MINE_DB.characters) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(left, right)
        local leftCharacter = MINE_DB.characters[left]
        local rightCharacter = MINE_DB.characters[right]
        return string.lower(leftCharacter.name .. " - " .. leftCharacter.realm)
            < string.lower(rightCharacter.name .. " - " .. rightCharacter.realm)
    end)
    return keys
end

local function GetDisplayLines()
    local lines = {}
    local character = GetCurrentCharacter()
    if activeTab == "character" then
        if character then
            AddInventoryLines(lines, character.items)
        end
    elseif activeTab == "characters" then
        if selectedCharacterKey == "preview" then
            lines[#lines + 1] = { kind = "character", text = "Material Preview - Classic sample data" }
            AddInventoryLines(lines, previewItems)
        else
            local entry = MINE_DB.characters[selectedCharacterKey]
            if entry then
                lines[#lines + 1] = { kind = "character", text = entry.name .. " - " .. entry.realm }
                AddInventoryLines(lines, entry.items)
                AddInventoryLines(lines, entry.bankItems, "Bank")
            end
        end
    elseif activeTab == "account" then
        local totals = {}
        for _, entry in pairs(MINE_DB.characters) do
            local ownerName = entry.name .. " (" .. entry.realm .. ")"
            AddInventoryToTotals(totals, entry.items, ownerName)
            AddInventoryToTotals(totals, entry.bankItems, ownerName .. " bank")
        end
        local guildBank = MINE_DB.guildBank
        if guildBank and guildBank.guildName == currentGuildName then
            AddInventoryToTotals(totals, guildBank.items, "Guild Bank (" .. guildBank.guildName .. ")")
        end
        local items = MakeItemList(totals)
        local previousCategory
        for _, item in ipairs(items) do
            if item.category ~= previousCategory then
                lines[#lines + 1] = { kind = "header", text = item.category }
                previousCategory = item.category
            end
            lines[#lines + 1] = {
                kind = "item",
                text = item.name .. "  x" .. item.count .. "  (" .. table.concat(totals[item.id].owners, ", ") .. ")",
                itemId = item.id,
                quality = item.quality,
                icon = item.icon
            }
        end
    else
        local senders = {}
        for sender in pairs(MINE_DB.shared) do
            senders[#senders + 1] = sender
        end
        table.sort(senders, function(left, right)
            return string.lower(left) < string.lower(right)
        end)
        for _, sender in ipairs(senders) do
            local shared = MINE_DB.shared[sender]
            lines[#lines + 1] = { kind = "character", text = sender }
            AddInventoryLines(lines, shared.items, sender)
        end
    end
    return lines
end

Refresh = function()
    if not MINE_DB or not MINEFrame or not MINEFrame:IsShown() then
        return
    end

    local lines = GetDisplayLines()
    local content = MINEFrame.content
    content:SetHeight(math.max(#lines * rowHeight, 1))
    while #MINEFrame.rows < #lines do
        local index = #MINEFrame.rows + 1
        local row = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 24, -((index - 1) * rowHeight))
        row:SetWidth(480)
        row:SetHeight(rowHeight)
        row:SetJustifyH("LEFT")
        row.icon = content:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(18, 18)
        row.icon:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -((index - 1) * rowHeight) - 1)
        MINEFrame.rows[index] = row
    end
    for index, row in ipairs(MINEFrame.rows) do
        local line = lines[index]
        if line then
            row:SetText(line.text)
            row:SetTextColor(1, 0.82, 0)
            if line.kind == "character" then
                row:SetTextColor(1, 0.82, 0)
            elseif line.kind == "item" then
                local color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[line.quality or 1]
                row:SetTextColor(color and color.r or 1, color and color.g or 1, color and color.b or 1)
                if line.icon then
                    row.icon:SetTexture(line.icon)
                    row.icon:Show()
                else
                    row.icon:Hide()
                end
            else
                row.icon:Hide()
            end
            row.itemId = line.itemId
            row:Show()
        else
            row:Hide()
            row.icon:Hide()
        end
    end
    MINEFrame.emptyText:SetShown(#lines == 0)
    if #lines == 0 then
        MINEFrame.emptyText:SetText(activeTab == "shared"
            and "No shared materials yet. Ask addon users to share."
            or "No crafting materials found.")
    end
end

local function SetTab(tab)
    activeTab = tab
    for name, button in pairs(MINEFrame.tabButtons) do
        if name == tab then
            button:Disable()
        else
            button:Enable()
        end
    end
    if MINEFrame.characterDropdown then
        if tab == "characters" then
            MINEFrame.characterDropdown:Show()
        else
            MINEFrame.characterDropdown:Hide()
        end
    end
    Refresh()
end

local function InitializeCategoryDropdown(dropdown)
    UIDropDownMenu_Initialize(dropdown, function(_, level)
        local function addCategory(category)
            local info = UIDropDownMenu_CreateInfo()
            info.text = category == "All" and "All Categories" or category
            info.value = category
            info.checked = selectedCategory == category
            info.func = function()
                selectedCategory = category
                UIDropDownMenu_SetText(dropdown, info.text)
                Refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
        addCategory("All")
        for _, category in ipairs(categoryOrder) do
            addCategory(category)
        end
    end)
end

local function InitializeCharacterDropdown(dropdown)
    UIDropDownMenu_Initialize(dropdown, function(_, level)
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Material Preview"
        info.value = "preview"
        info.checked = selectedCharacterKey == "preview"
        info.func = function()
            selectedCharacterKey = "preview"
            UIDropDownMenu_SetText(dropdown, "Material Preview")
            Refresh()
        end
        UIDropDownMenu_AddButton(info, level)
        for _, key in ipairs(GetCharacterKeys()) do
            local character = MINE_DB.characters[key]
            local label = character.name .. " - " .. character.realm
            local characterKeyValue = key
            info = UIDropDownMenu_CreateInfo()
            info.text = label
            info.value = characterKeyValue
            info.checked = selectedCharacterKey == characterKeyValue
            info.func = function()
                selectedCharacterKey = characterKeyValue
                UIDropDownMenu_SetText(dropdown, label)
                Refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
end

local function GetShareChannel()
    if IsInRaid and IsInRaid() then
        return "RAID"
    elseif IsInGroup and IsInGroup() then
        return "PARTY"
    elseif IsInGuild and IsInGuild() then
        return "GUILD"
    end
    return nil
end

local function SendSnapshot(immediate)
    local channel = GetShareChannel()
    if not channel then
        if not immediate then
            print("|cffff5555MINE:|r Join a party, raid, or guild to share materials.")
        end
        return
    end
    SaveCurrentCharacter()
    local character = GetCurrentCharacter()
    if not character then
        return
    end

    local entries = {}
    local inventory = {}
    AddInventoryToTotals(inventory, character.items)
    AddInventoryToTotals(inventory, character.bankItems)
    for itemId, item in pairs(inventory) do
        entries[#entries + 1] = tostring(itemId) .. "=" .. tostring(item.count)
    end
    table.sort(entries)
    snapshotSequence = snapshotSequence + 1
    local snapshotId = tostring(math.floor((GetTime and GetTime() or time()) * 1000) % 1000000000)
        .. "-" .. tostring(snapshotSequence)
    local payloads = {}
    local payload = ""
    for _, entry in ipairs(entries) do
        local nextPayload = payload == "" and entry or (payload .. "," .. entry)
        if #nextPayload > 160 then
            payloads[#payloads + 1] = payload
            payload = entry
        else
            payload = nextPayload
        end
    end
    if payload ~= "" or #payloads == 0 then
        payloads[#payloads + 1] = payload
    end
    if #payloads > 100 then
        print("|cffff5555MINE:|r Inventory is too large to share in one snapshot.")
        return
    end
    for index, part in ipairs(payloads) do
        outgoingMessages[#outgoingMessages + 1] = {
            message = "S|" .. snapshotId .. "|" .. index .. "|" .. #payloads .. "|" .. part,
            channel = channel
        }
    end
    if immediate then
        for _, outgoing in ipairs(outgoingMessages) do
            sendAddonMessage(messagePrefix, outgoing.message, outgoing.channel)
        end
        wipe(outgoingMessages)
        sendCooldown = 0
    else
        runtimeFrame:SetScript("OnUpdate", RuntimeUpdate)
    end
    print("|cff66ccffMINE:|r Shared " .. #entries .. " material types with " .. channel .. ".")
end

RuntimeUpdate = function(_, elapsed)
    if bagRefreshDelay then
        bagRefreshDelay = bagRefreshDelay - elapsed
        if bagRefreshDelay <= 0 then
            bagRefreshDelay = nil
            SaveCurrentCharacter()
            if bankOpen then
                SaveBank()
            end
            Refresh()
        end
    end

    if loginShareDelay then
        loginShareDelay = loginShareDelay - elapsed
        if loginShareDelay <= 0 then
            loginShareDelay = nil
            SendSnapshot(false)
        end
    end

    if guildCheckDelay then
        guildCheckDelay = guildCheckDelay - elapsed
        if guildCheckDelay <= 0 then
            guildCheckDelay = nil
            RefreshGuildMembership()
        end
    end

    if guildTabQueryDelay then
        guildTabQueryDelay = guildTabQueryDelay - elapsed
        if guildTabQueryDelay <= 0 then
            local tabCount = GetNumGuildBankTabs and GetNumGuildBankTabs() or 0
            if queuedGuildTab and queuedGuildTab <= tabCount and GetGuildBankTabInfo then
                local _, _, isViewable = GetGuildBankTabInfo(queuedGuildTab)
                if isViewable ~= false and QueryGuildBankTab then
                    QueryGuildBankTab(queuedGuildTab)
                end
                queuedGuildTab = queuedGuildTab + 1
                guildTabQueryDelay = 0.4
            else
                queuedGuildTab = nil
                guildTabQueryDelay = nil
                guildBankRefreshDelay = 0.5
            end
        end
    end

    if guildBankRefreshDelay then
        guildBankRefreshDelay = guildBankRefreshDelay - elapsed
        if guildBankRefreshDelay <= 0 then
            guildBankRefreshDelay = nil
            ScanGuildBank()
            Refresh()
        end
    end

    if #outgoingMessages > 0 then
        sendCooldown = sendCooldown - elapsed
        if sendCooldown <= 0 then
            local outgoing = table.remove(outgoingMessages, 1)
            sendAddonMessage(messagePrefix, outgoing.message, outgoing.channel)
            sendCooldown = 0.15
        end
    end

    if not bagRefreshDelay and not loginShareDelay and not guildCheckDelay
        and not guildTabQueryDelay and not guildBankRefreshDelay and #outgoingMessages == 0 then
        sendCooldown = 0
        runtimeFrame:SetScript("OnUpdate", nil)
    end
end

local function HandleAddonMessage(message, sender)
    if not message or not sender then
        return
    end
    local snapshotId, indexText, totalText, payload = message:match("^S|([^|]+)|(%d+)|(%d+)|(.*)$")
    if not snapshotId then
        return
    end
    local index = tonumber(indexText)
    local total = tonumber(totalText)
    if not index or not total or total < 1 or total > 100 or index < 1 or index > total then
        return
    end

    local key = sender .. "|" .. snapshotId
    local currentTime = time()
    for transferKey, pending in pairs(incomingTransfers) do
        if currentTime - pending.created > 120 then
            incomingTransfers[transferKey] = nil
        end
    end
    local transfer = incomingTransfers[key]
    if not transfer then
        transfer = { parts = {}, total = total, received = 0, created = currentTime }
        incomingTransfers[key] = transfer
    end
    if transfer.total ~= total then
        incomingTransfers[key] = nil
        return
    end
    if not transfer.parts[index] then
        transfer.parts[index] = payload
        transfer.received = transfer.received + 1
    end
    if transfer.received ~= transfer.total then
        return
    end

    local items = {}
    local allItems = table.concat(transfer.parts)
    for pair in allItems:gmatch("[^,]+") do
        local itemId, count = pair:match("^(%d+)=(%d+)$")
        if itemId and count then
            items[tonumber(itemId)] = {
                name = "Item " .. itemId,
                count = tonumber(count),
                category = "Other",
                level = 0
            }
            UpdateItemMetadata(tonumber(itemId), items[tonumber(itemId)])
        end
    end
    MINE_DB.shared[sender] = { items = items, lastUpdate = time() }
    incomingTransfers[key] = nil
    Refresh()
end

local function CreateWindow()
    if MINEFrame then
        return
    end

    local frame = CreateFrame("Frame", "MINEFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(560, 520)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -6)
    frame.title:SetText("MINE - Materials In Everyone's Inventory")

    frame.tabButtons = {}
    local tabs = {
        { key = "character", text = "Character", x = 12 },
        { key = "characters", text = "Characters", x = 100 },
        { key = "account", text = "Account", x = 188 },
        { key = "shared", text = "Shared", x = 276 }
    }
    for _, tab in ipairs(tabs) do
        local tabKey = tab.key
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetSize(82, 22)
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", tab.x, -30)
        button:SetText(tab.text)
        button:SetScript("OnClick", function()
            SetTab(tabKey)
        end)
        frame.tabButtons[tab.key] = button
    end

    local shareButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    shareButton:SetSize(92, 22)
    shareButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -30)
    shareButton:SetText("Share")
    shareButton:SetScript("OnClick", function()
        SendSnapshot(false)
    end)

    frame.categoryDropdown = CreateFrame("Frame", "MINECategoryDropdown", frame, "UIDropDownMenuTemplate")
    frame.categoryDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -58)
    UIDropDownMenu_SetWidth(frame.categoryDropdown, 155)
    UIDropDownMenu_SetText(frame.categoryDropdown, "All Categories")
    InitializeCategoryDropdown(frame.categoryDropdown)

    frame.characterDropdown = CreateFrame("Frame", "MINECharacterDropdown", frame, "UIDropDownMenuTemplate")
    frame.characterDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 210, -58)
    UIDropDownMenu_SetWidth(frame.characterDropdown, 250)
    UIDropDownMenu_SetText(frame.characterDropdown, "Material Preview")
    InitializeCharacterDropdown(frame.characterDropdown)
    frame.characterDropdown:Hide()

    local scroll = CreateFrame("ScrollFrame", nil, frame)
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -92)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 12)
    scroll:EnableMouseWheel(true)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(508)
    content:SetHeight(1)
    scroll:SetScrollChild(content)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local maxScroll = math.max(content:GetHeight() - self:GetHeight(), 0)
        self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScroll() - delta * 44, maxScroll)))
    end)

    frame.content = content
    frame.rows = {}
    for index = 1, 120 do
        local row = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -((index - 1) * rowHeight))
        row:SetWidth(460)
        row:SetHeight(rowHeight)
        row:SetJustifyH("LEFT")
        frame.rows[index] = row
    end

    frame.emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    frame.emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 2, 0)
    frame.emptyText:SetText("No crafting materials found.")
    frame.emptyText:Hide()
    frame:SetScript("OnShow", Refresh)
    MINEFrame = frame
    SetTab(activeTab)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_LOGOUT")
events:RegisterEvent("BAG_UPDATE")
events:RegisterEvent("BANKFRAME_OPENED")
events:RegisterEvent("BANKFRAME_CLOSED")
events:RegisterEvent("GUILDBANKFRAME_OPENED")
events:RegisterEvent("GUILDBANKFRAME_CLOSED")
events:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
events:RegisterEvent("GUILDBANK_UPDATE_TABS")
events:RegisterEvent("PLAYER_GUILD_UPDATE")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:RegisterEvent("CHAT_MSG_ADDON")
events:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        local realm = GetRealmName() or "Unknown"
        local name = UnitName("player") or "Unknown"
        characterKey = realm .. "|" .. name
        MINE_DB = MINE_DB or {}
        MINE_DB.characters = MINE_DB.characters or {}
        MINE_DB.shared = MINE_DB.shared or {}
        currentGuildName = GetCurrentGuildName()
        MINE_DB.characters[characterKey] = MINE_DB.characters[characterKey] or {
            name = name,
            realm = realm,
            items = {},
            bankItems = {}
        }
        local character = MINE_DB.characters[characterKey]
        character.name = name
        character.realm = realm
        registerAddonMessagePrefix(messagePrefix)
        CreateWindow()
        SaveCurrentCharacter()
        guildCheckDelay = 5
        runtimeFrame:SetScript("OnUpdate", RuntimeUpdate)
        Refresh()
    elseif event == "BAG_UPDATE" then
        bagRefreshDelay = 0.1
        runtimeFrame:SetScript("OnUpdate", RuntimeUpdate)
    elseif event == "BANKFRAME_OPENED" then
        bankOpen = true
        SaveBank()
        Refresh()
    elseif event == "BANKFRAME_CLOSED" then
        bankOpen = false
    elseif event == "GUILDBANKFRAME_OPENED" then
        RefreshGuildMembership()
        guildBankOpen = currentGuildName ~= nil
        if guildBankOpen then
            MINE_DB.guildBank = MINE_DB.guildBank or { guildName = currentGuildName, items = {} }
            MINE_DB.guildBank.guildName = currentGuildName
            queuedGuildTab = 1
            guildTabQueryDelay = 0
            guildBankRefreshDelay = 0.5
            runtimeFrame:SetScript("OnUpdate", RuntimeUpdate)
        end
        Refresh()
    elseif event == "GUILDBANKFRAME_CLOSED" then
        guildBankOpen = false
        queuedGuildTab = nil
        guildTabQueryDelay = nil
    elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
        guildBankRefreshDelay = 0.2
        runtimeFrame:SetScript("OnUpdate", RuntimeUpdate)
    elseif event == "GUILDBANK_UPDATE_TABS" then
        if guildBankOpen then
            queuedGuildTab = 1
            guildTabQueryDelay = 0
            runtimeFrame:SetScript("OnUpdate", RuntimeUpdate)
        end
    elseif event == "PLAYER_GUILD_UPDATE" then
        local unit = ...
        if unit == "player" then
            guildCheckDelay = 2
            runtimeFrame:SetScript("OnUpdate", RuntimeUpdate)
        end
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        local itemId, success = ...
        if success and itemId then
            requestedItemData[itemId] = nil
            UpdateSharedItemMetadata(itemId)
            UpdateGuildBankItemMetadata(itemId)
            UpdateCharacterItemMetadata(itemId)
        end
        bagRefreshDelay = 0.1
        if guildBankOpen then
            guildBankRefreshDelay = 0.1
        end
        runtimeFrame:SetScript("OnUpdate", RuntimeUpdate)
    elseif event == "PLAYER_ENTERING_WORLD" then
        loginShareDelay = 4
        guildCheckDelay = 5
        runtimeFrame:SetScript("OnUpdate", RuntimeUpdate)
    elseif event == "PLAYER_LOGOUT" then
        SaveCurrentCharacter()
        SendSnapshot(true)
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, _, sender = ...
        if prefix == messagePrefix then
            HandleAddonMessage(message, sender)
        end
    end
end)

SLASH_MINE1 = "/mine"
SlashCmdList.MINE = function()
    if not MINEFrame then
        CreateWindow()
    end
    if MINEFrame:IsShown() then
        MINEFrame:Hide()
    else
        SaveCurrentCharacter()
        Refresh()
        MINEFrame:Show()
    end
end
