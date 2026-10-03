-- Holiday Herald: Hallow's End data
-- All IDs are item IDs unless noted. Lines marked VERIFY need an in-game check.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.HallowsEnd = {
    name  = "Hallow's End",
    match = "hallow's end",

    colors = {
        main   = "F07F2E",              -- pumpkin
        accent = "9B6BD6",              -- witchy purple
        card   = "1F1626",
    },

    meta = {
        holidayMeta = 1656,                                 -- Hallowed Be Thy Name (verified in-game; one ID for both factions)
        strangeTrip = 2144,                                 -- What a Long, Strange Trip It's Been (verified in-game)
    },

    -- Holiday boss: Headless Horseman, Loot-Filled Pumpkin (item 209024)
    boss = {
        name = "Headless Horseman",
        lfg  = 285,                     -- Dungeon Finder ID (verified in-game; levels 10-90)
        drops = {
            { item = 37012,  kind = "mount", name = "The Horseman's Reins" },
            { item = 247721, kind = "mount", name = "The Headless Horseman's Ghoulish Charger" },
            { item = 211271, kind = "pet",   name = "Arfus" },
            { item = 33154,  kind = "pet",   name = "Sinister Squashling" },
            { item = 208680, kind = "drake", name = "Windborne Velocidrake: Hallow's End Armor",
              reminderOnly = true },
            { item = 117355, kind = "transmog", name = "The Horseman's Horrific Hood" },
            { item = 117356, kind = "transmog", name = "The Horseman's Sinister Slicer" },
            { item = 33292,  kind = "transmog", name = "Hallowed Helm" },
            { item = 247973, kind = "ensemble", name = "The Horseman's Ghoulish Collection",
              note = "One guaranteed piece per day, no duplicates" },   -- VERIFY how to check ensembles
        },
        hardMode = "Before the fight, talk to the four Wicker Men at the start of the Scarlet Monastery "
                .. "Graveyard. Each curse raises your first-kill-of-the-day mount chance. Everyone opts in "
                .. "separately, and you must not die. All four curses earns Kickin' With the Wick.",
        hardModeAchievement = 18960,
    },

    -- Vendor toys (Tricky Treats, from Chub and Dorothy)
    toys = {
        { item = 163045, name = "Headless Horseman's Hearthstone", cost = "150 treats" },
        { item = 151271, name = "Horse Head Costume",              cost = "150 treats" },
        { item = 151270, name = "Horse Tail Costume",              cost = "150 treats" },
        { item = 70722,  name = "Little Wickerman",                cost = "150 treats" },
    },

    -- Vendor battle pets (Tricky Treats, from Woim and Pippi)
    pets = {
        { item = 116801, name = "Cursed Birman",       cost = "150 treats" },
        { item = 70908,  name = "Feline Familiar",     cost = "150 treats" },
        { item = 33154,  name = "Sinister Squashling", cost = "150 treats (also drops from the boss)" },
        { item = 116804, name = "Widget the Departed", cost = "150 treats" },
        { item = 151269, name = "Naxxy",               cost = "150 treats" },
        { item = 71076,  name = "Creepy Crate",        cost = "Missing Heirlooms quest chain" },
    },

    -- Vendor transmog (count line only)
    transmog = {
        226453, 226427,         -- Patched Harvest Golem's Post, Patched Harvester's Claw
        230042,                 -- Prowler's Faded Shoulder Cape
        208735,                 -- Bucket of Morbid Treats
        247710, 247706, 247715, -- The Horseman's Ghoulish Great Blade, Blade, Bulwark
    },

    -- Ensembles can't be checked yet, so they're listed as plain reminders
    reminders = {
        { item = 226471, kind = "reminder", name = "Ensemble: Patched Harvest Golem", cost = "700 treats" },
        { item = 230173, kind = "reminder", name = "Ensemble: Prowler's Faded Headgear" },
    },

    tip = {
        short = "Candy buckets in inns give Tricky Treats. Queue for the Headless Horseman daily.",
        hover = {
            "#Candy buckets",
            "Each continent's candy buckets count toward its achievement.",
            " ",
            "#Leveling",
            "Each bucket is a quick quest worth XP.",
            "The Wickerman bonfire outside Undercity or Stormwind gives a 10% XP and reputation buff.",
            " ",
            "#Save your treats",
            "Wait until the last few days to shop: the Horseman's pumpkin can drop some vendor items for free.",
        },
    },

    classLines = {},

    secrets = {
        {
            teaser = "Secret: Pepe dresses up for Hallow's End too...",
            reveal = "Find Pepe in a level 3 Warlords of Draenor garrison during the event "
                  .. "(Horde 71, 90 / Alliance 40, 70) for A Frightening Friend and his scarecrow costume.",
            achievement = 10365,
        },
        {
            teaser = "Secret: something creepy crawls in old garrisons...",
            reveal = "Place the Creepy Crawlers decoration in your Warlords of Draenor garrison. Pet battle "
                  .. "there for the Ghastly Rat, Ghost Maggot, and Spectral Spinner, and look for the rare "
                  .. "Arachnis, who can drop the Sack of Spectral Spiders toy (once a day).",
            toy = 128794,
        },
        {
            teaser = "Secret: a coin with many faces hides on a shadowy isle...",
            reveal = "The Coin of Many Faces toy is a rare drop from Hallow's End-only enemies on the Isle "
                  .. "of Shadows, off the southwest coast of Shadowmoon Valley (Warlords of Draenor).",
            toy = 128807,
        },
        {
            teaser = "Secret: four sisters left their hats behind...",
            reveal = "The daily quest Under the Crooked Tree, in Bradensbrook, Val'sharah (Legion) at 35.0, 56.0, "
                  .. "rewards Hag's Belongings, which can contain one of four witch hats.",
            transmog = { 139133, 139134, 139135, 139136 },
        },
    },
}
