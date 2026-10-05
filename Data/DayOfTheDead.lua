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
        { item = 46861, name = "Bouquet of Orange Marigolds" },
        { item = 46860, name = "Whimsical Skull Mask", note = "Can only be transmogged during the holiday" },
    },

    tip = {
        short = "/dance with Catrina at a capital city graveyard for Dead Man's Party!",
        hover = {
            "#Dead Man's Party",
            "Target Catrina near the graveyard of any capital city and /dance. You'll turn into a dressed-up skeleton for 12 hours, too.",
            " ",
            "#Before you go (pet quest)",
            "Buy Simple Flour from a cooking supplies vendor and Ice Cold Milk from an innkeeper first.",
            " ",
            "#Where: your race's home graveyard",
            { "Human, Kul Tiran: Stormwind", "46.8, 26.0" },
            { "Dwarf, Dark Iron, Gnome, Mechagnome: Dun Morogh", "61.6, 37.4" },
            { "Night Elf, Worgen, Void Elf: Darnassus", "68.6, 40.0" },
            { "Draenei, Lightforged: Azuremyst Isle", "47.6, 55.8" },
            { "Orc, Mag'har, Goblin, Troll, Zandalari: Durotar", "47.4, 17.6" },
            { "Undead: Ruins of Lordaeron", "68.0, 10.4" },
            { "Tauren, Highmountain: Thunder Bluff", "56.8, 17.6" },
            { "Blood Elf, Nightborne: Eversong Woods", "48.0, 49.4" },
            "Any race (including Pandaren, Vulpera, Dracthyr, and Earthen) can use Dalaran or Shattrath instead.",
            "Darnassus and Undercity may need Zidormi to show their older versions.",
            " ",
            "#The Grateful Dead",
            "From Chapman, next to Catrina: buy Recipe: Bread of the Dead, plus an Orange Marigold or the reusable Marigold Petal Offering Bowl (it works again every year).",
            "Bake the bread first, at the blue Ghostly Cooking Fire by Chapman. The marigold only shows the spirits for about 30 seconds, so be ready!",
            "Use the marigold to see the hidden Cheerful Spirit, accept The Grateful Dead, and the bread in your bags turns it in for the Macabre Marionette. A Spirit Candle shows even more spirits.",
            " ",
            "#Vendor",
            "Chapman also sells crowns, deathmasks, and veils (100 gold each), and the drake armor (50,000 gold).",
            "Bread of the Dead can't be mailed and disappears after the holiday, so don't bake extras for alts.",
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
                  .. "It even works after the holiday ends! Duel a costumed friend: you won't lose "
                  .. "durability, and three people go faster than two, since all the costumes share one cooldown.",
        },
        {
            teaser = "Secret: some heroes can already see the dead...",
            reveal = "Demon Hunters can use Spectral Sight instead of a marigold to see the Cheerful Spirit "
                  .. "and pick up The Grateful Dead.",
        },
    },
}
