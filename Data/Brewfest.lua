-- Holiday Herald: Brewfest data
-- All IDs are item IDs unless noted. The addon looks up mount and pet
-- details from the item ID, so no separate mount or species IDs are needed.
-- Lines marked VERIFY still need an in-game check.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.Brewfest = {
    name  = "Brewfest",
    match = "brewfest",                 -- text found in the calendar title (lowercase)

    colors = {
        main   = "E3A43C",              -- amber
        accent = "F1D9A0",              -- wheat gold
        card   = "241E16",
        border = "B87333",              -- copper keg
        titleGradient = { "C47A1E", "E3A43C", "F6E7C1" },   -- dark ale -> amber -> foam
    },

    -- Meta line: holiday meta + the Violet Proto-Drake meta
    meta = {
        holidayMeta  = 1683,                                 -- Brewmaster (verified in-game)
        strangeTrip  = 2144,                                 -- What a Long, Strange Trip It's Been (verified in-game)
    },

    -- Holiday boss: Coren Direbrew, Keg-Shaped Treasure Chest (item 117393)
    boss = {
        name = "Coren Direbrew",
        lfg  = 287,                     -- Dungeon Finder ID (verified in-game)
        drops = {
            { item = 248761, kind = "mount", name = "Brewfest Bomber" },
            { item = 37828,  kind = "mount", name = "Great Brewfest Kodo" },
            { item = 33977,  kind = "mount", name = "Swift Brewfest Ram" },
            { item = 208742, kind = "drake", name = "Renewed Proto-Drake: Brewfest Armor",
              reminderOnly = true },       -- can't confirm ownership yet
        },
    },

    -- Vendor toys (Brewfest Prize Tokens unless noted)
    toys = {
        { item = 245946, name = "Brewer's Balloon",                     cost = "200 tokens" },
        { item = 209052, name = "Brew Barrel",                          cost = "200 tokens" },
        { item = 71137,  name = "Brewfest Keg Pony",                    cost = "200 tokens" },
        { item = 116757, name = "Steamworks Sausage Grill",             cost = "200 tokens" },
        { item = 166747, name = "Brewfest Reveler's Hearthstone",       cost = "200 tokens" },
        { item = 33927,  name = "Brewfest Pony Keg",                    cost = "100 tokens" },
        { item = 116758, name = "Brewfest Banner",                      cost = "100 tokens" },
        { item = 138900, name = "Gravil Goldbraid's Famous Sausage Hat", cost = "100 tokens (sausage vendor)" },
        { item = 169865, name = "Brewfest Chowdown Trophy",             cost = "5 Chowdown Champion Tokens" },
        { item = 90427,  name = "Pandaren Brewpack",                    cost = "100 tokens" },  -- verified at vendor
    },

    -- Vendor battle pets
    pets = {
        { item = 46707,  name = "Pint-Sized Pink Pachyderm", cost = "100 tokens" },
        { item = 32233,  name = "Wolpertinger",              cost = "200 tokens" },
        { item = 116756, name = "Stout Alemental",           cost = "200 tokens" },
    },

    -- Vendor transmog (count line only; appearances are checked, not items)
    transmog = {
        245947,                                                 -- Barrel Helm
        227795,                                                 -- Homebrewer's Sampling Mantle
        209044,                                                 -- Orange Brewfest Bulwark
        169448,                                                 -- Bottomless Brewfest Stein
        168915,                                                 -- Tabard of Brew
        169461,                                                 -- Garland of Grain
        138730,                                                 -- Synthebrew Goggles XL
        248319, 248320, 248394, 248321, 248324, 248325, 248323, 248322, 248326, -- Dark Iron's Ceremonial
        241344, 241266, 241348, 249860,                         -- Brewer's Black
        241346, 241342, 241351, 249859,                         -- Brewer's Green
        33862, 33863, 33868, 33966, 33969, 33967, 33864, 33968, -- Brewfest Garb
    },

    -- Housing decor (seasonal ones cost tokens; the gold ones are sold year-round)
    -- IDs verified in-game. VERIFY: how the addon can check decor ownership
    decor = {
        { item = 280343, name = "Hanging Brewfest Wreath",      cost = "75 tokens" },
        { item = 280337, name = "Traditional Brewfest Banner",  cost = "125 tokens" },
        { item = 280339, name = "Brewfest Fence",               cost = "50 tokens" },
        { item = 280341, name = "Brewfest Fencepost",           cost = "50 tokens" },
        { item = 248101, name = "Traditional Brewfest Stein",   cost = "100 gold (year-round)" },
        { item = 280335, name = "Brewfest Crate",               cost = "100 gold (year-round)" },
    },

    -- Bar Tab Barrel achievements (shown in the tip's hover)
    barTabs = {
        18579,   -- A Round on the House on the Dragon Isles
        41212,   -- A Round on the House in Khaz Algar
        63253,   -- A Round on the House in Midnight
    },

    tip = {
        short = "Queue for Coren Direbrew daily for mount chances. Bar Tab Barrels in newer zones give 10 tokens each (5 on alts).",
        hover = {
            "#Bar Tab Barrels",
            "Found in taverns across these zones:",
            { "Dragon Isles", "Dragonflight" },
            { "Khaz Algar", "The War Within" },
            { "Silvermoon, Zul'Aman, Harandar, Voidstorm", "Midnight" },
            "The first character on your account to use each barrel gets 10 tokens. Alts get 5 per barrel after that.",
            " ",
            "#Vendors",
            "Lots of transmog and several housing decor pieces, besides the toys and pets.",
            " ",
            "#Before it ends",
            "Spend your tokens! They disappear when Brewfest is over.",
        },
    },

    classLines = {
        {
            class = "HUNTER",
            short = "Hunters: tame the Pink Elekk in Blackrock Depths!",
            hover = {
                "#Before you go",
                "Get drunk, or put on Synthebrew Goggles (item 46735, free from the Snipehunter at the Brewfest grounds). Otherwise you won't see it.",
                " ",
                "#Where",
                "Just inside the entrance of the Grim Guzzler bar in Blackrock Depths. It's not in the Coren Direbrew version of the bar.",
            },
        },
    },

    secrets = {},
}
