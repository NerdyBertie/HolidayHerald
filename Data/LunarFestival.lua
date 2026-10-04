-- Holiday Herald: Lunar Festival
-- Starter file: colors only for now. Full data gets added before the holiday arrives.

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

    tip = {
        short = "Full details for this holiday are on the way in a future update!",
    },
}
