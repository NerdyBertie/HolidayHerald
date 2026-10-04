-- Holiday Herald: Feast of Winter Veil
-- Starter file: colors only for now. Full data gets added before the holiday arrives.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.WinterVeil = {
    name  = "Feast of Winter Veil",
    match = "winter veil",

    colors = {
        main   = "E23B3B",
        accent = "3E9E6A",
        card   = "1C1A18",
        border = "3E9E6A",
        titleGradient = { "E23B3B", "F3E9E4", "3E9E6A" },   -- cranberry -> snow -> evergreen
    },

    tip = {
        short = "Full details for this holiday are on the way in a future update!",
    },
}
