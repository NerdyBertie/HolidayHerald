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
        { achievement = 40994, name = "An Original" },
        { achievement = 40995, name = "The Originals" },
        { achievement = 40996, name = "A Gatecrasher" },
        { achievement = 40997, name = "The Gatecrashers" },
        { achievement = 40999, name = "You're in Your Blackrock Depths" },
        { achievement = 41015, name = "A Dark Iron Past" },
        { achievement = 40977, name = "Codex Editor: Ahn'Qiraj" },
        { achievement = 13930, name = "Alterac Valley of Olde" },
    },

    mounts = {
        { item = 186469, name = "Illidari Doomhawk", cost = "Doomwalker (guaranteed)" },
        { item = 43959,  name = "Reins of the Grand Black War Mammoth", cost = "Archavon (rare)" },
        { item = 87771,  name = "Reins of the Heavenly Onyx Cloud Serpent", cost = "Sha of Anger (rare)" },
        { item = 208572, name = "Azure Worldchiller", cost = "Historian Ma'di" },
        { item = 172022, name = "Stormpike Battle Ram", cost = "Korrak's Revenge", faction = "Alliance" },
        { item = 172023, name = "Frostwolf Snarler", cost = "Korrak's Revenge", faction = "Horde" },
    },

    transmog = {
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
            "The festival grounds are outside the Caverns of Time in Tanaris. Pick up the starting quest from any festival celebrant in a major city, or just fly there.",
            " ",
            "#Currency",
            "Timewarped Badges buy most rewards: from quests, trivia, Korrak's Revenge, Chromie's Codex, and world bosses. Some Alterac Valley gear also costs Marks of Honor.",
            " ",
            "#Weekly",
            "Chromie's Codex: 200 Timewarped Badges for your first clear each week (once per Warband).",
            "One world boss weekly each week: The Originals (Azuregos, Lord Kazzak, and a Dragon of Nightmare) or Timely Gate Crashers (Doomwalker, Archavon, and the Sha of Anger).",
            " ",
            "#Every hour at the celebration",
            { "Story Time", ":00 and :30" },
            { "Fashion Frenzy", ":15" },
            { "Mount Mania", ":45" },
        },
    },

    moreTips = {
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
              "Each boss has a daily loot lockout. Doomwalker always drops the Illidari Doomhawk.",
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
        { teaser = "Secret: pull up a chair...",
          reveal = "Lorewalker Cho is the Storyteller. Catch Story Time on the hour and half hour." },
    },
}
