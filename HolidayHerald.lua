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
    alertDays    = 0,      -- short-holiday alert: -1 = off, 0 = day of only, 1/3/7 = start that many days before
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
    achievementToast = true,   -- a small toast for every achievement
    showTradingPost  = true,   -- Trading Post reminder under Weekly Events
    timeDisplay  = "realm",    -- start/end times: "realm", "local", or "both"
    showReset    = true,       -- "Daily reset: ..." line under the holiday cards
    popupOnStart = true,       -- show the popup again on the day a holiday starts
    showPins     = true,       -- HandyNotes map pins (only if HandyNotes is installed)
}
local FANFARE_SOUND_ID     = 888    -- level-up fanfare (VERIFY sound choice)
local BIG_FANFARE_SOUND_ID = 888    -- for the Violet Proto-Drake (VERIFY sound choice)
local SHORT_HOLIDAY_HOURS = 72
local ALERT_SOUND_ID      = 8959       -- raid warning
local START_SOUND_ID      = (SOUNDKIT and SOUNDKIT.ALARM_CLOCK_WARNING_3) or 12889   -- soft calendar chime
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
    teatime  = "Interface\\AddOns\\HolidayHerald\\Media\\teatime",
    tradingPost = "Interface\\Icons\\INV_Misc_Coin_17",
    daily    = "Interface\\GossipFrame\\DailyQuestIcon",
    reset    = "Interface\\Icons\\INV_Misc_PocketWatch_01",
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

-- Colors each letter along a list of color stops (for rainbow or gradient titles)
local function GradientText(text, stops)
    local letters = {}
    for char in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do letters[#letters + 1] = char end
    if #stops < 2 or #letters < 2 then return text end
    local out = {}
    for i, char in ipairs(letters) do
        local pos = (i - 1) / (#letters - 1) * (#stops - 1)
        local a = math.floor(pos) + 1
        local b = math.min(a + 1, #stops)
        local t = pos - (a - 1)
        local r1, g1, b1 = tonumber(stops[a]:sub(1, 2), 16), tonumber(stops[a]:sub(3, 4), 16), tonumber(stops[a]:sub(5, 6), 16)
        local r2, g2, b2 = tonumber(stops[b]:sub(1, 2), 16), tonumber(stops[b]:sub(3, 4), 16), tonumber(stops[b]:sub(5, 6), 16)
        out[#out + 1] = ("|cff%02x%02x%02x%s|r"):format(
            math.floor(r1 + (r2 - r1) * t), math.floor(g1 + (g2 - g1) * t), math.floor(b1 + (b2 - b1) * t), char)
    end
    return table.concat(out)
end

-- Alternates colors letter by letter (spaces don't use up a color), for stripes
local function StripeText(text, stripes)
    local out, index = {}, 0
    for char in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        if char == " " then
            out[#out + 1] = char
        else
            index = index + 1
            out[#out + 1] = "|cff" .. stripes[(index - 1) % #stripes + 1] .. char .. "|r"
        end
    end
    return table.concat(out)
end

local function Color(hex, text)
    return "|cff" .. hex .. text .. "|r"
end

-- Text in a holiday's own title style: its gradient, its stripes, or its main color
local function ThemedText(text, colors)
    colors = colors or DEFAULT_COLORS
    if colors.titleGradient then return GradientText(text, colors.titleGradient) end
    if colors.titleStripes then return StripeText(text, colors.titleStripes) end
    return Color(colors.main, text)
end

-- The chat prefix wears the colors of the next holiday coming up (set after each calendar scan)
local chatTheme = nil

-- With no holiday to borrow colors from, the prefix wears your faction's colors
local FACTION_THEMES = {
    Alliance = { main = "3F8CFF", titleGradient = { "3F8CFF", "A9C8F0", "E3C27A" } },   -- blue -> silver -> gold
    Horde    = { main = "C41E3A", titleGradient = { "C41E3A", "E0566A", "E3A43C" } },   -- crimson -> ember -> gold
    Neutral  = { main = "E3C27A", titleGradient = { "E3C27A", "C41E3A", "3F8CFF" } },   -- gold -> Horde red -> Alliance blue
}

local function FactionTheme()
    if HolidayHeraldDB and not HolidayHeraldDB.showThemes then return nil end
    return FACTION_THEMES[UnitFactionGroup("player") or "Neutral"] or FACTION_THEMES.Neutral
end

local function Print(msg)
    print(ThemedText("Holiday Herald:", chatTheme or FactionTheme()) .. " " .. msg)
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

-- "Oct 10 at 11:59 PM", or "today at 7:00 AM" / "tomorrow at 7:00 AM" when it's that close.
-- t and today are { year, month, monthDay, hour, minute } tables.
local function FormatMoment(t, today)
    local tomorrow = date("*t", time({ year = today.year, month = today.month, day = today.monthDay + 1, hour = 12 }))
    local hour, minute = t.hour or 0, t.minute or 0
    local clock = ("%d:%02d %s"):format((hour % 12 == 0) and 12 or (hour % 12), minute, hour < 12 and "AM" or "PM")
    if t.year == today.year and t.month == today.month and t.monthDay == today.monthDay then
        return "today at " .. clock
    elseif t.year == tomorrow.year and t.month == tomorrow.month and t.monthDay == tomorrow.day then
        return "tomorrow at " .. clock
    end
    return FormatDate(t) .. " at " .. clock
end

-- How far your computer's clock is ahead of the realm's, rounded to 15 minutes
local function LocalOffset()
    local realmNow = ToEpoch(C_DateAndTime.GetCurrentCalendarTime())
    if not realmNow then return 0 end
    return math.floor((time() - realmNow) / 900 + 0.5) * 900
end

-- Calendar times are realm time. Depending on the setting, show them as
-- realm time, your own time, or both
local function FormatEnd(t)
    if not t or not t.month then return nil end
    local realmText = FormatMoment(t, C_DateAndTime.GetCurrentCalendarTime())
    local mode = HolidayHeraldDB.timeDisplay or "realm"
    local offset = LocalOffset()
    if mode == "realm" or offset == 0 then return realmText end

    local lt = date("*t", ToEpoch(t) + offset)
    local now = date("*t")
    local localText = FormatMoment(
        { year = lt.year, month = lt.month, monthDay = lt.day, hour = lt.hour, minute = lt.min },
        { year = now.year, month = now.month, monthDay = now.day })
    if mode == "local" then return localText end

    -- Both: "today at 9:00 PM (11:00 PM your time)", or with the day when it differs:
    -- "today at 11:59 PM (tomorrow at 1:59 AM your time)"
    local sameDay = realmText:match("^(.-) at ") == localText:match("^(.-) at ")
    return realmText .. " (" .. (sameDay and localText:match(" at (.+)$") or localText) .. " your time)"
end

local function ItemName(entry)
    if entry.name then return entry.name end
    if entry.achievement then
        local _, name = GetAchievementInfo(entry.achievement)
        return name or ("Achievement " .. entry.achievement)
    end
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

-- The holiday's own achievement category (like World Events > Hallow's End).
-- Uses the data file's achievementCategory if it has one, otherwise looks for a
-- World Events subcategory whose name matches the holiday ("Feast of Winter Veil"
-- matches "Winter Veil"). Holidays without their own subcategory return nil.
local WORLD_EVENTS = 155
local categoryCache = {}   -- [data] = categoryID or false (the category list doesn't change in a session)
local FindHolidayCategory
local function HolidayCategoryID(data)
    if categoryCache[data] == nil then
        local found = FindHolidayCategory(data)
        -- Only remember "none" once the game has actually loaded its category list
        if found or #(GetCategoryList() or {}) > 0 then categoryCache[data] = found or false end
        return found
    end
    return categoryCache[data] or nil
end
FindHolidayCategory = function(data)
    local best, bestLength
    local holidayName = (data.name or ""):lower()
    for _, categoryID in ipairs(GetCategoryList() or {}) do
        local title, parent = GetCategoryInfo(categoryID)
        if title then
            if data.achievementCategory then
                if title == data.achievementCategory then return categoryID end
            elseif parent == WORLD_EVENTS then
                local lower = title:lower()
                if data.categoryMatch and lower:find(data.categoryMatch, 1, true) then return categoryID end
                if (lower == holidayName or holidayName:find(lower, 1, true))
                        and (not bestLength or #lower > bestLength) then
                    best, bestLength = categoryID, #lower
                end
            end
        end
    end
    return best
end

-- Everything in the holiday's achievement category, plus any extras the data
-- file lists (like Feats of Strength). Read live from the game, so new
-- achievements show up without an update. The meta achievements themselves
-- are left out, since the meta line already covers them.
local function HolidayAchievements(data)
    local category = HolidayCategoryID(data)
    if not category or not GetCategoryNumAchievements then return data.achievements end
    local list, seen = {}, {}
    if data.meta then
        if data.meta.holidayMeta then seen[data.meta.holidayMeta] = true end
        if data.meta.strangeTrip then seen[data.meta.strangeTrip] = true end
    end
    for _, entry in ipairs(data.achievements or {}) do
        list[#list + 1] = entry
        if entry.achievement then seen[entry.achievement] = true end
    end
    for i = 1, (GetCategoryNumAchievements(category)) or 0 do
        local id = GetAchievementInfo(category, i)
        if id and not seen[id] then
            seen[id] = true
            list[#list + 1] = { achievement = id, kind = "achievement" }
        end
    end
    return list
end

-- A clickable item link, even if the item isn't cached yet
local function ItemLink(id, name)
    local _, link = C_Item.GetItemInfo(id)
    return link or ("|cffffffff|Hitem:%d::::::::::::::|h[%s]|h|r"):format(id, name or ("Item " .. id))
end

-- Opens the Dungeon Finder. If a holiday dungeon ID is given and it's open,
-- picks it in the dropdown too, so all that's left is clicking Find Group.
-- (Addons can't queue you, but they can choose what's selected.)
local function OpenDungeonFinder(dungeonID)
    if PVEFrame_ShowFrame then
        pcall(PVEFrame_ShowFrame, "GroupFinderFrame", LFDParentFrame)
    end
    if type(dungeonID) == "number" and LFDQueueFrame_SetType then
        C_Timer.After(0, function()
            pcall(LFDQueueFrame_SetType, dungeonID)
        end)
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

-- Drake manuscripts and ensembles have no "do I have this?" API, but their
-- tooltip says "Already known" once learned, so read that. Returns nil until
-- the item has loaded, so it gets checked again shortly.
local function KnownFromTooltip(itemID)
    if not (C_TooltipInfo and C_TooltipInfo.GetItemByID) then return nil end
    if not C_Item.GetItemInfo(itemID) then
        C_Item.RequestLoadItemDataByID(itemID)
        return nil
    end
    local data = C_TooltipInfo.GetItemByID(itemID)
    if not (data and data.lines) then return nil end
    for _, line in ipairs(data.lines) do
        if line.leftText == ITEM_SPELL_KNOWN then return true end
    end
    return false
end

local function IsOwned(entry)
    if simulateOwned and entry.item and entry.kind ~= "decor" and entry.kind ~= "reminder" then
        return true
    end
    if entry.achievement then return AchievementDone(entry.achievement) end
    if entry.reminderOnly or not entry.item then return nil end

    local kind = entry.kind
    -- Drake armor manuscripts set a hidden, account-wide "unlocked" quest flag
    if entry.unlockQuest then
        return C_QuestLog.IsQuestFlaggedCompleted(entry.unlockQuest) and true or false
    end
    if kind == "drake" or kind == "ensemble" then
        return KnownFromTooltip(entry.item)
    end
    if kind == "decor" then
        -- Recipes for decor say "Already known" once learned
        if entry.recipe then return KnownFromTooltip(entry.item) end
        -- The housing catalog counts what you own: in storage, waiting to be
        -- claimed, and placed. One or more counts as collected (the line
        -- itself stays "N pieces", since decor can be owned many times over).
        local catalog = C_HousingCatalog
        if not (catalog and catalog.GetCatalogEntryInfoByItem) then return nil end
        local ok, info = pcall(catalog.GetCatalogEntryInfoByItem, entry.item, true)
        if not (ok and info) then return nil end
        local total = (info.totalNumStored or 0) + (info.remainingRedeemable or 0) + (info.totalNumPlaced or 0)
        return total > 0
    end
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

local CHECKABLE = { toy = true, mount = true, pet = true, transmog = true, drake = true, ensemble = true }
local pendingData = false     -- set when something checkable hasn't loaded yet

-- Returns: owned, total checkable, reminders (can never be checked)
-- Checkable items that haven't loaded yet count as not owned for now,
-- and trigger a redraw once their data arrives.
-- Entries can be marked faction = "Alliance" or "Horde", and/or
-- races = { "Gnome", ... } (English race names); others are skipped
local function ForMyFaction(entry)
    if entry.faction and entry.faction ~= UnitFactionGroup("player") then
        return false
    end
    if entry.races then
        local _, myRace = UnitRace("player")
        for _, race in ipairs(entry.races) do
            if race == myRace then return true end
        end
        return false
    end
    return true
end

local function CountOwned(list)
    local owned, total, reminders = 0, 0, 0
    for _, entry in ipairs(list) do
        if not ForMyFaction(entry) then
            -- not for this character's faction
        elseif entry.kind == "decor" then
            -- decor ownership can't be read yet, so the line shows "N pieces"
            -- (an achievement-reward piece still shows "collected" in the hover)
            reminders = reminders + 1
        elseif entry.achievement or (entry.item and CHECKABLE[entry.kind] and not entry.reminderOnly) then
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
local LIST_KINDS = { mounts = "mount", toys = "toy", pets = "pet", transmog = "transmog", decor = "decor", reminders = "reminder", achievements = "achievement" }

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
                if (drop.kind == "drake" or drop.kind == "ensemble") and not C_TooltipInfo then drop.reminderOnly = true end
            end
        end
    end
end

local function RequestAllItems()
    for _, data in pairs(HH.Holidays) do
        for field in pairs(LIST_KINDS) do RequestItems(data[field]) end
        if data.boss then RequestItems(data.boss.drops) end
        RequestItems(data.shopping)
        for _, list in ipairs(data.shoppingLists or {}) do RequestItems(list.items) end
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

-- Expansion names to look for in an event's calendar description.
-- Longest names first, so "Wrath of the Lich King" wins over shorter matches.
local EXPANSIONS = {
    "Wrath of the Lich King", "Mists of Pandaria", "Warlords of Draenor",
    "Battle for Azeroth", "The Burning Crusade", "The War Within",
    "Shadowlands", "Dragonflight", "Cataclysm", "Midnight", "Legion",
}

local function HolidayDescription(monthOffset, day, index)
    if not C_Calendar.GetHolidayInfo then return nil end
    local ok, info = pcall(C_Calendar.GetHolidayInfo, monthOffset, day, index)
    if not ok or type(info) ~= "table" then return nil end
    return info.description
end

local function FindExpansion(text)
    if not text then return nil end
    for _, name in ipairs(EXPANSIONS) do
        if text:find(name, 1, true) then return name end
    end
end

---------------------------------------------------------------------------
-- Calendar scan
---------------------------------------------------------------------------
local function ScanCalendar()
    local today = C_DateAndTime.GetCurrentCalendarTime()
    local shown = C_Calendar.GetMonthInfo and C_Calendar.GetMonthInfo(0)
    C_Calendar.SetAbsMonth(today.month, today.year)

    local seen, items = {}, {}
    -- Calendar times are realm (server) time, and so is "today", so this
    -- comparison works no matter what time zone the player is in
    local now = ToEpoch(today)
    for dayOffset = 0, HolidayHeraldDB.lookahead do
        local d = C_DateAndTime.AdjustTimeByDays(today, dayOffset)
        local monthOffset = (d.year - today.year) * 12 + (d.month - today.month)

        for i = 1, C_Calendar.GetNumDayEvents(monthOffset, d.monthDay) do
            local ev = C_Calendar.GetDayEvent(monthOffset, d.monthDay, i)
            -- Skip events that are already over: holidays often end in the morning,
            -- but still show on the calendar for the rest of that day
            local ended = ev and now and ev.endTime and (ToEpoch(ev.endTime) or now + 1) <= now
            if ev and ev.calendarType == "HOLIDAY" and ev.title and not seen[ev.title] and not ended then
                seen[ev.title] = true
                local data = FindData(ev.title)
                local s, e = ToEpoch(ev.startTime), ToEpoch(ev.endTime)
                local isShort = (data and data.short) or (s and e and (e - s) <= SHORT_HOLIDAY_HOURS * 3600) or false
                local startKey = ev.startTime and ("%d-%d-%d"):format(ev.startTime.year, ev.startTime.month, ev.startTime.monthDay) or "?"

                items[#items + 1] = {
                    title    = ev.title,
                    data     = data,
                    category = (data and not data.micro) and "holiday" or (IsWeekly(ev.title) and "weekly" or "micro"),
                    daysAway = dayOffset,
                    endTime  = ev.endTime,
                    icon     = ev.iconTexture,
                    isShort  = isShort,
                    key      = ev.title .. "@" .. startKey,
                }
                local item = items[#items]
                if item.category == "weekly" then
                    item.description = HolidayDescription(monthOffset, d.monthDay, i)
                    if ev.title:lower():find("timewalking", 1, true) then
                        item.expansion = FindExpansion(item.description) or FindExpansion(ev.title)
                    end
                end
                item.endEpoch   = e
                item.startEpoch = s
                item.startTime  = ev.startTime
                -- Holidays start at different times of day, so "today" doesn't always mean "now"
                item.started    = (not s) or (now ~= nil and s <= now)
            end
        end
    end

    -- Pick whose colors the chat prefix wears, in this order:
    -- a big holiday that's on now, then the next big holiday coming up,
    -- then a micro-holiday that's on now, then the next micro-holiday coming up
    local nextBig, nextMicro, nowBig, nowMicro
    local function Sooner(a, b) return not b or (a.startEpoch or 0) < (b.startEpoch or 0) end
    for _, item in ipairs(items) do
        if item.data and item.data.colors then
            local big = (item.category == "holiday")
            if item.started == false then
                if big and Sooner(item, nextBig) then nextBig = item end
                if not big and Sooner(item, nextMicro) then nextMicro = item end
            else
                if big and not nowBig then nowBig = item end
                if not big and not nowMicro then nowMicro = item end
            end
        end
    end
    local pick = nowBig or nextBig or nowMicro or nextMicro
    chatTheme = (HolidayHeraldDB.showThemes and pick) and pick.data.colors or nil
    -- If the player had the calendar on another month, put it back
    if shown and shown.month and (shown.month ~= today.month or shown.year ~= today.year) then
        C_Calendar.SetAbsMonth(shown.month, shown.year)
    end
    return items
end

---------------------------------------------------------------------------
-- Tooltip builders
---------------------------------------------------------------------------
-- Tooltips that show map coordinates get a small tip about /way commands
local WAY_TIP = "Tip: with TomTom installed, type /way and the coordinates to get an arrow."

local function HasCoords(text)
    return type(text) == "string" and text:find("%d+%.%d+,%s*%d+%.%d+") ~= nil
end

local function AddWayTip(tt)
    tt:AddLine(" ")
    tt:AddLine(WAY_TIP, 0.55, 0.52, 0.47, true)
end

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
            if HasCoords(body) then AddWayTip(tt) end
            return
        end
        local coords = false
        for _, line in ipairs(body) do
            if HasCoords(line) or (type(line) == "table" and (HasCoords(line[1]) or HasCoords(line[2]))) then
                coords = true
            end
            if type(line) == "table" then
                tt:AddDoubleLine(line[1], line[2], 1, 1, 1, 0.72, 0.68, 0.61)
            elseif line:sub(1, 1) == "#" then
                tt:AddLine(line:sub(2), Hex(colors.accent))
            else
                tt:AddLine(line, 1, 1, 1, true)
            end
        end
        if coords then AddWayTip(tt) end
    end
end

-- When an item's name hasn't loaded yet, ask the game for it and redraw the
-- tooltip a moment later (a few tries at most), so "Item 226453" turns into its name
local function RetryTooltipSoon(tt, tries)
    local owner = tt:GetOwner()
    if not owner or tries >= 3 then return end
    C_Timer.After(0.4, function()
        if tt:IsOwned(owner) and owner:GetScript("OnEnter") then
            owner.nameRetries = tries + 1
            owner:GetScript("OnEnter")(owner)
            owner.nameRetries = nil
        end
    end)
end

local function ListTooltip(title, list, colors, notes)
    return function(tt)
        local owner = tt:GetOwner()
        local tries = (owner and owner.nameRetries) or 0
        local missingNames = false
        tt:AddLine(title, Hex(colors.main))
        -- Long lists (like a holiday's whole achievement list) only show what's left
        local hideCollected = #list > 15 and list[1].kind ~= "decor"
        local hidden = 0
        local lastGroup
        for _, entry in ipairs(list) do
          local state = ForMyFaction(entry) and IsOwned(entry)
          if hideCollected and state == true then
            hidden = hidden + 1
          elseif ForMyFaction(entry) then
            if entry.group and entry.group ~= lastGroup then
                tt:AddLine(" ")
                tt:AddLine(entry.group, Hex(colors.accent))
                lastGroup = entry.group
            end
            local name = ItemName(entry)
            if not entry.name and entry.item and not C_Item.GetItemNameByID(entry.item) then
                C_Item.RequestLoadItemDataByID(entry.item)
                missingNames = true
            end
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
        end
        if hidden > 0 then
            tt:AddLine("+ " .. hidden .. " already done", 0.55, 0.52, 0.47)
        end
        if missingNames then RetryTooltipSoon(tt, tries) end
        for _, note in ipairs(notes or {}) do
            tt:AddLine(" ")
            tt:AddLine(note, 0.72, 0.68, 0.61, true)
        end
        for _, entry in ipairs(list) do
            if HasCoords(entry.where) then AddWayTip(tt) break end
        end
    end
end

---------------------------------------------------------------------------
-- Line builders for one holiday card
---------------------------------------------------------------------------
local COUNT_LABELS = {
    achievements = { label = "Achievements" },
    reminders    = { label = "Also look for", unit = "item", units = "items" },   -- things the game can't check for us
    mounts       = { label = "Mounts" },
    toys         = { label = "Toys" },
    pets         = { label = "Pets" },
    transmog     = { label = "Transmog" },
    decor        = { label = "Housing decor", unit = "piece", units = "pieces" },
}
local COUNT_ORDER = { "achievements", "reminders", "mounts", "toys", "pets", "transmog", "decor" }

local DONE_ICON = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12|t "

-- Picks the achievement to open from a list: the first one not yet earned,
-- or the first one if they're all done
-- Feats of Strength (and its subcategories, like Promotions) live under category 81
local FEATS_OF_STRENGTH = 81
local function IsFeat(id)
    local category = GetAchievementCategory and GetAchievementCategory(id)
    while category and category > 0 do
        if category == FEATS_OF_STRENGTH then return true end
        local _, parent = GetCategoryInfo(category)
        if parent == category then break end
        category = parent
    end
    return false
end

-- Which achievement a click should open. Prefers the first unfinished one,
-- but skips Feats of Strength when the holiday has its own achievement list
-- (World Events), so clicking lands on the holiday instead of a feats page.
-- Returns the one to open, and the one to link with shift-click.
local function AchievementToOpen(list, data)
    local first, firstUnfinished, firstUnfinishedFeat
    for _, entry in ipairs(list or {}) do
        if entry.achievement and ForMyFaction(entry) then
            first = first or entry.achievement
            if not AchievementDone(entry.achievement) then
                if IsFeat(entry.achievement) then
                    firstUnfinishedFeat = firstUnfinishedFeat or entry.achievement
                else
                    firstUnfinished = firstUnfinished or entry.achievement
                end
            end
        end
    end
    local linkTarget = firstUnfinished or firstUnfinishedFeat or first
    if firstUnfinished then return firstUnfinished, linkTarget end
    local category = data and HolidayCategoryID(data)
    local holidayList = (category and GetAchievementInfo(category, 1))
        or (data and data.meta and data.meta.holidayMeta)
    return holidayList or linkTarget, linkTarget
end

local function AchievementClick(id, linkID)
    return function()
        if IsShiftKeyDown() then
            if linkID or id then LinkAchievement(linkID or id) end
        elseif id then
            OpenAchievement(id)
        end
    end
end

-- Returns a count line spec, and whether that category is finished
local function CountLine(holidayName, field, list, colors, data, owned, total, reminders)
    local info = COUNT_LABELS[field]
    if not owned then owned, total, reminders = CountOwned(list) end
    local right, done
    if total == 0 then
        right = reminders .. " " .. (reminders == 1 and (info.unit or "item") or (info.units or "items"))
        done = false
    else
        right = owned .. " of " .. total
        done = (owned == total and reminders == 0)
    end
    local spec = {
        text = info.label,
        right = Color(colors.main, right),
        tooltip = ListTooltip(holidayName .. ": " .. info.label, list, colors),
        doneLabel = info.label,
    }
    if field == "decor" then
        local notes = {}
        if data.decorNote then notes[#notes + 1] = data.decorNote end
        notes[#notes + 1] = "Grey: you already have at least one."
        spec.tooltip = ListTooltip(holidayName .. ": " .. info.label, list, colors, notes)
    end
    if field == "achievements" then
        local target, linkTarget = AchievementToOpen(list, data)
        spec.tooltip = ListTooltip(holidayName .. ": " .. info.label, list, colors,
            { "Click: open in the achievement window. Shift-click: link it in chat." })
        spec.onClick = AchievementClick(target, linkTarget)
    end
    return spec, done
end

-- The skill line IDs of this character's professions (cooking, fishing and
-- archaeology included), for showing only the shopping items they need
local function MyProfessionSkillLines()
    local lines = {}
    for _, index in ipairs({ GetProfessions() }) do
        if index then
            local skillLine = select(7, GetProfessionInfo(index))
            if skillLine then lines[skillLine] = true end
        end
    end
    return lines
end

-- Which shopping item a shift-click sends next, per holiday. Kept outside the
-- card so redrawing the popup doesn't reset it.
local shoppingNext = {}

-- Builds the card's lines, grouped under small section headers
---------------------------------------------------------------------------
-- Holiday currency across the account. Each character's own count (bags and
-- their own banks) is remembered when it changes; the warband bank is shared,
-- so it's counted once. Other characters' counts are as of their last login.
---------------------------------------------------------------------------
local function MyCharKey()
    return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
end

-- Saves this character's count of one currency item. Returns true if it changed.
local function SaveCurrencyCount(itemID)
    local mine = C_Item.GetItemCount(itemID, true, false, true, false) or 0
    local all = C_Item.GetItemCount(itemID, true, false, true, true) or mine
    HolidayHeraldDB.currencyCounts = HolidayHeraldDB.currencyCounts or {}
    local byChar = HolidayHeraldDB.currencyCounts[itemID] or {}
    HolidayHeraldDB.currencyCounts[itemID] = byChar
    local key = MyCharKey()
    local old, oldWarband = byChar[key], byChar["#warband"]
    byChar[key] = (mine > 0) and mine or nil
    byChar["#warband"] = math.max(all - mine, 0)
    return old ~= byChar[key] or oldWarband ~= byChar["#warband"]
end

-- Returns the account total, and a sorted list of { name, count } (you first, warband bank last)
local function AccountCurrency(itemID)
    SaveCurrencyCount(itemID)
    local byChar = (HolidayHeraldDB.currencyCounts or {})[itemID] or {}
    local me = MyCharKey()
    local total, rows = 0, {}
    for key, count in pairs(byChar) do
        if key ~= "#warband" and count > 0 then
            total = total + count
            rows[#rows + 1] = { key:match("^(.-)%-") or key, count, key == me }
        end
    end
    table.sort(rows, function(a, b)
        if a[3] ~= b[3] then return a[3] end
        return a[2] > b[2]
    end)
    local warband = byChar["#warband"] or 0
    total = total + warband
    if warband > 0 then rows[#rows + 1] = { "Warband bank", warband } end
    return total, rows
end
HH.SaveCurrencyCount = SaveCurrencyCount

-- "45 min" or "2h 15m"
local function MinutesText(mins)
    if mins < 60 then return mins .. " min" end
    return ("%dh %02dm"):format(math.floor(mins / 60), mins % 60)
end

-- Minutes to add to UTC to get US Pacific time (-480 standard, -420 daylight).
-- Daylight time: 2nd Sunday of March 10:00 UTC to 1st Sunday of November 09:00 UTC.
local function PacificOffsetMinutes(t)
    local y = tonumber(date("!%Y", t))
    local function Weekday(year, month, day)   -- 0 = Sunday
        local k = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 }
        if month < 3 then year = year - 1 end
        return (year + math.floor(year / 4) - math.floor(year / 100) + math.floor(year / 400) + k[month] + day) % 7
    end
    local function DaysFromCivil(year, month, day)   -- days since 1970-01-01
        if month <= 2 then year = year - 1 end
        local era = math.floor(year / 400)
        local yoe = year - era * 400
        local mp = (month + 9) % 12
        local doy = math.floor((153 * mp + 2) / 5) + day - 1
        local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
        return era * 146097 + doe - 719468
    end
    local marchSun = 8 + (7 - Weekday(y, 3, 8)) % 7    -- 2nd Sunday of March
    local novSun   = 1 + (7 - Weekday(y, 11, 1)) % 7   -- 1st Sunday of November
    local dstStart = DaysFromCivil(y, 3, marchSun) * 86400 + 10 * 3600
    local dstEnd   = DaysFromCivil(y, 11, novSun) * 86400 + 9 * 3600
    return (t >= dstStart and t < dstEnd) and -420 or -480
end

local function BuildLines(item)
    local data = item.data
    local colors = (HolidayHeraldDB.showThemes and data.colors) or DEFAULT_COLORS
    local name = data.name or item.title
    local toGet, done, howTo, secrets = {}, {}, {}, {}
    local doneTooltips = {}
    local hasGoals = false

    -- Holiday meta achievement
    if HolidayHeraldDB.showMeta and data.meta and data.meta.holidayMeta then
        local metaID, tripID = data.meta.holidayMeta, data.meta.strangeTrip
        hasGoals = true
        local spec = {
            text = "Drake meta",
            right = Color(colors.main, AchievementName(metaID)),
            tooltip = function(tt)
                tt:AddLine(AchievementName(metaID), Hex(colors.main))
                tt:AddLine("This holiday's part of " .. AchievementName(tripID or 2144) .. " (Violet Proto-Drake).", 1, 1, 1, true)
                tt:AddLine(" ")
                tt:AddLine("Click: open it", 0.72, 0.68, 0.61)
                if tripID then tt:AddLine("Ctrl-click: open " .. AchievementName(tripID), 0.72, 0.68, 0.61) end
                tt:AddLine("Shift-click: link it in chat", 0.72, 0.68, 0.61)
            end,
            onClick = function()
                if IsShiftKeyDown() then LinkAchievement(metaID)
                elseif IsControlKeyDown() and tripID then OpenAchievement(tripID)
                else OpenAchievement(metaID) end
            end,
        }
        if AchievementDone(metaID) then
            done[#done + 1] = "Drake meta"
            doneTooltips[#doneTooltips + 1] = spec
        else
            toGet[#toGet + 1] = spec
        end
    end

    -- Browse an achievement category (holidays without a meta)
    if data.achievementCategory then
        howTo[#howTo + 1] = {
            icon = ICONS.meta,
            text = "Browse all " .. data.achievementCategory .. " achievements",
            tooltip = function(tt)
                tt:AddLine(data.achievementCategory .. " achievements", Hex(colors.main))
                tt:AddLine("Click to open the achievement window on this holiday's list.", 1, 1, 1, true)
            end,
            onClick = function()
                local first = FirstAchievementInCategory(data.achievementCategory)
                if first then OpenAchievement(first)
                else Print("couldn't find the " .. data.achievementCategory .. " achievement list.") end
            end,
        }
    end

    -- Holiday boss
    if data.boss then
        local boss = data.boss
        hasGoals = true
        local owned, total, reminders = CountOwned(boss.drops)
        local bossDone = (total > 0 and owned == total and reminders == 0)

        local status
        local active = (item.daysAway == 0 and item.started ~= false)
        if boss.lfg and not active then
            -- The holiday dungeon isn't open yet, and the game reports it as "done"
            -- until it is, so don't trust (or record) anything before it starts
            status = "\n" .. Color(GRAY, "Opens when the holiday starts")
        elseif boss.lfg and GetLFGDungeonRewards then
            local doneToday = GetLFGDungeonRewards(boss.lfg)
            local now = GetServerTime()
            if doneToday then
                HolidayHeraldDB.bestRoll[boss.lfg] = now + (C_DateAndTime.GetSecondsUntilDailyReset() or 0)
            end
            local bestUsed = (HolidayHeraldDB.bestRoll[boss.lfg] or 0) > now
            status = "\n" .. Color(SOFT, "Best roll: ")
                .. (bestUsed and Color(GRAY, "used today") or Color(colors.main, "available"))
                .. Color(SOFT, "  ·  This character: ")
                .. (doneToday and Color(GRAY, "done") or Color("FF6B6B", "not done"))
        end

        local notes = {
            "Your first boss kill of the day, across your whole account, gets the best mount chance. "
                .. "Each alt can still try once a day at a much lower chance.",
        }
        if boss.hardMode then notes[#notes + 1] = "Hard mode: " .. boss.hardMode end
        -- A little cheer for any mount still missing
        local wanted = {}
        for _, drop in ipairs(boss.drops) do
            if drop.kind == "mount" and IsOwned(drop) == false then wanted[#wanted + 1] = ItemName(drop) end
        end
        if #wanted > 0 then
            notes[#notes + 1] = Color(colors.accent, "Good luck on " .. table.concat(wanted, " and ") .. "!")
        end
        notes[#notes + 1] = active and "Click to open the Dungeon Finder with the " .. boss.name .. " already picked. Just hit Find Group!"
            or "Click to open the Dungeon Finder."

        toGet[#toGet + 1] = {
            icon = ICONS.boss,
            text = boss.name .. (status or ""),
            right = Color(bossDone and GRAY or colors.main, owned .. " of " .. total),
            tooltip = ListTooltip(boss.name .. " drops", boss.drops, colors, notes),
            onClick = function() OpenDungeonFinder(active and boss.lfg or nil) end,
        }
    end

    -- Daily quests: a checklist that resets each day.
    -- An entry can list several quest IDs (quests = {...}) when any one of them counts.
    local function DailyDone(quest)
        for _, id in ipairs(quest.quests or { quest.quest }) do
            if C_QuestLog.IsQuestFlaggedCompleted(id) then return true end
        end
        return false
    end
    local dailies = {}
    for _, quest in ipairs(data.dailies or {}) do
        if ForMyFaction(quest) then dailies[#dailies + 1] = quest end
    end
    if #dailies > 0 then
        local active = (item.daysAway == 0 and item.started ~= false)
        local doneCount = 0
        for _, quest in ipairs(dailies) do
            if active and DailyDone(quest) then doneCount = doneCount + 1 end
        end
        local allDone = active and doneCount == #dailies
        local spec = {
            icon = ICONS.daily,
            text = "Daily quests" .. (active and "" or ("\n" .. Color(GRAY, "Open when the holiday starts"))),
            right = Color(allDone and GRAY or colors.main, active and (doneCount .. " of " .. #dailies) or (#dailies .. " quests")),
            tooltip = function(tt)
                tt:AddLine(name .. ": daily quests", Hex(colors.main))
                local lastGroup
                for _, quest in ipairs(dailies) do
                    if quest.group and quest.group ~= lastGroup then
                        tt:AddLine(" ")
                        tt:AddLine(quest.group, Hex(colors.accent))
                        lastGroup = quest.group
                    end
                    local doneToday = active and DailyDone(quest)
                    if doneToday then
                        tt:AddDoubleLine(quest.name, "done today", 0.55, 0.52, 0.47, 0.55, 0.52, 0.47)
                    else
                        tt:AddDoubleLine(quest.name, quest.giver or "", 1, 1, 1, 0.72, 0.68, 0.61)
                        if quest.where then tt:AddLine("   " .. quest.where, 0.72, 0.68, 0.61, true) end
                    end
                end
                if data.dailyNote then
                    tt:AddLine(" ")
                    tt:AddLine(data.dailyNote, 0.72, 0.68, 0.61, true)
                end
                tt:AddLine(" ")
                tt:AddLine("Resets with the daily reset.", 0.55, 0.52, 0.47, true)
            end,
            doneLabel = "Today's dailies",
        }
        hasGoals = true
        if allDone then
            done[#done + 1] = spec.doneLabel
            doneTooltips[#doneTooltips + 1] = spec
        else
            toGet[#toGet + 1] = spec
        end
    end

    -- Timed events, like a world quest that runs for part of every hour.
    -- Asks the game for the time left; away from the zone it works it out from the clock.
    for _, ev in ipairs(data.timedEvents or {}) do
        local active = (item.daysAway == 0 and item.started ~= false)
        local rightRegion = not ev.region or (GetCurrentRegion and GetCurrentRegion() == ev.region)
        if active and rightRegion and ForMyFaction(ev) then
            local left = ev.quest and C_TaskQuest and C_TaskQuest.GetQuestTimeLeftMinutes and C_TaskQuest.GetQuestTimeLeftMinutes(ev.quest)
            local every = ev.every or 60
            local nowMin = math.floor(GetServerTime() / 60)
            if ev.clock == "pacific" then nowMin = nowMin + PacificOffsetMinutes(GetServerTime()) end
            local into = (nowMin - (ev.startMinute or 0)) % every
            local on, mins
            if left and left > 0 then
                on, mins = true, left
            elseif into < ev.length then
                on, mins = true, ev.length - into
            else
                on, mins = false, every - into
            end
            toGet[#toGet + 1] = {
                icon = ICONS.reset,
                text = ev.name,
                right = on and Color(colors.main, "on now, " .. MinutesText(mins) .. " left") or Color(SOFT, "in " .. MinutesText(mins)),
                tooltip = function(tt)
                    tt:AddLine(ev.name, Hex(colors.main))
                    tt:AddLine(ev.runs or ("Runs for %d minutes at the start of every hour."):format(ev.length), 1, 1, 1, true)
                    if ev.where then tt:AddLine(ev.where, 0.72, 0.68, 0.61, true) end
                end,
            }
        end
    end

    -- Collection counts: unfinished ones listed, finished ones folded into "Done"
    for _, field in ipairs(COUNT_ORDER) do
        local list = (field == "achievements") and HolidayAchievements(data) or data[field]
        local owned, total, reminders = 0, 0, 0
        if list and #list > 0 then
            owned, total, reminders = CountOwned(list)
        end
        -- skip lists where nothing applies to this character (race/faction-only items)
        if total + reminders > 0 then
            hasGoals = true
            local spec, isDone = CountLine(name, field, list, colors, data, owned, total, reminders)
            if isDone then
                done[#done + 1] = spec.doneLabel
                doneTooltips[#doneTooltips + 1] = spec
            else
                toGet[#toGet + 1] = spec
            end
        end
    end

    -- Holiday currency total: what one of everything you're still missing costs
    -- (entries carry price = N in the holiday's currency, like Tricky Treats)
    if data.currency then
        local cur = data.currency
        local need, parts = 0, {}
        for _, field in ipairs(COUNT_ORDER) do
            local sum = 0
            for _, entry in ipairs(data[field] or {}) do
                if entry.price and ForMyFaction(entry) and IsOwned(entry) ~= true then
                    sum = sum + entry.price
                end
            end
            if sum > 0 then
                need = need + sum
                parts[#parts + 1] = { COUNT_LABELS[field].label, sum }
            end
        end
        -- Boss drops that are also sold (like the Hallowed Helm)
        if data.boss and data.boss.drops then
            local sum = 0
            for _, entry in ipairs(data.boss.drops) do
                if entry.price and ForMyFaction(entry) and IsOwned(entry) ~= true then
                    sum = sum + entry.price
                end
            end
            if sum > 0 then
                need = need + sum
                parts[#parts + 1] = { data.boss.name .. " drops (also sold)", sum }
            end
        end
        local have, haveRows = AccountCurrency(cur.item)
        local short = math.max(need - have, 0)
        local Num = BreakUpLargeNumbers or tostring
        local spec = {
            icon = C_Item.GetItemIconByID(cur.item) or ICONS.collect,
            text = cur.name .. " for the rest",
            right = Color(need == 0 and GRAY or colors.main,
                need == 0 and "all bought" or (Num(have) .. " / " .. Num(need))),
            tooltip = function(tt)
                tt:AddLine(name .. ": " .. cur.name, Hex(colors.main))
                if need == 0 then
                    tt:AddLine("You have everything sold for " .. cur.name .. ".", 1, 1, 1, true)
                else
                    tt:AddLine("One of everything you don't have yet costs:", 1, 1, 1, true)
                    for _, part in ipairs(parts) do
                        tt:AddDoubleLine("   " .. part[1], Num(part[2]), 0.72, 0.68, 0.61, 1, 1, 1)
                    end
                    tt:AddDoubleLine("Total", Num(need), 1, 0.82, 0, 1, 0.82, 0)
                    tt:AddLine(" ")
                    tt:AddDoubleLine("Your account has", Num(have), 0.72, 0.68, 0.61, 1, 1, 1)
                    for _, row in ipairs(haveRows) do
                        tt:AddDoubleLine("   " .. row[1] .. (row[3] and " (you)" or ""), Num(row[2]),
                            0.55, 0.52, 0.47, 0.72, 0.68, 0.61)
                    end
                    if short > 0 then
                        tt:AddDoubleLine("Still to earn", Num(short), 0.72, 0.68, 0.61, 1, 0.82, 0)
                    else
                        tt:AddLine("You have enough for all of it!", 0.4, 1, 0.4)
                    end
                end
                if cur.note then
                    tt:AddLine(" ")
                    tt:AddLine(cur.note, 0.72, 0.68, 0.61, true)
                end
                tt:AddLine("Other characters' counts are from the last time you logged in on them.", 0.55, 0.52, 0.47, true)
            end,
        }
        if need == 0 then
            done[#done + 1] = cur.name
            doneTooltips[#doneTooltips + 1] = spec
        else
            toGet[#toGet + 1] = spec
        end
    end

    -- How to: tip, shopping, class lines
    if HolidayHeraldDB.showTips and data.tip then
        howTo[#howTo + 1] = {
            icon = ICONS.tip,
            text = Color("C9C1B1", data.tip.short),
            tooltip = data.tip.hover and TextTooltip(name .. " tip", colors, data.tip.hover),
        }
    end
    -- More tips (can be faction-specific)
    for _, extra in ipairs(HolidayHeraldDB.showTips and data.moreTips or {}) do
        if ForMyFaction(extra) then
            -- warning = true: a red line with a skull, for "this will kill you" tips
            howTo[#howTo + 1] = {
                icon = extra.warning and ICONS.boss or ICONS.tip,
                text = Color(extra.warning and "FF6B6B" or "C9C1B1", extra.short),
                tooltip = extra.hover and TextTooltip(extra.title or (name .. " tip"), colors, extra.hover),
            }
        end
    end

    -- Shopping lines. A holiday can have one list (shopping + shoppingFor) or several
    -- (shoppingLists), like "Greatfather Winter's treats" plus "Bake the cookies".
    local lists = data.shoppingLists
    if not lists and data.shopping then
        lists = { { title = data.shoppingFor, items = data.shopping, byProfession = data.shoppingByProfession } }
    end
    local mine = MyProfessionSkillLines()
    for listIndex, list in ipairs(HolidayHeraldDB.showTips and lists or {}) do
    -- Only list items for this character's professions (items without one always show)
    local shopping = {}
    for _, buy in ipairs(list.items) do
        if not buy.skillLine or mine[buy.skillLine] then shopping[#shopping + 1] = buy end
    end
    local listTitle = list.title

    if #shopping > 0 then
        local names = {}
        for _, buy in ipairs(shopping) do
            names[#names + 1] = Color(colors.accent, (buy.count and (buy.count .. "x ") or "") .. buy.name)
        end
        local key = (data.key or name) .. "#" .. listIndex
        shoppingNext[key] = shoppingNext[key] or 1
        howTo[#howTo + 1] = {
            icon = C_Item.GetItemIconByID(shopping[1].item) or ICONS.collect,
            text = (listTitle and (listTitle .. ": bring ") or "Bring along: ")
                .. table.concat(names, " + "),
            tooltip = function(tt)
                tt:AddLine(listTitle or "Bring along", Hex(colors.main))
                for _, buy in ipairs(shopping) do
                    tt:AddDoubleLine((buy.count and (buy.count .. "x ") or "") .. buy.name, "ID " .. buy.item, 1, 1, 1, 0.72, 0.68, 0.61)
                    local detail = buy.where
                    if buy.profession then detail = buy.profession .. (detail and (": " .. detail) or "") end
                    if detail then tt:AddLine("   " .. detail, 0.72, 0.68, 0.61) end
                end
                if list.note then tt:AddLine(list.note, 1, 1, 1, true) end
                if list.byProfession then
                    tt:AddLine("Showing only what your professions need.", 0.55, 0.52, 0.47, true)
                end
                if shoppingNext[key] > #shopping then shoppingNext[key] = 1 end
                local nextBuy = shopping[shoppingNext[key]]
                tt:AddLine(" ")
                tt:AddLine("Next shift-click sends: " .. Color(colors.accent, nextBuy.name), 1, 1, 1)
                tt:AddLine("Each shift-click sends one item, then moves on to the next.", 0.72, 0.68, 0.61, true)
                tt:AddLine(" ")
                if ItemWatch_AddToGoal then
                    tt:AddLine("Ctrl-click: add them all to ItemWatch", 1, 0.82, 0)
                    tt:AddLine("Adds each amount on top of any goal you already have.", 0.72, 0.68, 0.61, true)
                else
                    tt:AddLine("To track them with ItemWatch:", 1, 0.82, 0)
                    tt:AddLine("1. Click the + on the ItemWatch box.", 0.72, 0.68, 0.61, true)
                    tt:AddLine("2. Click into the item ID field.", 0.72, 0.68, 0.61, true)
                    tt:AddLine("3. Shift-click this line, then add it.", 0.72, 0.68, 0.61, true)
                    tt:AddLine("4. Repeat for each item. The line above shows which one is next.", 0.72, 0.68, 0.61, true)
                end
            end,
            onClick = function()
                -- Ctrl-click: hand the whole list to ItemWatch in one go
                if IsControlKeyDown() and ItemWatch_AddToGoal then
                    for _, buy in ipairs(shopping) do
                        ItemWatch_AddToGoal(buy.item, buy.count or 1)
                    end
                    return
                end
                if not IsShiftKeyDown() then return end
                if shoppingNext[key] > #shopping then shoppingNext[key] = 1 end
                local buy = shopping[shoppingNext[key]]
                HandleModifiedItemClick(ItemLink(buy.item, buy.name))
                shoppingNext[key] = (shoppingNext[key] % #shopping) + 1
            end,
        }
    end
    end

    for _, cl in ipairs(HolidayHeraldDB.showClass and data.classLines or {}) do
        howTo[#howTo + 1] = {
            icon = ICONS[cl.class] or ICONS.tip,
            text = cl.short,
            tooltip = cl.hover and TextTooltip(cl.short, colors, cl.hover),
        }
    end

    for _, secret in ipairs(HolidayHeraldDB.showSecrets and data.secrets or {}) do
        secrets[#secrets + 1] = {
            icon = ICONS.secret,
            text = Color("C9C1B1", (secret.teaser:gsub("^Secret: ", ""):gsub("^%l", string.upper))),
            tooltip = TextTooltip("Secret!", colors, secret.reveal),
        }
    end

    -- Assemble sections
    local specs = {}
    -- Sections can fold up to one line (click the heading); remembered across holidays and characters
    -- A holiday can color each section heading (colors.sections = { toGet, howTo, secrets })
    local SECTION_KEYS = { ["Still to get"] = "toGet", ["How to"] = "howTo", ["Secrets"] = "secrets" }
    local function Section(title, list, foldable)
        if #list == 0 then return end
        local folded = foldable and HolidayHeraldDB.folded[title]
        local sectionColor = colors.sections and colors.sections[SECTION_KEYS[title]]
        local header = { header = title, colors = colors, color = sectionColor }
        if foldable then
            header.right = Color(sectionColor or SOFT, folded and ("+ show " .. #list) or "- hide")
            header.tooltip = function(tt)
                tt:AddLine(title, Hex(colors.main))
                tt:AddLine(folded and ("Click to show all " .. #list .. ".") or "Click to fold this section up.", 1, 1, 1, true)
                tt:AddLine("Remembered for every holiday card.", 0.72, 0.68, 0.61, true)
            end
            header.onClick = function()
                HolidayHeraldDB.folded[title] = not folded or nil
                GameTooltip:Hide()
                if HH.Rerender then HH.Rerender() end
            end
        end
        specs[#specs + 1] = header
        if folded then return end
        -- With section colors on, the counts in a section take that section's color
        -- (so orange only means "How to" on Hallow's End, for example)
        local from = "|cff" .. colors.main
        local to = sectionColor and ("|cff" .. sectionColor)
        for _, spec in ipairs(list) do
            if to and to ~= from then
                if type(spec.right) == "string" then spec.right = spec.right:gsub(from, to) end
                if type(spec.text) == "string" then spec.text = spec.text:gsub(from, to) end
            end
            specs[#specs + 1] = spec
        end
    end

    if hasGoals and #toGet == 0 then
        specs[#specs + 1] = { text = Color(GRAY, DONE_ICON .. "Everything here is collected. All done! Grats!") }
    else
        if #done > 0 then
            local target = AchievementToOpen(HolidayAchievements(data), data)
                or (data.meta and data.meta.holidayMeta)
            toGet[#toGet + 1] = {
                text = Color(GRAY, DONE_ICON .. "Done: " .. table.concat(done, ", ")),
                tooltip = function(tt)
                    tt:AddLine("Already finished", Hex(colors.main))
                    tt:AddLine(table.concat(done, ", "), 1, 1, 1, true)
                    if target then
                        tt:AddLine(" ")
                        tt:AddLine("Click: open the achievement window", 0.72, 0.68, 0.61)
                    end
                end,
                onClick = AchievementClick(target),
            }
        end
        Section("Still to get", toGet)
    end
    Section("How to", howTo, true)
    Section("Secrets", secrets, true)
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
popup:SetClampedToScreen(true)
popup:EnableMouse(true)
popup:RegisterForDrag("LeftButton")
popup:SetScript("OnDragStart", popup.StartMoving)
popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
popup:Hide()
tinsert(UISpecialFrames, "HolidayHeraldFrame")

-- Puts the popup back in its default spot (top middle of the screen)
local function ResetPopupPosition()
    popup:StopMovingOrSizing()
    popup:ClearAllPoints()
    popup:SetPoint("CENTER", 0, 150)
    if popup.SetUserPlaced then popup:SetUserPlaced(false) end
end

local popupTitle = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
popupTitle:SetPoint("TOP", 0, -18)
popupTitle:SetText("Holiday Herald")

-- Version number next to the title, read from the .toc. Copies installed by
-- hand straight from the repo show "dev" instead of the packager's placeholder.
local function AddonVersion()
    local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    local version = getMeta and getMeta(ADDON, "Version")
    if not version or version:find("@", 1, true) then return "dev" end
    return version
end

local popupVersion = popup:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
popupVersion:SetPoint("BOTTOMLEFT", popupTitle, "BOTTOMRIGHT", 6, 1)
popupVersion:SetText(AddonVersion())

local closeButton = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -6, -6)

-- Pools of reusable pieces
local linePool, headerPool, cardPool = {}, {}, {}
local lineCount, headerCount, cardCount = 0, 0, 0

local function ReleaseAll()
    for i = 1, lineCount do linePool[i]:Hide() end
    for i = 1, headerCount do headerPool[i].text:Hide(); headerPool[i].hint:Hide(); headerPool[i].rule:Hide() end
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
    b.right = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    b.right:SetPoint("TOPRIGHT", 0, 0)
    b.right:SetJustifyH("RIGHT")
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
    if spec.header then
        -- Small section header inside a card
        b.text:SetFontObject(GameFontNormalSmall)
        b.text:ClearAllPoints()
        b.text:SetPoint("TOPLEFT", 0, 0)
        b.text:SetWidth(width)
        b.text:SetText(spec.header:upper())
        if spec.color then
            b.text:SetTextColor(Hex(spec.color))
        else
            b.text:SetTextColor(DarkHex((spec.colors or DEFAULT_COLORS).main, 0.8))
        end
        b.right:SetText(spec.right or "")
        b.icon:Hide()
        b.tooltip, b.onClick = spec.tooltip, spec.onClick
        b:SetHeight(16)
        b:Show()
        return 16
    end
    b.text:SetFontObject(GameFontHighlight)
    b.text:SetTextColor(1, 1, 1)
    b.text:ClearAllPoints()
    b.text:SetPoint("TOPLEFT", 20, 0)
    b.right:SetText(spec.right or "")
    local rightWidth = spec.right and (b.right:GetStringWidth() + 10) or 0
    b.text:SetWidth(width - 20 - rightWidth)
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

local function PlaceHeader(text, y, hint)
    headerCount = headerCount + 1
    local h = headerPool[headerCount]
    if not h then
        h = { text = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal"),
              hint = popup:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall"),
              rule = popup:CreateTexture(nil, "ARTWORK") }
        headerPool[headerCount] = h
    end
    -- Optional small hint on the right side of the header, like "Hover any line for details"
    h.hint:ClearAllPoints()
    h.hint:SetPoint("BOTTOMRIGHT", popup, "TOPRIGHT", -22, y - 14)
    h.hint:SetText(hint or "")
    h.hint:SetShown(hint ~= nil)
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
    -- A 2-pixel border: 1-pixel borders can vanish on some sides at certain
    -- UI scales, because they land between screen pixels
    c:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 2 })
    c.icon = c:CreateTexture(nil, "ARTWORK")
    c.icon:SetSize(28, 28)
    c.icon:SetPoint("TOPLEFT", 10, -10)
    c.title = c:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    c.title:SetPoint("TOPLEFT", 46, -9)
    c.title:SetShadowOffset(1, -1)
    c.title:SetShadowColor(0, 0, 0, 1)
    c.status = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    c.status:SetPoint("TOPLEFT", c.title, "BOTTOMLEFT", 0, -2)
    c.status:SetJustifyH("LEFT")
    c.status:SetWordWrap(true)
    return c
end

local function StatusText(item)
    if item.preview then
        local when = (item.daysAway == 0) and "as if active today" or ("as if starting in " .. item.daysAway .. " days")
        local text = Color("B48CE0", "Preview") .. Color(SOFT, "  ·  " .. when)
        if item.isShort and item.category ~= "micro" then text = text .. Color("FF8000", "  (short!)") end
        return text
    end
    local text
    if item.daysAway == 0 and item.started ~= false then
        text = Color("33FF33", "Now")
        local ends = FormatEnd(item.endTime)
        if ends then text = text .. Color(SOFT, "  ·  ends " .. ends) end
    elseif item.daysAway <= 1 then
        -- Starts later today or tomorrow: show the exact time
        text = Color("FFD100", "Starts " .. (FormatEnd(item.startTime) or (item.daysAway == 0 and "today" or "tomorrow")))
    else
        text = Color("FFD100", "In " .. item.daysAway .. " days")
    end
    if item.isShort and item.category ~= "micro" then text = text .. Color("FF8000", "  (short!)") end
    return text
end

-- The calendar's own holiday art is a wide banner that squishes badly into a
-- square, so cards prefer a proper square icon: one set in the data file, the
-- holiday's meta achievement icon, or a key item's icon.
local function CardIcon(item)
    local data = item.data
    if data.icon then return data.icon end
    local achievementID = data.iconAchievement or (data.meta and data.meta.holidayMeta)
    if achievementID then
        local icon = select(10, GetAchievementInfo(achievementID))
        if icon then return icon end
    end
    if data.iconItem then
        local icon = C_Item.GetItemIconByID(data.iconItem)
        if icon then return icon end
    end
    return item.icon or ICONS.fallback
end

local function PlaceCard(item, y, width, x)
    cardCount = cardCount + 1
    local c = cardPool[cardCount]
    if not c then
        c = NewCard()
        cardPool[cardCount] = c
    end
    local colors = (HolidayHeraldDB.showThemes and item.data.colors) or DEFAULT_COLORS
    c:ClearAllPoints()
    c:SetPoint("TOPLEFT", x or 16, y)
    c:SetWidth(width)
    c:SetBackdropColor(Hex(colors.card))
    c:SetBackdropBorderColor(Hex(colors.border or colors.main))
    c.icon:SetTexture(CardIcon(item))
    local titleText = item.data.name or item.title
    if colors.titleGradient then
        c.title:SetText(GradientText(titleText, colors.titleGradient))
        c.title:SetTextColor(1, 1, 1)
    elseif colors.titleStripes then
        c.title:SetText(StripeText(titleText, colors.titleStripes))
        c.title:SetTextColor(1, 1, 1)
    else
        c.title:SetText(titleText)
        c.title:SetTextColor(Hex(colors.main))
    end
    c.title:SetShadowColor(DarkHex(colors.main, 0.25))
    c.title:SetShadowOffset(2, -2)
    -- The status line can be long ("ends Nov 2 at 12:00 PM (1:00 PM your time)"),
    -- so let it wrap inside the card and push the lines below down to fit
    c.status:SetWidth(width - 46 - 10)
    c.status:SetText(StatusText(item))
    local headerHeight = 9 + c.title:GetStringHeight() + 2 + c.status:GetStringHeight() + 6

    local ly = -math.max(46, math.ceil(headerHeight))
    for index, spec in ipairs(BuildLines(item)) do
        if spec.header and index > 1 then ly = ly - 4 end
        ly = ly - PlaceLine(c, spec, 12, ly, width - 24) - 3
    end
    c:SetHeight(-ly + 8)
    c:Show()
    return y - c:GetHeight() - 8
end

local QueueRedraw   -- defined below
local refreshToken  -- bumps each render, so only the latest end-of-event refresh runs
local retryCount = 0

---------------------------------------------------------------------------
-- Trading Post reminder
---------------------------------------------------------------------------
local TRADERS_TENDER = 2032   -- currency ID

local function TenderBalance()
    if not (C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo) then return nil end
    local info = C_CurrencyInfo.GetCurrencyInfo(TRADERS_TENDER)
    return info and info.quantity
end

-- Opens the Adventure Guide on the Traveler's Log, where Trader's Tender is earned
local function OpenTravelersLog()
    local ok = pcall(function()
        if not EncounterJournal and C_AddOns and C_AddOns.LoadAddOn then
            C_AddOns.LoadAddOn("Blizzard_EncounterJournal")
        end
        ShowUIPanel(EncounterJournal)
        if EncounterJournal.MonthlyActivitiesTab and EJ_ContentTab_Select then
            EJ_ContentTab_Select(EncounterJournal.MonthlyActivitiesTab:GetID())
        end
    end)
    if not ok and ToggleEncounterJournal then ToggleEncounterJournal() end
end

local function TradingPostLine()
    local today = C_DateAndTime.GetCurrentCalendarTime()
    local newThisWeek = today.monthDay <= 7
    local balance = TenderBalance()
    local text = newThisWeek
        and (Color("33FF33", "New this month: ") .. Color(SOFT, "the Trading Post has fresh items!"))
        or (Color("FFD100", "Trading Post: ") .. Color(SOFT, "new items arrive on the 1st of each month"))
    if balance then
        text = text .. Color(GRAY, "  (" .. balance .. " Tender)")
    end
    return {
        icon = ICONS.tradingPost,
        text = text,
        tooltip = function(tt)
            tt:AddLine("Trading Post", Hex(DEFAULT_COLORS.main))
            if balance then tt:AddDoubleLine("Your Trader's Tender", tostring(balance), 1, 1, 1, 1, 0.82, 0) end
            tt:AddLine(" ")
            tt:AddLine("Where", Hex(DEFAULT_COLORS.main))
            tt:AddDoubleLine("Stormwind", "on the city map", 1, 1, 1, 0.72, 0.68, 0.61)
            tt:AddDoubleLine("Orgrimmar", "on the city map", 1, 1, 1, 0.72, 0.68, 0.61)
            tt:AddDoubleLine("Silvermoon: The Bazaar (Midnight)", "49.0, 78.0", 1, 1, 1, 0.72, 0.68, 0.61)
            tt:AddDoubleLine("Dornogal: The Foregrounds (The War Within)", "44.6, 56.0", 1, 1, 1, 0.72, 0.68, 0.61)
            tt:AddLine(" ")
            tt:AddLine("Earning Trader's Tender", Hex(DEFAULT_COLORS.main))
            tt:AddLine("Complete activities in the Traveler's Log, in the Adventure Guide. New activities and new Trading Post items arrive on the 1st of every month, and unspent Tender carries over.", 1, 1, 1, true)
            tt:AddLine(" ")
            tt:AddLine("Click to open the Traveler's Log.", 0.72, 0.68, 0.61)
            AddWayTip(tt)
        end,
        onClick = OpenTravelersLog,
    }
end

local COLUMN_GAP = 12
local TWO_COLUMN_AT = 3      -- this many cards or more switches to two columns

-- Lays cards out in one column, or two balanced columns (each card goes into
-- whichever column is currently shorter). Returns the y below the lowest card.
local function PlaceCards(list, y, columns, columnWidth)
    if columns == 1 then
        for _, item in ipairs(list) do
            y = PlaceCard(item, y, columnWidth)
        end
        return y
    end
    local columnY = { y, y }
    for _, item in ipairs(list) do
        local col = (columnY[2] > columnY[1]) and 2 or 1      -- y is negative: larger = shorter column
        local x = 16 + (col - 1) * (columnWidth + COLUMN_GAP)
        columnY[col] = PlaceCard(item, columnY[col], columnWidth, x)
    end
    return math.min(columnY[1], columnY[2])
end

local function Render(items)
    ReleaseAll()
    lastItems = items
    pendingData = false
    local y = -46

    local holidays, weekly, micro = {}, {}, {}
    for _, item in ipairs(items) do
        if item.category == "holiday" then
            holidays[#holidays + 1] = item
        elseif item.category == "weekly" then
            weekly[#weekly + 1] = item
        elseif item.category == "micro" and item.data then
            micro[#micro + 1] = item
        end
    end

    -- Three or more cards: go wide, with two columns of cards
    local columns = (#holidays + #micro >= TWO_COLUMN_AT) and 2 or 1
    local columnWidth = POPUP_WIDTH - 32
    popup:SetWidth(columns * columnWidth + (columns - 1) * COLUMN_GAP + 32)
    local width = popup:GetWidth() - 32

    local hint = Color(GRAY, "Hover any line for details")
    if #holidays > 0 then
        y = PlaceHeader("Holidays", y, hint)
        hint = nil
        y = PlaceCards(holidays, y, columns, columnWidth)
    end

    if #micro > 0 then
        y = PlaceHeader("Micro-holidays", y, hint)
        y = PlaceCards(micro, y, columns, columnWidth)
    end

    -- When the daily reset happens, asked of the game so it's right in every region
    if HolidayHeraldDB.showReset and (#holidays > 0 or #micro > 0) and C_DateAndTime.GetSecondsUntilDailyReset then
        local seconds = C_DateAndTime.GetSecondsUntilDailyReset()
        local realmNow = ToEpoch(C_DateAndTime.GetCurrentCalendarTime())
        if seconds and realmNow then
            -- Round to the nearest 5 minutes; the game's countdown drifts by a minute or two
            local r = date("*t", math.floor((realmNow + seconds) / 300 + 0.5) * 300)
            local when = FormatEnd({ year = r.year, month = r.month, monthDay = r.day, hour = r.hour, minute = r.min })
            local hours, minutes = math.floor(seconds / 3600), math.floor((seconds % 3600) / 60)
            y = y - PlaceLine(popup, {
                icon = ICONS.reset,
                text = Color(SOFT, "Daily reset: " .. when),
                tooltip = function(tt)
                    tt:AddLine("Daily reset", Hex(DEFAULT_COLORS.main))
                    tt:AddLine(("In %dh %02dm."):format(hours, minutes), 1, 1, 1)
                    tt:AddLine("Daily quests and the holiday boss's daily loot come back at this time every day.", 0.72, 0.68, 0.61, true)
                    tt:AddLine("Change how times are shown under Start and end times in the settings.", 0.55, 0.52, 0.47, true)
                end,
            }, 20, y, width - 8) - 2
        end
    end

    local showWeeklySection = (#weekly > 0 and HolidayHeraldDB.showWeekly) or HolidayHeraldDB.showTradingPost
    if showWeeklySection then
        y = PlaceHeader("Weekly Events", y)
        if HolidayHeraldDB.showTradingPost then
            y = y - PlaceLine(popup, TradingPostLine(), 20, y, width - 8) - 2
        end
    end
    if #weekly > 0 and HolidayHeraldDB.showWeekly then
        for _, item in ipairs(weekly) do
            local label
            local title = item.title
            if item.expansion then
                title = title .. Color(DEFAULT_COLORS.main, " (" .. item.expansion .. ")")
            end
            if item.daysAway == 0 and item.started ~= false then
                local ends = FormatEnd(item.endTime)
                label = Color("33FF33", "Now: ") .. Color(SOFT, title .. (ends and (", ends " .. ends) or ""))
            elseif item.daysAway <= 1 then
                label = Color("FFD100", "Starts " .. (FormatEnd(item.startTime) or "soon") .. ": ") .. Color(SOFT, title)
            else
                label = Color("FFD100", "In " .. item.daysAway .. " days: ") .. Color(SOFT, title)
            end
            local tooltip
            if item.description and item.description ~= "" then
                tooltip = TextTooltip(item.title, DEFAULT_COLORS, item.description)
            end
            y = y - PlaceLine(popup, { text = label, tooltip = tooltip }, 20, y, width - 8) - 2
        end
    end

    if #holidays == 0 and #micro == 0 and not showWeeklySection then
        y = y - PlaceLine(popup, { text = Color(SOFT, "No holidays or events in the next " .. HolidayHeraldDB.lookahead .. " days.") }, 20, y, width - 8)
    end

    popup:SetHeight(-y + 18)

    -- If something starts or ends while the popup is open, refresh right after
    local today = C_DateAndTime.GetCurrentCalendarTime()
    local now, soonest = ToEpoch(today), nil
    for _, item in ipairs(items) do
        -- The next moment something starts or ends
        for _, moment in ipairs({ item.startEpoch or 0, item.endEpoch or 0 }) do
            if now and moment > now then
                soonest = math.min(soonest or moment, moment)
            end
        end
    end
    refreshToken = (refreshToken or 0) + 1
    if soonest and soonest - now < 12 * 3600 then
        local token = refreshToken
        C_Timer.After(soonest - now + 5, function()
            if token == refreshToken and popup:IsShown() then
                lastItems = ScanCalendar()
                Render(lastItems)
            end
        end)
    end

    -- Some collection data wasn't ready; try again shortly (a few times at most)
    if pendingData and retryCount < 5 then
        retryCount = retryCount + 1
        C_Timer.After(1.5, function() QueueRedraw() end)
    elseif not pendingData then
        retryCount = 0
    end
end

HH.Rerender = function()
    if popup:IsShown() and lastItems then Render(lastItems) end
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
    local msg = name .. (item.daysAway == 0 and " is TODAY ONLY!" or (" starts in " .. item.daysAway .. (item.daysAway == 1 and " day!" or " days!")))
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
    -- More than a day out: just a quiet chat line, the noise comes closer to the day
    if (item.daysAway or 0) > 1 then
        local themed = name
        if item.data and item.data.colors and HolidayHeraldDB.showThemes then themed = ThemedText(name, item.data.colors) end
        Print(themed .. msg:sub(#name + 1) .. " " .. OPEN_LINK)
        return
    end
    if HolidayHeraldDB.alertMessage then
        RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
    end
    Print(msg)
    if HolidayHeraldDB.alertSound then PlaySound(ALERT_SOUND_ID) end
end

-- While you're playing: if a holiday starts (most begin at midnight or in the
-- morning), pop up once for it. Waits until you're out of combat.
-- Holiday bosses whose dungeon is open right now, and when the next holiday
-- starts (calendar time), both refreshed whenever the calendar is scanned
local activeBossLfg = {}
local nextStartAt = nil
local activeHolidayData = {}   -- data for every holiday that's on right now

---------------------------------------------------------------------------
-- HandyNotes map pins (optional: only if HandyNotes is installed)
-- A holiday's data can list pins = { { map = uiMapID, x = 53.9, y = 33.8,
--   title = "...", note = { "line", { "left", "right" }, ... }, faction = "Horde", warning = true,
--   icon = "Interface\\Icons\\..." (optional, replaces the pin icon), noContinent = true } }
-- Pins only show while that holiday is on, and only for your faction.
---------------------------------------------------------------------------
local PIN_ICON = "Interface\\AddOns\\HolidayHerald\\Media\\icon"
local pinLookup = {}   -- [uiMapID] = { [coord] = { pin = pin, data = data } }

local function PackCoord(x, y)
    return math.floor(x * 100 + 0.5) * 10000 + math.floor(y * 100 + 0.5)
end

-- The continent a zone map sits on (nil if none)
local function ContinentOf(uiMapID)
    local info = C_Map.GetMapInfo(uiMapID)
    while info and info.parentMapID and info.parentMapID ~= 0 do
        info = C_Map.GetMapInfo(info.parentMapID)
        if info and info.mapType == Enum.UIMapType.Continent then return info.mapID end
    end
end

local function AddPin(uiMapID, x, y, entry)
    pinLookup[uiMapID] = pinLookup[uiMapID] or {}
    pinLookup[uiMapID][PackCoord(x, y)] = entry
end

local function RebuildPins()
    wipe(pinLookup)
    if not HolidayHeraldDB.showPins then return end
    for _, data in ipairs(activeHolidayData) do
        for _, pin in ipairs(data.pins or {}) do
            if ForMyFaction(pin) then
                AddPin(pin.map, pin.x, pin.y, { pin = pin, data = data })
                -- Also show it on the continent map (smaller), placed by where the zone sits on it
                local cont = not pin.noContinent and ContinentOf(pin.map)
                local minX, maxX, minY, maxY
                if cont then minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(pin.map, cont) end
                if minX and maxX and minY and maxY and maxX > minX and maxY > minY then
                    local cx = (minX + pin.x / 100 * (maxX - minX)) * 100
                    local cy = (minY + pin.y / 100 * (maxY - minY)) * 100
                    if cx > 0 and cx < 100 and cy > 0 and cy < 100 then
                        AddPin(cont, cx, cy, { pin = pin, data = data, onContinent = true })
                    end
                end
            end
        end
    end
end

local PinHandler = {}

function PinHandler:GetNodes2(uiMapID, minimap)
    local nodes = pinLookup[uiMapID]
    local coord
    return function()
        if not nodes then return nil end
        local entry
        coord, entry = next(nodes, coord)
        if coord then
            local icon = entry.pin.icon or (entry.pin.warning and ICONS.boss) or PIN_ICON
            return coord, nil, icon, entry.onContinent and 1 or 1.4, 1
        end
    end
end

-- HandyNotes calls these with self = the pin on the map
function PinHandler:OnEnter(uiMapID, coord)
    local entry = pinLookup[uiMapID] and pinLookup[uiMapID][coord]
    if not entry then return end
    local tt = GameTooltip
    tt:SetOwner(self, (self:GetCenter() > UIParent:GetCenter()) and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
    local colors = (HolidayHeraldDB.showThemes and entry.data.colors) or DEFAULT_COLORS
    tt:AddLine(entry.pin.title, Hex(entry.pin.warning and "FF6B6B" or colors.main))
    local where = ("(%.1f, %.1f)"):format(entry.pin.x, entry.pin.y)
    if entry.onContinent then
        local zone = C_Map.GetMapInfo(entry.pin.map)
        if zone then where = "(" .. zone.name .. " " .. where:sub(2) end
    end
    tt:AddLine((entry.data.name or "Holiday") .. "  " .. where, 0.72, 0.68, 0.61)
    local note = entry.pin.note
    if type(note) == "string" then note = { note } end
    for _, line in ipairs(note or {}) do
        if type(line) == "table" then
            tt:AddDoubleLine(line[1], line[2], 1, 1, 1, 0.72, 0.68, 0.61)
        elseif line:sub(1, 1) == "#" then
            tt:AddLine(" ")
            tt:AddLine(line:sub(2), Hex(colors.accent))
        else
            tt:AddLine(line, 1, 1, 1, true)
        end
    end
    if TomTom and TomTom.AddWaypoint then
        tt:AddLine(" ")
        tt:AddLine("Click: set a TomTom waypoint", 1, 0.82, 0)
    end
    tt:Show()
end

function PinHandler:OnLeave()
    GameTooltip:Hide()
end

function PinHandler:OnClick(button, down, uiMapID, coord)
    if button ~= "LeftButton" or down then return end
    local entry = pinLookup[uiMapID] and pinLookup[uiMapID][coord]
    if entry and TomTom and TomTom.AddWaypoint then
        TomTom:AddWaypoint(entry.pin.map, entry.pin.x / 100, entry.pin.y / 100, { title = entry.pin.title, from = "Holiday Herald" })
    end
end

HH.RefreshPins = function()
    RebuildPins()
    if HandyNotes and HandyNotes.SendMessage then
        HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "HolidayHerald")
    end
end

local function RegisterHandyNotes()
    if not (HandyNotes and HandyNotes.RegisterPluginDB) then return end
    HandyNotes:RegisterPluginDB("HolidayHerald", PinHandler, {
        type = "group",
        name = "Holiday Herald",
        desc = "Holiday spots, shown only while that holiday is on.",
        args = {
            about = {
                type = "description", order = 1,
                name = "Pins for the holidays that are on right now, like event hubs and hard-to-find vendors. "
                    .. "Hover a pin for details. With TomTom installed, click one to set a waypoint.",
            },
        },
    })
end

-- Re-save this character's count for the currencies of holidays that are on now
local function SaveActiveCurrencies()
    for _, data in ipairs(activeHolidayData) do
        if data.currency then HH.SaveCurrencyCount(data.currency.item) end
    end
end

local function NoteScan(items)
    wipe(activeBossLfg)
    wipe(activeHolidayData)
    nextStartAt = nil
    for _, item in ipairs(items) do
        if item.data and item.daysAway == 0 and item.started ~= false then
            activeHolidayData[#activeHolidayData + 1] = item.data
        end
        local boss = item.data and item.data.boss
        if boss and boss.lfg and item.daysAway == 0 and item.started ~= false then
            activeBossLfg[boss.lfg] = true
        end
        if item.category == "holiday" and item.started == false and item.startEpoch then
            nextStartAt = math.min(nextStartAt or item.startEpoch, item.startEpoch)
        end
    end
    HH.RefreshPins()
end

-- Saves "best roll used" for the account as soon as the game says the holiday
-- boss is done today, on whichever character did it (no need to open the popup)
local function RecordBestRolls()
    if not GetLFGDungeonRewards then return end
    for lfg in pairs(activeBossLfg) do
        if GetLFGDungeonRewards(lfg) then
            HolidayHeraldDB.bestRoll[lfg] = GetServerTime() + (C_DateAndTime.GetSecondsUntilDailyReset() or 0)
        end
    end
end

-- Instead of checking every minute, set one alarm: for the moment the next
-- holiday starts, or in 6 hours as a safety net if the calendar changes
local SAFETY_CHECK = 6 * 3600
local wakeTimer
local CheckForNewStarts
local DayAlerts
local StartNotice

local function ScheduleNextCheck(delay)
    if wakeTimer then wakeTimer:Cancel() end
    if not delay then
        delay = SAFETY_CHECK
        local nowCal = ToEpoch(C_DateAndTime.GetCurrentCalendarTime())
        if nextStartAt and nowCal then
            delay = math.min(delay, nextStartAt - nowCal + 5)   -- a few seconds after it starts
        end
    end
    wakeTimer = C_Timer.NewTimer(math.max(5, delay), function() CheckForNewStarts() end)
end

-- "Hallow's End has started!" at the top of the screen, plus a chat line with a link
StartNotice = function(item)
    local name = (item.data and item.data.name) or item.title
    if HolidayHeraldDB.alertMessage then
        RaidNotice_AddMessage(RaidWarningFrame, name .. " has started!", ChatTypeInfo["RAID_WARNING"])
    end
    -- A soft ding (the calendar's own event-reminder chime), so you hear it while alt-tabbed
    if HolidayHeraldDB.alertSound then PlaySound(START_SOUND_ID) end
    if item.data and item.data.colors and HolidayHeraldDB.showThemes then
        name = ThemedText(name, item.data.colors)
    end
    Print(name .. " has started! " .. OPEN_LINK)
end

CheckForNewStarts = function()
    -- Busy? Try again in a minute
    if InCombatLockdown() then
        ScheduleNextCheck(60)
        return
    end
    local seen = HolidayHeraldCharDB.seen
    local items = ScanCalendar()
    NoteScan(items)
    RecordBestRolls()
    ScheduleNextCheck()
    DayAlerts(items)
    -- A holiday started while you're playing: no big popup in your face, just a
    -- raid-warning style heads-up and a chat line with a link to open it
    for _, item in ipairs(items) do
        if item.category == "holiday" and item.started and not seen[item.key .. "#started"] then
            seen[item.key] = true
            seen[item.key .. "#started"] = true
            -- Short holidays already got their own (louder) alert from DayAlerts
            local shortAlerted = item.isShort and HolidayHeraldDB.alertDays >= 0 and item.daysAway <= HolidayHeraldDB.alertDays
            if not shortAlerted then StartNotice(item) end
        end
    end
    if popup:IsShown() then Render(items) end
end

local function HandleLogin()
    local items = ScanCalendar()
    NoteScan(items)
    RecordBestRolls()
    local seen = HolidayHeraldCharDB.seen
    local alerted = HolidayHeraldCharDB.alerted

    -- Full popup the first time this character sees a holiday; chat line after
    -- and again once it actually starts (if that setting is on)
    local holidays, unseen = {}, false
    for _, item in ipairs(items) do
        if item.category == "holiday" then
            holidays[#holidays + 1] = item
            if not seen[item.key] then unseen = true end
            if HolidayHeraldDB.popupOnStart and item.started and not seen[item.key .. "#started"] then unseen = true end
        end
    end
    local function MarkSeen()
        for _, item in ipairs(holidays) do
            seen[item.key] = true
            if item.started then seen[item.key .. "#started"] = true end
        end
    end
    if unseen and HolidayHeraldDB.showPopup then
        Render(items)
        popup:Show()
        MarkSeen()
    elseif #holidays > 0 then
        MarkSeen()
        -- "Now: A, ends today at 11:59 PM. Coming up: B in 9 days."
        local onNow, comingUp = {}, {}
        for _, item in ipairs(holidays) do
            local colors = HolidayHeraldDB.showThemes and item.data.colors or DEFAULT_COLORS
            local name = ThemedText(item.data.name or item.title, colors)
            if item.started then
                local ends = FormatEnd(item.endTime)
                onNow[#onNow + 1] = name .. (ends and (", ends " .. ends) or "")
            elseif item.daysAway == 0 then
                comingUp[#comingUp + 1] = name .. " later today"
            else
                comingUp[#comingUp + 1] = name .. " in " .. item.daysAway
                    .. (item.daysAway == 1 and " day" or " days")
            end
        end
        local parts = {}
        if #onNow > 0 then parts[#parts + 1] = "Now: " .. table.concat(onNow, "; ") .. "." end
        if #comingUp > 0 then parts[#parts + 1] = "Coming up: " .. table.concat(comingUp, ", ") .. "." end
        Print(table.concat(parts, " ") .. " " .. OPEN_LINK)
    end

    DayAlerts(items)
end

-- Micro-holiday chat line and short-holiday alerts. Runs at login and whenever
-- a holiday starts while you're playing; each one only fires once.
DayAlerts = function(items)
    local seen = HolidayHeraldCharDB.seen
    local alerted = HolidayHeraldCharDB.alerted

    -- Micro-holidays: one chat line on the day
    for _, item in ipairs(items) do
        if HolidayHeraldDB.microChat and item.category == "micro" and item.daysAway == 0 and not seen[item.key] then
            local name = (item.data and item.data.name) or item.title
            if item.data and item.data.colors and HolidayHeraldDB.showThemes then
                name = ThemedText(name, item.data.colors)
            end
            local tip = (item.data and item.data.tip and HolidayHeraldDB.showTips) and (" " .. item.data.tip.short) or ""
            Print("today's micro-holiday is " .. name .. "." .. tip .. " " .. OPEN_LINK)
            seen[item.key] = true
        end
    end

    -- Short-holiday alerts
    for _, item in ipairs(items) do
        if item.category == "holiday" and item.isShort and HolidayHeraldDB.alertDays >= 0 and item.daysAway <= HolidayHeraldDB.alertDays then
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
        category = data.micro and "micro" or "holiday",
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

-- Toasts wait their turn, so several achievements at once don't overlap
local toastQueue, toastShowing = {}, false
local ShowNextToast

local function DisplayToast(t)
    toastShowing = true
    toast.icon:SetTexture(t.icon or ICONS.mascot)
    toast:SetBackdropColor(Hex(t.colors.card))
    toast:SetBackdropBorderColor(Hex(t.colors.border or t.colors.main))
    toast.title:SetText(t.title)
    toast.title:SetTextColor(Hex(t.colors.main))
    toast.titleBack:SetText(t.title)
    toast.titleBack:SetTextColor(DarkHex(t.colors.main))
    toast.subtitle:SetText(t.subtitle)
    toast:SetAlpha(1)
    toast:Show()
    if t.sound then
        -- Wait a moment so it doesn't pile on top of the game's own chime
        C_Timer.After(1, function() PlaySound(t.sound) end)
    end
    C_Timer.After(t.duration or 6, function()
        UIFrameFadeOut(toast, 1.5, 1, 0)
        C_Timer.After(1.6, function()
            toast:Hide()
            toastShowing = false
            ShowNextToast()
        end)
    end)
end

function ShowNextToast()
    if toastShowing or #toastQueue == 0 then return end
    DisplayToast(table.remove(toastQueue, 1))
end

local function QueueToast(t)
    if #toastQueue >= 5 then return end     -- a big batch at once only shows the first few
    toastQueue[#toastQueue + 1] = t
    ShowNextToast()
end

-- Holiday celebration toast: the thumbs-up herald
local function ShowToast(colors, title, subtitle, big)
    if not HolidayHeraldDB.toast then return end
    QueueToast({
        colors = colors, title = title, subtitle = subtitle, icon = ICONS.mascot,
        duration = big and 8 or 6,
        sound = HolidayHeraldDB.fanfare and (big and BIG_FANFARE_SOUND_ID or FANFARE_SOUND_ID) or nil,
    })
end

-- Everyday achievement toast: the tea-sipping herald
local TEA_COLORS = { main = "E3C27A", accent = "B48CE0", card = "1C1824", border = "B48CE0" }
local TEA_TITLES = {
    "Tea-rrific!",
    "Jolly good show!",
    "Splendid, simply splendid!",
    "Pinkies up!",
    "How delightful!",
}

local function TeaToast(achievementID)
    if not HolidayHeraldDB.achievementToast then return end
    local _, name, points = GetAchievementInfo(achievementID)
    if not name then return end
    QueueToast({
        colors = TEA_COLORS,
        title = TEA_TITLES[math.random(#TEA_TITLES)],
        subtitle = name .. ((points and points > 0) and Color(GRAY, "  (" .. points .. " points)") or ""),
        icon = ICONS.teatime,
        duration = 5,
    })
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
    -- Any other achievement gets the everyday toast
    TeaToast(achievementID)
end

---------------------------------------------------------------------------
-- Settings panel (Options > AddOns > NerdyBertie > Holiday Herald)
---------------------------------------------------------------------------
local PRESETS = {
    all     = {},
    visuals = { alertSound = false, fanfare = false },
    quiet   = { alertMessage = false, alertSound = false, toast = false, fanfare = false, microChat = false, achievementToast = false },
}
-- The presets only change these (how loud Holiday Herald is), never the display settings
local PRESET_KEYS = { "alertMessage", "alertSound", "toast", "fanfare", "microChat", "achievementToast" }
local settingObjects = {}
local settingsCategory

-- Which preset matches the current settings, or "custom" if none do
local function CurrentPreset()
    for _, name in ipairs({ "all", "visuals", "quiet" }) do
        local matches = true
        for _, key in ipairs(PRESET_KEYS) do
            local expected = PRESETS[name][key]
            if expected == nil then expected = true end
            if HolidayHeraldDB[key] ~= expected then matches = false break end
        end
        if matches then return name end
    end
    return "custom"
end

local function ApplyPreset(name)
    if not PRESETS[name] then return end
    for _, key in ipairs(PRESET_KEYS) do
        local value = PRESETS[name][key]
        if value == nil then value = true end
        if settingObjects[key] then
            settingObjects[key]:SetValue(value)
        else
            HolidayHeraldDB[key] = value
        end
    end
end

-- Shared "NerdyBertie" heading: whichever NerdyBertie addon loads first creates it.
-- Every NerdyBertie addon carries this same function, the same list, and the
-- same Media/workshop.tga image, so the page looks the same whoever builds it.
local WORKSHOP_ADDONS = {
    { name = "HandyNotes: Dive Bar Front Crawl", folder = "HandyNotes_DiveBarCrawl" },
    { name = "HandyNotes: Seeking the Soulstones", folder = "HandyNotes_SeekingTheSoulstones" },
    { name = "ItemWatch",                        folder = "ItemWatch" },
    { name = "Boomkin Buff Watcher",             folder = "BoomkinBuffWatcher" },
    { name = "Holiday Herald",                   folder = "HolidayHerald" },
}

local function GetBrandCategory()
    if NerdyBertie_SettingsCategory then return NerdyBertie_SettingsCategory end
    local panel = CreateFrame("Frame")

    local mascot = panel:CreateTexture(nil, "ARTWORK")
    mascot:SetSize(80, 80)
    mascot:SetPoint("TOPLEFT", 16, -16)
    mascot:SetTexture("Interface\\AddOns\\" .. ADDON .. "\\Media\\workshop")

    local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    heading:SetPoint("TOPLEFT", mascot, "TOPRIGHT", 14, -10)
    heading:SetText("NerdyBertie's Addon Workshop")

    local presents = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    presents:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -6)
    presents:SetText("presents...")

    local blurb = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    blurb:SetPoint("TOPLEFT", mascot, "BOTTOMLEFT", 0, -16)
    blurb:SetWidth(560)
    blurb:SetJustifyH("LEFT")
    blurb:SetText("Addons for quality of life improvements. If you'd like to check out my other addons, here's the list:")

    local lines = {}
    for i, addon in ipairs(WORKSHOP_ADDONS) do
        local line = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line:SetPoint("TOPLEFT", (i == 1) and blurb or lines[i - 1], "BOTTOMLEFT", (i == 1) and 12 or 0, (i == 1) and -12 or -6)
        lines[i] = line
        line.addon = addon
    end

    local footer = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    footer:SetPoint("TOPLEFT", lines[#lines], "BOTTOMLEFT", -12, -16)
    footer:SetWidth(560)
    footer:SetJustifyH("LEFT")
    footer:SetText("Find them all on CurseForge, Wago, and WoWInterface. Pick an installed one from the list on the left to see its settings.")

    -- Fill in the list, with "installed" marks. This runs right away, and again
    -- every time the page is shown, since other addons may load after this one.
    local function RefreshList()
        for i, line in ipairs(lines) do
            local loaded = C_AddOns and C_AddOns.IsAddOnLoaded(line.addon.folder)
            line:SetText(i .. ". " .. line.addon.name
                .. (loaded and "  |cff33ff33(installed)|r" or ""))
        end
    end
    RefreshList()
    panel:SetScript("OnShow", RefreshList)
    -- Start hidden so the first time the page is opened counts as "shown"
    panel:Hide()

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

    Header("Quick setup: how loud Holiday Herald is")
    do
        -- A dropdown that shows the preset currently in use ("Custom" once you
        -- change individual settings), and applies a preset when you pick one.
        local setting = Settings.RegisterProxySetting(category, "HolidayHerald_preset", "string",
            "Alerts and sounds", "all", CurrentPreset, function(value) ApplyPreset(value) end)
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add("all", "All on (alerts + sounds)", "Everything on, sounds included.")
            container:Add("visuals", "Visuals only (no sounds)", "All messages and toasts, no sounds.")
            container:Add("quiet", "Quiet (popup + chat only)", "Just the popup and chat lines. No alerts or toasts.")
            if CurrentPreset() == "custom" then
                container:Add("custom", "Custom (your own picks)", "You've changed individual settings below.")
            end
            return container:GetData()
        end
        CreateDropdown(category, setting, GetOptions,
            "A one-click way to set how loud Holiday Herald is. All on: every alert, toast, and sound. Visuals only: the same, but silent. Quiet: just the popup and chat lines. Changing a setting below switches this to Custom.")
    end

    Header("Popup")
    Checkbox("showPopup", "Show popup for new holidays",
        "Show the full popup the first time each character sees a holiday. After that, it's a chat line.")
    Checkbox("popupOnStart", "Popup when a holiday starts",
        "Show the popup again when you log in on the day a holiday begins, even if you saw it earlier in the week. If you're already playing when it starts, you get an on-screen heads-up and a chat link instead.")
    do
        local setting = Settings.RegisterAddOnSetting(category, "HolidayHerald_lookahead", "lookahead",
            HolidayHeraldDB, "number", "Look ahead (days)", DB_DEFAULTS.lookahead)
        settingObjects.lookahead = setting
        local options = Settings.CreateSliderOptions(1, 14, 1)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
        Settings.CreateSlider(category, setting, options, "How many days ahead to list upcoming holidays.")
    end
    do
        local setting = Settings.RegisterAddOnSetting(category, "HolidayHerald_timeDisplay", "timeDisplay",
            HolidayHeraldDB, "string", "Start and end times", DB_DEFAULTS.timeDisplay)
        settingObjects.timeDisplay = setting
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add("both", "Server time + (your time)")
            container:Add("realm", "Server time only")
            container:Add("local", "Your time only")
            return container:GetData()
        end
        CreateDropdown(category, setting, GetOptions,
            "Holiday times follow your realm's clock, the same one the in-game calendar uses. Each realm keeps its own time zone, so it isn't always Pacific. Show server time, your computer's time, or server time with yours after it. If the two clocks match, you'll only see one time.")
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
    Button("Popup position", "Reset", function()
        ResetPopupPosition()
        Print("popup moved back to its default spot.")
    end, "Move the Holiday Herald popup back to the middle of the screen.")
    Checkbox("showThemes", "Holiday color themes", "Give each holiday card its own colors.")
    Checkbox("showTradingPost", "Trading Post reminder",
        "Show the Trading Post and your Trader's Tender under Weekly Events. Click it to open the Traveler's Log.")
    Checkbox("showWeekly", "Weekly events", "List brawls, bonus events, and Timewalking under Weekly Events.")
    Checkbox("showReset", "Daily reset time", "Show when daily quests reset, under the holiday cards.")

    Header("What the cards show")
    Checkbox("showMeta", "Meta achievement line", "Link to the holiday's part of the Violet Proto-Drake meta.")
    Checkbox("showTips", "Tips", "One helpful tip per holiday, with more on hover.")
    Checkbox("showClass", "Class lines", "Class-specific goodies, like hunter pets, labeled for everyone.")
    Checkbox("showSecrets", "Secrets", "Spoiler teasers that reveal on hover.")
    Checkbox("showPins", "Map pins (HandyNotes)",
        "With HandyNotes installed, show holiday spots on your map, like event hubs and vendors, while the holiday is on.")
    if Settings.SetOnValueChangedCallback then
        Settings.SetOnValueChangedCallback("HolidayHerald_showPins", function() HH.RefreshPins() end)
    end

    Header("Alerts")
    do
        local setting = Settings.RegisterAddOnSetting(category, "HolidayHerald_alertDays", "alertDays",
            HolidayHeraldDB, "number", "Short-holiday heads-up", DB_DEFAULTS.alertDays)
        settingObjects.alertDays = setting
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(-1, "Off")
            container:Add(0, "Day of only")
            container:Add(1, "1 day before")
            container:Add(3, "3 days before")
            container:Add(7, "1 week before")
            return container:GetData()
        end
        CreateDropdown(category, setting, GetOptions,
            "When to start reminding you about short holidays (three days or less). Until the day before, it's a quiet chat line once a day; the day before and the day of, you get the full alert. Off turns these reminders off; the holiday still shows in the popup as usual.")
    end
    Checkbox("alertMessage", "On-screen alert", "Show short-holiday alerts in the middle of the screen.")
    Checkbox("alertSound", "Alert sound", "Play a sound with short-holiday alerts.")
    Checkbox("microChat", "Micro-holiday chat lines", "One chat line on the day of each micro-holiday.")

    Header("Celebrations")
    Checkbox("toast", "Celebration toast", "A \"Grats!\" toast when you finish a holiday's meta achievement.")
    Checkbox("fanfare", "Celebration fanfare", "Play a fanfare with the celebration toast.")
    Checkbox("achievementToast", "Toast for every achievement",
        "A small toast from the tea-sipping herald whenever you earn any achievement.")
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
local function RunLogin()
    if loginDone then return end
    loginDone = true
    HandleLogin()
    SaveActiveCurrencies()
    ScheduleNextCheck()
end

events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        HolidayHeraldDB = HolidayHeraldDB or {}
        HolidayHeraldDB.bestRoll = HolidayHeraldDB.bestRoll or {}
        HolidayHeraldDB.minimapIcon = HolidayHeraldDB.minimapIcon or {}
        HolidayHeraldDB.folded = HolidayHeraldDB.folded or {}
        for key, value in pairs(DB_DEFAULTS) do
            if HolidayHeraldDB[key] == nil then HolidayHeraldDB[key] = value end
        end
        -- Keep the heads-up setting on one of the dropdown's choices
        local validDays = { [-1] = true, [0] = true, [1] = true, [3] = true, [7] = true }
        if not validDays[HolidayHeraldDB.alertDays] then HolidayHeraldDB.alertDays = 3 end
        HolidayHeraldCharDB = HolidayHeraldCharDB or {}
        HolidayHeraldCharDB.seen    = HolidayHeraldCharDB.seen or {}
        HolidayHeraldCharDB.alerted = HolidayHeraldCharDB.alerted or {}
        PrepareData()
        HH.BuildSettings()

    elseif event == "PLAYER_LOGIN" then
        CreateMinimapButton()
        RegisterHandyNotes()
        self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
        self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        self:RegisterEvent("ITEM_DATA_LOAD_RESULT")
        self:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
        self:RegisterEvent("LFG_COMPLETION_REWARD")
        self:RegisterEvent("ACHIEVEMENT_EARNED")
        self:RegisterEvent("BAG_UPDATE_DELAYED")
        RequestAllItems()
        if RequestLFDPlayerLockInfo then RequestLFDPlayerLockInfo() end
        C_Calendar.OpenCalendar()
        -- Backup: if the calendar never answers, carry on anyway after 20 seconds
        C_Timer.After(20, RunLogin)

    elseif event == "CALENDAR_UPDATE_EVENT_LIST" then
        -- This fires several times in a row; wait for it to settle once
        if loginDone or loginPending then return end
        loginPending = true
        C_Timer.After(2, function()
            loginPending = false
            RunLogin()
        end)

    elseif event == "BAG_UPDATE_DELAYED" then
        -- Cheap: only re-counts the currency of holidays that are on now
        if loginDone then SaveActiveCurrencies() end

    elseif event == "ACHIEVEMENT_EARNED" then
        CelebrateAchievement(arg1)
        QueueRedraw()

    elseif event == "LFG_UPDATE_RANDOM_INFO" or event == "LFG_COMPLETION_REWARD" then
        RecordBestRolls()
        QueueRedraw()

    elseif event == "GET_ITEM_INFO_RECEIVED" or event == "ITEM_DATA_LOAD_RESULT" then
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
    elseif cmd == "resetpos" then
        ResetPopupPosition()
        Print("popup moved back to its default spot.")
    elseif cmd == "weekly" then
        HolidayHeraldDB.showWeekly = not HolidayHeraldDB.showWeekly
        Print("weekly events " .. (HolidayHeraldDB.showWeekly and "shown." or "hidden."))
    elseif cmd == "debug" then
        HolidayHeraldDB.debug = (arg1 == "on")
        Print("preview commands " .. (HolidayHeraldDB.debug and "unlocked." or "locked."))
    elseif cmd == "preview" or cmd == "alert" or cmd == "reset" or cmd == "toast" or cmd == "start" then
        if not HolidayHeraldDB.debug then
            Print("type /herald debug on first.")
            return
        end
        if cmd == "start" and not arg1 then
            -- Act as if every holiday that's on now just started: runs the real mid-game check
            for key in pairs(HolidayHeraldCharDB.seen) do
                if key:find("#started$") then HolidayHeraldCharDB.seen[key] = nil end
            end
            CheckForNewStarts()
        elseif cmd == "start" then
            local data = FindDataByKey(arg1)
            if data then StartNotice({ title = data.name, data = data }) end
        elseif cmd == "reset" then
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
            elseif arg1 == "tea" then
                TeaToast(6)      -- "Level 10", just for a preview
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
        Print("commands: /herald, /herald options, /herald resetpos, /herald weekly, /herald debug on|off, /herald preview <holiday> [soon|done], /herald alert <holiday>, /herald start [holiday], /herald reset")
    end
end
