-- Holiday Herald: Darkmoon Faire data (monthly, first Sunday through the following Saturday)
-- All IDs are item IDs unless noted.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.DarkmoonFaire = {
    name  = "Darkmoon Faire",
    match = "darkmoon",
    icon  = "Interface\\Icons\\INV_Misc_Ticket_Darkmoon_01",
    achievementCategory = "Darkmoon Faire",   -- achievement window category name

    colors = {
        main   = "B48CE0",              -- carnival purple
        accent = "5FC7BE",              -- teal
        card   = "1E1A24",
        border = "B48CE0",
        titleStripes = { "B48CE0", "5FC7BE" },              -- circus-tent stripes
    },

    achievements = {
        { achievement = 6019,  name = "Come One, Come All!" },
        { achievement = 6020,  name = "Step Right Up" },
        { achievement = 9885,  name = "Ace Tonk Commander" },
        { achievement = 6021,  name = "Blastenheimer Bullseye" },
        { achievement = 6022,  name = "Quick Shot" },
        { achievement = 9983,  name = "That's Whack!" },
        { achievement = 9894,  name = "Triumphant Turtle Tossing" },
        { achievement = 9252,  name = "Brood of Alysrazor" },
        { achievement = 15221, name = "Dancing Machine" },
        { achievement = 9764,  name = "Rocketeer: Gold" },
        { achievement = 9785,  name = "Powermonger: Gold" },
        { achievement = 9792,  name = "Wanderluster: Gold" },
        { achievement = 9761,  name = "Darkmoon Racer Roadhog" },
        { achievement = 9805,  name = "Big Rocketeer: Gold" },
        { achievement = 9811,  name = "Big Wanderluster: Gold" },
        { achievement = 9819,  name = "Darkmoon Like the Wind" },
        { achievement = 11918, name = "Hey, You're a Rockstar!" },
        { achievement = 11921, name = "Mosh Pit" },
        { achievement = 11919, name = "Taking this Show on the Road" },
        { achievement = 11920, name = "Perfect Performance" },
        { achievement = 6023,  name = "Darkmoon Duelist" },
        { achievement = 6024,  name = "Darkmoon Dominator" },
        { achievement = 6027,  name = "Darkmoon Dungeoneer" },
        { achievement = 6028,  name = "Darkmoon Defender" },
        { achievement = 6029,  name = "Darkmoon Despoiler" },
        { achievement = 6032,  name = "Faire Favors" },
        { achievement = 6026,  name = "Fairegoer's Feast" },
        { achievement = 6025,  name = "I Was Promised a Pony" },
        { achievement = 6332,  name = "That Rabbit's Dynamite!" },
        { achievement = 6030,  name = "Taking the Show on the Road", faction = "Alliance" },
        { achievement = 6031,  name = "Taking the Show on the Road", faction = "Horde" },
    },

    mounts = {
        { item = 73766,  name = "Darkmoon Dancing Bear", cost = "180 tickets" },
        { item = 72140,  name = "Swift Forest Strider",  cost = "180 tickets" },
        { item = 153485, name = "Darkmoon Dirigible",    cost = "1,000 tickets" },
        { item = 142398, name = "Darkwater Skate",       cost = "500 Daggermaw" },
    },

    toys = {
        { item = 97994,  name = "Darkmoon Seesaw",              cost = "50 tickets" },
        { item = 90899,  name = "Darkmoon Whistle",             cost = "90 tickets" },
        { item = 116139, name = "Haunting Memento",             cost = "90 tickets" },
        { item = 138202, name = "Sparklepony XL",               cost = "150 tickets" },
        { item = 75042,  name = "Flimsy Yellow Balloon",        cost = "10 silver" },
        { item = 126931, name = "Seafarer's Slidewhistle",      cost = "Daggermaw" },
        { item = 187689, name = "Dance Dance Darkmoon",         cost = "Dancing Machine" },
        { item = 122123, name = "Darkmoon Ring-Flinger",        cost = "Triumphant Turtle Tossing" },
        { item = 122122, name = "Darkmoon Tonk Controller",     cost = "Ace Tonk Commander" },
        { item = 116115, name = "Blazing Wings",                cost = "Brood of Alysrazor" },
        { item = 122119, name = "Everlasting Darkmoon Firework", cost = "Rocketeer: Gold" },
        { item = 122120, name = "Gaze of the Darkmoon",         cost = "Powermonger: Gold" },
        { item = 122126, name = "Attraction Sign",              cost = "Wanderluster: Gold" },
        { item = 122129, name = "Fire-Eater's Vial",            cost = "Darkmoon Racer Roadhog" },
        { item = 122121, name = "Darkmoon Gazer",               cost = "Big Wanderluster: Gold" },
        { item = 151265, name = "Blight Boar Microphone",       cost = "Blight Boar concert" },
        { item = 101571, name = "Moonfang Shroud",              cost = "Moonfang" },
        { item = 105898, name = "Moonfang's Paw",               cost = "Moonfang" },
        { item = 116067, name = "Ring of Broken Promises",      cost = "Broken Promises quest" },
    },

    pets = {
        { item = 164969, name = "Horse Balloon",       cost = "90 tickets" },
        { item = 164971, name = "Murloc Balloon",      cost = "90 tickets" },
        { item = 164970, name = "Wolf Balloon",        cost = "90 tickets" },
        { item = 73762,  name = "Darkmoon Balloon",    cost = "90 tickets" },
        { item = 74981,  name = "Darkmoon Cub",        cost = "90 tickets" },
        { item = 91003,  name = "Darkmoon Hatchling",  cost = "90 tickets" },
        { item = 73764,  name = "Darkmoon Monkey",     cost = "90 tickets" },
        { item = 73903,  name = "Darkmoon Tonk",       cost = "90 tickets" },
        { item = 73765,  name = "Darkmoon Turtle",     cost = "90 tickets" },
        { item = 73905,  name = "Darkmoon Zeppelin",   cost = "90 tickets" },
        { item = 11026,  name = "Tree Frog",           cost = "Flik" },
        { item = 11027,  name = "Wood Frog",           cost = "Flik (1 in stock)" },
        { item = 126925, name = "Blorp's Bubble",      cost = "50 Daggermaw" },
        { item = 126926, name = "Translucent Shell",   cost = "100 Daggermaw" },
        { item = 123862, name = "Hogs",                cost = "That's Whack!" },
        { item = 122125, name = "Racer MiniZep",       cost = "Big Rocketeer: Gold" },
        { item = 19450,  name = "Jubling",             cost = "Spawn of Jubjub quest" },
        { item = 101570, name = "Moon Moon",           cost = "Moonfang" },
        { item = 80008,  name = "Darkmoon Rabbit",     cost = "Darkmoon Rabbit" },
        { item = 91040,  name = "Darkmoon Eye",        cost = "Darkmoon Pet Supplies" },
        { item = 116064, name = "Syd the Squid",       cost = "Greater Darkmoon Pet Supplies" },
        { item = 73953,  name = "Sea Pony",            cost = "Fishing (rare)" },
    },

    transmog = {
        { item = 78341,  name = "Darkmoon Hammer" },
        { item = 78340,  name = "Cloak of the Darkmoon Faire" },
        { item = 116052, name = "Nobleman's Coat" },
        { item = 116133, name = "Nobleman's Pantaloons" },
        { item = 116134, name = "Noble's Fancy Boots" },
        { item = 116136, name = "Noblewoman's Skirt" },
        { item = 116137, name = "Noblewoman's Finery" },
        { item = 151254, name = "Chain-Linked Cage Helm" },
        { item = 151253, name = "Lightly-Padded Cage Helm" },
        { item = 151252, name = "Leather-Lined Cage Helm" },
        { item = 151251, name = "Steel-Reinforced Cage Helm" },
        { item = 151255, name = "Necromedes, the Death Resonator" },
        { item = 164972, name = "Severed Crimsonscale Head" },
        { item = 164973, name = "Severed Azurefin Head" },
    },

    -- Profession quests that need items from outside the Faire.
    -- Each player only sees the items for professions they have.
    shoppingFor = "Profession quests",
    shoppingByProfession = true,
    shopping = {
        { item = 30817, count = 5, name = "Simple Flour",    profession = "Cooking",     skillLine = 185,
          where = "cooking or trade goods vendor" },
        { item = 1645,  count = 5, name = "Moonberry Juice", profession = "Alchemy",     skillLine = 171,
          where = "innkeeper" },
        { item = 39354, count = 5, name = "Light Parchment", profession = "Inscription", skillLine = 773,
          where = "trade goods vendor" },
    },

    tip = {
        short = "Ride the carousel or roller coaster for a 10% XP and reputation buff!",
        hover = {
            "#XP and reputation",
            "Riding the Darkmoon Carousel or the Roller Coaster gives WHEE!: +10% XP and reputation for an hour. Great for leveling alts or grinding reputation.",
            "The Darkmoon Top Hat, sold at the Faire and sometimes found in prize boxes, gives the same kind of buff, and it stacks!",
            " ",
            "#Game achievement rewards",
            { "Ring Toss",            "Darkmoon Ring-Flinger" },
            { "Tonk Challenge",       "Darkmoon Tonk Controller" },
            { "Firebird's Challenge", "Blazing Wings" },
            { "Whack-a-Gnoll",        "Hogs (pet)" },
            { "Dance game",           "Dance Dance Darkmoon" },
            { "Races",                "Racer MiniZep (pet) and toys" },
            " ",
            "#Blight Boar concert",
            "Every hour on the half hour in the eastern woods (Cauldron of Rock). Protect the band from the Death Metal Knight for the Blight Boar Microphone, cage helms, and Necromedes.",
            " ",
            "#Profession quests",
            "One per profession, per faire. Each gives Prize Tickets and a few profession skill points.",
            " ",
            "#Getting there",
            "Talk to the Darkmoon Faire Mystic Mage near Goldshire in Elwynn Forest, or near Thunder Bluff in Mulgore.",
        },
    },

    secrets = {
        {
            teaser = "Secret: something fishy lurks in the island's waters...",
            reveal = "Fish around Darkmoon Island for two ominous hats: the Severed Crimsonscale Head and the Severed Azurefin Head.",
        },
        {
            teaser = "Secret: Silas has a stash...",
            reveal = "Buy a Faded Treasure Map from Galissa Sundew for 100 Darkmoon Daggermaw and follow the clues to Silas' Secret Stash, worth 100 Prize Tickets.",
        },
        {
            teaser = "Secret: the arena isn't just for show...",
            reveal = "Every 3 hours, starting at midnight, a chest appears in the Darkmoon Arena. Everyone outside your party is hostile there, so loot it first for a Pit Fighter trinket and some Darkmoon goodies.",
        },
    },
}
