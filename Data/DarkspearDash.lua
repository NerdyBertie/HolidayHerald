-- Holiday Herald: Darkspear Dash
-- Starter file: colors only for now. Full data gets added before the holiday arrives.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.DarkspearDash = {
    name  = "Darkspear Dash",
    match = "darkspear",
    micro = true,

    colors = {
        main   = "4FC3A1",
        accent = "FFE45A",
        card   = "14201E",
        border = "4FC3A1",
        titleGradient = { "FF5A5A", "FFB04A", "FFE45A", "6EE07A", "5AB4FF", "B48CFF" },   -- rainbow, for the Rainbow Roll
    },

    tip = {
        short = "Full details for this holiday are on the way in a future update!",
    },
}
