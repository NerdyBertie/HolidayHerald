-- Holiday Herald: Fireworks Celebration (New Year's Eve, December 31)
-- Micro-holidays never pop up or alert: one chat line on the day, plus a card in the popup.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.FireworksCelebration = {
    name  = "New Year's Fireworks",
    match = "fireworks celebration",
    micro = true,
    iconItem = 21171,                   -- Filled Festive Mug

    colors = {
        main   = "F2D27A",              -- champagne gold
        accent = "6FA8DC",              -- midnight sky blue
        card   = "121428",
        border = "F2C14E",
        titleGradient = { "6FA8DC", "F2D27A", "E86FB0" },   -- night sky -> gold sparks -> pink burst
    },

    tip = {
        short = "Fireworks over the capital cities every hour on the hour, 6 PM to 6 AM realm time!",
        hover = {
            "#Where and when",
            "Stormwind, Orgrimmar, Dornogal, and other major cities light up the sky every hour on the hour, from 6 PM to 6 AM realm time.",
            " ",
            "#Make it pop",
            "An Inky Black Potion or the Shadescale toy darkens the sky so the fireworks really shine. The Date Simulation Modulator and Environmental Emulator toys are fun to pull out too.",
            " ",
            "#Party favors",
            "/dance with a Winter Reveler for the Celebrate Good Times! buff.",
            "Fill an Empty Festive Mug at a Festive Keg. The Filled Festive Mug makes you Lightheaded, so you float gently down from anywhere!",
        },
    },

    secrets = {
        {
            teaser = "Secret: a floating bar crawl...",
            reveal = "The Filled Festive Mug's Lightheaded buff gives you slow fall. Grab one, gather your guild, "
                  .. "and float from rooftop to rooftop between the fireworks shows.",
        },
        {
            teaser = "Secret: some say one city has the best show...",
            reveal = "Plenty of players swear Valdrakken (Dragonflight) has the best fireworks of all. "
                  .. "See for yourself, then hop to another city for the next hour!",
        },
    },
}
