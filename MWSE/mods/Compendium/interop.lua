---@class Compendium.Chapter A chapter in the compendium containing entries
---@type table<string, table<_,Compendium.Entry>>

---@class Compendium.Chapter.Parent A chapter that can contain other chapters
---@type table<string, table<string,Compendium.Chapter>>

---@class Compendium.Entry An entry in the compendium.
---@field object tes3object | tes3item The base object this entry is for. The object must exist.
---@field description string? If nil when the entry is created, it will be taken from Tooltips Complete if it's installed
---@field image string? optional file path to a dds file for the image to be displayed in this entry. Uses base icon if drawing isnt possible
---@field chapter Compendium.Chapter? optional Compendium chapter override
---@field duplicateOf tes3object? Optional. Merges this object with an existing entry and adds a "Variants" section in that entry
---@field variants table? Optional. A table of objects that are variants of this object. This will be added to the "Variants" section of the entry

---@class Compendium The Compendium data structure
---@field chapters table<string, Compendium.Chapter.Parent> A table of all chapters in the compendium.
---@field customFilters table<string, function> A table of custom filters for chapters.
---@field entries table<string, Compendium.Entry> A table of all entries in the compendium.
---@field add fun(object: tes3object): boolean Adds an object to the compendium.
---@field onLoaded fun(e: loadedEventData) Called when a new game is loaded. Loads the saved compendium data.
---@field entry fun(entry: Compendium.Entry): Compendium.Entry? | nil Creates or updates an entry in the compendium.

local config = require("Compendium.config")
local log = config.log
local tooltipData = include("Tooltips Completedata")
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

---@type Compendium
local Compendium = {
    chapters = {
        Bestiary = {
            ["Wildlife"] = {},
            ["Daedra"] = {},
            ["Undead"] = {},
            ["Ash Creatures"] = {},
        },
        People = { 
            ["Characters"] = {},
            ["Factions"] = {},
            ["Races"] = {},
            ["Classes"] = {}
        },
        Magic = {
            ["Scrolls"] = {},
            ["Herbarium"] = {},
            ["Potions"] = {},
            ["Effects"] = {}
        },
        Items = {
            ["Armor"] = {},
            ["Tools"] = {},
            ["Clothing"] = {},
            ["Books"] = {},
            ["Misc"] = {}
        },
    },
    customFilters = {},
    entries = {},
    add = function(object)
        if not object then return false end
        -- Add to loaded compendium here
    end,
    onLoaded = function(e)
        if e.newGame then return end
    end,
}

local function findChapter(object)
    local type = object.objectType ---@type tes3.objectType
    local lookup = {
        [tes3.objectType.creature] = function ()
            local creature = object ---@type tes3creature
            if creature.type == tes3.creatureType.undead then
                return Compendium.chapters.Bestiary["Undead"]
            elseif creature.type == tes3.creatureType.daedra then
                return Compendium.chapters.Bestiary["Daedra"]
            elseif creature.type == tes3.creatureType.humanoid then
                return Compendium.chapters.Bestiary["Ash Creatures"]
            else
                return Compendium.chapters.Bestiary["Wildlife"]
            end
        end,
        [tes3.objectType.book] = function ()
            local book = object ---@type tes3book
            if book.enchantment then
                return Compendium.chapters.Magic["Scrolls"]
            else
                return Compendium.chapters.Items["Books"]
            end
            
        end,
        [tes3.objectType.alchemy] = function()
            ---@cast object tes3alchemy
            if not object.autoCalc then return Compendium.chapters.Magic["Potions"] end
        end,
        [tes3.objectType.npc] = Compendium.chapters.People["Characters"],
        [tes3.objectType.armor] = function() return Compendium.chapters.Items["Armor"] end,
        [tes3.objectType.clothing] = function() return Compendium.chapters.Items["Clothing"] end,
        [tes3.objectType.lockpick] = function() return Compendium.chapters.Items["Tools"] end,
        [tes3.objectType.apparatus] = function() return Compendium.chapters.Items["Tools"] end,
        [tes3.objectType.miscItem] = function() return Compendium.chapters.Items["Misc"] end,
        [tes3.objectType.weapon] = function() return Compendium.chapters.Items["Weapons"] end,
        [tes3.objectType.ingredient] = function() return Compendium.chapters.Magic["Herbarium"] end,
        [tes3.objectType.repairItem] = function() return Compendium.chapters.Items["Tools"] end,
        [tes3.objectType.class] = function() return Compendium.chapters.People["Classes"] end,
        [tes3.objectType.ammunition] = function() return Compendium.chapters.Items["Weapons"] end,
        [tes3.objectType.faction] = function() return Compendium.chapters.People["Factions"] end,
        [tes3.objectType.magicEffect] = function() return Compendium.chapters.Magic["Effects"] end,
        [tes3.objectType.race] = function() return Compendium.chapters.People["Races"] end
    }
    local chapter = lookup[type]() ---@type Compendium.Chapter
    if not chapter then
        log:warn("No chapter found for object: " .. object.id)
        return false
    end
end

local function findDescription(object)
    if not tooltipData then return end
    for _, data in ipairs(tooltipMapping) do
        local description = data.descriptionTable[object.id:lower()]
        if description then
            return description
        end
    end
end

local function customFilters(object)
    for chapter, filter in pairs(Compendium.customFilters) do
        if filter(object) then
            Compendium.entry{
                object = object,
                chapter = chapter
            }
            return
        end
    end
end

function Compendium.chapters.new(chapter)
    if not chapter then log:warn("No chapter passed to interop!") return false end
    if (string.lower(chapter.name) == "new") or (string.lower(chapter.name) == "newparent") then log:warn("Chapter name cannot be 'new' or 'newparent!") return false end
    if Compendium.chapters[chapter.name] then return true end
    Compendium.chapters[chapter.name] = {}
    if chapter.filter then
        Compendium.customFilters[chapter.name] = chapter.filter
    end
end

function Compendium.chapters.newParent(chapter)
    if not chapter then log:warn("No chapter passed to interop!") return false end
    if (string.lower(chapter.name) == "new") or (string.lower(chapter.name) == "newparent") then log:warn("Chapter name cannot be 'new' or 'newparent!") return false end
    if Compendium.chapters[chapter.name] then return true end
    Compendium.chapters[chapter.name] = {}
    if chapter.filter then
        Compendium.customFilters[chapter.name] = chapter.filter
    end
end

function Compendium.entry(entry)
    if not entry then log:warn("No entry passed to interop!") return nil end

    local existingEntry = Compendium.entries[entry.object.id]
    local moved = false
    local newEntry = {
        object = entry.object,
        description = entry.description or existingEntry.description or findDescription(entry.object) or "Should be self explanatory, right?",
        image = entry.image or existingEntry.image or entry.object.icon or nil,
        chapter = entry.chapter or existingEntry.chapter or findChapter(entry.object),
        duplicateOf = entry.duplicateOf or existingEntry.duplicateOf,
    }

    if entry.variants and existingEntry and existingEntry.variants then
        for _, variant in ipairs(entry.variants) do
            if not table.contains(existingEntry.variants, variant) then
                table.insert(existingEntry.variants, variant)
            end
        end
    elseif entry.variants then
        newEntry.variants = entry.variants
    end

    if newEntry.duplicateOf then
        local baseEntry = Compendium.entry(Compendium.entries[newEntry.duplicateOf])
        if baseEntry then
            table.insert(baseEntry.variants, newEntry.object)
            return baseEntry
        end
    end

    if
        (existingEntry and entry.chapter and entry.chapter ~= existingEntry.chapter)
        or
        (existingEntry and entry.duplicateOf and entry.duplicateOf ~= existingEntry.duplicateOf)
    then
        table.removevalue(Compendium.chapters[existingEntry.chapter], entry.object.id)
        moved = true
    end

    if moved or not existingEntry then
        table.insert(Compendium.chapters[newEntry.chapter], { newEntry.object.id, newEntry })
        table.insert(Compendium.entries,newEntry.object.id, newEntry)
    else
        Compendium.entries[newEntry.object.id] = newEntry
        table.insert(newEntry.chapter, { newEntry.object.id, newEntry })
    end

    return newEntry
end

return Compendium