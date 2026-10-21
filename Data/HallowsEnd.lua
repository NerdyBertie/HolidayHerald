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
        sections = { toGet = "7CD13E", howTo = "F07F2E", secrets = "B48CF0" },   -- fel, pumpkin, purple (lifted a bit to read on the dark card)
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

        -- Neighborhood (player housing) dailies, new in Midnight. IDs from the quest log (verified Oct 2026).
        { quest = 93400, group = "Your neighborhood", name = "Sugar Run", giver = "Yin Shuilan",
          where = "Take the portal to Nomi in the day's zone (like Duskwood), then take the portal back." },
        -- Nomi's candies: three per theme (Duskwood, Felwood, Drustvar). Pick one a day; any counts.
        -- IDs from Wowhead (Oct 2026).
        { quests = { 95822, 93401, 95825,     -- Duskwood
                     95827, 95828, 95829,     -- Felwood
                     92536, 92537, 92535 },   -- Drustvar
          group = "Your neighborhood", name = "Candy Crafting", giver = "Nomi",
          where = "Through the Sugar Run portal. Nomi offers three candies; pick one and bring it to the Wickerman piñata in your neighborhood. "
               .. "Duskwood: Blighted Core Caramels, Howling Honey Drops, Twisted Vine Licorice. "
               .. "Felwood: Blighted Bloom Bites, Felroot Crunch, Rotleaf Wafers. "
               .. "Drustvar: Bewitched Berry Bites, Hexed Honeycombs, Witchbane Truffles. "
               .. "All three from one theme earns that theme's achievement; all three themes earns Sweet Tooth." },
        { quest = 92104, faction = "Alliance", group = "Your neighborhood", name = "Broomstick Express", giver = "Alaric Duskwick",
          where = "Founder's Point (54.0, 33.8). Switch to steady flight first (the broom won't fly with skyriding), then deliver candy to the NPCs marked on your map." },
        { quest = 92104, faction = "Horde", group = "Your neighborhood", name = "Broomstick Express", giver = "Nargok Ghostcleaver",
          where = "Razorwind Shores (51.6, 54.2). Switch to steady flight first (the broom won't fly with skyriding), then deliver candy to the NPCs marked on your map." },
        { quest = 92455, faction = "Alliance", group = "Your neighborhood", name = "Specter Inspector", giver = "Alaric Duskwick",
          where = "Use the Ghost Gear, step into a ghost's or witch's circle, press the extra action button, and chase the ghost. Catch and deposit 5." },
        { quest = 92455, faction = "Horde", group = "Your neighborhood", name = "Specter Inspector", giver = "Nargok Ghostcleaver",
          where = "Use the Ghost Gear, step into a ghost's or witch's circle, press the extra action button, and chase the ghost. Catch and deposit 5." },

        { quest = 43162, group = "Val'sharah (Legion)", name = "Under the Crooked Tree", giver = "Bradensbrook",
          where = "Defeat the Hag of the Crooked Tree. Tricky Treats, and a small chance at one of four sisters' hats." },

        { quest = 39716, group = "Your garrison (Draenor)", name = "Smashing Squashlings", giver = "Orukan" },
        { quest = 39720, group = "Your garrison (Draenor)", name = "Foul Fertilizer", giver = "Orukan" },
        { quest = 39721, group = "Your garrison (Draenor)", name = "Culling the Crew", giver = "Orukan" },
        { quest = 39719, group = "Your garrison (Draenor)", name = "Mutiny on the Boneship", giver = "Orukan", where = "Group quest. Worth 2 Spooky Supplies." },
    },
    -- Timed events (startMinute = minutes past the hour it begins; seen Oct 21: :00 to :15)
    timedEvents = {
        { quest = 98801, name = "Community Candy Crawl", startMinute = 0, length = 15,
          where = "A neighborhood world quest in Founder's Point and Razorwind Shores. Loot the candy buckets outside occupied plots. "
               .. "10 Neighborhood Candy gets you experience, 2 Tricky Treats, and 3 more Neighborhood Candy." },
    },

    -- Holiday currency: entries with price = N add up into "Tricky Treats for the rest"
    currency = { item = 33226, name = "Tricky Treats",
        note = "Counts one of each thing you don't have yet. Prices from Chub and Woim (Oct 2026)." },

    dailyNote = "Catch 10 ghosts at least once for I Ain't Afraid of no Ghost. The neighborhood quests also give the day's candy (like Duskwood Caramels). The city quests give about 17 Tricky Treats a day at max level. Garrison quests give Spooky Supplies: spend 5 at Izzy Hollyfizzle for each of the five Hallow's End decorations, and trade extras for Tricky Treats.",

    -- Shade of the Horseman fires (the quest itself is in dailies above)
    moreTips = {
        { short = "Start at the Holiday Enthusiast in Silvermoon (51.2, 76.4), near the Trading Post.",
          title = "Holiday Enthusiast",
          hover = {
              "#Start here",
              "Among the pumpkins near the Trading Post in Silvermoon (51.2, 76.4). He has three lead-in quests:",
              " ",
              { "A Season for Celebration", "the Wickerman quests" },
              { "Costumed Orphan Matron", "the village fires" },
              { "A Haunted Home", "your neighborhood" },
              " ",
              "A Haunted Home sends you to Yin Shuilan in your neighborhood for the new neighborhood dailies.",
          } },
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
            { item = 208680, kind = "drake", unlockQuest = 77725, name = "Windborne Velocidrake: Hallow's End Armor" },
            { item = 117355, kind = "transmog", name = "The Horseman's Horrific Hood" },
            { item = 117356, kind = "transmog", name = "The Horseman's Sinister Slicer" },
            { item = 33292,  kind = "transmog", name = "Hallowed Helm", price = 100, cost = "or 100 Tricky Treats" },
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
        { item = 163045, name = "Headless Horseman's Hearthstone", price = 150, cost = "150 treats" },
        { item = 151271, name = "Horse Head Costume",              price = 150, cost = "150 treats" },
        { item = 151270, name = "Horse Tail Costume",              price = 150, cost = "150 treats" },
        { item = 70722,  name = "Little Wickerman",                price = 100, cost = "100 treats" },
    },

    -- Vendor battle pets (Tricky Treats, from Woim and Pippi)
    pets = {
        { item = 116801, name = "Cursed Birman",       price = 150, cost = "150 treats" },
        { item = 70908,  name = "Feline Familiar",     price = 150, cost = "150 treats" },
        { item = 33154,  name = "Sinister Squashling", price = 150, cost = "150 treats (also drops from the boss)" },
        { item = 116804, name = "Widget the Departed", price = 150, cost = "150 treats" },
        { item = 151269, name = "Naxxy",               price = 150, cost = "150 treats" },
        { item = 71076,  name = "Creepy Crate",        cost = "Missing Heirlooms quest chain" },
    },

    achievements = {
        { achievement = 18960, name = "Kickin' With the Wick" },
        { achievement = 17547, name = "The Lick King (collect Arfus)" },
    },

    -- Vendor transmog (count line only)
    transmog = {
        { item = 226453, name = "Patched Harvest Golem's Post", price = 100, cost = "100 Tricky Treats" },
        { item = 226427, name = "Patched Harvester's Claw", price = 100, cost = "100 Tricky Treats" },
        -- Patched Harvest Golem set pieces, 100 Tricky Treats each
        { item = 226461, price = 100 }, { item = 226458, price = 100 }, { item = 226457, price = 100 },
        { item = 226456, price = 100 }, { item = 226690, price = 100 }, { item = 226455, price = 100 },
        { item = 226454, price = 100 },
        { item = 230042, name = "Prowler's Faded Shoulder Cape", price = 50, cost = "50 Tricky Treats" },
        { item = 208735, name = "Bucket of Morbid Treats", price = 150, cost = "150 Tricky Treats" },
        { item = 247710, name = "The Horseman's Ghoulish Great Blade", price = 100, cost = "100 Tricky Treats" },
        { item = 247706, name = "The Horseman's Ghoulish Blade", price = 100, cost = "100 Tricky Treats" },
        { item = 247715, name = "The Horseman's Ghoulish Bulwark", price = 100, cost = "100 Tricky Treats" },
    },

    -- Housing decor (new in Midnight). Decor ownership can't be checked yet,
    -- so the card shows how many pieces there are and lists them on hover.
    decor = {
        -- Sold for gold
        { item = 282081, group = "For gold", name = "Candlelit Smiling Jack-o'-Lantern", cost = "500g" },
        { item = 282083, group = "For gold", name = "Unlit Smiling Jack-o'-Lantern", cost = "500g" },
        { item = 282086, group = "For gold", name = "Buckled Witch Hat", cost = "250g" },
        { item = 282090, group = "For gold", name = "Eternally Powered Glowskull", cost = "100g" },
        { item = 282072, group = "For gold", name = "Enchanted Hallow's End Candle", cost = "100g" },
        { item = 282051, group = "For gold", name = "Simple Hallow's End Candle", cost = "100g" },
        { item = 282077, group = "For gold", name = "Spooky Scarecrow", cost = "500g" },
        { item = 282095, group = "For gold", name = "Ominous Heartsbane Banner", cost = "500g" },
        { item = 282075, group = "For gold", name = "Heartsbane Candle", cost = "100g" },
        { item = 282092, group = "For gold", name = "Heartsbane Ritual Markings", cost = "500g" },
        { item = 282100, group = "For gold", name = "Heartsbane Doom Catcher", cost = "100g" },
        { item = 282098, group = "For gold", name = "Elaborate Heartsbane Doom Catcher", cost = "100g" },
        -- Sold for Tricky Treats
        { item = 282192, group = "For Tricky Treats", name = "Candlelit Shrieking Jack-o'-Lantern", price = 20, cost = "20 Tricky Treats" },
        { item = 282194, group = "For Tricky Treats", name = "Candlelit Ogre Jack-o'-Lantern", price = 20, cost = "20 Tricky Treats" },
        { item = 282196, group = "For Tricky Treats", name = "Filled Candy Bucket", price = 20, cost = "20 Tricky Treats" },
        { item = 282198, group = "For Tricky Treats", name = "Unlit Shrieking Jack-o'-Lantern", price = 20, cost = "20 Tricky Treats" },
        { item = 282200, group = "For Tricky Treats", name = "Unlit Ogre Jack-o'-Lantern", price = 20, cost = "20 Tricky Treats" },
        { item = 282202, group = "For Tricky Treats", name = "Elaborate Heartsbane Ritual Markings", price = 15, cost = "15 Tricky Treats" },
        { item = 282204, group = "For Tricky Treats", name = "Ominous Heartsbane Shrine", price = 25, cost = "25 Tricky Treats" },
        { item = 282206, group = "For Tricky Treats", name = "Heartsbane Stone Circle", price = 15, cost = "15 Tricky Treats" },
        { item = 282208, group = "For Tricky Treats", name = "Heartsbane Banner", price = 25, cost = "25 Tricky Treats" },
        { item = 282213, group = "For Tricky Treats", name = "Looming Heartsbane Effigy", price = 25, cost = "25 Tricky Treats" },
        { item = 282289, group = "For Tricky Treats", name = "Horrific Head of the Horseman", price = 20, cost = "20 Tricky Treats",
          note = "Or free: guaranteed for beating the Headless Horseman in the Dungeon Finder." },
        -- Recipes for crafted decor
        { item = 284212, recipe = true, group = "Recipes", name = "Technique: Apple Bobbing Bucket", price = 20, cost = "20 Tricky Treats" },
        { item = 284213, recipe = true, group = "Recipes", name = "Pattern: Spidery Witch Hat", price = 20, cost = "20 Tricky Treats" },
        -- Achievement reward (this one can be checked)
        { achievement = 10365, group = "Achievement reward", name = "Scarecrow Pepe", cost = "A Frightening Friend",
          note = "Talk to Pepe in a level 3 garrison during Hallow's End to unlock A Tiny Scarecrow Costume." },
    },
    decorNote = "Where to buy: the gold and Tricky Treat pieces and the recipes are sold by Echo (Tirisfal Glades), Jack (Elwynn Forest), Spew Gutsout (Razorwind Shores), and Cordula Wolfgang (Founder's Point).",

    -- Ensembles are checked from their tooltip ("Already known")
    reminders = {
        { item = 230173, kind = "ensemble", name = "Ensemble: Prowler's Faded Headgear", price = 150, cost = "150 Tricky Treats",
          faction = "Alliance", note = "From Dorothy or Pippi, the Hallow's End vanity vendors." },
        { item = 230173, kind = "ensemble", name = "Ensemble: Prowler's Faded Headgear", price = 150, cost = "150 Tricky Treats",
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
            teaser = "Secret: your neighborhood could use more cobwebs...",
            reveal = "Look for Webspinner Egg Sacs around your neighborhood. Click one to turn into a spider for "
                  .. "3 minutes and spin up to 10 webs, which adds to your Neighborhood Contribution. You can "
                  .. "stop early, but then there's a 15-minute wait before you can be a spider again.",
        },
        {
            teaser = "Secret: a glowing portal waits in your neighborhood...",
            reveal = "Catch ghosts with the Ghost Gear and drop them in the Ghost Tank. When the neighborhood fills "
                  .. "the tank, the Shade of Seabreaker Skoloth appears in the Holiday Hub. Click him to keep the "
                  .. "Ghost Gear beam on him, get close, and press the flexing-arm extra action button to yank him "
                  .. "forward. Keep doing it until he's in the glowing portal circle. He doesn't fight back, but watch "
                  .. "the ground: purple swirls fear you and watery circles knock you back. More neighbors make it "
                  .. "quicker. The portal opens a chest of Tricky Treats and Neighborhood Candy. The Headless Horseman "
                  .. "himself sometimes shows up and summons another Shade.",
        },
        {
            teaser = "Secret: some candy buckets hide in the past...",
            reveal = "Can't find a bucket in Darkshore, Silithus, Blasted Lands, Arathi Highlands, or Tirisfal "
                  .. "Glades? Talk to Zidormi in that zone to see its older version, where the bucket is.",
        },
    },
}
