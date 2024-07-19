local BreedEgg = require("PalPurebredRework/Models/BreedEgg");
local Helpers = require("PalPurebredRework/Utils/Helpers");
local Log = require("PalPurebredRework/Utils/Log");
local UserData = require("PalPurebredRework/Utils/UserData");


---@class BreedEggManager
local BreedEggManager = {};

---@param session GameSession
function BreedEggManager:New(session)
  ---@class BreedEggManager
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.session = session;

  ---@private
  ---@type BreedEggRegistry
  instance.eggs = {};

  ---@private
  instance.userData = UserData:New("breed_eggs");

  instance:LoadSaveData();

  return instance;
end

function BreedEggManager:__tostring() return "BreedEggManager" end

---@param id FGuid
function BreedEggManager:GetByInstanceId(id)
  if not Helpers:IsValidGuid(id) then
    Log:Error(self, "Failed to find by instance id", "invalid guid");
    return nil;
  end;

  local egg = self.eggs[Helpers:ToStringGuid(id)];

  if not egg then
    Log:Error(self, "Failed to find by instance id", "no instance found");
    return nil;
  end;

  if not egg:IsValid() then
    Log:Error(self, "Failed to find by instance id", "invalid instance");
    return nil;
  end;

  return egg;
end

---@param parents PalIndividualCP[]
---@param mapPalEgg UPalMapObjectPalEggModel
function BreedEggManager:ProcessNewBreedFarmEgg(parents, mapPalEgg) 
  if not parents or not #parents == 2 then
    Log:Error(self, "Failed to process new BreedEgg", "no parents found");
    return;
  end;

  local egg = BreedEgg:New(self.session):InitFromGameData(parents, mapPalEgg);
  if not egg:IsValid() then
    Log:Error(self, "Failed to process new BreedEgg", "invalid BreedEgg instance");
    return;
  end

  self.eggs[egg:GetId()] = egg;
  self:SaveData();
end

---@param egg BreedEgg
function BreedEggManager:Delete(egg)
  self.eggs[egg:GetId()] = nil;
  self:SaveData();
end

---@private
function BreedEggManager:LoadSaveData()
  local lines = self.userData:Load();
  for i = 1, #lines do
    local data = Helpers:SplitString(lines[i], ";");
    local egg = BreedEgg:New(self.session):InitFromUserData(data);

    if not egg:IsValid() then
      Log:Error(self, "Failed to process new BreedEgg", "invalid BreedEgg instance");
      return;
    end

    self.eggs[egg:GetId()] = egg;
  end
end

function BreedEggManager:SaveData()
  ---@type string[]
  local data = {};

  for _, egg in pairs(self.eggs) do 
    local eggData = egg:GetSaveString();
    if eggData then table.insert(data, eggData) end;
  end;

  self.userData:Save(data);
end


return BreedEggManager;
