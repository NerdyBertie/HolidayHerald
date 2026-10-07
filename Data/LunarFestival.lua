-- Holiday Herald: Lunar Festival data (about two weeks in late January / February)
-- All IDs are item IDs unless noted.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.LunarFestival = {
    name  = "Lunar Festival",
    match = "lunar festival",

    colors = {
        main   = "A9C8F0",
        accent = "F2C14E",
        card   = "141A2A",
        border = "A9C8F0",
        titleGradient = { "A9C8F0", "EEF0FF", "C7B8F0" },   -- moon blue -> moonlight -> lavender
    },

    meta = {
        holidayMeta = 913,              -- To Honor One's Elders
        strangeTrip = 2144,
    },

    achievements = {
        { achievement = 17321, name = "Elders of the Dragon Isles" },
        { achievement = 41130, name = "Elders of Khaz Algar" },
        { achievement = 606,   name = "5 Coins of Ancestry" },
        { achievement = 607,   name = "10 Coins of Ancestry" },
        { achievement = 608,   name = "25 Coins of Ancestry" },
        { achievement = 609,   name = "50 Coins of Ancestry" },
    },

    mounts = {
        { item = 232901, name = "Lunar Launcher", cost = "Coins of Ancestry" },
    },

    toys = {
        { item = 165669, name = "Lunar Elder's Hearthstone",   cost = "Fariel Starsong" },
        { item = 89999,  name = "Everlasting Alliance Firework", cost = "Fariel Starsong", faction = "Alliance" },
        { item = 90000,  name = "Everlasting Horde Firework",    cost = "Fariel Starsong", faction = "Horde" },
        { item = 143827, name = "Red Dragon Head Costume",     cost = "Fariel Starsong" },
        { item = 143828, name = "Red Dragon Body Costume",     cost = "Fariel Starsong" },
        { item = 143829, name = "Red Dragon Tail Costume",     cost = "Fariel Starsong" },
        { item = 165671, name = "Blue Dragon Head Costume",    cost = "Fariel Starsong" },
        { item = 165672, name = "Blue Dragon Body Costume",    cost = "Fariel Starsong" },
        { item = 165673, name = "Blue Dragon Tail Costume",    cost = "Fariel Starsong" },
        { item = 165674, name = "Green Dragon Head Costume",   cost = "Fariel Starsong" },
        { item = 165675, name = "Green Dragon Body Costume",   cost = "Fariel Starsong" },
        { item = 165676, name = "Green Dragon Tail Costume",   cost = "Fariel Starsong" },
        { item = 21540,  name = "Elune's Lantern",             cost = "Elune's Blessing quest (Omen)" },
    },

    -- Valadar only sells one lantern, depending on your faction, but both can be traded on the Auction House
    pets = {
        { item = 74610, name = "Lunar Lantern",    cost = "Valadar Starsong or Auction House" },
        { item = 74611, name = "Festival Lantern", cost = "Valadar Starsong or Auction House" },
    },

    transmog = {
        { item = 21157,  name = "Festive Green Dress" },
        { item = 21538,  name = "Festive Pink Dress" },
        { item = 21539,  name = "Festive Purple Dress" },
        { item = 21541,  name = "Festive Black Pant Suit" },
        { item = 21543,  name = "Festive Teal Pant Suit" },
        { item = 21544,  name = "Festive Blue Pant Suit" },
        { item = 169208, name = "Crown of Everlasting Fortune", note = "Lunar Preservation quest (year-round transmog)" },
        { item = 170205, name = "Crown of Boundless Courage",   note = "Lunar Preservation quest (year-round transmog)" },
        { item = 170206, name = "Crown of Infinite Prosperity", note = "Lunar Preservation quest (year-round transmog)" },
        { item = 170207, name = "Crown of Eternal Memorial",    note = "Lunar Preservation quest (year-round transmog)" },
        { item = 233239, name = "Sunny Pack of Lunar Explosives" },
        { item = 233224, name = "Obsidian Lunar Blade" },
        { item = 233221, name = "Violet Lunar Lantern" },
        { item = 233235, name = "Violet Lunar Firewhacker" },
        { item = 233231, name = "Steel Lunar Polearm" },
    },

    reminders = {
        { item = 211868, kind = "reminder", name = "Winding Slitherdrake: Lunar Festival Armor",
          cost = "Coins of Ancestry", where = "Valadar Starsong or any Lunar Festival Vendor" },
        { item = 234059, kind = "reminder", name = "Ensemble: Ornate Violet Lunar Festival Attire",
          cost = "Coins of Ancestry", where = "Moonglade vendors" },
    },

    tip = {
        short = "Honor the Elders around the world for Coins of Ancestry, then shop in Moonglade!",
        hover = {
            "#Getting to Moonglade",
            "Talk to a Lunar Festival Herald in any capital, then set off fireworks for the Harbinger's quest. Its Lunar Festival Invitation teleports you to Moonglade from the big beam of moonlight in each city's festival camp.",
            " ",
            "#The Elders",
            "Elders all over the world each give a Coin of Ancestry and reputation. Coins never expire, so leftovers from past years still spend.",
            "Can't see an Elder? Talk to Zidormi to see the older version of these zones:",
            { "Tirisfal Glades (Undercity, Brill)", "69.4, 62.8" },
            { "Blasted Lands", "48.2, 7.2" },
            { "Darkshore (Teldrassil, Darnassus)", "48.8, 24.4" },
            { "Silithus", "78.8, 22.0" },
            " ",
            "#Omen",
            "Fire 30 rocket clusters from the launchers by the lake near the Stormrage Barrow Dens in Moonglade to summon Omen. Just be near his body when he dies for Elune's Blessing.",
            " ",
            "#Year-round flower crowns",
            "Myrael Lunarbloom's Lunar Preservation quests send you to moonwells around the world. They reward four crowns you can transmog all year, plus 25 coins.",
        },
    },

    secrets = {
        {
            teaser = "Secret: a little luck goes a long way for alts...",
            reveal = "Elders sometimes give a Lucky Rocket Cluster. Fire it from a cluster launcher for Lunar Fortune, "
                  .. "a health boost that makes low-level dungeons much easier to solo.",
        },
        {
            teaser = "Secret: one firework, two factions...",
            reveal = "Buy either Everlasting Firework toy and you learn both, so it only costs coins once.",
        },
        {
            teaser = "Secret: the festival ends with a show...",
            reveal = "On the last evening of the festival, villagers line the shore of Lake Elune'ara to light floating "
                  .. "lanterns, followed by big fireworks over the lake.",
        },
    },
}
