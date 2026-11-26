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
    dailyNote = "Pick one reward for each daily: a piece of the Pilgrim's outfit (Hat, Attire, Dress, Robe, or Boots) or the Pilgrim's Bounty bag. "
             .. "Buy the ingredients and cook the dishes yourself. Honey, Autumnal Herbs, and each dish's main ingredient (pumpkins, cranberries, sweet potatoes) are sold only by the holiday vendors. "
             .. "Spices, spring water, and flour are sold by regular vendors too. Can't Get Enough Turkey needs Wild Turkey meat from hunting. The rest can be bought.",

    tip = {
        short = "The best time of year to level Classic Cooking! Grab the Bountiful Cookbook at a feast table.",
        hover = {
            "#Cooking (1 to 300)",
            "Buy the Bountiful Cookbook (1 silver) from a Pilgrim's Bounty vendor by the tables. Its five recipes, plus vendor ingredients, can take Classic Cooking all the way from 1 to 300. They show up under Holiday Cooking in your cooking window, and there's a cooking fire by the quest givers at the Bountiful Tables.",
            "Spice Bread Stuffing needs regular Spice Bread, so learn that recipe from any cooking trainer too.",
            "Wild Turkeys for the Slow-Roasted Turkey live in Tirisfal Glades, Elwynn Forest, Ohn'ahran Plains, and Isle of Dorn.",
            " ",
            "#Dailies",
            "Five cooking dailies at your faction's capital cities. Pick one reward for each: a piece of the Pilgrim's outfit or the Pilgrim's Bounty bag. Buy the ingredients and cook the dishes yourself.",
            " ",
            "#Ingredients",
            "Honey, Autumnal Herbs, and each dish's main ingredient (pumpkins, cranberries, sweet potatoes) are sold only by the holiday vendors. Spices, spring water, and flour are sold by regular vendors too.",
            " ",
            "#Spirit of Sharing",
            "Eat five helpings of every food at a Bountiful Table for +10% reputation for an hour.",
            " ",
            "#Where",
            "Feast tables are by every capital city, in Valdrakken and Dornogal, and in many smaller towns with an inn. Silvermoon's table is in Falconwing Square.",
        },
    },

    moreTips = {
        { short = "Easiest daily: Sharing a Bountiful Feast, no cooking needed.",
          title = "Sharing a Bountiful Feast",
          hover = {
              "#Sharing a Bountiful Feast",
              "Talk to the hostess at any Bountiful Table, then eat five helpings of each food. No cooking needed, and you pick your reward just like the other dailies.",
              " ",
              "#The Pilgrim's Bounty bag",
              "Your bag can hold a bonus food with buffs, a Turkey Shooter, the Silver-Plated Turkey Shooter toy, the Bush Chicken pet, the Fine Pilgrim's Hat, or Bountiful Backpacks.",
          } },
        { short = "Turkey Lurkey needs a Turkey Shooter for each Rogue race.",
          title = "Turkey Lurkey",
          hover = {
              "Most Pilgrim's Bounty bags hold a Turkey Shooter. Use one on a Rogue of each race to turn them into a turkey.",
              "The Turkey Shooter is soulbound, and it only works while the holiday is running.",
          } },
        { short = "Wild Turkeys are all over Tirisfal Glades, around Brill.", faction = "Horde",
          title = "Wild Turkeys",
          hover = {
              "Wild Turkeys are all over Tirisfal Glades, around Brill. They also live in Elwynn Forest, Ohn'ahran Plains, and Isle of Dorn.",
              "You need their meat for Slow-Roasted Turkey and the Can't Get Enough Turkey daily.",
          } },
        { short = "Wild Turkeys are all over Elwynn Forest.", faction = "Alliance",
          title = "Wild Turkeys",
          hover = {
              "Wild Turkeys are all over Elwynn Forest. They also live in Tirisfal Glades, Ohn'ahran Plains, and Isle of Dorn.",
              "You need their meat for Slow-Roasted Turkey and the Can't Get Enough Turkey daily.",
          } },
    },

    -- HandyNotes map pins (only shown with HandyNotes installed, while Pilgrim's Bounty is on).
    -- The Bountiful Tables by each capital city, with the vendor, quest givers, and a cooking fire.
    -- All spots stood on in game by Roberta, Nov 24 2026.
    pins = {
        { map = 37, x = 33.8, y = 50.8, faction = "Alliance", title = "Pilgrim's Bounty: Stormwind feast",
          note = { "Bountiful Tables, the quest givers, and a cooking fire.", { "Wilmina Holbeck", "Ripe Elwynn Pumpkin" }, "Honey and Autumnal Herbs are sold here too." } },
        { map = 27, x = 60.0, y = 34.4, faction = "Alliance", title = "Pilgrim's Bounty: Ironforge feast",
          note = { "Bountiful Tables, the quest givers, and a cooking fire.", { "Elizabeth Barker Winslow", "Tangy Wetland Cranberries" }, "Honey and Autumnal Herbs are sold here too." } },
        { map = 89, x = 62.1, y = 46.1, faction = "Alliance", title = "Pilgrim's Bounty: Darnassus feast",
          note = { "Bountiful Tables, the quest givers, and a cooking fire.", { "Ikaneba Summerset", "Teldrassil Sweet Potato" }, "Honey and Autumnal Herbs are sold here too." } },
        { map = 1, x = 46.4, y = 13.9, faction = "Horde", title = "Pilgrim's Bounty: Orgrimmar feast",
          note = { "Bountiful Tables, the quest givers, and a cooking fire.", { "Dalni Tallgrass", "Tangy Southfury Cranberries" }, "Honey and Autumnal Herbs are sold here too." } },
        { map = 18, x = 61.2, y = 66.9, faction = "Horde", title = "Pilgrim's Bounty: Undercity feast",
          note = { "Bountiful Tables, the quest givers, and a cooking fire.", { "Rose Standish", "Ripe Tirisfal Pumpkin" }, "Honey and Autumnal Herbs are sold here too." } },
        { map = 88, x = 30.8, y = 69.9, faction = "Horde", title = "Pilgrim's Bounty: Thunder Bluff feast",
          note = { "Bountiful Tables, the quest givers, and a cooking fire, at the foot of the elevators.", { "Laha Farplain", "Mulgore Sweet Potato" }, "Honey and Autumnal Herbs are sold here too." } },
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
                  .. "Veil Gourmet, part of Merrymaker, which counts toward What a Long, Strange Trip It's Been. "
                  .. "Short of 300? The Baked Salmon, Lobster Stew, and Mightfish Steak recipes (about 2 gold each) are sold by a cooking vendor in Feralas, "
                  .. "and the Mightfish Steak recipe also in The Cape of Stranglethorn. Try the auction house for the fish. If not, happy fishing! "
                  .. "Large Raw Mightfish is caught in open water in Swamp of Sorrows, and Raw Whitescale Salmon near Surwich in Blasted Lands.",
        },
        {
            teaser = "Secret: a bird king has a dress code...",
            reveal = "Defeat Talon King Ikiss in Sethekk Halls, Terokkar Forest (The Burning Crusade), while "
                  .. "wearing a Pilgrim's Hat and a Pilgrim's Dress, Robe, or Attire, for Terokkar Turkey Time.",
        },
    },
}
