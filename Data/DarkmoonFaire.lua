-- Holiday Herald: Darkmoon Faire data
-- Starter card: tip only for now. Collectibles (with IDs) to be added.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.DarkmoonFaire = {
    name  = "Darkmoon Faire",
    match = "darkmoon",
    achievementCategory = "Darkmoon Faire",   -- achievement window category name

    colors = {
        main   = "B48CE0",              -- carnival purple
        accent = "5FC7BE",              -- teal
        card   = "1E1A24",
    },

    tip = {
        short = "Many of the games and races give a toy or pet for their achievements!",
        hover = {
            "#Game achievement rewards",
            { "Ring Toss",            "Darkmoon Ring-Flinger" },
            { "Tonk Challenge",       "Darkmoon Tonk Controller" },
            { "Firebird's Challenge", "Blazing Wings" },
            { "Whack-a-Gnoll",        "Hogs (pet)" },
            { "Races",                "Racer MiniZep (pet) and toys" },
            " ",
            "#Profession quests",
            "One per profession, per faire. Each gives Prize Tickets and a few profession skill points.",
            " ",
            "#Getting there",
            "Talk to the Darkmoon Faire Mystic Mage near Goldshire in Elwynn Forest, or near Thunder Bluff in Mulgore.",
        },
    },
}
