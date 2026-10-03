-- Holiday Herald: Pirates' Day data
-- All IDs are item IDs unless noted.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.PiratesDay = {
    name  = "Pirates' Day",
    match = "pirate",
    short = true,                       -- one day only

    colors = {
        main   = "3FA7A0",              -- sea teal
        accent = "E8C15A",              -- doubloon gold
        card   = "10201F",
    },

    toys = {
        { item = 150547, name = "Jolly Roger", cost = "10 gold",
          requires = 871,                                   -- Avast Ye, Admiral!
          where = "Edward Techt, beach directly south of Booty Bay (39.6, 84.6)" },
    },

    reminders = {
        { name = "Highland Drake: Pirates' Day Armor", cost = "50,000 gold",
          where = "Dread Captain DeMeza, Booty Bay bank roof" },
    },

    tip = {
        short = "One day only! Two vendors: the bank roof and the beach.",
        hover = {
            "#Booty Bay bank roof",
            "Dread Captain DeMeza: the drake armor and cosmetics.",
            " ",
            "#Beach directly south (39.6, 84.6)",
            "Edward Techt: the Jolly Roger, but only if you have Avast Ye, Admiral!",
        },
    },
}
