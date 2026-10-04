-- Holiday Herald: Children's Week
-- Starter file: colors only for now. Full data gets added before the holiday arrives.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.ChildrensWeek = {
    name  = "Children's Week",
    match = "children's week",

    colors = {
        main   = "6EC1F0",
        accent = "F7D35C",
        card   = "15202A",
        border = "F7D35C",
        titleGradient = { "6EC1F0", "F7D35C" },   -- sky -> sunshine
    },

    tip = {
        short = "Full details for this holiday are on the way in a future update!",
    },
}
