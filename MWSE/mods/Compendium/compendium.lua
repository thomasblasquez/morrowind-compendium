---@class Compendium The Compendium data structure
---@field chapters table<string,Compendium.Chapter> Access to the root chapter of the compendium.
---@field entries Compendium.Entries A table of all entries in the compendium.
---@field current table The currently loaded Compendium chapters and entries as seen by the player.
---@field filters table<Compendium.Chapter, fun(object: tes3baseObject)> A table of filters for the chapters. The key is the chapter ID, and the value is the filter function.
local Compendium = {}

local common = require("Compendium.common")
local config = require("Compendium.config")
Compendium.chapter = require("Compendium.chapter")
Compendium.entries = require("Compendium.entries")

local tooltipData = include("Tooltips Complete.data")
local ncn = include("NotClairvoyantNerevarine.main")

local log = common.log
local i18n = common.i18n

Compendium.filters = {}
Compendium.unlockedEntries = {}

local tooltipMapping = {
    { descriptionTable = function() return tooltipData.keyTable end },
    { descriptionTable = function() return tooltipData.questTable end },
    { descriptionTable = function() return tooltipData.uniqueTable end },
    { descriptionTable = function() return tooltipData.artifactTable end },
    { descriptionTable = function() return tooltipData.armorTable end },
    { descriptionTable = function() return tooltipData.weaponTable end },
    { descriptionTable = function() return tooltipData.toolTable end },
    { descriptionTable = function() return tooltipData.miscTable end },
    { descriptionTable = function() return tooltipData.bookTable end },
    { descriptionTable = function() return tooltipData.clothingTable end },
    { descriptionTable = function() return tooltipData.soulgemTable end },
    { descriptionTable = function() return tooltipData.lightTable end },
    { descriptionTable = function() return tooltipData.potionTable end },
    { descriptionTable = function() return tooltipData.ingredientTable end },
    { descriptionTable = function() return tooltipData.scrollTable end },
}

local chapterFilters = {
    [tes3.objectType.creature] = function (object)
        local creature = object ---@type tes3creature
        if creature.type == tes3.creatureType.undead then
            return Compendium.Chapter.chapters["Bestiary"].chapters["Undead"]
        elseif creature.type == tes3.creatureType.daedra then
            return Compendium.Chapter.chapters["Bestiary"].chapters["Daedra"]
        elseif creature.type == tes3.creatureType.humanoid then
            return Compendium.Chapter.chapters["Bestiary"].chapters["AshCreatures"]
        else
            return Compendium.Chapter.chapters["Bestiary"].chapters["Wildlife"]
        end
    end,
    [tes3.objectType.book] = function (object)
        local book = object ---@type tes3book
        if book.enchantment then
            return Compendium.Chapter.chapters["Magic"].chapters["Scrolls"]
        else
            return Compendium.Chapter.chapters["Items"].chapters["Books"]
        end
    end,
    [tes3.objectType.alchemy] = function(object)
        ---@cast object tes3alchemy
        if not object.autoCalc then
            return Compendium.Chapter.chapters["Magic"].chapters["Potions"]
        end
    end,
    [tes3.objectType.npc] = function(object) return Compendium.Chapter.chapters["People"].chapters["Characters"] end,
    [tes3.objectType.class] = function(object) return Compendium.Chapter.chapters["People"].chapters["Classes"] end,
    [tes3.objectType.faction] = function(object) return Compendium.Chapter.chapters["People"].chapters["Factions"] end,
    [tes3.objectType.race] = function(object) return Compendium.Chapter.chapters["People"].chapters["Races"] end,
    [tes3.objectType.magicEffect] = function(object) return Compendium.Chapter.chapters["Magic"].chapters["Effects"] end,
    [tes3.objectType.ingredient] = function(object) return Compendium.Chapter.chapters["Magic"].chapters["Herbarium"] end,
    [tes3.objectType.weapon] = function(object) return Compendium.Chapter.chapters["Items"].chapters["Weapons"] end,
    [tes3.objectType.ammunition] = function(object) return Compendium.Chapter.chapters["Items"].chapters["Weapons"] end,
    [tes3.objectType.armor] = function(object) return Compendium.Chapter.chapters["Items"].chapters["Armor"] end,
    [tes3.objectType.clothing] = function(object) return Compendium.Chapter.chapters["Items"].chapters["Clothing"] end,
    [tes3.objectType.lockpick] = function(object) return Compendium.Chapter.chapters["Items"].chapters["Tools"] end,
    [tes3.objectType.probe] = function(object) return Compendium.Chapter.chapters["Items"].chapters["Tools"] end,
    [tes3.objectType.apparatus] = function(object) return Compendium.Chapter.chapters["Items"].chapters["Tools"] end,
    [tes3.objectType.repairItem] = function(object) return Compendium.Chapter.chapters["Items"].chapters["Tools"] end,
    [tes3.objectType.miscItem] = function(object) return Compendium.Chapter.chapters["Items"].chapters["Misc"] end,
}

local ncnFilters = {
    [tes3.objectType.npc] = function(object) return "Some "..object.race.name end,
    [tes3.objectType.book] = function (object) if object.enchantment then return "Some scroll" else return "Some book"end end,
}

function Compendium.load()
    tes3.player.data.Compendium = tes3.player.data.Compendium or {}
    Compendium.unlockedEntries = tes3.player.data.Compendium
    for _, chapter in pairs(Compendium.chapters.chapters) do
        if chapter.filter then
            Compendium.filters[chapter.id] = chapter.filter
        end
    end
    for _, entry in ipairs(Compendium.unlockedEntries) do
        if entry then
            Compendium.entries[entry.object.id] = entry
        end
    end
end

function Compendium.unlock(entry)
    if not entry then
        log:warn("Entry is nil, cannot unlock.")
        return
    end
    if not Compendium.entries[entry.object.id] then
        log:warn("Entry does not exist in Compendium, register with Compendium.entries:new(entry, chapter), cannot unlock.")
        return
    end
    entry.unlocked = true
    Compendium.unlockedEntries[entry.object.id] = entry
end

---Create and add dynamic information to the object's entry.
---@param object tes3baseObject The object to add the entry for.
---@return Compendium.Entry|nil entry The entry for the object, or nil if it failed to create.
function Compendium.unlockDynamicEntry(object)
    local entry = Compendium.entries.get(object)
    if entry then
        log:info("Entry already exists, skipping dynamic creation: " .. object.id)
        return entry
    end
    if not config.validObjectTypes[object.objectType] then
        log:warn("Invalid object type for dynamic entry: " .. object.id)
        return
    end

    local dynamicChapter
    local dynamicDescription
    local dynamicName

    for chapter, filter in pairs(Compendium.filters) do
        if filter(object) then
            dynamicChapter = chapter
        end
    end
    if not dynamicChapter then
        dynamicChapter = chapterFilters[object.objectType](object) ---@type Compendium.Chapter
        if not dynamicChapter then
            log:warn("No chapter found for object: " .. object.id)
            return
        end
    end
    if tooltipData then
        for _, data in ipairs(tooltipMapping) do
            dynamicDescription = data.descriptionTable[object.id:lower()]
        end
    end
    if ncn then
        dynamicName = ncnFilters[object.objectType](object)
    end

    entry = Compendium.entries:new(object, dynamicChapter)
    entry.description = dynamicDescription
    entry.name = dynamicName or object.name or object.id
    Compendium.unlock(entry)
    return entry
end

return Compendium