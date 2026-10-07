-- Holiday Herald: Call of the Scarab (micro-holiday, January 21-23)
-- Micro-holidays never pop up or alert: one chat line on the day, plus a card in the popup.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.CallOfTheScarab = {
    name  = "Call of the Scarab",
    match = "call of the scarab",
    micro = true,
    iconItem = 21176,                   -- Black Qiraji Resonating Crystal

    colors = {
        main   = "E0B860",              -- desert gold
        accent = "3FA7A0",              -- scarab teal
        card   = "201C14",
        border = "C9963F",
        titleGradient = { "C9963F", "E0B860", "3FA7A0" },   -- sand -> gold -> scarab
    },

    achievements = {
        { achievement = 424, name = "Why? Because It's Red" },
    },

    tip = {
        short = "Fight for your faction in Silithus: whoever earns more Commendations flies their flag by the Scarab Gong all year!",
        hover = {
            "#How to help",
            "Turn in 20 meat to Master Sergeant Fizzlebolt (Alliance) or Warlord Gorchuk (Horde) by the Scarab Gong.",
            "Do the event's world quests: Wind Stones, silithid colossi, silithyst, and the two Ahn'Qiraj raids.",
            "Wear Twilight Cultist pieces from the cultist camps to summon Abyssals at the Wind Stones.",
            " ",
            "#Old Silithus",
            "If you only see the newer, wounded Silithus, talk to Zidormi to see the old one, where the event happens.",
            " ",
            "#Mounts",
            "The Ruby and Sapphire Qiraji Resonating Crystals cost one Abyssal Crest each, but they only last a week.",
        },
    },

    secrets = {
        {
            teaser = "Secret: the bugs are feeling generous...",
            reveal = "Players report much better drop rates for the Qiraji Battle Tank mounts from Temple of Ahn'Qiraj "
                  .. "trash during the event, including the rare red one for Why? Because It's Red.",
        },
        {
            teaser = "Secret: one gong started it all...",
            reveal = "On January 23, 2006, a player named Kalahad rang the Scarab Gong and opened the gates of Ahn'Qiraj, "
                  .. "starting a ten-hour battle with thousands of players. Whoever rang the gong earned the Black Qiraji "
                  .. "Resonating Crystal, one of the rarest mounts in the game.",
        },
    },
}
