---@class Compendium.Entry An entry in the compendium.
---@field duplicateOf fun(self: Compendium.Entry, object: tes3object): Compendium.Entry | nil Optional. Merges this object with an existing entry and adds a "Variants" section in that entry. Returns the new entry if successful or nil if it failed.
---@field object tes3baseObject The base object this entry is for. The object must exist.
---@field description string? If nil when the entry is created, it will be taken from Tooltips Complete if it's installed
---@field image string? optional file path to a dds file for the image to be displayed in this entry. Uses base icon if drawing isnt possible
---@field chapter Compendium.Chapter Chapter to add this entry to. This must be a valid chapter in the compendium.
---@field unlocked boolean? Optional. If true, this entry will be unlocked and displayed in the compendium. If false, it will be locked. Defaults to false.
---@field variants table? Optional. A table of objects that are variants of this object. This will be added to the "Variants" section of the entry
---@field name string? The name of the object to be displayed in the entry. This will display instead of the default name of the object.
---@field killCount number? The number of times the object has been killed.
---@field partial boolean? Optional. If true, this entry will be marked as partially unlocked. This is used for entries that are not fully unlocked yet and should have some of their information hidden. Defaults to false.
---@field class tes3class? Optional. The class of the object. This will be displayed in the entry. Nil unless the player asks about the object's class in dialog
---@field faction tes3faction? Optional. The faction of the object. This will be displayed in the entry. Nil unless the player asks about the object's faction in dialog
---@field services table? Optional. A table of services that the object provides. This will be displayed in the entry. Nil unless the player activates the object in dialog
local entry = {}

---@class Compendium.Entries A table of all entries in the compendium. The key is the object ID, and the value is the entry itself.
---@field new fun(self: Compendium.Entries, object: tes3baseObject, chapter: Compendium.Chapter): Compendium.Entry|false Creates a new entry in the compendium. Returns the new entry if successful or false if it failed.
---@field get fun(object: tes3baseObject): Compendium.Entry|nil Gets an entry from the compendium. Returns the entry if it exists or nil if it doesn't.
local entries = {
    all = {},
}

local common = require("Compendium.common")
local config = require("Compendium.config")
local log = common.log
local i18n = common.i18n

---Get a given object's entry from the compendium.
---@param object tes3baseObject
---@return Compendium.Entry|nil entry The entry if it exists, or nil if it doesn't.
function entries.get(object)
    return entries.all[object.id]
end

function entry:duplicateOf(object)
    if self.chapter then
        table.removevalue(self.chapter.entries, self)
    end
    local baseEntry = entries.get(object)
    if not baseEntry then
        log:warn("Base entry does not exist: " .. object.id)
        return nil
    end
    self.chapter = baseEntry.variants
    table.insert(baseEntry.variants, self.object)
end

---@param object tes3baseObject
---@param chapter Compendium.Chapter
---@return Compendium.Entry|false
function entries:new(object, chapter)
    if not object or not chapter then
        log:warn("Object and chapter are required")
        return false
    end
    if not tes3.getObject(object.id) then
        log:warn("Object does not exist: " .. object.id)
        return false
    end
    if entries.all[object.id] then
        log:warn("Entry already exists: " .. object.id)
        return false
    end

    local newEntry = {
        object = object,
        chapter = chapter,
        description = "",
        image = "",
        variants = {},
        services = {},
        duplicateOf = entry.duplicateOf
    }
    
    self.all[object.id] = newEntry
    chapter.entries[object.id] = newEntry
    return newEntry
end