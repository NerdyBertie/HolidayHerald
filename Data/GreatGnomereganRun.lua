-- Holiday Herald: The Great Gnomeregan Run (micro-holiday, October)
-- Micro-holidays never pop up or alert: one chat line on the day, plus a card in the popup.

local _, HH = ...
HH.Holidays = HH.Holidays or {}

HH.Holidays.GreatGnomereganRun = {
    name  = "The Great Gnomeregan Run",
    match = "gnomeregan run",
    micro = true,
    icon  = "Interface\\Icons\\Achievement_Character_Gnome_Male",

    colors = {
        main   = "E86FB0",              -- gnome pink
        accent = "4FC3C9",              -- tinker teal
        card   = "1A1824",
        border = "4FC3C9",
        titleGradient = { "E86FB0", "4FC3C9" },   -- gnome pink -> tinker teal
    },

    tip = {
        short = "Alliance only: race 34 gates from New Tinkertown to Booty Bay!",
        hover = {
            "#Start",
            "Accept The Great Gnomeregan Run from Mina Gleespanner in New Tinkertown, Dun Morogh (36.5, 36.5).",
            " ",
            "#The route",
            "Dun Morogh, Ironforge, the Deeprun Tram, Stormwind, Elwynn Forest, Duskwood, and Stranglethorn Vale. Course markers and cheering fans point the way, and every gate bursts into fireworks.",
            " ",
            "#Finish",
            "Turn in the quest to Prince Erazmin at the finish line in Booty Bay.",
            " ",
            "#Safety tip",
            "Stranglethorn is dangerous for low-level gnomes. Bring a bodyguard, or play chaperone on a higher-level character!",
        },
    },

    secrets = {
        {
            teaser = "Secret: this race started with the players...",
            reveal = {
                "This holiday started as a player-run charity event for breast cancer awareness.",
                " ",
                "Every October (breast cancer awareness month), players roll level 1 gnomes with pink hair and run this same route together, raising money for breast cancer charities. It grew so popular that Blizzard asked permission to turn it into an official holiday.",
                " ",
                "The community run still happens each year on the Scarlet Crusade (US) server. And look for a goggle-wearing Supporter along the route: its look is based on the charity run's mascot!",
            },
        },
    },
}
