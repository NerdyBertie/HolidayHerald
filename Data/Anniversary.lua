-- Holiday Herald: WoW's Anniversary (late November)
-- Built from the 2025 event (Wowhead's anniversary guide). Update once this year's
-- version is announced: rewards and bosses can change from year to year.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.Anniversary = {
    name  = "WoW's Anniversary",
    match = "anniversary",
    categoryMatch = "anniversary",      -- World Events subcategory name contains this
    icon  = "Interface\\Icons\\INV_Misc_PocketWatch_01",

    colors = {
        main   = "C9963F",              -- bronze
        accent = "7FC8D8",              -- bronze dragonflight teal
        card   = "1C1A16",
        border = "C9963F",
        titleGradient = { "3F8CFF", "E3C27A", "C41E3A" },   -- Alliance blue -> bronze -> Horde crimson
        sections = { toGet = "5FA0FF", howTo = "E3C27A", secrets = "E04A5E" },   -- Alliance blue, bronze, Horde crimson
    },

    achievements = {
        { achievement = 63714, name = "WoW's 22nd Anniversary" },
        { achievement = 40994, name = "An Original" },
        { achievement = 40995, name = "The Originals" },
        { achievement = 40996, name = "A Gatecrasher" },
        { achievement = 40997, name = "The Gatecrashers" },
        { achievement = 40999, name = "You're in Your Blackrock Depths" },
        { achievement = 41015, name = "A Dark Iron Past" },
        { achievement = 40977, name = "Codex Editor: Ahn'Qiraj" },
        { achievement = 13930, name = "Alterac Valley of Olde" },
        { achievement = 8397,  name = "Crazy for Cats" },
    },

    mounts = {
        { item = 186469, name = "Illidari Doomhawk", cost = "Doomwalker or Historian Ma'di (5,000 badges)" },
        { item = 208572, name = "Azure Worldchiller", cost = "Doomwalker (rare) or Historian Ma'di (5,000 badges)" },
        { item = 43959,  name = "Reins of the Grand Black War Mammoth", cost = "Archavon (rare)" },
        { item = 87771,  name = "Reins of the Heavenly Onyx Cloud Serpent", cost = "Sha of Anger (rare)" },
        { item = 172022, name = "Stormpike Battle Ram", cost = "Korrak's Revenge", faction = "Alliance" },
        { item = 172023, name = "Frostwolf Snarler", cost = "Korrak's Revenge", faction = "Horde" },
    },

    -- Historian Ma'di (prices from her vendor window)
    pets = {
        { item = 136925, name = "Corgi Pup",                   cost = "200 Timewarped Badges" },
        { item = 186556, name = "Timeless Mechanical Dragonling", cost = "200 Timewarped Badges" },
        { item = 228781, name = "Lil'Doomy's Hilt",            cost = "100 Timewarped Badges" },
        -- Breanni (down the stairs from the main tent): cats and the Polished Pet Charm pets
        { item = 8490,   name = "Cat Carrier (Siamese)",       cost = "Breanni (60 silver)" },
        { item = 46398,  name = "Cat Carrier (Calico Cat)",    cost = "Breanni (50 gold)" },
        { item = 129798, name = "Plump Jelly",                 cost = "Breanni (50 Polished Pet Charms)" },
        { item = 140274, name = "River Calf",                  cost = "Breanni (50 Polished Pet Charms)" },
        { item = 129878, name = "Nightwatch Swooper",          cost = "Breanni (100 Polished Pet Charms)" },
        { item = 118599, name = "Autumnal Sproutling",         cost = "Breanni (100 Polished Pet Charms)" },
        { item = 129760, name = "Fel Piglet",                  cost = "Breanni (200 Polished Pet Charms)" },
        { item = 136910, name = "Alarm-o-Bot",                 cost = "Breanni (200 Polished Pet Charms)" },
        -- Carl Goodup also sells these Darkmoon balloon pets (also on the Darkmoon card)
        { item = 164969, name = "Horse Balloon",               cost = "Carl Goodup (90 Darkmoon Prize Tickets), can't battle" },
        { item = 164971, name = "Murloc Balloon",              cost = "Carl Goodup (90 Darkmoon Prize Tickets), can't battle" },
        { item = 164970, name = "Wolf Balloon",                cost = "Carl Goodup (90 Darkmoon Prize Tickets), can't battle" },
    },

    toys = {
        { item = 128510, name = "Exquisite Costume Set: \"Edwin VanCleef\"", cost = "200 Timewarped Badges" },
        { item = 128507, name = "Inflatable Thunderfury, Blessed Blade of the Windseeker", cost = "50 Timewarped Badges" },
        { item = 140670, name = "Souvenir Elekk",              cost = "Kieule (100 Ancient Mana)" },
        { item = 140671, name = "Souvenir Raptor",             cost = "Kieule (100 Ancient Mana)" },
        { item = 130151, name = "The \"Devilsaur\" Lunchbox",  cost = "Kieule (1000 Ancient Mana)" },
        { item = 229828, name = "20th Anniversary Balloon Chest", cost = "Carl Goodup (100 Timewarped Badges)" },
        { item = 158149, name = "Overtuned Corgi Goggles",    cost = "200 Timewarped Badges" },
        { item = 228789, name = "Coldflame Ring",             cost = "100 Timewarped Badges" },
        { item = 147884, name = "Tranquil Mechanical Yeti Costume", cost = "50 Timewarped Badges" },
        { item = 147883, name = "Celebration Wand - Quilboar", cost = "25 Timewarped Badges" },
        { item = 147882, name = "Celebration Wand - Trogg",    cost = "25 Timewarped Badges" },
        { item = 128506, name = "Celebration Wand - Gnoll",    cost = "25 Timewarped Badges" },
        { item = 128505, name = "Celebration Wand - Murloc",   cost = "25 Timewarped Badges" },
    },

    transmog = {
        -- Coldflame set (Historian Ma'di)
        { item = 228784 },
        { item = 228785 },
        { item = 228786 },
        { item = 228788 },
        { item = 178514 },   -- Crafted Cloak of War
        { item = 147885 },   -- Bronze-Tinted Sunglasses
        -- Loyal Watchman set (Traeya)
        { item = 253160 },
        { item = 253159 },
        { item = 253158 },
        { item = 253154 },
        { item = 253155 },
        { item = 253157 },
        { item = 253156 },
        -- Eternal Tier 2 ensembles (Traeya), checked from their tooltip
        { item = 228205, kind = "ensemble", name = "Pale Rider's Eternal Armor" },
        { item = 228206, kind = "ensemble", name = "Netherwalker's Eternal Armor" },
        { item = 228207, kind = "ensemble", name = "Earth-Warder's Eternal Armor" },
        { item = 228199, kind = "ensemble", name = "Eternal Stormrage Armor" },
        { item = 228200, kind = "ensemble", name = "Dragonstalker's Eternal Armor" },
        { item = 228201, kind = "ensemble", name = "Eternal Netherwind Regalia" },
        { item = 228208, kind = "ensemble", name = "Eternal Battlegear of the August Acolyte" },
        { item = 228198, kind = "ensemble", name = "Eternal Judgment Armor" },
        { item = 228204, kind = "ensemble", name = "Eternal Vestments of Transcendence" },
        { item = 228202, kind = "ensemble", name = "Eternal Bloodfang Armor" },
        { item = 228203, kind = "ensemble", name = "Eternal Ten Storms" },
        { item = 228209, kind = "ensemble", name = "Eternal Nemesis Raiment" },
        { item = 228197, kind = "ensemble", name = "Eternal Battlegear of Wrath" },
    },

    -- Daily quests (2025 IDs from Wowhead; VERIFY in-game)
    dailies = {
        { quest = 84616, group = "Celebration grounds (Tanaris)", name = "Celebrate Good Fun!", giver = "Yllana",
          where = "An extra +10% XP and reputation for 12 hours of play time." },
        { quests = { 43323, 43461 }, group = "Celebration grounds (Tanaris)", name = "A Time to Reflect",
          giver = "Historian Llore or Ju'pa", where = "Anniversary trivia. Answer right for 5 Timewarped Badges." },
        { quest = 6781, group = "Korrak's Revenge", name = "More Armor Scraps",
          where = "Alterac Valley of Olde, from the PvP group finder." },
    },
    dailyNote = "World bosses have a daily loot lockout too. Hover the World bosses line under How to for where they are.",

    tip = {
        short = "Head to the celebration outside the Caverns of Time in Tanaris!",
        hover = {
            "#The celebration",
            "The festival grounds are outside the Caverns of Time in Tanaris. Pick up the starting quest from any Holiday Celebrant, and take the portal there from Stormwind or Orgrimmar.",
            " ",
            "#XP and reputation",
            "Everyone gets +10% XP and reputation during the event. Turn in Celebrate Good Fun! from Yllana each day for another +10%. It stacks with your other XP and reputation buffs.",
            " ",
            "#One run per Warband",
            "Quests and activities count Warband-wide, so you don't need to run the event on every character each week (unless you want to!).",
        },
    },

    -- HandyNotes map pins. Dragons of Nightmare spots from 2026 guides (check in game);
    -- the celebration grounds, Tanaris bosses, Azuregos, and Kazzak confirmed in game.
    pins = {
        { map = 17, x = 32.9, y = 48.8, title = "Lord Kazzak",
          note = "In the Tainted Forest, Blasted Lands. Part of The Originals." },
        { map = 76, x = 48.8, y = 84.3, title = "Azuregos",
          note = "In southern Azshara. Part of The Originals." },
        { map = 71, x = 62.7, y = 56.7, title = "Doomwalker",
          note = "South of the Caverns of Time. Can drop the Illidari Doomhawk. Part of Timely Gate Crashers." },
        { map = 71, x = 33.9, y = 55.5, title = "Sha of Anger",
          note = "South of the Noxious Lair. Part of Timely Gate Crashers." },
        { map = 71, x = 46.1, y = 28.5, title = "Archavon the Stone Watcher",
          note = "West of Gadgetzan. Part of Timely Gate Crashers." },
        { map = 71, x = 62.9, y = 50.6, title = "Anniversary celebration",
          note = { "Yllana is under the big main tent, right in the middle of the celebration.",
                   "Pick up Celebrate Good Fun! here each day. Story Time, Fashion Frenzy and Mount Mania all happen on these grounds." } },
        { map = 71, x = 62.4, y = 49.9, title = "Chromie, Breanni, and Kieule",
          note = { "Just off the main tent, down the stairs. All three stand close together.",
                   { "Chromie", "Chromie's Codex quest" },
                   { "Breanni", "Pets, for gold, silver, and Polished Pet Charms" },
                   { "Kieule", "Toys, for Ancient Mana" } } },
        { map = 26, x = 63.3, y = 26.7, title = "Dragon of Nightmare: Lethon",
          note = "At the Emerald Dream portal in Seradane. Only one of the four dragons is up each day." },
        { map = 47, x = 46.6, y = 37.4, title = "Dragon of Nightmare: Emeriss",
          note = "At the Emerald Dream portal in Twilight Grove. Only one of the four dragons is up each day." },
        { map = 63, x = 93.6, y = 38.4, title = "Dragon of Nightmare: Taerar",
          note = "At the Emerald Dream portal at Bough Shadow. Only one of the four dragons is up each day." },
        { map = 69, x = 51.5, y = 10.0, title = "Dragon of Nightmare: Ysondre",
          note = "At the Emerald Dream portal at Dream Bough. Only one of the four dragons is up each day." },
    },

    -- Hub activities at the celebration grounds (schedule from a 2026 guide; check in game)
    timedEvents = {
        { name = "Story Time", every = 30, startMinute = 0, length = 5,
          runs = "Lorewalker Cho tells a story twice an hour, at :00 and :30, for about 5 minutes. React to his stories for Peanut Gallery, and hear them all for Avid Listener.",
          where = "At the celebration grounds outside the Caverns of Time." },
        { name = "Fashion Frenzy", every = 60, startMinute = 15, length = 5,
          runs = "Every hour at :15, for about 5 minutes. Dress for the theme and vote on outfits: 1 vote for Fashion Critic, 20 for Big Fan.",
          where = "At the celebration grounds outside the Caverns of Time." },
        { name = "Mount Mania", every = 60, startMinute = 45, length = 8,
          runs = "Every hour at :45, for about 8 minutes. Match the mounts shown: 1 match for I Have That One!, 20 for Mount Master.",
          where = "At the celebration grounds outside the Caverns of Time." },
    },

    moreTips = {
        { short = "Quests: Meet and Greet, Chromie's Codex, Soldier of Time, and Timely Gate Crashers.",
          title = "Anniversary quests",
          hover = {
              "#Quests to pick up",
              "Meet and Greet: a one-time quest each event (once per character). Turning it in gives you Shopping Squee!",
              "Celebrate Good Fun! and A Time to Reflect (trivia) can be repeated.",
              "Chromie's Codex (from Chromie): the Codex of Chromie event, repeatable. The first clear each week (once per Warband) gives 200 Timewarped Badges, plus a Bronze Celebration Cache of Treasures.",
              "Soldier of Time (from Izaik Kadarov): earn 500 honor in Korrak's Revenge, repeatable. Rewards Marks of Honor, 100 Timewarped Badges, and caches.",
              "Timely Gate Crashers (from Izaik Kadarov): kill Doomwalker, Archavon, and the Sha of Anger, repeatable.",
              " ",
              "#Bronze Celebration Cache",
              "The first weekly cache holds a piece of Champion gear from Blackrock Depths and a Restored Coffer Key. Later caches hold a piece of Veteran gear.",
          } },
        { short = "Timewarped Badges buy most rewards. Hover for prices.",
          title = "Badges and vendors",
          hover = {
              "Timewarped Badges buy most rewards: from quests, trivia, Korrak's Revenge, Chromie's Codex, and world bosses.",
              " ",
              "#Where to spend them",
              "Loyal Watchman pieces cost 20 to 50 badges each (230 for the set), and the Tier 2 ensembles cost 400. Notary Grably sells 16 Bronze Celebration titles for 100 badges each.",
              " ",
              "#Alterac Valley gear",
              "Thanthaldis Snowgleam (Alliance) and Jorek Ironside (Horde) charge 1 to 2 Marks of Honor plus 20 to 90 badges. Some weapons need you to finish The Legend of Korrak in Classic Alterac Valley first.",
              " ",
              "#Korrak's Revenge",
              "Gives 20 badges for a win and 10 for a loss. Earning 200 badges there unlocks the Stormpike Battle Ram or Frostwolf Snarler.",
          } },
        { short = "Breanni and Kieule sell pets and toys, down the stairs from the main tent.",
          title = "Breanni and Kieule",
          hover = {
              "They stand close together, down the stairs from the main tent and near Chromie.",
              " ",
              "Breanni sells pets for gold, silver, and Polished Pet Charms. Kieule, next to her, sells toys for Ancient Mana.",
              " ",
              "#Where the currencies come from",
              "Neither comes from the event. Ancient Mana drops in Suramar (Legion) from creatures, mining, herbs, and ancient mana nodes. Polished Pet Charms come from pet battle quests, pet world quests, and pet battle dungeons.",
              " ",
              "Breanni's Cat Carriers (Siamese and Calico) count toward the Crazy for Cats achievement.",
          } },
        { short = "World bosses: Kazzak, Azuregos, a Dragon of Nightmare, and three in Tanaris.",
          title = "Anniversary world bosses",
          hover = {
              "#Always up",
              { "Lord Kazzak", "Blasted Lands, Tainted Forest" },
              { "Azuregos", "Southern Azshara" },
              { "Doomwalker", "Tanaris, south of the Caverns" },
              { "Archavon the Stone Watcher", "Tanaris, west of Gadgetzan" },
              { "Sha of Anger", "Tanaris, south of the Noxious Lair" },
              " ",
              "#Dragons of Nightmare (one at a time)",
              "Only one of the four is up each day, at its Emerald Dream portal:",
              { "Lethon", "The Hinterlands (63.3, 26.7)" },
              { "Emeriss", "Duskwood (46.6, 37.4)" },
              { "Taerar", "Ashenvale (93.6, 38.4)" },
              { "Ysondre", "Feralas (51.5, 10.0)" },
              " ",
              "Each boss has a daily loot lockout. Doomwalker can drop the Illidari Doomhawk and the Azure Worldchiller.",
          } },
        { short = "Blackrock Depths is back as a 25-player raid in Raid Finder.",
          title = "Blackrock Depths",
          hover = {
              "Queue through Raid Finder for 8 bosses and 5 mini-bosses, with classic rewards scaled up.",
              " ",
              "For A Dark Iron Past, find all of Moira Thaurissan's Temporal Missives along the way.",
          } },
    },

    secrets = {
        { teaser = "Secret: dress up as a hero...",
          reveal = "Cosplay items around the celebration grounds turn you into famous heroes like Khadgar and Illidan, complete with their own emotes and voice lines." },
        { teaser = "Secret: guests need help...",
          reveal = "Guest Relations runs a treasure hunt around the celebration. Keep an eye out for its clues!" },
        { teaser = "Secret: a familiar face is selling chicken...",
          reveal = "Leeroy Jenkins is at the celebration, selling chicken. At least he's got a plan this time." },
        { teaser = "Secret: Druids have a shortcut to the dragons...",
          reveal = "If you've opened your Druid Class Hall in Legion, you can cast Dreamwalk from anywhere to reach the Emerald Dreamway. Its portals lead to Duskwood, Feralas, and the Hinterlands, where Emeriss, Ysondre, and Lethon wait." },
    },
}
