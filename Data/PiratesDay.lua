-- Holiday Herald: Pirates' Day data
-- All IDs are item IDs unless noted. One day only: September 19.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.PiratesDay = {
    name  = "Pirates' Day",
    match = "pirate",
    iconItem = 150547,                  -- Jolly Roger
    short = true,                       -- one day only

    colors = {
        main   = "3FA7A0",              -- sea teal
        accent = "E8C15A",              -- doubloon gold
        card   = "10201F",
        border = "3FA7A0",
        titleGradient = { "3FA7A0", "E8C15A" },             -- sea teal -> doubloon gold
    },

    achievements = {
        { achievement = 3457, name = "The Captain's Booty" },
    },

    toys = {
        { item = 150547, name = "Jolly Roger", cost = "10 gold",
          requires = 871,                                   -- Avast Ye, Admiral!
          where = "Edward Techt, beach south of Booty Bay (39.6, 84.6)" },
        { item = 138415, name = "Slightly-Chewed Insult Book", cost = "Ol' Eary",
          where = "Drops the first time you defeat the shark Ol' Eary" },
    },

    -- Sold by Dread Captain DeMeza, 1,000 gold each
    transmog = {
        { item = 280333, name = "Pirate's Eyepatch", cost = "1,000 gold" },
        { item = 217373, name = "Frenzied Hat of the Dark Depths", cost = "1,000 gold" },
    },

    reminders = {
        { item = 208858, kind = "reminder", name = "Highland Drake: Pirates' Day Armor",
          cost = "50,000 gold", where = "Dread Captain DeMeza, Booty Bay bank roof" },
    },

    tip = {
        short = "One day only! Booty Bay's bank roof, its shark, and the beach party.",
        hover = {
            "#Dread Captain DeMeza (bank roof, 40.2, 72.4)",
            "Drink or /dance with her to become a pirate for 12 hours, and earn The Captain's Booty.",
            "Sells the drake armor, the Pirate's Eyepatch, the Frenzied Hat, and Petey, a shoulder parrot for 10 gold.",
            "Her quest You're Gonna Need A Bigger Boat! rewards Emergency Pirate Outfits to wear the rest of the year.",
            " ",
            "#Beach party (south of Booty Bay, 39.6, 84.6)",
            "Edward Techt sells the Jolly Roger, but only if you have Avast Ye, Admiral!",
        },
    },

    secrets = {
        {
            teaser = "Secret: something big circles the bay...",
            reveal = "Ol' Eary, an elite shark, shows up in the waters of Booty Bay about every 30 minutes "
                  .. "(around 36.8, 67.2). Bring friends! The first time you defeat him, he drops the "
                  .. "Slightly-Chewed Insult Book toy.",
        },
    },
}
