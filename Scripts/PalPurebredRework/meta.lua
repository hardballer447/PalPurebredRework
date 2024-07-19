---@meta PalPurebredRework

---@alias BreedEggRegistry { [string]: BreedEgg | nil }
---@alias BreedFarmRegistry { [string]: BreedFarm | nil }
---@alias EggHatcherRegistry { [string]: EggHatcher | nil }
---@alias PalIndividualCPRegistry { [string]: PalIndividualCP | nil }

--- Table holding the pal IV (Talent in palworld)
---@class PalIVs
---@field hp number
---@field shot number
---@field melee number
---@field defense number
PalIVs = {}


---@generic T
---@class TArray<T>
TArray = {}

-- The number of current elements in the array
---@return number
function TArray:GetArrayNum() end

-- Clears the array
function TArray:Empty() end

-- Iterates the entire TArray and calls the callback function for each element in the array
---@param callback fun(index: number, element: RemoteUnrealParam)
function TArray:ForEach(callback) end

---@class FName
FName = {}

-- Get the string for this FName
---@return string
function FName:ToString() end
