-- Holiday Herald: Moonkin Festival (micro-holiday, November 12)
-- Micro-holidays never pop up or alert: one chat line on the day, plus a card in the popup.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.MoonkinFestival = {
    name  = "Moonkin Festival",
    match = "moonkin festival",
    micro = true,
    icon  = "Interface\\Icons\\Spell_Nature_ForceOfNature",

    colors = {
        main   = "A98BE8",              -- arcane lilac
        accent = "F2D27A",              -- starfire gold
        card   = "171A2C",
        border = "6FA8DC",              -- Moonglade blue
        titleGradient = { "8C7BE8", "C9B8F0", "F2D27A" },   -- arcane -> moonlight -> starfire
    },

    tip = {
        short = "Head to Moonglade and earn up to five Moonkin Hatchlings that follow you for 5 days!",
        hover = {
            "#Start",
            "Talk to Makkaw in Moonglade, by the Stormrage Barrow Dens (45.4, 62.0), for Moonkin Monitoring. Watch his three hatchling classes, then turn it in for your first hatchling and the temporary title \"Adventuring Instructor.\"",
            " ",
            "#Earning all five (talk to your hatchlings for hints)",
            { "2nd: feed it 5 Moonberries", "by tree trunks, east (61, 66)" },
            { "3rd: Moonkissed Antidote", "from Jadefire satyr drops" },
            { "4th: cure Clookle", "bottom of the Barrow Den (71.2, 56.2)" },
            { "5th: defeat Xavinox", "use his Beanie Boomie" },
            " ",
            "#Heads up",
            "Xavinox scales to your level and hits hard, so bring friends. Once you have the hatchlings, the buff can't be cancelled, and stealth hides them for a moment.",
        },
    },

    secrets = {
        {
            teaser = "Secret: the hatchlings love a good party...",
            reveal = "Target one of your Moonkin Hatchlings and /dance, and it dances with you! Do it with each one "
                  .. "until the whole flock is dancing. While watching Makkaw's classes, try /dance, /sleep, and "
                  .. "saying BOOM too.",
        },
        {
            teaser = "Secret: they're tiny, but they're fierce...",
            reveal = "Your hatchlings fire tiny Moonfires at whatever you're fighting. It doesn't do any damage, "
                  .. "but it's the thought that counts!",
        },
    },
}
