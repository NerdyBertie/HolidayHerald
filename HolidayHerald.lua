-- Holiday Herald
-- Reads the in-game calendar and shows a themed popup of current and upcoming
-- holidays, what you can still collect, tips, and secrets.

local ADDON, HH = ...
HH.Holidays = HH.Holidays or {}

---------------------------------------------------------------------------
-- Settings and constants
---------------------------------------------------------------------------
local DB_DEFAULTS = {
    showPopup    = true,   -- full popup once per character per holiday
    lookahead    = 7,      -- days ahead to list holidays
    alertDays    = 0,      -- short-holiday alert: 0 = day of only
    alertMessage = true,
    alertSound   = true,
    toast        = true,
    fanfare      = true,
    showMeta     = true,
    showTips     = true,
    showClass    = true,
    showSecrets  = true,
    showThemes   = true,
    showWeekly   = true,
    microChat    = true,
    showMinimap  = true,
}
local FANFARE_SOUND_ID     = 888    -- level-up fanfare (VERIFY sound choice)
local BIG_FANFARE_SOUND_ID = 888    -- for the Violet Proto-Drake (VERIFY sound choice)
local SHORT_HOLIDAY_HOURS = 72
local ALERT_SOUND_ID      = 8959       -- raid warning
local POPUP_WIDTH         = 400
local GRAY                = "8A8477"
local SOFT                = "B7AE9C"

local DEFAULT_COLORS = { main = "E3C27A", accent = "B7AE9C", card = "1C1915" }
local WEEKLY_PATTERNS = { "brawl", "bonus event", "timewalking" }
local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

local ICONS = {
    meta     = "Interface\\Icons\\Achievement_General",
    boss     = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull",
    collect  = "Interface\\Icons\\INV_Misc_Coin_01",
    tip      = "Interface\\Icons\\INV_Misc_Note_01",
    secret   = "Interface\\Icons\\INV_Misc_QuestionMark",
    HUNTER   = "Interface\\Icons\\ClassIcon_Hunter",
    fallback = "Interface\\Icons\\INV_Misc_QuestionMark",
    mascot   = "Interface\\AddOns\\HolidayHerald\\Media\\mascot",
}

local simulateOwned = false   -- preview "done" mode
local lastItems = nil         -- what the popup is currently showing

---------------------------------------------------------------------------
-- Small helpers
---------------------------------------------------------------------------
local function Hex(h)
    return tonumber(h:sub(1, 2), 16) / 255, tonumber(h:sub(3, 4), 16) / 255, tonumber(h:sub(5, 6), 16) / 255
end

-- Same hue, darker: used for the raised "3D" shadow behind titles
local function DarkHex(h, factor)
    local r, g, b = Hex(h)
    factor = factor or 0.35
    return r * factor, g * factor, b * factor
end

local function Color(hex, text)
    return "|cff" .. hex .. text .. "|r"
end

local function Print(msg)
    print(Color(DEFAULT_COLORS.main, "Holiday Herald:") .. " " .. msg)
end

local function FormatDate(t)
    if not t or not t.month then return nil end
    return MONTHS[t.month] .. " " .. t.monthDay
end

local function ToEpoch(t)
    if not t or not t.year then return nil end
    return time({ year = t.year, month = t.month, day = t.monthDay,
                  hour = t.hour or 0, min = t.minute or 0 })
end

local function ItemName(entry)
    if entry.name then return entry.name end
    local name = entry.item and C_Item.GetItemNameByID(entry.item)
    return name or ("Item " .. tostring(entry.item))
end

local function AchievementName(id)
    local _, name = GetAchievementInfo(id)
    return name or ("Achievement " .. tostring(id))
end

local function AchievementDone(id)
    if simulateOwned then return true end
    if not id then return false end
    local _, _, _, completed = GetAchievementInfo(id)
    return completed and true or false
end

local function OpenAchievement(id)
    local ok, err = pcall(function()
        if C_AddOns and C_AddOns.LoadAddOn and not (C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_AchievementUI")) then
            C_AddOns.LoadAddOn("Blizzard_AchievementUI")
        end
        if OpenAchievementFrameToAchievement then
            OpenAchievementFrameToAchievement(id)
        elseif AchievementFrame and AchievementFrame_SelectAchievement then
            ShowUIPanel(AchievementFrame)
            AchievementFrame_SelectAchievement(id)
        else
            error("no way to open the achievement window was found")
        end
    end)
    if not ok then
        print("|cffE3C27AHoliday Herald:|r couldn't open the achievement (" .. tostring(err) .. ")")
    end
end

local function LinkAchievement(id)
    local link = GetAchievementLink(id)
    if not link then return end
    -- Paste into an open chat box, or open one if none is active
    if not ChatEdit_InsertLink(link) then
        ChatFrame_OpenChat(link)
    end
end

-- Finds an achievement category by its name (like "Darkmoon Faire")
-- and returns the first achievement in it, so the window opens on that list.
local function FirstAchievementInCategory(categoryName)
    for _, categoryID in ipairs(GetCategoryList() or {}) do
        local title = GetCategoryInfo(categoryID)
        if title == categoryName then
            local achievementID = GetAchievementInfo(categoryID, 1)
            return achievementID
        end
    end
end

local function OpenDungeonFinder()
    if PVEFrame_ShowFrame then
        pcall(PVEFrame_ShowFrame, "GroupFinderFrame", LFDParentFrame)
    end
end

---------------------------------------------------------------------------
-- Collection checks
-- Returns true (owned), false (not owned), or nil (can't check / not loaded).
---------------------------------------------------------------------------
local function PetInfo(entry)
    local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(entry.item))
    if not speciesID then return nil end
    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
    return numCollected or 0, limit or 3
end

local function IsOwned(entry)
    if simulateOwned and entry.item and entry.kind ~= "decor" and entry.kind ~= "reminder" then
        return true
    end
    if entry.reminderOnly or not entry.item then return nil end

    local kind = entry.kind
    if kind == "toy" then
        return PlayerHasToy(entry.item) and true or false
    elseif kind == "mount" then
        local mountID = C_MountJournal.GetMountFromItem(entry.item)
        if not mountID then return nil end
        local isCollected = select(11, C_MountJournal.GetMountInfoByID(mountID))
        return isCollected and true or false
    elseif kind == "pet" then
        local owned = PetInfo(entry)
        if owned == nil then return nil end
        return owned > 0
    elseif kind == "transmog" then
        if C_TransmogCollection and C_TransmogCollection.PlayerHasTransmog then
            return C_TransmogCollection.PlayerHasTransmog(entry.item) and true or false
        end
    end
    return nil
end

local CHECKABLE = { toy = true, mount = true, pet = true, transmog = true }
local pendingData = false     -- set when something checkable hasn't loaded yet

-- Returns: owned, total checkable, reminders (can never be checked)
-- Checkable items that haven't loaded yet count as not owned for now,
-- and trigger a redraw once their data arrives.
local function CountOwned(list)
    local owned, total, reminders = 0, 0, 0
    for _, entry in ipairs(list) do
        if entry.item and CHECKABLE[entry.kind] and not entry.reminderOnly then
            total = total + 1
            local state = IsOwned(entry)
            if state == true then
                owned = owned + 1
            elseif state == nil then
                pendingData = true
            end
        else
            reminders = reminders + 1
        end
    end
    return owned, total, reminders
end

local function RequestItems(list)
    if not (C_Item and C_Item.RequestLoadItemDataByID) then return end
    for _, entry in ipairs(list or {}) do
        if entry.item then C_Item.RequestLoadItemDataByID(entry.item) end
    end
end

---------------------------------------------------------------------------
-- Data prep: normalize lists so every entry is a table with a kind
---------------------------------------------------------------------------
local LIST_KINDS = { toys = "toy", pets = "pet", transmog = "transmog", decor = "decor", reminders = "reminder" }

local function Normalize(list, kind)
    local out = {}
    for _, entry in ipairs(list or {}) do
        if type(entry) == "number" then
            out[#out + 1] = { item = entry, kind = kind }
        else
            entry.kind = entry.kind or kind
            out[#out + 1] = entry
        end
    end
    return out
end

local function PrepareData()
    for key, data in pairs(HH.Holidays) do
        data.key = key
        for field, kind in pairs(LIST_KINDS) do
            if data[field] then data[field] = Normalize(data[field], kind) end
        end
        if data.boss then
            data.boss.drops = Normalize(data.boss.drops, "transmog")
            for _, drop in ipairs(data.boss.drops) do
                if drop.kind == "drake" or drop.kind == "ensemble" then drop.reminderOnly = true end
            end
        end
    end
end

local function RequestAllItems()
    for _, data in pairs(HH.Holidays) do
        for field in pairs(LIST_KINDS) do RequestItems(data[field]) end
        if data.boss then RequestItems(data.boss.drops) end
    end
end

local function FindData(title)
    local lower = title:lower()
    for _, data in pairs(HH.Holidays) do
        if data.match and lower:find(data.match, 1, true) then return data end
    end
end

local function IsWeekly(title)
    local lower = title:lower()
    for _, pattern in ipairs(WEEKLY_PATTERNS) do
        if lower:find(pattern, 1, true) then return true end
    end
    return false
end

---------------------------------------------------------------------------
-- Calendar scan
---------------------------------------------------------------------------
local function ScanCalendar()
    local today = C_DateAndTime.GetCurrentCalendarTime()
    C_Calendar.SetAbsMonth(today.month, today.year)

    local seen, items = {}, {}
    for dayOffset = 0, HolidayHeraldDB.lookahead do
        local d = C_DateAndTime.AdjustTimeByDays(today, dayOffset)
        local monthOffset = (d.year - today.year) * 12 + (d.month - today.month)

        for i = 1, C_Calendar.GetNumDayEvents(monthOffset, d.monthDay) do
            local ev = C_Calendar.GetDayEvent(monthOffset, d.monthDay, i)
            if ev and ev.calendarType == "HOLIDAY" and ev.title and not seen[ev.title] then
                seen[ev.title] = true
                local data = FindData(ev.title)
                local s, e = ToEpoch(ev.startTime), ToEpoch(ev.endTime)
                local isShort = (data and data.short) or (s and e and (e - s) <= SHORT_HOLIDAY_HOURS * 3600) or false
                local startKey = ev.startTime and ("%d-%d-%d"):format(ev.startTime.year, ev.startTime.month, ev.startTime.monthDay) or "?"

                items[#items + 1] = {
                    title    = ev.title,
                    data     = data,
                    category = data and "holiday" or (IsWeekly(ev.title) and "weekly" or "micro"),
                    daysAway = dayOffset,
                    endTime  = ev.endTime,
                    icon     = ev.iconTexture,
                    isShort  = isShort,
                    key      = ev.title .. "@" .. startKey,
                }
            end
        end
    end
    return items
end

---------------------------------------------------------------------------
-- Tooltip builders
---------------------------------------------------------------------------
-- body can be a plain string, or a list of lines:
--   "text"            a wrapped line
--   "#Heading"        a heading in the holiday's accent color
--   " "               a blank spacer line
--   { "left", "right" } a two-column line
local function TextTooltip(title, colors, body)
    return function(tt)
        tt:AddLine(title, Hex(colors.main))
        if type(body) ~= "table" then
            tt:AddLine(body, 1, 1, 1, true)
            return
        end
        for _, line in ipairs(body) do
            if type(line) == "table" then
                tt:AddDoubleLine(line[1], line[2], 1, 1, 1, 0.72, 0.68, 0.61)
            elseif line:sub(1, 1) == "#" then
                tt:AddLine(line:sub(2), Hex(colors.accent))
            else
                tt:AddLine(line, 1, 1, 1, true)
            end
        end
    end
end

local function ListTooltip(title, list, colors, notes)
    return function(tt)
        tt:AddLine(title, Hex(colors.main))
        for _, entry in ipairs(list) do
            local name = ItemName(entry)
            local state = IsOwned(entry)
            if entry.kind == "pet" and entry.item and not simulateOwned then
                local owned, limit = PetInfo(entry)
                if owned then name = ("%s (%d/%d)"):format(name, owned, limit) end
            end

            if state == true then
                tt:AddDoubleLine(name, "collected", 0.55, 0.52, 0.47, 0.55, 0.52, 0.47)
            elseif state == nil then
                tt:AddDoubleLine(name, entry.cost or entry.where or "can't check yet", 1, 0.82, 0, 0.72, 0.68, 0.61)
            elseif entry.requires and not AchievementDone(entry.requires) then
                tt:AddDoubleLine(name, "requires " .. AchievementName(entry.requires), 0.76, 0.55, 1, 1, 0.33, 0.33)
            else
                tt:AddDoubleLine(name, entry.cost or "", 0.76, 0.55, 1, 0.72, 0.68, 0.61)
            end
            if entry.where and state ~= true then
                tt:AddLine("   " .. entry.where, 0.72, 0.68, 0.61, true)
            end
            if entry.note then
                tt:AddLine("   " .. entry.note, 0.72, 0.68, 0.61, true)
            end
        end
        for _, note in ipairs(notes or {}) do
            tt:AddLine(" ")
            tt:AddLine(note, 0.72, 0.68, 0.61, true)
        end
    end
end

---------------------------------------------------------------------------
-- Line builders for one holiday card
---------------------------------------------------------------------------
local COUNT_LABELS = {
    toys      = { label = "Toys",          noun = "collected",   one = "collected" },
    pets      = { label = "Pets",          noun = "collected",   one = "collected" },
    transmog  = { label = "Transmog",      noun = "appearances", one = "appearance" },
    decor     = { label = "Housing decor", noun = "pieces",      one = "piece" },
    reminders = { label = "Also on sale",  noun = "items",       one = "item" },
}
local COUNT_ORDER = { "reminders", "toys", "pets", "transmog", "decor" }

local function CountLine(holidayName, field, list, colors)
    local info = COUNT_LABELS[field]
    local owned, total, reminders = CountOwned(list)
    local text, done

    if total == 0 then
        text = ("%s: %d %s"):format(info.label, reminders, reminders == 1 and info.one or info.noun)
        done = false
    else
        text = ("%s: %d of %d %s"):format(info.label, owned, total, total == 1 and info.one or info.noun)
        done = (owned == total and reminders == 0)
    end
    text = text .. Color(GRAY, " (hover to see)")
    if done then text = Color(GRAY, text) end

    return {
        icon = ICONS.collect,
        text = text,
        tooltip = ListTooltip(holidayName .. " " .. info.label:lower(), list, colors),
    }, done
end

local function BuildLines(item)
    local data = item.data
    local colors = (HolidayHeraldDB.showThemes and data.colors) or DEFAULT_COLORS
    local name = data.name or item.title
    local specs = {}
    local allDone = true
    local hasGoals = false

    -- Meta achievement line
    if HolidayHeraldDB.showMeta and data.meta and data.meta.holidayMeta then
        local metaID, tripID = data.meta.holidayMeta, data.meta.strangeTrip
        hasGoals = true
        local done = AchievementDone(metaID)
        local text
        if done then
            text = Color(GRAY, "Counts toward the Violet Proto-Drake meta. All done! Grats!")
        else
            allDone = false
            text = "Counts toward " .. Color(colors.accent, AchievementName(tripID or 2144))
                .. ". See what you still need: " .. Color(colors.main, AchievementName(metaID))
        end
        specs[#specs + 1] = {
            icon = ICONS.meta,
            text = text,
            tooltip = function(tt)
                tt:AddLine(AchievementName(metaID), Hex(colors.main))
                tt:AddLine("Click: open this holiday's meta achievement", 1, 1, 1)
                if tripID then tt:AddLine("Ctrl-click: open " .. AchievementName(tripID), 1, 1, 1) end
                tt:AddLine("Shift-click: link it in chat", 1, 1, 1)
            end,
            onClick = function()
                if IsShiftKeyDown() then LinkAchievement(metaID)
                elseif IsControlKeyDown() and tripID then OpenAchievement(tripID)
                else OpenAchievement(metaID) end
            end,
        }
    end

    -- Browse a whole achievement category (for holidays without a meta)
    if data.achievementCategory then
        specs[#specs + 1] = {
            icon = ICONS.meta,
            text = data.achievementCategory .. " achievements" .. Color(GRAY, " (click to browse)"),
            tooltip = function(tt)
                tt:AddLine(data.achievementCategory .. " achievements", Hex(colors.main))
                tt:AddLine("Click to open the achievement window on this holiday's list.", 1, 1, 1, true)
            end,
            onClick = function()
                local first = FirstAchievementInCategory(data.achievementCategory)
                if first then
                    OpenAchievement(first)
                else
                    Print("couldn't find the " .. data.achievementCategory .. " achievement list.")
                end
            end,
        }
    end

    -- Holiday boss line
    if data.boss then
        local boss = data.boss
        hasGoals = true
        local owned, total, reminders = CountOwned(boss.drops)
        local done = (total > 0 and owned == total and reminders == 0)
        if not done then allDone = false end

        local status = ""
        if boss.lfg and GetLFGDungeonRewards then
            local doneToday = GetLFGDungeonRewards(boss.lfg)
            local now = GetServerTime()
            if doneToday then
                HolidayHeraldDB.bestRoll[boss.lfg] = now + (C_DateAndTime.GetSecondsUntilDailyReset() or 0)
            end
            local bestUsed = (HolidayHeraldDB.bestRoll[boss.lfg] or 0) > now
            status = "\n" .. Color(SOFT, "Best roll: ")
                .. (bestUsed and Color(GRAY, "used today") or Color(colors.main, "available"))
                .. Color(SOFT, "  ·  This character: ")
                .. (doneToday and Color(GRAY, "done today") or Color(colors.main, "not done today"))
        end

        local text = ("%s: %d of %d collectibles"):format(boss.name, owned, total)
            .. Color(GRAY, " (hover to see drops)")
        if done then text = Color(GRAY, text) end

        local notes = {
            "Your first boss kill of the day, across your whole account, gets the best mount chance. "
                .. "Each alt can still try once a day at a much lower chance.",
        }
        if boss.hardMode then notes[#notes + 1] = "Hard mode: " .. boss.hardMode end
        notes[#notes + 1] = "Click to open the Dungeon Finder."

        specs[#specs + 1] = {
            icon = ICONS.boss,
            text = text .. status,
            tooltip = ListTooltip(boss.name .. " drops", boss.drops, colors, notes),
            onClick = OpenDungeonFinder,
        }
    end

    -- Collection count lines
    for _, field in ipairs(COUNT_ORDER) do
        if data[field] and #data[field] > 0 then
            local spec, done = CountLine(name, field, data[field], colors)
            hasGoals = true
            if not done then allDone = false end
            specs[#specs + 1] = spec
        end
    end

    -- Everything finished: collapse to one calm line
    if allDone and hasGoals then
        return { { text = Color(GRAY, "Everything here is collected. All done! Grats!") } }
    end

    -- Tip
    if HolidayHeraldDB.showTips and data.tip then
        local text = data.tip.short
        if data.tip.hover then text = text .. Color(GRAY, " (hover for more)") end
        specs[#specs + 1] = {
            icon = ICONS.tip,
            text = Color("C9C1B1", text),
            tooltip = data.tip.hover and TextTooltip(name .. " tip", colors, data.tip.hover),
        }
    end

    -- Class lines (shown to everyone with a label)
    for _, cl in ipairs(HolidayHeraldDB.showClass and data.classLines or {}) do
        specs[#specs + 1] = {
            icon = ICONS[cl.class] or ICONS.tip,
            text = cl.short .. (cl.hover and Color(GRAY, " (hover for more)") or ""),
            tooltip = cl.hover and TextTooltip(cl.short, colors, cl.hover),
        }
    end

    -- Secrets (spoilers: teaser only, reveal on hover)
    for _, secret in ipairs(HolidayHeraldDB.showSecrets and data.secrets or {}) do
        specs[#specs + 1] = {
            icon = ICONS.secret,
            text = Color("C9C1B1", secret.teaser) .. Color(GRAY, " (hover to reveal)"),
            tooltip = TextTooltip("Secret!", colors, secret.reveal),
        }
    end

    return specs
end

---------------------------------------------------------------------------
-- Popup frame
---------------------------------------------------------------------------
local popup = CreateFrame("Frame", "HolidayHeraldFrame", UIParent, "BackdropTemplate")
popup:SetWidth(POPUP_WIDTH)
popup:SetPoint("CENTER", 0, 150)
popup:SetFrameStrata("DIALOG")
popup:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
popup:SetMovable(true)
popup:EnableMouse(true)
popup:RegisterForDrag("LeftButton")
popup:SetScript("OnDragStart", popup.StartMoving)
popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
popup:Hide()
tinsert(UISpecialFrames, "HolidayHeraldFrame")

local popupTitle = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
popupTitle:SetPoint("TOP", 0, -18)
popupTitle:SetText("Holiday Herald")

local closeButton = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -6, -6)

-- Pools of reusable pieces
local linePool, headerPool, cardPool = {}, {}, {}
local lineCount, headerCount, cardCount = 0, 0, 0

local function ReleaseAll()
    for i = 1, lineCount do linePool[i]:Hide() end
    for i = 1, headerCount do headerPool[i].text:Hide(); headerPool[i].rule:Hide() end
    for i = 1, cardCount do cardPool[i]:Hide() end
    lineCount, headerCount, cardCount = 0, 0, 0
end

local function NewLine()
    local b = CreateFrame("Button", nil, popup)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(14, 14)
    b.icon:SetPoint("TOPLEFT", 0, -1)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    b.text:SetPoint("TOPLEFT", 20, 0)
    b.text:SetJustifyH("LEFT")
    b.text:SetSpacing(2)
    b:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
    b:SetScript("OnEnter", function(self)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            self.tooltip(GameTooltip)
            GameTooltip:Show()
        end
    end)
    b:SetScript("OnLeave", GameTooltip_Hide)
    b:SetScript("OnClick", function(self, button, down)
        if down then return end          -- act once, on release
        if self.onClick then self.onClick(self, button) end
    end)
    return b
end

-- Places one line and returns its height
local function PlaceLine(parent, spec, x, y, width)
    lineCount = lineCount + 1
    local b = linePool[lineCount]
    if not b then
        b = NewLine()
        linePool[lineCount] = b
    end
    b:SetParent(parent)
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", x, y)
    b:SetWidth(width)
    b.text:SetWidth(width - 20)
    b.text:SetText(spec.text)
    if spec.icon then
        b.icon:SetTexture(spec.icon)
        b.icon:Show()
    else
        b.icon:Hide()
    end
    b.tooltip = spec.tooltip
    b.onClick = spec.onClick
    local height = math.max(16, b.text:GetStringHeight() + 4)
    b:SetHeight(height)
    b:Show()
    return height
end

local function PlaceHeader(text, y)
    headerCount = headerCount + 1
    local h = headerPool[headerCount]
    if not h then
        h = { text = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal"),
              rule = popup:CreateTexture(nil, "ARTWORK") }
        headerPool[headerCount] = h
    end
    local r, g, b = Hex(DEFAULT_COLORS.main)
    h.text:ClearAllPoints()
    h.text:SetPoint("TOPLEFT", 20, y)
    h.text:SetText(text)
    h.text:SetTextColor(r, g, b)
    h.text:Show()
    h.rule:ClearAllPoints()
    h.rule:SetColorTexture(r, g, b, 0.45)
    h.rule:SetHeight(1)
    h.rule:SetPoint("TOPLEFT", 20, y - 16)
    h.rule:SetPoint("TOPRIGHT", -20, y - 16)
    h.rule:Show()
    return y - 24
end

local function NewCard()
    local c = CreateFrame("Frame", nil, popup, "BackdropTemplate")
    c:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    c.icon = c:CreateTexture(nil, "ARTWORK")
    c.icon:SetSize(28, 28)
    c.icon:SetPoint("TOPLEFT", 10, -10)
    c.title = c:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    c.title:SetPoint("TOPLEFT", 46, -9)
    c.title:SetShadowOffset(1, -1)
    c.title:SetShadowColor(0, 0, 0, 1)
    c.status = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    c.status:SetPoint("TOPLEFT", c.title, "BOTTOMLEFT", 0, -2)
    return c
end

local function StatusText(item)
    if item.preview then
        local when = (item.daysAway == 0) and "as if active today" or ("as if starting in " .. item.daysAway .. " days")
        local text = Color("B48CE0", "Preview") .. Color(SOFT, "  ·  " .. when)
        if item.isShort then text = text .. Color("FF8000", "  (short!)") end
        return text
    end
    local text
    if item.daysAway == 0 then
        text = Color("33FF33", "Now")
        local ends = FormatDate(item.endTime)
        if ends then text = text .. Color(SOFT, "  ·  ends " .. ends) end
    elseif item.daysAway == 1 then
        text = Color("FFD100", "Tomorrow")
    else
        text = Color("FFD100", "In " .. item.daysAway .. " days")
    end
    if item.isShort then text = text .. Color("FF8000", "  (short!)") end
    return text
end

local function PlaceCard(item, y, width)
    cardCount = cardCount + 1
    local c = cardPool[cardCount]
    if not c then
        c = NewCard()
        cardPool[cardCount] = c
    end
    local colors = (HolidayHeraldDB.showThemes and item.data.colors) or DEFAULT_COLORS
    c:ClearAllPoints()
    c:SetPoint("TOPLEFT", 16, y)
    c:SetWidth(width)
    c:SetBackdropColor(Hex(colors.card))
    c:SetBackdropBorderColor(Hex(colors.main))
    c.icon:SetTexture(item.icon or ICONS.fallback)
    c.title:SetText(item.data.name or item.title)
    c.title:SetTextColor(Hex(colors.main))
    c.title:SetShadowColor(DarkHex(colors.main, 0.25))
    c.title:SetShadowOffset(2, -2)
    c.status:SetText(StatusText(item))

    local ly = -46
    for _, spec in ipairs(BuildLines(item)) do
        ly = ly - PlaceLine(c, spec, 12, ly, width - 24) - 3
    end
    c:SetHeight(-ly + 8)
    c:Show()
    return y - c:GetHeight() - 8
end

local QueueRedraw   -- defined below
local retryCount = 0

local function Render(items)
    ReleaseAll()
    lastItems = items
    pendingData = false
    local y = -46
    local width = POPUP_WIDTH - 32

    local holidays, weekly = {}, {}
    for _, item in ipairs(items) do
        if item.category == "holiday" then
            holidays[#holidays + 1] = item
        elseif item.category == "weekly" then
            weekly[#weekly + 1] = item
        end
    end

    if #holidays > 0 then
        y = PlaceHeader("Holidays", y)
        for _, item in ipairs(holidays) do
            y = PlaceCard(item, y, width)
        end
    end

    if #weekly > 0 and HolidayHeraldDB.showWeekly then
        y = PlaceHeader("Weekly Events", y)
        for _, item in ipairs(weekly) do
            local label
            if item.daysAway == 0 then
                local ends = FormatDate(item.endTime)
                label = Color("33FF33", "Now: ") .. Color(SOFT, item.title .. (ends and (" (ends " .. ends .. ")") or ""))
            else
                label = Color("FFD100", "In " .. item.daysAway .. " days: ") .. Color(SOFT, item.title)
            end
            y = y - PlaceLine(popup, { text = label }, 20, y, width - 8) - 2
        end
    end

    if #holidays == 0 and (#weekly == 0 or not HolidayHeraldDB.showWeekly) then
        y = y - PlaceLine(popup, { text = Color(SOFT, "No holidays or events in the next " .. HolidayHeraldDB.lookahead .. " days.") }, 20, y, width - 8)
    end

    popup:SetHeight(-y + 18)

    -- Some collection data wasn't ready; try again shortly (a few times at most)
    if pendingData and retryCount < 5 then
        retryCount = retryCount + 1
        C_Timer.After(1.5, function() QueueRedraw() end)
    elseif not pendingData then
        retryCount = 0
    end
end

local function ShowPopup()
    simulateOwned = false
    retryCount = 0
    Render(ScanCalendar())
    popup:Show()
end

-- Redraw when item data arrives (names, mounts and pets load a moment late)
local redrawPending = false
function QueueRedraw()
    if redrawPending or not popup:IsShown() or not lastItems then return end
    redrawPending = true
    C_Timer.After(0.5, function()
        redrawPending = false
        if popup:IsShown() and lastItems then Render(lastItems) end
    end)
end

---------------------------------------------------------------------------
-- Alerts and chat lines
---------------------------------------------------------------------------
local OPEN_LINK = "|Haddon:HolidayHerald:open|h" .. Color(DEFAULT_COLORS.main, "[Click to open]") .. "|h"

local function ShortAlert(item)
    local name = (item.data and item.data.name) or item.title
    local msg = name .. (item.daysAway == 0 and " is TODAY ONLY!" or (" starts in " .. item.daysAway .. " day(s)!"))
    if item.data then
        local wants = {}
        for _, field in ipairs({ "toys", "reminders" }) do
            for _, entry in ipairs(item.data[field] or {}) do
                local state = IsOwned(entry)
                if state ~= true and not (entry.requires and not AchievementDone(entry.requires)) then
                    wants[#wants + 1] = ItemName(entry)
                end
            end
        end
        if #wants > 0 then msg = msg .. " Don't miss: " .. table.concat(wants, ", ") .. "!" end
    end
    if HolidayHeraldDB.alertMessage then
        RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
    end
    Print(msg)
    if HolidayHeraldDB.alertSound then PlaySound(ALERT_SOUND_ID) end
end

local function HandleLogin()
    local items = ScanCalendar()
    local seen = HolidayHeraldCharDB.seen
    local alerted = HolidayHeraldCharDB.alerted

    -- Full popup the first time this character sees a holiday; chat line after
    local holidays, unseen = {}, false
    for _, item in ipairs(items) do
        if item.category == "holiday" then
            holidays[#holidays + 1] = item
            if not seen[item.key] then unseen = true end
        end
    end
    if unseen and HolidayHeraldDB.showPopup then
        Render(items)
        popup:Show()
        for _, item in ipairs(holidays) do seen[item.key] = true end
    elseif #holidays > 0 then
        for _, item in ipairs(holidays) do seen[item.key] = true end
        local names = {}
        for _, item in ipairs(holidays) do
            names[#names + 1] = (item.data.name or item.title) .. (item.daysAway == 0 and "" or (" in " .. item.daysAway .. " days"))
        end
        Print(table.concat(names, ", ") .. ". " .. OPEN_LINK)
    end

    -- Micro-holidays: one chat line on the day
    for _, item in ipairs(items) do
        if HolidayHeraldDB.microChat and item.category == "micro" and item.daysAway == 0 and not seen[item.key] then
            Print("today's micro-holiday is " .. item.title .. ". " .. OPEN_LINK)
            seen[item.key] = true
        end
    end

    -- Short-holiday alerts
    for _, item in ipairs(items) do
        if item.category == "holiday" and item.isShort and item.daysAway <= HolidayHeraldDB.alertDays then
            local alertKey = item.key .. "#" .. item.daysAway
            if not alerted[alertKey] then
                ShortAlert(item)
                alerted[alertKey] = true
            end
        end
    end
end

hooksecurefunc("SetItemRef", function(link)
    if link == "addon:HolidayHerald:open" then ShowPopup() end
end)

---------------------------------------------------------------------------
-- Preview tools (debug only)
---------------------------------------------------------------------------
local function FindDataByKey(key)
    key = key:lower()
    for k, data in pairs(HH.Holidays) do
        if k:lower() == key then return data end
    end
end

local function Preview(key, mode)
    local data = FindDataByKey(key)
    if not data then
        Print("no holiday called '" .. key .. "'. Try /herald preview list")
        return
    end
    local today = C_DateAndTime.GetCurrentCalendarTime()
    local item = {
        title    = data.name,
        data     = data,
        category = "holiday",
        daysAway = (mode == "soon") and 3 or 0,
        endTime  = C_DateAndTime.AdjustTimeByDays(today, 5),
        isShort  = data.short or false,
        key      = "preview",
        preview  = true,
    }
    simulateOwned = (mode == "done")
    Render({ item })
    popup:Show()
end

---------------------------------------------------------------------------
-- Minimap button and addon compartment
-- Left-click toggles the popup, right-click opens settings.
---------------------------------------------------------------------------
local OpenSettings   -- defined with the settings panel below

local function TogglePopup()
    if popup:IsShown() then popup:Hide() else ShowPopup() end
end

local function HandleIconClick(button)
    if button == "RightButton" then
        if OpenSettings then OpenSettings() end
    else
        TogglePopup()
    end
end

local function AddIconTooltip(tooltip)
    tooltip:AddLine("Holiday Herald", Hex(DEFAULT_COLORS.main))
    tooltip:AddLine("Left-click: show current and upcoming holidays", 0.8, 0.8, 0.8)
    tooltip:AddLine("Right-click: open settings", 0.8, 0.8, 0.8)
end

local function CreateMinimapButton()
    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    local DBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not LDB or not DBIcon then return end

    local dataObject = LDB:NewDataObject("HolidayHerald", {
        type = "launcher",
        icon = "Interface\\AddOns\\HolidayHerald\\Media\\icon",
        OnClick = function(_, button) HandleIconClick(button) end,
        OnTooltipShow = AddIconTooltip,
    })
    HolidayHeraldDB.minimapIcon.hide = not HolidayHeraldDB.showMinimap
    DBIcon:Register("HolidayHerald", dataObject, HolidayHeraldDB.minimapIcon)
end

local function SetMinimapShown(shown)
    local DBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    HolidayHeraldDB.minimapIcon.hide = not shown
    if DBIcon then
        if shown then DBIcon:Show("HolidayHerald") else DBIcon:Hide("HolidayHerald") end
    end
end

-- These must be true globals: the .toc refers to them by name
function HolidayHerald_OnAddonCompartmentClick(_, button)
    HandleIconClick(button)
end

function HolidayHerald_OnAddonCompartmentEnter(_, button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    AddIconTooltip(GameTooltip)
    GameTooltip:Show()
end

function HolidayHerald_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end

---------------------------------------------------------------------------
-- Celebration toast
---------------------------------------------------------------------------
local toast = CreateFrame("Frame", "HolidayHeraldToast", UIParent, "BackdropTemplate")
toast:SetSize(440, 84)
toast:SetPoint("TOP", 0, -140)
toast:SetFrameStrata("HIGH")
toast:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 2 })
toast:Hide()

toast.icon = toast:CreateTexture(nil, "ARTWORK")
toast.icon:SetSize(60, 60)
toast.icon:SetPoint("LEFT", 12, 0)
toast.icon:SetTexture(ICONS.mascot)

-- Two copies of the title, slightly offset in contrasting colors, for a
-- brief eye-popping "3D" look. It's only on screen for a few seconds.
toast.titleBack = toast:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
toast.titleBack:SetPoint("TOPLEFT", 84, -18)
toast.title = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
toast.title:SetPoint("TOPLEFT", toast.titleBack, "TOPLEFT", -2, 2)
toast.subtitle = toast:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
toast.subtitle:SetPoint("TOPLEFT", toast.titleBack, "BOTTOMLEFT", 0, -8)
toast.subtitle:SetWidth(340)
toast.subtitle:SetJustifyH("LEFT")

local function ShowToast(colors, title, subtitle, big)
    if not HolidayHeraldDB.toast then return end
    toast:SetBackdropColor(Hex(colors.card))
    toast:SetBackdropBorderColor(Hex(colors.main))
    toast.title:SetText(title)
    toast.title:SetTextColor(Hex(colors.main))
    toast.titleBack:SetText(title)
    toast.titleBack:SetTextColor(DarkHex(colors.main))
    toast.subtitle:SetText(subtitle)
    toast:SetAlpha(1)
    toast:Show()
    if HolidayHeraldDB.fanfare then
        -- Wait a moment so it doesn't pile on top of the game's own chime
        C_Timer.After(1, function() PlaySound(big and BIG_FANFARE_SOUND_ID or FANFARE_SOUND_ID) end)
    end
    C_Timer.After(big and 8 or 6, function()
        UIFrameFadeOut(toast, 1.5, 1, 0)
        C_Timer.After(1.6, function() toast:Hide() end)
    end)
end

local function CelebrateAchievement(achievementID)
    if achievementID == 2144 then
        ShowToast(DEFAULT_COLORS, "What a Long, Strange Trip!",
            "Every holiday meta done. The Violet Proto-Drake is yours. Grats!", true)
        return
    end
    for _, data in pairs(HH.Holidays) do
        if data.meta and data.meta.holidayMeta == achievementID then
            local colors = (HolidayHeraldDB.showThemes and data.colors) or DEFAULT_COLORS
            ShowToast(colors, "Grats! You did all the things!",
                AchievementName(achievementID) .. " complete. " .. (data.name or "This holiday") .. " is done for the drake.")
            return
        end
    end
end

---------------------------------------------------------------------------
-- Settings panel (Options > AddOns > NerdyBertie > Holiday Herald)
---------------------------------------------------------------------------
local PRESETS = {
    all     = {},
    visuals = { alertSound = false, fanfare = false },
    quiet   = { alertMessage = false, alertSound = false, toast = false, fanfare = false, microChat = false },
}
local settingObjects = {}
local settingsCategory

local function ApplyPreset(name)
    for key, default in pairs(DB_DEFAULTS) do
        if type(default) == "boolean" then
            local value = PRESETS[name][key]
            if value == nil then value = true end
            if settingObjects[key] then
                settingObjects[key]:SetValue(value)
            else
                HolidayHeraldDB[key] = value
            end
        end
    end
end

-- Shared "NerdyBertie" heading: whichever NerdyBertie addon loads first creates it
local function GetBrandCategory()
    if NerdyBertie_SettingsCategory then return NerdyBertie_SettingsCategory end
    local panel = CreateFrame("Frame")
    local mascot = panel:CreateTexture(nil, "ARTWORK")
    mascot:SetSize(64, 64)
    mascot:SetPoint("TOPLEFT", 16, -16)
    mascot:SetTexture(ICONS.mascot)
    local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    heading:SetPoint("LEFT", mascot, "RIGHT", 14, 6)
    heading:SetText("NerdyBertie")
    local blurb = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    blurb:SetPoint("TOPLEFT", mascot, "BOTTOMLEFT", 0, -14)
    blurb:SetWidth(560)
    blurb:SetJustifyH("LEFT")
    blurb:SetText("Addons from the NerdyBertie workshop. Pick one from the list on the left to see its settings.")
    local category = Settings.RegisterCanvasLayoutCategory(panel, "NerdyBertie")
    Settings.RegisterAddOnCategory(category)
    NerdyBertie_SettingsCategory = category
    return category
end

local function BuildSettings()
    local category, layout = Settings.RegisterVerticalLayoutSubcategory(GetBrandCategory(), "Holiday Herald")
    settingsCategory = category
    local CreateDropdown = Settings.CreateDropdown or Settings.CreateDropDown

    local function Checkbox(key, label, tooltip)
        local setting = Settings.RegisterAddOnSetting(category, "HolidayHerald_" .. key, key,
            HolidayHeraldDB, type(DB_DEFAULTS[key]), label, DB_DEFAULTS[key])
        settingObjects[key] = setting
        Settings.CreateCheckbox(category, setting, tooltip)
        return setting
    end
    local function Header(text)
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
    end
    local function Button(label, buttonText, onClick, tooltip)
        layout:AddInitializer(CreateSettingsButtonInitializer(label, buttonText, onClick, tooltip, true))
    end

    Header("Quick presets")
    Button("All on", "Use", function() ApplyPreset("all") end, "Everything on, sounds included.")
    Button("Visuals only", "Use", function() ApplyPreset("visuals") end, "All messages and toasts, no sounds.")
    Button("Quiet", "Use", function() ApplyPreset("quiet") end, "Just the popup and chat lines. No alerts or toasts.")

    Header("Popup")
    Checkbox("showPopup", "Show popup for new holidays",
        "Show the full popup the first time each character sees a holiday. After that, it's a chat line.")
    do
        local setting = Settings.RegisterAddOnSetting(category, "HolidayHerald_lookahead", "lookahead",
            HolidayHeraldDB, "number", "Look ahead (days)", DB_DEFAULTS.lookahead)
        settingObjects.lookahead = setting
        local options = Settings.CreateSliderOptions(1, 14, 1)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
        Settings.CreateSlider(category, setting, options, "How many days ahead to list upcoming holidays.")
    end
    do
        local setting = Checkbox("showMinimap", "Minimap button", "Show the Holiday Herald button on the minimap.")
        local function OnChanged(_, value) SetMinimapShown(value) end
        if setting.SetValueChangedCallback then
            setting:SetValueChangedCallback(OnChanged)
        elseif Settings.SetOnValueChangedCallback then
            Settings.SetOnValueChangedCallback("HolidayHerald_showMinimap", OnChanged)
        end
    end
    Checkbox("showThemes", "Holiday color themes", "Give each holiday card its own colors.")
    Checkbox("showWeekly", "Weekly events", "List brawls, bonus events, and Timewalking under Weekly Events.")

    Header("What the cards show")
    Checkbox("showMeta", "Meta achievement line", "Link to the holiday's part of the Violet Proto-Drake meta.")
    Checkbox("showTips", "Tips", "One helpful tip per holiday, with more on hover.")
    Checkbox("showClass", "Class lines", "Class-specific goodies, like hunter pets, labeled for everyone.")
    Checkbox("showSecrets", "Secrets", "Spoiler teasers that reveal on hover.")

    Header("Alerts")
    do
        local setting = Settings.RegisterAddOnSetting(category, "HolidayHerald_alertDays", "alertDays",
            HolidayHeraldDB, "number", "Short-holiday heads-up", DB_DEFAULTS.alertDays)
        settingObjects.alertDays = setting
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(0, "Day of only")
            container:Add(1, "1 day before")
            container:Add(3, "3 days before")
            container:Add(7, "1 week before")
            return container:GetData()
        end
        CreateDropdown(category, setting, GetOptions,
            "When to fire the loud alert for one- or two-day holidays. The day-of alert always fires too.")
    end
    Checkbox("alertMessage", "On-screen alert", "Show short-holiday alerts in the middle of the screen.")
    Checkbox("alertSound", "Alert sound", "Play a sound with short-holiday alerts.")
    Checkbox("microChat", "Micro-holiday chat lines", "One chat line on the day of each micro-holiday.")

    Header("Celebrations")
    Checkbox("toast", "Celebration toast", "A \"Grats!\" toast when you finish a holiday's meta achievement.")
    Checkbox("fanfare", "Celebration fanfare", "Play a fanfare with the celebration toast.")
end

function HH.BuildSettings()
    if not (Settings and Settings.RegisterVerticalLayoutSubcategory) then return end
    local ok, err = pcall(BuildSettings)
    if not ok then Print("settings panel couldn't be built (" .. tostring(err) .. ")") end
end

function OpenSettings()
    if settingsCategory and Settings.OpenToCategory then
        Settings.OpenToCategory(settingsCategory:GetID())
    end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local events = CreateFrame("Frame")
local loginDone, loginPending = false, false

events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        HolidayHeraldDB = HolidayHeraldDB or {}
        HolidayHeraldDB.bestRoll = HolidayHeraldDB.bestRoll or {}
        HolidayHeraldDB.minimapIcon = HolidayHeraldDB.minimapIcon or {}
        for key, value in pairs(DB_DEFAULTS) do
            if HolidayHeraldDB[key] == nil then HolidayHeraldDB[key] = value end
        end
        HolidayHeraldCharDB = HolidayHeraldCharDB or {}
        HolidayHeraldCharDB.seen    = HolidayHeraldCharDB.seen or {}
        HolidayHeraldCharDB.alerted = HolidayHeraldCharDB.alerted or {}
        PrepareData()
        HH.BuildSettings()

    elseif event == "PLAYER_LOGIN" then
        CreateMinimapButton()
        self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
        self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        self:RegisterEvent("ITEM_DATA_LOAD_RESULT")
        self:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
        self:RegisterEvent("ACHIEVEMENT_EARNED")
        RequestAllItems()
        if RequestLFDPlayerLockInfo then RequestLFDPlayerLockInfo() end
        C_Calendar.OpenCalendar()

    elseif event == "CALENDAR_UPDATE_EVENT_LIST" then
        -- This fires several times in a row; wait for it to settle once
        if loginDone or loginPending then return end
        loginPending = true
        C_Timer.After(2, function()
            loginPending = false
            if not loginDone then
                loginDone = true
                HandleLogin()
            end
        end)

    elseif event == "ACHIEVEMENT_EARNED" then
        CelebrateAchievement(arg1)
        QueueRedraw()

    elseif event == "GET_ITEM_INFO_RECEIVED" or event == "ITEM_DATA_LOAD_RESULT" or event == "LFG_UPDATE_RANDOM_INFO" then
        QueueRedraw()
    end
end)

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
SLASH_HOLIDAYHERALD1 = "/herald"
SlashCmdList.HOLIDAYHERALD = function(msg)
    local cmd, arg1, arg2 = strsplit(" ", (msg or ""):lower())

    if cmd == "" or cmd == nil then
        ShowPopup()
    elseif cmd == "options" or cmd == "settings" or cmd == "config" then
        OpenSettings()
    elseif cmd == "weekly" then
        HolidayHeraldDB.showWeekly = not HolidayHeraldDB.showWeekly
        Print("weekly events " .. (HolidayHeraldDB.showWeekly and "shown." or "hidden."))
    elseif cmd == "debug" then
        HolidayHeraldDB.debug = (arg1 == "on")
        Print("preview commands " .. (HolidayHeraldDB.debug and "unlocked." or "locked."))
    elseif cmd == "preview" or cmd == "alert" or cmd == "reset" or cmd == "toast" then
        if not HolidayHeraldDB.debug then
            Print("type /herald debug on first.")
            return
        end
        if cmd == "reset" then
            wipe(HolidayHeraldCharDB.seen)
            wipe(HolidayHeraldCharDB.alerted)
            Print("this character's seen and alerted lists were cleared.")
        elseif arg1 == "list" or not arg1 then
            local keys = {}
            for key in pairs(HH.Holidays) do keys[#keys + 1] = key:lower() end
            table.sort(keys)
            Print("previews: " .. table.concat(keys, ", ") .. ". Add 'soon' or 'done' to the end.")
        elseif cmd == "preview" then
            Preview(arg1, arg2)
        elseif cmd == "toast" then
            if arg1 == "trip" then
                CelebrateAchievement(2144)
            else
                local data = FindDataByKey(arg1)
                if data and data.meta then CelebrateAchievement(data.meta.holidayMeta)
                else Print("that holiday has no meta achievement. Try brewfest, hallowsend, or trip.") end
            end
        else
            local data = FindDataByKey(arg1)
            if data then ShortAlert({ title = data.name, data = data, daysAway = 0 }) end
        end
    else
        Print("commands: /herald, /herald options, /herald weekly, /herald debug on|off, /herald preview <holiday> [soon|done], /herald alert <holiday>, /herald reset")
    end
end
