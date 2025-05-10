local common = require("Compendium.common")
local i18n = common.i18n
local log = common.log
local config = {}
config.defaultChapters = {
    Bestiary = {
        id = "beastiary",
        name = i18n("names.Beastiary"),
        description = i18n("description.Beastiary"),
        chapters = {
            {
                id = "beastiaryWildlife",
                name = i18n("names.Wildlife"),
                description = i18n("description.Wildlife")
            },
            {
                id = "beastiaryDaedra",
                name = i18n("names.Daedra"),
                description = i18n("description.Daedra")
            },
            {
                id = "beastiaryUndead",
                name = i18n("names.Undead"),
                description = i18n("description.Undead")
            },
            {
                id = "beastiaryAshCreatures",
                name = i18n("names.AshCreatures"),
                description = i18n("description.AshCreatures")
            }
        }
    },
    People = {
        id = "people",
        name = i18n("names.People"),
        description = i18n("description.People"),
        chapters = {
            {
                id = "peopleCharacters",
                name = i18n("names.Characters"),
                description = i18n("description.Characters")
            },
            {
                id = "peopleFactions",
                name = i18n("names.Factions"),
                description = i18n("description.Factions")
            },
            {
                id = "peopleRaces",
                name = i18n("names.Races"),
                description = i18n("description.Races")
            },
            {
                id = "peopleClasses",
                name = i18n("names.Classes"),
                description = i18n("description.Classes")
            }
        }
    },
    Magic = {
        id = "magic",
        name = i18n("names.Magic"),
        description = i18n("description.Magic"),
        chapters = {
            {
                id = "magicScrolls",
                name = i18n("names.Scrolls"),
                description = i18n("description.Scrolls")
            },
            {
                id = "magicHerbarium",
                name = i18n("names.Herbarium"),
                description = i18n("description.Herbarium")
            },
            {
                id = "magicPotions",
                name = i18n("names.Potions"),
                description = i18n("description.Potions")
            },
            {
                id = "magicEffects",
                name = i18n("names.Effects"),
                description = i18n("description.Effects")
            }
        }
    },
    Items = {
        id = "items",
        name = i18n("names.Items"),
        description = i18n("description.Items"),
        chapters = {
            {
                id = "itemsWeapons",
                name = i18n("names.Weapons"),
                description = i18n("description.Weapons")
            },
            {
                id = "itemsArmor",
                name = i18n("names.Armor"),
                description = i18n("description.Armor")
            },
            {
                id = "itemsTools",
                name = i18n("names.Tools"),
                description = i18n("description.Tools")
            },
            {
                id = "itemsClothing",
                name = i18n("names.Clothing"),
                description = i18n("description.Clothing")
            },
            {
                id = "itemsMisc",
                name = i18n("names.Misc"),
                description = i18n("description.Misc")
            }
        }
    },
    Books = {
        id = "books",
        name = i18n("names.Books"),
        description = i18n("description.Books"),
        chapters = {}
    }
}
config.validObjectTypes = {
    [tes3.objectType.creature] = true,
    [tes3.objectType.npc] = true,
    [tes3.objectType.class] = true,
    [tes3.objectType.faction] = true,
    [tes3.objectType.alchemy] = true,
    [tes3.objectType.ingredient] = true,
    [tes3.objectType.book] = true,
    [tes3.objectType.weapon] = true,
    [tes3.objectType.ammunition] = true,
    [tes3.objectType.armor] = true,
    [tes3.objectType.clothing] = true,
    [tes3.objectType.lockpick] = true,
    [tes3.objectType.probe] = true,
    [tes3.objectType.apparatus] = true,
    [tes3.objectType.repairItem] = true,
    [tes3.objectType.miscItem] = true,
    [tes3.objectType.magicEffect] = true,
    [tes3.objectType.race] = true
}


return config