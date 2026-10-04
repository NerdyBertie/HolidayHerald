-- Holiday Herald: Love is in the Air
-- Starter file: colors only for now. Full data gets added before the holiday arrives.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.LoveIsInTheAir = {
    name  = "Love is in the Air",
    match = "love is in the air",

    colors = {
        main   = "F06C9B",
        accent = "E0566A",
        card   = "26161C",
        border = "F06C9B",
        titleGradient = { "F06C9B", "FFB3C8", "E0566A" },   -- rose -> blush -> red
    },

    tip = {
        short = "Full details for this holiday are on the way in a future update!",
    },
}
