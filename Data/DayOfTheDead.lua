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
        sections = { toGet = "F2A33A", howTo = "E05AA0", secrets = "4FC3C9" },   -- marigold, magenta, teal
    },

    achievements = {
        { achievement = 3456, name = "Dead Man's Party" },
        { achievement = 9426, name = "To The Afterlife" },
        { achievement = 9427, name = "Vientos!" },
        { achievement = 9428, name = "Calavera" },
    },

    reminders = {
        { item = 208859, kind = "drake", unlockQuest = 77876, name = "Cliffside Wylderdrake: Day of the Dead Armor",
          cost = "50,000 gold", where = "Chapman, by Catrina at capital city graveyards" },
    },

    pets = {
        { item = 46831, name = "Macabre Marionette", cost = "The Grateful Dead quest" },
    },

    -- Contender's Costumes, sold by Chapman
    toys = {
        { item = 116856, name = "\"Blooming Rose\" Contender's Costume", cost = "100 gold" },
        { item = 116888, name = "\"Night Demon\" Contender's Costume", cost = "100 gold" },
        { item = 116889, name = "\"Purple Phantom\" Contender's Costume", cost = "100 gold" },
        { item = 116890, name = "\"Santo's Sun\" Contender's Costume", cost = "100 gold" },
        { item = 116891, name = "\"Snowy Owl\" Contender's Costume", cost = "100 gold" },
    },

    -- Crowns, deathmasks, and veils: 100 gold each from Chapman (vendor checked in game, Nov 1 2026)
    transmog = {
        { item = 246188, group = "Crowns of the Dead", cost = "100 gold" },
        { item = 246187, group = "Crowns of the Dead", cost = "100 gold" },
        { item = 246186, group = "Crowns of the Dead", cost = "100 gold" },
        { item = 246185, group = "Crowns of the Dead", cost = "100 gold" },
        { item = 246184, group = "Crowns of the Dead", cost = "100 gold" },
        { item = 246180, group = "Deathmasks", cost = "100 gold" },
        { item = 246181, group = "Deathmasks", cost = "100 gold" },
        { item = 246179, group = "Deathmasks", cost = "100 gold" },
        { item = 246182, group = "Deathmasks", cost = "100 gold" },
        { item = 246183, group = "Deathmasks", cost = "100 gold" },
        { item = 246154, group = "Remembrance Veils", cost = "100 gold" },
        { item = 246155, group = "Remembrance Veils", cost = "100 gold" },
        { item = 246156, group = "Remembrance Veils", cost = "100 gold" },
        { item = 246157, group = "Remembrance Veils", cost = "100 gold" },
        { item = 246158, group = "Remembrance Veils", cost = "100 gold" },
        { item = 46861, group = "Other", name = "Bouquet of Orange Marigolds", cost = "1 copper" },
        { item = 46860, group = "Other", name = "Whimsical Skull Mask", cost = "100 gold", note = "Can only be transmogged during the holiday" },
    },

    tip = {
        short = "/dance with Catrina at a capital city graveyard for Dead Man's Party!",
        hover = {
            "#Dead Man's Party",
            "Target Catrina near the graveyard of any capital city and /dance. You'll also get Honor the Dead, which turns you into a dressed-up skeleton like Catrina for 12 hours.",
            " ",
            "#Before you go (pet quest)",
            "Buy Simple Flour from a cooking supplies vendor and Ice Cold Milk from an innkeeper first. If you're doing it in Dalaran, buy them before you go: nobody there sells them.",
            " ",
            "#Where: your race's home graveyard",
            { "Human, Kul Tiran: Stormwind", "46.9, 25.9" },
            { "Dwarf, Dark Iron, Gnome, Mechagnome: Dun Morogh", "61.1, 36.9" },
            { "Night Elf, Worgen, Void Elf: Darnassus", "68.6, 40.0" },
            { "Draenei, Lightforged: Azuremyst Isle", "47.6, 55.8" },
            { "Orc, Mag'har, Goblin, Troll, Zandalari: Durotar", "47.4, 17.6" },
            { "Undead: Tirisfal Glades (Ruins of Lordaeron)", "62.3, 67.5" },
            { "Tauren, Highmountain: Thunder Bluff", "56.8, 17.6" },
            { "Blood Elf, Nightborne: Eversong Woods", "48.0, 49.4" },
            "Any race (including Pandaren, Vulpera, Dracthyr, and Earthen) can use a neutral spot instead:",
            { "Dalaran (Northrend or Legion)", "34.6, 38.6" },
            { "Terokkar Forest, outside Shattrath", "39.8, 21.8" },
            "Darnassus and Undercity may need Zidormi to show their older versions.",
            " ",
            "#The Grateful Dead",
            "From Chapman, next to Catrina: buy Recipe: Bread of the Dead, plus an Orange Marigold or the reusable Marigold Petal Offering Bowl (it works again every year).",
            "Bake the bread first, at the blue Ghostly Cooking Fire by Chapman (or drop a Spirit Candle from him, 30 copper: it works as a cooking fire too). The marigold only shows the spirits for about 30 seconds, so be ready!",
            "Use the marigold to see the hidden Cheerful Spirit, accept The Grateful Dead, and the bread in your bags turns it in for the Macabre Marionette.",
            " ",
            "#Vendor",
            "Chapman also sells the Contender's Costumes, crowns, deathmasks, and veils (100 gold each), and the drake armor (50,000 gold).",
            "Bread of the Dead can't be mailed and disappears after the holiday, so don't bake extras for alts.",
        },
    },

    -- HandyNotes map pins: the graveyard sites (Catrina, Chapman, and the Cheerful Spirit).
    -- Stormwind, Dun Morogh and Tirisfal from Roberta in game (Nov 1 2026); the rest from 2026 guides.
    pins = {
        { faction = "Alliance", map = 84, x = 46.9, y = 25.9, title = "Day of the Dead: Stormwind",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", "In the graveyard behind the Cathedral.", { "Spirit for", "Human, Kul Tiran" } } },
        { faction = "Alliance", map = 27, x = 61.1, y = 36.9, title = "Day of the Dead: Ironforge",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", "Outside Ironforge, up the hill to the left of the gates as you leave.", { "Spirit for", "Dwarf, Dark Iron, Gnome, Mechagnome" } } },
        { faction = "Alliance", map = 97, x = 47.6, y = 55.8, title = "Day of the Dead: Azuremyst Isle",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", "South of Azure Watch.", { "Spirit for", "Draenei, Lightforged" } } },
        { faction = "Alliance", map = 89, x = 68.6, y = 40.0, title = "Day of the Dead: Darnassus",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", "In the old Darnassus (talk to Zidormi in Darkshore to see it).", { "Spirit for", "Night Elf, Worgen, Void Elf" } } },
        { faction = "Horde", map = 1, x = 47.4, y = 17.6, title = "Day of the Dead: Orgrimmar",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", "South of Orgrimmar, beside the road toward Razor Hill.", { "Spirit for", "Orc, Mag'har, Goblin, Troll, Zandalari" } } },
        { faction = "Horde", map = 88, x = 56.8, y = 17.6, title = "Day of the Dead: Thunder Bluff",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", { "Spirit for", "Tauren, Highmountain" } } },
        { faction = "Horde", map = 94, x = 48.0, y = 49.4, title = "Day of the Dead: Silvermoon", noContinent = true,
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", "In the old Eversong Woods (talk to Zidormi in Eastern Plaguelands to see it), outside the city's western wall.", { "Spirit for", "Blood Elf, Nightborne" } } },
        { faction = "Horde", map = 18, x = 62.3, y = 67.5, title = "Day of the Dead: Undercity",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", "In the Ruins of Lordaeron courtyard. Talk to Zidormi (69.4, 62.8) first, or the plague will get you!", { "Spirit for", "Undead" } } },
        { map = 125, x = 34.6, y = 38.6, title = "Day of the Dead: Dalaran (Northrend)",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", "In the grassy graveyard just north of the stairs out of the Violet Citadel.", { "Spirit for", "any race" }, "Bring Simple Flour and Ice Cold Milk with you: nobody in Dalaran sells them." } },
        { map = 627, x = 34.0, y = 38.6, title = "Day of the Dead: Dalaran (Legion)",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", { "Spirit for", "any race" }, "Bring Simple Flour and Ice Cold Milk with you: nobody in Dalaran sells them." } },
        { map = 108, x = 39.8, y = 21.8, title = "Day of the Dead: Shattrath",
          note = { "Catrina (/dance for Dead Man's Party) and Chapman (marigolds, bread recipe, costumes) are here.", "Outside Shattrath in Terokkar Forest (Aldor and Scryer spirits stand side by side).", { "Spirit for", "any race" } } },
    },

    -- Things to buy before the pet quest (shift-click to link)
    shoppingFor = "Pet quest",
    shopping = {
        { item = 30817, count = 1, name = "Simple Flour",  where = "cooking supplies vendor (not in Dalaran)" },
        { item = 1179,  count = 1, name = "Ice Cold Milk", where = "innkeeper (not in Dalaran)" },
    },

    secrets = {
        {
            teaser = "Secret: Catrina's story is older than Azeroth...",
            reveal = "Catrina is a nod to La Catrina, an icon of Mexico's Día de los Muertos. She began in the early 1900s "
                  .. "as La Calavera Garbancera, a skeleton by engraver José Guadalupe Posada that poked fun at people who "
                  .. "put on European airs and forgot their roots, a reminder that death treats everyone the same. "
                  .. "Muralist Diego Rivera later made her famous as \"La Catrina,\" the elegant skeleton in the big hat.",
        },
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
