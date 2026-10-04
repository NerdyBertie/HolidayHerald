-- Holiday Herald: Pilgrim's Bounty data
-- All IDs are item IDs unless noted. Pilgrim is its own meta (title + pet),
-- not part of the Violet Proto-Drake meta.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.PilgrimsBounty = {
    name  = "Pilgrim's Bounty",
    match = "pilgrim",
    iconAchievement = 3478,             -- Pilgrim

    colors = {
        main   = "E0B05A",              -- harvest gold
        accent = "C2414F",              -- cranberry
        card   = "22141A",
        border = "C2414F",
        titleGradient = { "E0B05A", "C2414F" },             -- harvest gold -> cranberry
    },

    achievements = {
        { achievement = 3478, name = "Pilgrim (title + Plump Turkey pet)" },
        { achievement = 3579, name = "\"FOOD FIGHT!\"" },
        { achievement = 3577, name = "Now We're Cookin'" },
        { achievement = 3556, name = "Pilgrim's Paunch", faction = "Alliance" },
        { achievement = 3557, name = "Pilgrim's Paunch", faction = "Horde" },
        { achievement = 3558, name = "Sharing is Caring" },
        { achievement = 3582, name = "Terokkar Turkey Time" },
        { achievement = 3578, name = "The Turkinator" },
        { achievement = 3559, name = "Turkey Lurkey" },
        { achievement = 3597, name = "Pilgrim's Progress" },
        { achievement = 3580, name = "Pilgrim's Peril", faction = "Alliance" },   -- VERIFY faction
        { achievement = 3581, name = "Pilgrim's Peril", faction = "Horde" },      -- VERIFY faction
    },

    pets = {
        { item = 44810,  name = "Plump Turkey (Turkey Cage)", cost = "Pilgrim achievement" },
        { item = 116403, name = "Frightened Bush Chicken", cost = "Pilgrim's Bounty bag" },
    },

    toys = {
        { item = 116400, name = "Silver-Plated Turkey Shooter", cost = "Pilgrim's Bounty bag" },
    },

    -- Daily quest rewards, plus chance drops from the Pilgrim's Bounty bag
    transmog = {
        46723, 46800, 44785, 46824, 44788,      -- Pilgrim's Hat, Attire, Dress, Robe, Boots
        116401,                                 -- Fine Pilgrim's Hat
        248716, 248717, 248718, 248719,         -- Bountiful Backpacks (green, orange, purple, white)
    },

    tip = {
        short = "The best time of year to level Classic Cooking! Grab the Bountiful Cookbook at a feast table.",
        hover = {
            "#Cooking",
            "Buy the Bountiful Cookbook (1 silver) from a Pilgrim's Bounty vendor at the tables outside capital cities. It teaches five recipes, and the vendors sell the ingredients.",
            "Wild Turkeys for the Slow-Roasted Turkey can only be hunted during the event.",
            " ",
            "#Dailies",
            "The cooking dailies give the Pilgrim's outfit pieces, plus a Pilgrim's Bounty bag with a chance at the Bush Chicken pet, the Turkey Shooter toy, the Fine Pilgrim's Hat, and the Bountiful Backpacks.",
            " ",
            "#Spirit of Sharing",
            "Eat each food at a Bountiful Table five times for a 10% reputation buff.",
            " ",
            "#Where",
            "Feast tables are outside the capital cities, and there are full hubs in Valdrakken and Dornogal too.",
        },
    },

    secrets = {
        {
            teaser = "Secret: what you cook now pays off in December...",
            reveal = "Get Classic Cooking to 300 now. Winter Veil's Hot Apple Cider needs it for The Winter "
                  .. "Veil Gourmet, part of Merrymaker, which counts toward What a Long, Strange Trip It's Been.",
        },
        {
            teaser = "Secret: a bird king has a dress code...",
            reveal = "Defeat Talon King Ikiss in Sethekk Halls, Terokkar Forest (The Burning Crusade), while "
                  .. "wearing a Pilgrim's Hat and a Pilgrim's Dress, Robe, or Attire, for Terokkar Turkey Time.",
        },
    },
}
