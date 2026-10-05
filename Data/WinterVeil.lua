-- Holiday Herald: Feast of Winter Veil data (December 15 - January 2)
-- All IDs are item IDs unless noted. Lines marked VERIFY need an in-game check.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.WinterVeil = {
    name  = "Feast of Winter Veil",
    match = "winter veil",

    colors = {
        main   = "E23B3B",
        accent = "3E9E6A",
        card   = "1C1A18",
        border = "3E9E6A",
        titleGradient = { "E23B3B", "F3E9E4", "3E9E6A" },   -- cranberry -> snow -> evergreen
    },

    meta = {
        holidayMeta = 1691,             -- Merrymaker (verified in-game)
        strangeTrip = 2144,
    },

    achievements = {
        { achievement = 42192, name = "Snowball Fight!" },
    },

    mounts = {
        { item = 128671, name = "Minion of Grumpus", cost = "Savage Gift (Merry Supplies, very rare)" },
    },

    -- Many of these come from the Stolen Present (the Greench daily) or past years' gifts
    toys = {
        { item = 243304, name = "Jubilant Snowman Costume",          cost = "2025 gift" },
        { item = 245580, name = "Rolling Snowball",                  cost = "2025 gift" },
        { item = 172222, name = "Crashin' Thrashin' Juggernaught",   cost = "Stolen Present" },
        { item = 172223, name = "Crashin' Thrashin' Battleship",     cost = "Stolen Present" },
        { item = 162643, name = "Toy Armor Set (Horde)",             cost = "Stolen Present" },
        { item = 162642, name = "Toy Armor Set (Alliance)",          cost = "Stolen Present" },
        { item = 162973, name = "Greatfather Winter's Hearthstone",  cost = "Stolen Present" },
        { item = 151343, name = "Hearthstation (Horde)",             cost = "Stolen Present" },
        { item = 151344, name = "Hearthstation (Alliance)",          cost = "Stolen Present" },
        { item = 151349, name = "Toy Weapon Set (Horde)",            cost = "Stolen Present" },
        { item = 151348, name = "Toy Weapon Set (Alliance)",         cost = "Stolen Present" },
        { item = 139337, name = "Disposable Winter Veil Suits",      cost = "Stolen Present" },
        { item = 128636, name = "Endothermic Blaster",               cost = "Stolen Present" },
        { item = 128776, name = "Red Wooden Sled",                   cost = "Stolen Present" },
        { item = 178530, name = "Wreath-A-Rang",                     cost = "Stolen Present" },
        { item = 172219, name = "Wild Holly",                        cost = "Stolen Present" },
        { item = 116456, name = "Scroll of Storytelling",            cost = "Stolen Present" },
        { item = 116763, name = "Crashin' Thrashin' Shredder Controller", cost = "Stolen Present" },
        { item = 108632, name = "Crashin' Thrashin' Flamer Controller",   cost = "Stolen Present" },
        { item = 104318, name = "Crashin' Thrashin' Flyer Controller",    cost = "Stolen Present" },
        { item = 37710,  name = "Crashin' Thrashin' Racer Controller",    cost = "Stolen Present" },
        { item = 46709,  name = "MiniZep Controller",                cost = "Stolen Present" },
        { item = 90888,  name = "Special Edition Foot Ball",         cost = "Stolen Present" },
        { item = 90883,  name = "The Pigskin",                       cost = "Stolen Present" },
        { item = 116692, name = "Fuzzy Green Lounge Cushion",        cost = "Stolen Present" },
        { item = 116690, name = "Safari Lounge Cushion",             cost = "Stolen Present" },
        { item = 116689, name = "Pineapple Lounge Cushion",          cost = "Stolen Present" },
        { item = 116691, name = "Zhevra Lounge Cushion",             cost = "Stolen Present" },
        { item = 209859, name = "Festive Trans-Dimensional Bird Whistle", cost = "Stolen Present" },
        { item = 108635, name = "Crashin' Thrashin' Killdozer Controller", cost = "5 Merry Supplies" },
        { item = 17712,  name = "Winter Veil Disguise Kit",          cost = "Mailed after the Greench quests" },
    },

    pets = {
        { item = 245544, name = "Tiny Snow Buddy",            cost = "2025 gift" },
        { item = 178533, name = "Jingles (Shaking Pet Carrier)", cost = "Stolen Present" },
        { item = 73797,  name = "Lump of Coal",               cost = "Stolen Present" },
        { item = 104317, name = "Rotten Little Helper",       cost = "Stolen Present" },
        { item = 34425,  name = "Clockwork Rocket Bot",       cost = "Stolen Present" },
        { item = 54436,  name = "Blue Clockwork Rocket Bot",  cost = "Stolen Present or toy vendors" },
        { item = 21301,  name = "Green Helper Box",           cost = "Gaily Wrapped Present" },
        { item = 21305,  name = "Red Helper Box",             cost = "Gaily Wrapped Present" },
        { item = 21308,  name = "Jingling Bell",              cost = "Gaily Wrapped Present" },
        { item = 21309,  name = "Snowman Kit",                cost = "Gaily Wrapped Present" },
    },

    transmog = {
        234401, 234593, 234400, 234594,   -- Festive coats and vests (green, red)
        234407, 234406,                   -- Festive boots
        234403, 234405, 234402, 234404,   -- Festive pants and shorts
        234597, 234596, 234598, 234595,   -- Festive shirts and sweaters
        234398, 234399,                   -- Festive belts
        { item = 70923,  name = "Gaudy Winter Veil Sweater" },
        { item = 151790, name = "Red Winter Clothes" },
        { item = 151792, name = "Green Winter Clothes" },
        { item = 116448, name = "Warm Red Woolen Socks" },
        { item = 116451, name = "Warm Blue Woolen Socks" },
        { item = 116450, name = "Warm Green Woolen Socks" },
        { item = 139300, name = "Finely-Tailored Green Holiday Hat", note = "Rare drop from hat-wearing dungeon bosses" },
        { item = 139299, name = "Finely-Tailored Red Holiday Hat",   note = "Rare drop from hat-wearing dungeon bosses" },
        { item = 21525,  name = "Green Winter Hat", note = "Rare drop from hat-wearing dungeon bosses" },
        { item = 21524,  name = "Red Winter Hat",   note = "Rare drop from hat-wearing dungeon bosses" },
    },

    reminders = {
        { item = 210432, kind = "reminder", name = "Highland Drake: Winter Veil Armor", cost = "Stolen Present" },
    },

    -- Treats for Greatfather Winter: 5 Gingerbread Cookies and an Ice Cold Milk
    shoppingFor = "Greatfather Winter's treats",
    shopping = {
        { item = 17197, count = 5, name = "Gingerbread Cookie", where = "cook them, or check the Auction House" },
        { item = 1179,  count = 1, name = "Ice Cold Milk",      where = "innkeeper" },
    },

    tip = {
        short = "Presents appear under the tree on December 25. Open them on every character!",
        hover = {
            "#Presents (December 25 to January 2)",
            "Six presents wait under the tree in Ironforge and Orgrimmar, and every character can open them. Some need level 10.",
            " ",
            "#The Abominable Greench (daily)",
            "Take the quest You're a Mean One... in Ironforge or Orgrimmar, then defeat the Greench at Growless Cave in Hillsbrad Foothills. His Stolen Present can hold toys and pets from past years.",
            "Father Winter's Helper gives sleigh rides there from Ironforge and Orgrimmar, and to those cities from Dornogal (48.0, 52.2).",
            " ",
            "#Little extras",
            "/kiss a Winter Reveler under the mistletoe in inns (once an hour) for holiday goodies.",
            "Step into a Winter Wondervolt machine to become a Little Helper.",
            "Humanoid dungeon bosses wear festive hats, and have a rare chance to drop them.",
            " ",
            "#Cooking",
            "The Winter Veil Gourmet (part of Merrymaker) needs Hot Apple Cider, which takes Classic Cooking 300. Cooks get the recipe in the mail, or buy it from a Smokywood Pastures vendor.",
        },
    },

    classLines = {
        {
            class = "HUNTER",
            short = "Hunters: tame the Dreaming Festive Reindeer in Old Hillsbrad Foothills!",
            hover = {
                "#Before you go",
                "Buy a matching red or green festive set (coat, belt, pants or shorts, boots) from the Smokywood Pastures vendor (Penney Copperpinch in Orgrimmar, Wulmort Jinglepocket in Ironforge) and wear or transmog it. The vest doesn't work; the coat does.",
                " ",
                "#Where",
                "Old Hillsbrad Foothills is a dungeon in the Caverns of Time. Once you zone in, find the reindeer at 35.2, 37.3. Keep the outfit on or it disappears.",
            },
        },
    },

    secrets = {
        {
            teaser = "Secret: something small hides in the snow...",
            reveal = "The Grumpling can be looted from snow piles in Frostfire Ridge (Warlords of Draenor), "
                  .. "around Daggermaw Ravine (45.0, 27.0).",
        },
        {
            teaser = "Secret: look closely at the snow globes...",
            reveal = "Step into the snow globes in Ironforge and Orgrimmar to turn into a gnome and fly around inside. "
                  .. "Sometimes a Globe Yeti battle pet spawns in there, and it's the only way to get one.",
        },
        {
            teaser = "Hunters: one reindeer has a special nose...",
            reveal = "The red-nosed Dreaming Festive Reindeer is a rarer random spawn. Reset the dungeon to reroll "
                  .. "until you get it. Both versions are permanent pets once tamed.",
        },
        {
            teaser = "Secret: even a cosmic villain gets festive...",
            reveal = "Dimensius in K'aresh joins in on Winter Veil too. Maybe he'll give you his hat if you hit him hard enough...",
        },
        {
            teaser = "Secret: one boss only dresses up on Christmas Day...",
            reveal = "On December 25 only, Siegecrafter Blackfuse in Siege of Orgrimmar (Mists of Pandaria) decorates "
                  .. "himself with lights and wreaths, his sawblades turn into wreaths, and his mines carry gifts.",
        },
    },
}
