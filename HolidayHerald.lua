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
    achievementToast = true,   -- a small toast for every achievement
    showTradingPost  = true,   -- Trading Post reminder under Weekly Events
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
    teatime  = "Interface\\AddOns\\HolidayHerald\\Media\\teatime",
    tradingPost = "Interface\\Icons\\INV_Misc_Coin_17",
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

-- "Oct 10 at 11:59 PM", or "today at 7:00 AM" / "tomorrow at 7:00 AM" when it's that close
local function FormatEnd(t)
    if not t or not t.month then return nil end
    local today = C_DateAndTime.GetCurrentCalendarTime()
    local tomorrow = C_DateAndTime.AdjustTimeByDays(today, 1)
    local hour, minute = t.hour or 0, t.minute or 0
    local clock = ("%d:%02d %s"):format((hour % 12 == 0) and 12 or (hour % 12), minute, hour < 12 and "AM" or "PM")
    if t.year == today.year and t.month == today.month and t.monthDay == today.monthDay then
        return "today at " .. clock
    elseif t.year == tomorrow.year and t.month == tomorrow.month and t.monthDay == tomorrow.monthDay then
        return "tomorrow at " .. clock
    end
    return FormatDate(t) .. " at " .. clock
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

-- A clickable item link, even if the item isn't cached yet
local function ItemLink(id, name)
    local _, link = C_Item.GetItemInfo(id)
    return link or ("|cffffffff|Hitem:%d::::::::::::::|h[%s]|h|r"):format(id, name or ("Item " .. id))
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
    if entry.achievement then return AchievementDone(entry.achievement) end
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
-- Entries can be marked faction = "Alliance" or "Horde"; others are skipped
local function ForMyFaction(entry)
    return not entry.faction or entry.faction == UnitFactionGroup("player")
end

local function CountOwned(list)
    local owned, total, reminders = 0, 0, 0
    for _, entry in ipairs(list) do
        if not ForMyFaction(entry) then
            -- not for this character's faction
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
                if drop.kind == "drake" or drop.kind == "ensemble" then drop.reminderOnly = true end
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
    -- the next big holiday coming up, then the next micro-holiday coming up,
    -- then a big holiday that's on now, then a micro-holiday that's on now
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
    local pick = nextBig or nextMicro or nowBig or nowMicro
    chatTheme = (HolidayHeraldDB.showThemes and pick) and pick.data.colors or nil
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

local function ListTooltip(title, list, colors, notes)
    return function(tt)
        tt:AddLine(title, Hex(colors.main))
        for _, entry in ipairs(list) do
          if ForMyFaction(entry) then
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
        end
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
local function AchievementToOpen(list)
    local first
    for _, entry in ipairs(list or {}) do
        if entry.achievement and ForMyFaction(entry) then
            first = first or entry.achievement
            if not AchievementDone(entry.achievement) then return entry.achievement end
        end
    end
    return first
end

local function AchievementClick(id)
    return function()
        if not id then return end
        if IsShiftKeyDown() then LinkAchievement(id) else OpenAchievement(id) end
    end
end

-- Returns a count line spec, and whether that category is finished
local function CountLine(holidayName, field, list, colors)
    local info = COUNT_LABELS[field]
    local owned, total, reminders = CountOwned(list)
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
    if field == "achievements" then
        local target = AchievementToOpen(list)
        spec.tooltip = ListTooltip(holidayName .. ": " .. info.label, list, colors,
            { "Click: open in the achievement window. Shift-click: link it in chat." })
        spec.onClick = AchievementClick(target)
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
                .. (doneToday and Color(GRAY, "done") or Color(colors.main, "not done"))
        end

        local notes = {
            "Your first boss kill of the day, across your whole account, gets the best mount chance. "
                .. "Each alt can still try once a day at a much lower chance.",
        }
        if boss.hardMode then notes[#notes + 1] = "Hard mode: " .. boss.hardMode end
        notes[#notes + 1] = "Click to open the Dungeon Finder."

        toGet[#toGet + 1] = {
            icon = ICONS.boss,
            text = boss.name .. (status or ""),
            right = Color(bossDone and GRAY or colors.main, owned .. " of " .. total),
            tooltip = ListTooltip(boss.name .. " drops", boss.drops, colors, notes),
            onClick = OpenDungeonFinder,
        }
    end

    -- Collection counts: unfinished ones listed, finished ones folded into "Done"
    for _, field in ipairs(COUNT_ORDER) do
        if data[field] and #data[field] > 0 then
            hasGoals = true
            local spec, isDone = CountLine(name, field, data[field], colors)
            if isDone then
                done[#done + 1] = spec.doneLabel
                doneTooltips[#doneTooltips + 1] = spec
            else
                toGet[#toGet + 1] = spec
            end
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
    local function Section(title, list)
        if #list == 0 then return end
        specs[#specs + 1] = { header = title, colors = colors }
        for _, spec in ipairs(list) do specs[#specs + 1] = spec end
    end

    if hasGoals and #toGet == 0 then
        specs[#specs + 1] = { text = Color(GRAY, DONE_ICON .. "Everything here is collected. All done! Grats!") }
    else
        if #done > 0 then
            local target = AchievementToOpen(data.achievements)
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
    Section("How to", howTo)
    Section("Secrets", secrets)
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
        b.text:SetTextColor(DarkHex((spec.colors or DEFAULT_COLORS).main, 0.8))
        b.right:SetText("")
        b.icon:Hide()
        b.tooltip, b.onClick = nil, nil
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
    c.status:SetText(StatusText(item))

    local ly = -46
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
                label = Color("33FF33", "Now: ") .. Color(SOFT, title .. (ends and (" (ends " .. ends .. ")") or ""))
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
            local colors = HolidayHeraldDB.showThemes and item.data.colors or DEFAULT_COLORS
            names[#names + 1] = ThemedText(item.data.name or item.title, colors)
                .. (item.daysAway == 0 and "" or (" in " .. item.daysAway .. " days"))
        end
        Print(table.concat(names, ", ") .. ". " .. OPEN_LINK)
    end

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
local settingObjects = {}
local settingsCategory

-- Which preset matches the current settings, or "custom" if none do
local function CurrentPreset()
    for _, name in ipairs({ "all", "visuals", "quiet" }) do
        local matches = true
        for key, default in pairs(DB_DEFAULTS) do
            if type(default) == "boolean" and key ~= "showMinimap" then
                local expected = PRESETS[name][key]
                if expected == nil then expected = true end
                if HolidayHeraldDB[key] ~= expected then matches = false break end
            end
        end
        if matches then return name end
    end
    return "custom"
end

local function ApplyPreset(name)
    if not PRESETS[name] then return end
    for key, default in pairs(DB_DEFAULTS) do
        if type(default) == "boolean" and key ~= "showMinimap" then
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

-- Shared "NerdyBertie" heading: whichever NerdyBertie addon loads first creates it.
-- Every NerdyBertie addon carries this same function, the same list, and the
-- same Media/workshop.tga image, so the page looks the same whoever builds it.
local WORKSHOP_ADDONS = {
    { name = "HandyNotes: Dive Bar Front Crawl", folder = "HandyNotes_DiveBarCrawl" },
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

    Header("Quick presets")
    do
        -- A dropdown that shows the preset currently in use ("Custom" once you
        -- change individual settings), and applies a preset when you pick one.
        local setting = Settings.RegisterProxySetting(category, "HolidayHerald_preset", "string",
            "Preset", "all", CurrentPreset, function(value) ApplyPreset(value) end)
        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add("all", "All on", "Everything on, sounds included.")
            container:Add("visuals", "Visuals only", "All messages and toasts, no sounds.")
            container:Add("quiet", "Quiet", "Just the popup and chat lines. No alerts or toasts.")
            if CurrentPreset() == "custom" then
                container:Add("custom", "Custom", "You've changed individual settings below.")
            end
            return container:GetData()
        end
        CreateDropdown(category, setting, GetOptions,
            "Shows which preset is in use. Pick one to apply it. Changing settings below switches this to Custom.")
    end

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
    Button("Popup position", "Reset", function()
        ResetPopupPosition()
        Print("popup moved back to its default spot.")
    end, "Move the Holiday Herald popup back to the middle of the screen.")
    Checkbox("showThemes", "Holiday color themes", "Give each holiday card its own colors.")
    Checkbox("showTradingPost", "Trading Post reminder",
        "Show the Trading Post and your Trader's Tender under Weekly Events. Click it to open the Traveler's Log.")
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
    elseif cmd == "resetpos" then
        ResetPopupPosition()
        Print("popup moved back to its default spot.")
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
        Print("commands: /herald, /herald options, /herald resetpos, /herald weekly, /herald debug on|off, /herald preview <holiday> [soon|done], /herald alert <holiday>, /herald reset")
    end
end
