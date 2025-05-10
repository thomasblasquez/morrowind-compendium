--#region Requirements

    local common = require("Compendium.common")
    local config = require("Compendium.config")
    local Compendium = require("Compendium.compendium")
    local log = common.log
    local i18n = common.i18n

--#endregion

--#region Variables

    local dialogFilters = {
        background = function ()
            
        end
    }

--#endregion

--#region Functions

    -- Creates the default chapters for the compendium when the mod is initialized.
    local function onInitialized()
        for parentChapterID, parentChapter in ipairs(config.defaultChapters) do
            Compendium.chapters:new(
            {
                id = parentChapter.id,
                name = parentChapter.name,
                description = parentChapter.description
            })
            for chapterID, chapter in ipairs(parentChapter.chapters) do
                Compendium.chapters[parentChapterID]:new(
                {
                    id = chapter.id,
                    name = chapter.name,
                    description = chapter.description
                })
            end
        end
    end

    -- Unlock entries for all items in the player's inventory and their race/class after character generation is finished.
    local function onChargenFinished()
        for _, itemStack in ipairs(tes3.mobilePlayer.inventory) do
            local item = itemStack.object
            if config.validObjectTypes[item.objectType] then
                local entry = unlockDynamicEntry(item)
            end
        end
        unlockDynamicEntry(tes3.player.object.race)
    end

    ---Unlock a new entry to the compendium whenever the player activates an object.
    ---@param e activateEventData
    local function onActivate(e)
        local object = e.target.baseObject
        local entry = Compendium.unlockDynamicEntry(object)
        if not entry then return end
        entry.partial = true
        for serviceName, service in pairs(tes3.merchantService) do
            if object:offersService(service) and not table.contains(entry.services, serviceName) then
                table.insert(entry.services, serviceName)
            end
        end
    end

    ---Unlock a new entry to the compendium whenever the player interacts with an object in dialogue.
    ---@param e dialogueFilteredEventData
    local function onDialogueFiltered(e)
        local object = e.reference.baseObject
        local entry = Compendium.unlockDynamicEntry(object)
        if not entry then return end
        if e.dialogue.id == "background" then
            entry.name = object.name
        end
    end

    ---Unlock a new entry to the compendium whenever an object dies.
    ---@param e damagedEventData
    local function onDamaged(e)
        local object = e.reference.baseObject
        if not object then return end
        if not e.attacker == tes3.mobilePlayer then return end
        if e.killingBlow then
            local entry = Compendium.unlockDynamicEntry(object)
            if not entry then return end
            entry.partial = false
        end
    end

--#endregion

--#region Events

event.register(tes3.event.activate, onActivate)
event.register(tes3.event.charGenFinished, onChargenFinished)
event.register(tes3.event.initialized, onInitialized)
event.register(tes3.event.dialogFiltered, onDialogueFiltered)
event.register(tes3.event.damaged, onDamaged)
event.register(tes3.event.loaded, Compendium.load)

--#endregion

return Compendium