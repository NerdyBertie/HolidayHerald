-- Holiday Herald: WoW's Anniversary (late November)
-- Starter card: general tips. This year's rewards get added once they're announced.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.Anniversary = {
    name  = "WoW's Anniversary",
    match = "anniversary",
    icon  = "Interface\\Icons\\INV_Misc_PocketWatch_01",

    colors = {
        main   = "C9963F",              -- bronze
        accent = "7FC8D8",              -- bronze dragonflight teal
        card   = "1C1A16",
        border = "C9963F",
        titleGradient = { "3F8CFF", "E3C27A", "C41E3A" },   -- Alliance blue -> bronze -> Horde crimson
    },

    tip = {
        short = "Head to the celebration outside the Caverns of Time in Tanaris!",
        hover = {
            "#The celebration",
            "The festival grounds are outside the Caverns of Time in Tanaris, with activities, quests, and vendors.",
            " ",
            "#Rewards",
            "Activities earn event currency for transmog, mounts, and pets at the celebration's vendors. There's usually an XP buff during the event too, which makes it a great time to level alts.",
            " ",
            "#This year",
            "Each anniversary brings something new. Check the in-game calendar or event news for this year's details.",
        },
    },
}
