-- Holiday Herald: Twitch Drops
-- One entry per drop. Times are real-world (UTC) moments, so they're right in every region.
-- Dec 1 2026 10:00 am PST = 18:00 UTC; Dec 29 2026 10:00 am PST = 18:00 UTC.

local _, HH = ...

HH.TwitchDrops = {
    {
        name  = "Cuddly Seafoam Grrgle",
        kind  = "Housing decor",
        hours = 4,
        startUTC = 1796148000,
        endUTC   = 1798567200,
        vendors = {
            { "Dennia Silvertongue", "Silvermoon City" },
            { "Tuuran", "Stormwind" },
            { "Gabbi", "Orgrimmar, near the Trading Post" },
        },
        -- Shown on the map only while the drop is on
        pins = {
            {
                map = 2393, x = 51.1, y = 56.4,
                title = "Dennia Silvertongue",
                note = {
                    "Sells more copies of the Cuddly Seafoam Grrgle for gold, once you've claimed one from the Twitch Drop.",
                    "Tuuran in Stormwind and Gabbi in Orgrimmar (near the Trading Post) sell it too.",
                },
            },
        },
    },
}
