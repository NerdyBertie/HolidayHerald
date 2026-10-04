-- Holiday Herald: Midsummer Fire Festival
-- Starter file: colors only for now. Full data gets added before the holiday arrives.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.Midsummer = {
    name  = "Midsummer Fire Festival",
    match = "midsummer",

    colors = {
        main   = "F5872F",
        accent = "4A78C9",
        card   = "161B28",
        border = "4A78C9",
        titleGradient = { "E8392A", "F5872F", "FFC94A" },   -- fire red -> orange -> gold
    },

    tip = {
        short = "Full details for this holiday are on the way in a future update!",
    },
}
