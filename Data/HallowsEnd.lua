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
        border = "7CD13E",              -- fel green
        titleGradient = { "7CD13E", "F07F2E", "9B6BD6" },   -- fel -> pumpkin -> purple
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
            -- The Horseman's Ghoulish Collection: one guaranteed piece per day until you have all nine
            { item = 247964, kind = "transmog", name = "The Horseman's Ghoulish Helm" },
            { item = 247965, kind = "transmog", name = "The Horseman's Ghoulish Mantle" },
            { item = 247972, kind = "transmog", name = "The Horseman's Ghoulish Cloak" },
            { item = 247966, kind = "transmog", name = "The Horseman's Ghoulish Breastplate" },
            { item = 247967, kind = "transmog", name = "The Horseman's Ghoulish Cinch" },
            { item = 247968, kind = "transmog", name = "The Horseman's Ghoulish Greaves" },
            { item = 250708, kind = "transmog", name = "The Horseman's Ghoulish Cowl" },
            { item = 247971, kind = "transmog", name = "The Horseman's Ghoulish Grips" },
            { item = 247969, kind = "transmog", name = "The Horseman's Ghoulish Treads" },
        },
        hardMode = "Just inside the dungeon on your left are five Wicker Men. Each small one gives one "
                .. "curse; the big one in the middle gives all four at once. Each curse raises your "
                .. "first-kill-of-the-day mount chance. Curses are personal, so they only affect you. "
                .. "If you would die, the Wicker Men save you but take the curses (and their bonus) away. "
                .. "All four curses earns Kickin' With the Wick.",
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

    achievements = {
        { achievement = 18960, name = "Kickin' With the Wick" },
        { achievement = 17547, name = "The Lick King (collect Arfus)" },
    },

    -- Vendor transmog (count line only)
    transmog = {
        226453, 226427,         -- Patched Harvest Golem's Post, Patched Harvester's Claw
        226461, 226458, 226457, 226456, 226690, 226455, 226454, -- Patched Harvest Golem set pieces
        230042,                 -- Prowler's Faded Shoulder Cape
        208735,                 -- Bucket of Morbid Treats
        247710, 247706, 247715, -- The Horseman's Ghoulish Great Blade, Blade, Bulwark
    },

    -- Ensembles can't be checked yet, so they're listed as plain reminders
    reminders = {
        { item = 230173, kind = "reminder", name = "Ensemble: Prowler's Faded Headgear" },
    },

    tip = {
        short = "Candy buckets in inns give Tricky Treats. Queue for the Headless Horseman daily.",
        hover = {
            "#Candy buckets",
            "Each continent's candy buckets count toward its achievement. Each bucket is a one-time quest worth XP, a little gold, and treats.",
            " ",
            "#Wickerman buffs (outside Stormwind and Undercity)",
            "Click the glowing ashes by the Wickerman for +10% XP and reputation for 2 hours. It drops if you die, but you can grab it again right away.",
            "Every 4 hours, Genn Greymane or Sylvanas watches the Wickerman burn and gives everyone nearby an hour-long buff.",
            " ",
            "#Shade of the Horseman",
            "Every half hour he attacks Goldshire, Kharanos, and Azure Watch (Alliance) or Razor Hill, Falconwing Square, and Brill (Horde). Help put out the fires for a gift that can hold candy, masks, or even a broom.",
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
            reveal = "The Coin of Many Faces toy is a rare drop from enemies like Salty Dregs and Boneship "
                  .. "Revelers on the Isle of Shadows, Shadowmoon Valley (Warlords of Draenor), around 39.0, 80.0. "
                  .. "They'll get you drunk, so bring some coffee to sober up!",
            toy = 128807,
        },
        {
            teaser = "Secret: four sisters left their hats behind...",
            reveal = "Duroc Ironjaw, drinking in the Legerdemain Lounge in Legion's Dalaran, warns you away from "
                  .. "the crooked tree in Bradensbrook, Val'sharah (Legion) at 35.0, 56.0. Go anyway! Its daily "
                  .. "quest, Under the Crooked Tree, rewards Hag's Belongings, which can contain one of four "
                  .. "witch hats. Level 40 or higher.",
            transmog = { 139133, 139134, 139135, 139136 },
        },
        {
            teaser = "Secret: innkeepers want a little performance...",
            reveal = "The yearly quest from Spoops (Horde) or Jesper (Alliance) by the Wickerman sends you to "
                  .. "capital city innkeepers for treats, but each one wants a different emote first: "
                  .. "/flex, /train, /chicken, or /dance.",
        },
        {
            teaser = "Secret: some candy buckets hide in the past...",
            reveal = "Can't find a bucket in Darkshore, Silithus, Blasted Lands, Arathi Highlands, or Tirisfal "
                  .. "Glades? Talk to Zidormi in that zone to see its older version, where the bucket is.",
        },
    },
}
