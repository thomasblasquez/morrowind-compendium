---@class Compendium.Chapter
---@field id string The unique ID of the chapter. This is used to identify the chapter in the compendium.
---@field name string The name of the chapter. This is used to display the chapter in the compendium.
---@field description string? The description of the chapter. This is used to display the chapter in the compendium.
---@field chapters table<string, Compendium.Chapter>? A table of chapters belonging to this chapter. The key is the chapter id, and the value is the chapter itself.
---@field entries table? A table of entries belonging to this chapter. The key is the object ID, and the value is the entry itself.
---@field filter fun(object: tes3object)? A function that takes an object and returns true if it should be added to this chapter. This is used to create custom filters for chapters. The function should take a single argument, the object, and return a boolean value.
---@field new fun(self: Compendium.Chapter, newChapter: Compendium.Chapter.new.params): Compendium.Chapter|false Creates a new chapter under this chapter. Returns the new chapter if successful or false if it failed.
local chapter = {}

---@class Compendium.Chapter.new.params A new chapter to create. This must contain an ID and a name:
---@field id string The ID of the new chapter. This must be unique.
---@field name string The name of the new chapter. This will be displayed in the compendium.
---@field description string? The description of the new chapter. This will be displayed in the compendium.
---@field filter fun(object: tes3object)? A function that takes an object and returns true if it should be added to this chapter. This is used to create custom filters for chapters. The function should take a single argument, the object, and return a boolean value.

local common = require("Compendium.common")
local config = common.config
local log = common.log
local i18n = common.i18n
chapter.name = ""
chapter.description = ""
chapter.chapters = {}
chapter.entries = {}

---Create a new chapter under this chapter.
---@param params Compendium.Chapter.new.params The new chapter to create. This must contain an ID and a name:
---@return Compendium.Chapter | false chapter The new chapter if successful, or false if it failed.
function chapter:new(params)
    if not params or not params.id or not params.name then
        log:warn("Chapter ID and name are required")
        return false
    end
    local newChapter = {
        id = params.id,
        name = params.name,
        description = params.description,
    }
    newChapter.filter = params.filter or nil
    newChapter.chapters = {}
    newChapter.entries = {}
    setmetatable(newChapter, chapter)
    self.__index = self
    self.chapters[newChapter.id] = newChapter
    return self[newChapter.id]
end

return chapter