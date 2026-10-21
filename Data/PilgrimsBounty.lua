-- Holiday Herald: Pilgrim's Bounty data
-- All IDs are item IDs unless noted. Pilgrim is its own meta (title + pet),
-- not part of the Violet Proto-Drake meta.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.PilgrimsBounty = {
    name  = "Pilgrim's Bounty",
    match = "pilgrim",
    iconAchievement = 3478,             -- Pilgrim

    colors = {
        main   = "E0B05A",              -- harvest gold
        accent = "C2414F",              -- cranberry
        card   = "22141A",
        border = "C2414F",
        titleGradient = { "E0B05A", "C2414F" },             -- harvest gold -> cranberry
        sections = { toGet = "E0B05A", howTo = "E8913A", secrets = "D9566A" },   -- harvest gold, squash, cranberry
    },

    achievements = {
        { achievement = 3478, name = "Pilgrim (title + Plump Turkey pet)" },
        { achievement = 3579, name = "\"FOOD FIGHT!\"" },
        { achievement = 3576, name = "Now We're Cookin'", faction = "Alliance" },
        { achievement = 3577, name = "Now We're Cookin'", faction = "Horde" },
        { achievement = 3556, name = "Pilgrim's Paunch", faction = "Alliance" },
        { achievement = 3557, name = "Pilgrim's Paunch", faction = "Horde" },
        { achievement = 3558, name = "Sharing is Caring" },
        { achievement = 3582, name = "Terokkar Turkey Time" },
        { achievement = 3578, name = "The Turkinator" },
        { achievement = 3559, name = "Turkey Lurkey" },
        { achievement = 3596, name = "Pilgrim's Progress", faction = "Alliance" },
        { achievement = 3597, name = "Pilgrim's Progress", faction = "Horde" },
        { achievement = 3580, name = "Pilgrim's Peril", faction = "Alliance" },
        { achievement = 3581, name = "Pilgrim's Peril", faction = "Horde" },
    },

    pets = {
        { item = 44810,  name = "Plump Turkey (Turkey Cage)", cost = "Pilgrim achievement" },
        { item = 116403, name = "Frightened Bush Chicken", cost = "Pilgrim's Bounty bag" },
    },

    toys = {
        { item = 116400, name = "Silver-Plated Turkey Shooter", cost = "Pilgrim's Bounty bag" },
    },

    -- Daily quest rewards, plus chance drops from the Pilgrim's Bounty bag
    transmog = {
        46723, 46800, 44785, 46824, 44788,      -- Pilgrim's Hat, Attire, Dress, Robe, Boots
        116401,                                 -- Fine Pilgrim's Hat
        248716, 248717, 248718, 248719,         -- Bountiful Backpacks (green, orange, purple, white)
    },

    -- Daily quests: turn in 20 of one dish each (cook it or buy it). IDs from Wowhead's guide; VERIFY in-game.
    dailies = {
        { quest = 14051, faction = "Alliance", group = "Outside Ironforge", name = "Don't Forget The Stuffing!", giver = "Caitrin Ironkettle", where = "20 Spice Bread Stuffing" },
        { quest = 14048, faction = "Alliance", group = "Outside Ironforge", name = "Can't Get Enough Turkey", giver = "Caitrin Ironkettle", where = "20 Slow-Roasted Turkey" },
        { quest = 14053, faction = "Alliance", group = "Stormwind gates", name = "We're Out of Cranberry Chutney Again?", giver = "Ellen Moore", where = "20 Cranberry Chutney" },
        { quest = 14055, faction = "Alliance", group = "Stormwind gates", name = "She Says Potato", giver = "Jasper Moore", where = "20 Candied Sweet Potato" },
        { quest = 14054, faction = "Alliance", group = "Outside Darnassus", name = "Easy As Pie", giver = "Mary Allerton", where = "20 Pumpkin Pie" },

        { quest = 14062, faction = "Horde", group = "Outside Orgrimmar", name = "Don't Forget The Stuffing!", giver = "Ondani Greatmill", where = "20 Spice Bread Stuffing" },
        { quest = 14061, faction = "Horde", group = "Outside Orgrimmar", name = "Can't Get Enough Turkey", giver = "Ondani Greatmill", where = "20 Slow-Roasted Turkey" },
        { quest = 14059, faction = "Horde", group = "Undercity courtyard", name = "We're Out of Cranberry Chutney Again?", giver = "Roberta Carter", where = "20 Cranberry Chutney" },
        { quest = 14058, faction = "Horde", group = "Undercity courtyard", name = "She Says Potato", giver = "William Mullins", where = "20 Candied Sweet Potato" },
        { quest = 14060, faction = "Horde", group = "Outside Thunder Bluff", name = "Easy As Pie", giver = "Mahara Goldwheat", where = "20 Pumpkin Pie" },
    },
    dailyNote = "Cook the dishes yourself or buy them from the holiday vendors. Each daily gives a Pilgrim's Bounty bag, which can hold the Bush Chicken pet, the Turkey Shooter toy, the Fine Pilgrim's Hat, and the Bountiful Backpacks.",

    tip = {
        short = "The best time of year to level Classic Cooking! Grab the Bountiful Cookbook at a feast table.",
        hover = {
            "#Cooking (1 to 300)",
            "Buy the Bountiful Cookbook (1 silver) from a Pilgrim's Bounty vendor by the tables outside capital cities. Its five recipes, plus vendor ingredients, can take Classic Cooking all the way from 1 to 300.",
            "Spice Bread Stuffing needs regular Spice Bread, so learn that recipe from any cooking trainer too.",
            "Wild Turkeys for the Slow-Roasted Turkey live in Tirisfal Glades, Elwynn Forest, Ohn'ahran Plains, and Isle of Dorn.",
            " ",
            "#Dailies",
            "Five cooking dailies at your faction's capital cities. You don't have to cook the food yourself, just turn it in. Their Pilgrim's Bounty bag can hold the Bush Chicken pet, the Turkey Shooter toy, the Fine Pilgrim's Hat, and the Bountiful Backpacks.",
            " ",
            "#Spirit of Sharing",
            "Eat five helpings of every food at a Bountiful Table for +10% reputation for an hour.",
            " ",
            "#Where",
            "Feast tables are outside every capital city, in Valdrakken and Dornogal, and in many smaller towns with an inn. Silvermoon's table is in Falconwing Square.",
        },
    },

    secrets = {
        {
            teaser = "Secret: your turkey has a dark sense of destiny...",
            reveal = "Summon your Plump Turkey pet near a campfire. It runs straight to it... and turns into a roast turkey!",
        },
        {
            teaser = "Secret: turkey hunters get a sixth sense...",
            reveal = "While working on The Turkinator, after about 20 Wild Turkeys you gain Turkey Tracking, "
                  .. "which shows nearby turkeys on your minimap.",
        },
        {
            teaser = "Secret: what you cook now pays off in December...",
            reveal = "Get Classic Cooking to 300 now. Winter Veil's Hot Apple Cider needs it for The Winter "
                  .. "Veil Gourmet, part of Merrymaker, which counts toward What a Long, Strange Trip It's Been.",
        },
        {
            teaser = "Secret: a bird king has a dress code...",
            reveal = "Defeat Talon King Ikiss in Sethekk Halls, Terokkar Forest (The Burning Crusade), while "
                  .. "wearing a Pilgrim's Hat and a Pilgrim's Dress, Robe, or Attire, for Terokkar Turkey Time.",
        },
    },
}
