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

    -- Daily quests (IDs from Wowhead and the WoW wiki; VERIFY in-game)
    dailies = {
        { quest = 29054, faction = "Alliance", group = "Stormwind", name = "Stink Bombs Away!", giver = "Gretchen Fenlow" },
        { quest = 29144, faction = "Alliance", group = "Stormwind", name = "Clean Up in Stormwind", giver = "Gretchen Fenlow" },
        { quest = 29075, faction = "Alliance", group = "Stormwind", name = "A Time to Gain", giver = "Celestine of the Harvest", where = "At the Wickerman bonfire." },
        { quest = 29371, faction = "Alliance", group = "Stormwind", name = "A Time to Lose", giver = "Keira", where = "Douse the Horde's Wickerman." },
        { quest = 29374, faction = "Horde", group = "Undercity", name = "Stink Bombs Away!", giver = "Candace Fenlow" },
        { quest = 29375, faction = "Horde", group = "Undercity", name = "Clean Up in Undercity", giver = "Candace Fenlow" },
        { quest = 29376, faction = "Horde", group = "Undercity", name = "A Time to Build Up", giver = "Darkcaller Yanka", where = "At the Wickerman bonfire." },
        { quest = 29377, faction = "Horde", group = "Undercity", name = "A Time to Break Down", giver = "Darkcaller Yanka", where = "Douse the Alliance's Wickerman." },

        -- "Let the Fires Come!" starts the attack; "Stop the Fires!" is taken mid-attack. Either one counts.
        { quests = { 12135, 11131 }, faction = "Alliance", group = "Village fires", name = "Let the Fires Come!",
          giver = "Costumed Orphan Matron", where = "Goldshire, Kharanos, or Azure Watch. Any one town, once a day." },
        { quests = { 12139, 11219 }, faction = "Horde", group = "Village fires", name = "Let the Fires Come!",
          giver = "Masked Orphan Matron", where = "Razor Hill, Brill, or Eversong Woods. Any one town, once a day." },

        { quest = 43162, group = "Val'sharah (Legion)", name = "Under the Crooked Tree", giver = "Bradensbrook",
          where = "Defeat the Hag of the Crooked Tree. Tricky Treats, and a small chance at one of four sisters' hats." },

        { quest = 39716, group = "Your garrison (Draenor)", name = "Smashing Squashlings", giver = "Orukan" },
        { quest = 39720, group = "Your garrison (Draenor)", name = "Foul Fertilizer", giver = "Orukan" },
        { quest = 39721, group = "Your garrison (Draenor)", name = "Culling the Crew", giver = "Orukan" },
        { quest = 39719, group = "Your garrison (Draenor)", name = "Mutiny on the Boneship", giver = "Orukan", where = "Group quest. Worth 2 Spooky Supplies." },
    },
    dailyNote = "The city quests give about 17 Tricky Treats a day at max level. Garrison quests give Spooky Supplies: spend 5 at Izzy Hollyfizzle for each of the five Hallow's End decorations, and trade extras for Tricky Treats.",

    -- Shade of the Horseman fires (the quest itself is in dailies above)
    moreTips = {
        { faction = "Alliance", short = "Save Goldshire, Kharanos, or Azure Watch from the Shade of the Horseman's fires once a day.",
          title = "Let the Fires Come!",
          hover = {
              "#How it works",
              "Take Let the Fires Come! from the Costumed Orphan Matron. Accepting it starts the attack, so there's no timer to wait for.",
              "Grab a bucket from the Water Barrel next to her. Use it to make a target circle, then click the circle to throw.",
              "Put out every fire and the Shade of the Horseman lands. Defeat him and loot the Large Jack-o'-Lantern (once a day) for a Crudely Wrapped Gift.",
              " ",
              "#Missed it?",
              "If the fires win, the quest stays in your log. Turn it in the next time a town is saved, at any of your faction's Matrons.",
          } },
        { faction = "Horde", short = "Save Razor Hill, Brill, or Eversong Woods from the Shade of the Horseman's fires once a day.",
          title = "Let the Fires Come!",
          hover = {
              "#How it works",
              "Take Let the Fires Come! from the Masked Orphan Matron. Accepting it starts the attack, so there's no timer to wait for.",
              "Grab a bucket from the Water Barrel next to her. Use it to make a target circle, then click the circle to throw.",
              "Put out every fire and the Shade of the Horseman lands. Defeat him and loot the Large Jack-o'-Lantern (once a day) for a Crudely Wrapped Gift.",
              " ",
              "#Missed it?",
              "If the fires win, the quest stays in your log. Turn it in the next time a town is saved, at any of your faction's Matrons.",
          } },
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
            { item = 208680, kind = "drake", name = "Windborne Velocidrake: Hallow's End Armor" },
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
        { item = 226453, name = "Patched Harvest Golem's Post" },
        { item = 226427, name = "Patched Harvester's Claw" },
        226461, 226458, 226457, 226456, 226690, 226455, 226454, -- Patched Harvest Golem set pieces
        { item = 230042, name = "Prowler's Faded Shoulder Cape" },
        { item = 208735, name = "Bucket of Morbid Treats" },
        { item = 247710, name = "The Horseman's Ghoulish Great Blade" },
        { item = 247706, name = "The Horseman's Ghoulish Blade" },
        { item = 247715, name = "The Horseman's Ghoulish Bulwark" },
    },

    -- Ensembles are checked from their tooltip ("Already known")
    reminders = {
        { item = 230173, kind = "ensemble", name = "Ensemble: Prowler's Faded Headgear", cost = "150 Tricky Treats",
          faction = "Alliance", note = "From Dorothy or Pippi, the Hallow's End vanity vendors." },
        { item = 230173, kind = "ensemble", name = "Ensemble: Prowler's Faded Headgear", cost = "150 Tricky Treats",
          faction = "Horde", note = "From Chub or Woim, the Hallow's End vanity vendors." },
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
