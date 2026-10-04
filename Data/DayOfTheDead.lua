-- Holiday Herald: Day of the Dead data
-- All IDs are item IDs unless noted. Not part of the Violet Proto-Drake meta.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.DayOfTheDead = {
    name  = "Day of the Dead",
    match = "day of the dead",
    iconAchievement = 3456,             -- Dead Man's Party

    colors = {
        main   = "F2A33A",              -- marigold
        accent = "D9468F",              -- magenta
        card   = "241621",
        border = "D9468F",
        titleGradient = { "F2A33A", "D9468F" },             -- marigold -> magenta
    },

    achievements = {
        { achievement = 3456, name = "Dead Man's Party" },
        { achievement = 9426, name = "To The Afterlife" },
        { achievement = 9427, name = "Vientos!" },
        { achievement = 9428, name = "Calavera" },
    },

    reminders = {
        { item = 208859, kind = "reminder", name = "Cliffside Wylderdrake: Day of the Dead Armor",
          cost = "50,000 gold", where = "Chapman, by Catrina at capital city graveyards" },
    },

    pets = {
        { item = 46831, name = "Macabre Marionette", cost = "The Grateful Dead quest" },
    },

    -- Contender's Costumes, sold by Chapman
    toys = {
        { item = 116856, name = "\"Blooming Rose\" Contender's Costume" },
        { item = 116888, name = "\"Night Demon\" Contender's Costume" },
        { item = 116889, name = "\"Purple Phantom\" Contender's Costume" },
        { item = 116890, name = "\"Santo's Sun\" Contender's Costume" },
        { item = 116891, name = "\"Snowy Owl\" Contender's Costume" },
    },

    -- Crowns, deathmasks, and veils: 100 gold each from Chapman
    transmog = {
        246188, 246187, 246186, 246185, 246184,   -- Crowns of the Dead
        246180, 246181, 246179, 246182, 246183,   -- Deathmasks
        246154, 246155, 246156, 246157, 246158,   -- Remembrance Veils
    },

    tip = {
        short = "/dance with Catrina at a capital city graveyard for Dead Man's Party!",
        hover = {
            "#Dead Man's Party",
            "Target Catrina near the graveyard of any capital city and /dance. You'll turn into a dressed-up skeleton, too.",
            " ",
            "#Before you go (pet quest)",
            "Buy Simple Flour from a cooking supplies vendor and Ice Cold Milk from an innkeeper first.",
            " ",
            "#Where",
            { "Alliance: Stormwind graveyard", "46.8, 26.0" },
            { "Horde: Ruins of Lordaeron", "68.0, 10.4" },
            "Dalaran and Shattrath graveyards work too. Do the quest at your own side's spot.",
            " ",
            "#The Grateful Dead",
            "From Chapman, next to Catrina: buy Recipe: Bread of the Dead and an Orange Marigold.",
            "Learn the recipe, and bake the bread at the Ghostly Cooking Fire by the vendor.",
            "Use the marigold to see the hidden Cheerful Spirit, accept The Grateful Dead, and hand over the bread for the Macabre Marionette.",
            " ",
            "#Vendor",
            "Chapman also sells crowns, deathmasks, and veils (100 gold each), and the drake armor (50,000 gold).",
        },
    },

    -- Things to buy before the pet quest (shift-click to link)
    shoppingFor = "Pet quest",
    shopping = {
        { item = 30817, count = 1, name = "Simple Flour",  where = "cooking supplies vendor" },
        { item = 1179,  count = 1, name = "Ice Cold Milk", where = "innkeeper" },
    },

    secrets = {
        {
            teaser = "Secret: those costumes aren't just for show...",
            reveal = "Wearing a Contender's Costume gives you a button with random fighting moves. Beat other "
                  .. "costumed players for To The Afterlife (1), Vientos! (20), and Calavera (50). "
                  .. "It even works after the holiday ends!",
        },
    },
}
