local Compendium = require("Compendium.interop")

-- Create a new compendium entry, or get/edit an existing one. Returns an Entry object or false
local exampleEntry = Compendium.entry{
    object = tes3object, -- Required. The base object this entry is for. The object must exist.
    description = string, -- If nil when the entry is created, it will be taken from Tooltips Complete if it's installed
    image = string, -- optional file path to a dds file for the image to be displayed in this entry. Uses base icon if drawing isnt possible
    chapter = CompendiumChapter, -- optional Compendium chapter override
    duplicateOf = tes3object, -- Optional. Merges this object with an existing entry and adds a "Variants" section in that entry
    variants = {} -- Optional. A table of objects that are variants of this object. This will be added to the "Variants" section of the entry
}

-- Chapters

-- Create a new chapter with a custom filter function. This will override an object's default dynamically assigned chapter if the function returns true. Returns false if the chapter failed to create
Compendium.chapters:new{
  name = string,
  filter = function(object) return false end
}

-- Create new parent chapter. Only parent chapters can contain other chapters
Compendium.chapters:newParent("New Chapter")

-- Entries

-- Add an entry to the Compendium via object id or Entry object. No options are passed
local fargoth = tes3.getObject("fargoth")
Compendium.add(fargoth)
-- or
exampleEntry:add()

-- Add a description to an entry
Compendium.entry{ object = fargoth, description = "Fear him, for he has achieved CHIM. The most powerful being in existence. Owner of a powerful healing artifact." }
-- or
exampleEntry.description = "Fear him, for he has achieved CHIM. The most powerful being in existence. Owner of a powerful healing artifact."

-- Add art file to compendium. Only the image is passed, so everything else will be determined dynamically
Compendium.entry{ object = fargoth, image = "Textures\\jop\\p\\2bf8c8bdf9834.dds" }
-- or
exampleEntry.image = "Textures\\jop\\p\\2bf8c8bdf9834.dds"

-- Override the dynamically assigned Compendium chapter, automatically creating new ones if needed. Parent chapters must already exist
Compendium.entry{ object = fargoth, chapter = Compendium.chapters.Beastiary["Godlike"] }
-- or
exampleEntry.chapter = Compendium.chapters.Beastiary["Sixth House"]

-- Add an object's entry as a variant of another base object
Compendium.entry{ object = fargoth, duplicateOf = tes3.getObject("Dagoth Ur") }
exampleEntry.duplicateOf = tes3.getObject("mudcrab")