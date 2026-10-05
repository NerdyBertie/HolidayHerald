-- Holiday Herald: Wanderer's Festival (micro-holiday, early December)
-- Micro-holidays never pop up or alert: one chat line on the day, plus a card in the popup.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.WanderersFestival = {
    name  = "Wanderer's Festival",
    match = "wanderer's festival",
    micro = true,
    iconAchievement = 7518,             -- Wanderers, Dreamers, and You

    colors = {
        main   = "8FD1B4",              -- jade
        accent = "F2C14E",              -- lantern gold
        card   = "142224",
        border = "3F9E8A",              -- sea green
        titleGradient = { "3F9E8A", "8FD1B4", "F2C14E" },   -- sea -> jade -> lantern
    },

    achievements = {
        { achievement = 7518, name = "Wanderers, Dreamers, and You" },
    },

    reminders = {
        { kind = "reminder", name = "Wanderer's Festival Hatchling (battle pet)",
          where = "Catch it in a pet battle on Turtle Beach during the festival" },
    },

    tip = {
        short = "Watch the ceremony on Turtle Beach in Krasarang Wilds for an achievement and a turtle pet!",
        hover = {
            "#Where",
            "Turtle Beach in Krasarang Wilds (Mists of Pandaria), by the big statue around 72.3, 31.2.",
            " ",
            "#When (realm time, on the evening of the festival)",
            { "Opening ceremony", "9:02 PM" },
            { "Short speech",     "9:22 PM" },
            { "Singing",          "11:02 PM" },
            { "Closing ceremony", "11:22 PM" },
            "Be there for any of these to earn Wanderers, Dreamers, and You. The Wandering Herald by the statue tells you how long until it starts.",
            " ",
            "#Also",
            "Pet battle the Wanderer's Festival Hatchlings on the beach to catch one. Tortollan Seekers vendors sell items during the festival, if you have the reputation.",
        },
    },

    secrets = {
        {
            teaser = "Secret: you don't have to wait a whole year...",
            reveal = "The ceremony happens every Sunday night on Turtle Beach, not just on the festival's calendar day. "
                  .. "Same times, same achievement, same turtle pet.",
        },
        {
            teaser = "Secret: a little light on the water...",
            reveal = "Pick up a lantern near 72.2, 31.2 and use your extra action button to set it on the water. "
                  .. "For the full experience, drink an Inky Black Potion and turn up your music.",
        },
    },
}
