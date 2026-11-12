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
            "#Getting there",
            "Take the portal to Mount Hyjal from Stormwind or Orgrimmar and fly down into Moonglade. Druids can teleport straight there.",
            " ",
            "#Start",
            "Talk to Makkaw in Moonglade, on the path by the Stormrage Barrow Dens (45.4, 62.0), for Moonkin Monitoring. Watch his three hatchling classes for about 30 seconds each:",
            { "Astralaire (dancing)", "45.4, 63.4" },
            { "Pewkew (Moonfire)", "42.4, 66.5" },
            { "Dramock (naptime)", "44.7, 69.9" },
            "Turn it in for your first hatchling and the temporary title \"Adventuring Instructor.\"",
            " ",
            "#Earning all five (talk to your hatchlings for hints)",
            { "2nd: feed it 5 Moonberries", "by tree bases, east (61, 66)" },
            { "3rd: Moonkissed Antidote", "combine 3 Jadefire drops" },
            { "4th: cure Clookle", "bottom of the Barrow Den (68.2, 56.9)" },
            { "5th: defeat Xavinox", "use his Beanie Boomie (68, 60)" },
            "The antidote takes Moonglow Water, a Brilliant Vial, and Constellas Corruption, from the Jadefire satyrs around the Barrow Dens. Once you have all three, click one in your bags to combine them into the Moonkissed Antidote. Clookle is at the very bottom of the den: go in by the big moonwell (71.2, 56.2) and keep taking the paths down. Can't spot Clookle? Once you're near the bottom, type /target Clookle in chat to find them. Xavinox stays friendly (green) until you've cured Clookle, then you can fight him.",
            " ",
            "#Heads up",
            "Jadefire satyrs are all over the berry area and will attack you, so keep an eye out while you're picking. (Makkaw's classes are safe.)",
            "Xavinox scales to your level and hits hard (interrupt his Pyroblast, and watch his Mirror Images), so bring friends. Once you have the hatchlings, the buff can't be cancelled, and stealth hides them for a moment.",
        },
    },

    -- HandyNotes map pins (Moonglade, map 80). All checked in game by Roberta, Nov 12 2026.
    pins = {
        { map = 80, x = 45.4, y = 62.0, title = "Moonkin Festival: Makkaw",
          note = { "Start here: Moonkin Monitoring.", { "Astralaire (dancing)", "45.4, 63.4" }, { "Pewkew (Moonfire)", "42.4, 66.5" }, { "Dramock (naptime)", "44.7, 69.9" } } },
        { map = 80, x = 61.0, y = 66.0, title = "Moonkin Festival: Moonberries",
          note = "Glittering at the bases of trees past the second bridge east of Makkaw. Feed 5 to your hatchling for the 2nd one. Watch out: Jadefire satyrs roam here and will attack." },
        { map = 80, x = 71.2, y = 56.2, title = "Moonkin Festival: Clookle's den (entrance)",
          note = "Go in here, by the big moonwell, and keep taking the paths down to find Clookle at the very bottom. Tip: /target Clookle makes them easier to spot." },
        { map = 80, x = 68.2, y = 56.9, title = "Moonkin Festival: Clookle",
          note = "Deep inside the Barrow Den: go in at the entrance by the big moonwell (71.2, 56.2) and keep taking the paths down. Cure them with the Moonkissed Antidote for the 4th hatchling. Hard to spot? Type /target Clookle once you're near the bottom." },
        { map = 80, x = 68.0, y = 60.0, title = "Moonkin Festival: Xavinox",
          note = "On a platform in the moonwell. He stays friendly (green) until you've cured Clookle. Tough, so bring friends. Use his Beanie Boomie for the 5th hatchling." },
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
