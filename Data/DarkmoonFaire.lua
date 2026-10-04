-- Holiday Herald: Darkmoon Faire data
-- Starter card: tip only for now. Collectibles (with IDs) to be added.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.DarkmoonFaire = {
    name  = "Darkmoon Faire",
    match = "darkmoon",
    icon  = "Interface\\Icons\\INV_Misc_Ticket_Darkmoon_01",
    achievementCategory = "Darkmoon Faire",   -- achievement window category name

    colors = {
        main   = "B48CE0",              -- carnival purple
        accent = "5FC7BE",              -- teal
        card   = "1E1A24",
        border = "B48CE0",
        titleStripes = { "B48CE0", "5FC7BE" },              -- circus-tent stripes
    },

    -- Profession quests that need items from outside the Faire.
    -- Each player only sees the items for professions they have.
    shoppingFor = "Profession quests",
    shoppingByProfession = true,
    shopping = {
        { item = 30817, count = 5, name = "Simple Flour",    profession = "Cooking",     skillLine = 185,
          where = "cooking or trade goods vendor" },
        { item = 1645,  count = 5, name = "Moonberry Juice", profession = "Alchemy",     skillLine = 171,
          where = "innkeeper" },
        { item = 39354, count = 5, name = "Light Parchment", profession = "Inscription", skillLine = 773,
          where = "trade goods vendor" },
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
