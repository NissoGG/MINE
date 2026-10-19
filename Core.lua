local addonName = "MINE"
local materialItems = {}
local rowHeight = 22

local function IsMaterial(itemType)
    if not itemType then
        return false
    end
    local tradeGoodsType = GetItemClassInfo and GetItemClassInfo(7)
    return itemType == tradeGoodsType or itemType == "Trade Goods"
end

local function ScanBags()
    local items = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, (GetContainerNumSlots(bag) or 0) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local itemId = tonumber(link:match("item:(%d+)"))
                local _, count = GetContainerItemInfo(bag, slot)
                local name, _, _, _, _, itemType = GetItemInfo(link)
                if itemId and name and IsMaterial(itemType) then
                    local item = items[itemId]
                    if item then
                        item.count = item.count + (count or 1)
                    else
                        items[itemId] = {
                            name = name,
                            count = count or 1
                        }
                    end
                end
            end
        end
    end
    return items
end

local function GetSortedItems()
    local items = {}
    for itemId, item in pairs(materialItems) do
        items[#items + 1] = {
            id = itemId,
            name = item.name,
            count = item.count
        }
    end
    table.sort(items, function(left, right)
        return string.lower(left.name) < string.lower(right.name)
    end)
    return items
end

local function Refresh()
    materialItems = ScanBags()
    if not MINEFrame or not MINEFrame:IsShown() then
        return
    end

    local items = GetSortedItems()
    local content = MINEFrame.content
    content:SetHeight(math.max(#items * rowHeight, 1))
    for index, row in ipairs(MINEFrame.rows) do
        local item = items[index]
        if item then
            row:SetText(item.name .. "  x" .. item.count)
            row.itemId = item.id
            row:Show()
        else
            row:Hide()
        end
    end
    MINEFrame.emptyText:SetShown(#items == 0)
end

local function CreateWindow()
    if MINEFrame then
        return
    end

    local frame = CreateFrame("Frame", "MINEFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(360, 420)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -6)
    frame.title:SetText("MINE - Materials In Everyone's Inventory")

    local scroll = CreateFrame("ScrollFrame", nil, frame)
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -32)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 12)
    scroll:EnableMouseWheel(true)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(306)
    content:SetHeight(1)
    scroll:SetScrollChild(content)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local maxScroll = math.max(content:GetHeight() - self:GetHeight(), 0)
        self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScroll() - delta * 44, maxScroll)))
    end)

    frame.content = content
    frame.rows = {}
    for index = 1, 160 do
        local row = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -((index - 1) * rowHeight))
        row:SetWidth(300)
        row:SetHeight(rowHeight)
        row:SetJustifyH("LEFT")
        frame.rows[index] = row
    end

    frame.emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    frame.emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 2, 0)
    frame.emptyText:SetText("No crafting materials found in your bags.")
    frame.emptyText:Hide()
    frame:SetScript("OnShow", Refresh)
    MINEFrame = frame
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("BAG_UPDATE")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        CreateWindow()
        Refresh()
    else
        Refresh()
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
        Refresh()
        MINEFrame:Show()
    end
end
