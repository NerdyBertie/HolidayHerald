-- Holiday Herald: Noblegarden
-- Starter file: colors only for now. Full data gets added before the holiday arrives.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.Noblegarden = {
    name  = "Noblegarden",
    match = "noblegarden",

    colors = {
        main   = "8FD19E",
        accent = "B9A3E3",
        card   = "1A2120",
        border = "F3E08A",
        titleGradient = { "8FD19E", "F3E08A", "F5B5D0", "B9A3E3" },   -- pastel egg colors
    },

    tip = {
        short = "Full details for this holiday are on the way in a future update!",
    },
}
