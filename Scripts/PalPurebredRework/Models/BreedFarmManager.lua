local BreedFarm = require("PalPurebredRework/Models/BreedFarm");
local Helpers = require("PalPurebredRework/Utils/Helpers");
local Log = require("PalPurebredRework/Utils/Log");

---@class BreedFarmManager
local BreedFarmManager = {};

---@param session GameSession
function BreedFarmManager:New(session)
  ---@class BreedFarmManager
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.session = session;

  ---@private
  ---@type BreedFarmRegistry
  instance.farms = {};

  ---@private
  ---@type number
  instance.instanceSinceLastValidation = 0;

  ---@private
  ---@type number
  instance.maxInstanceBeforeValidation = 20;

  return instance;
end

function BreedFarmManager:__tostring() return "BreedFarmManager" end

---@private
function BreedFarmManager:ValidateInstances()
  -- No validation needed
  if self.instanceSinceLastValidation < self.maxInstanceBeforeValidation then return end;

  ---@type BreedFarmRegistry
  local refresh = {};
  local removed = 0;

  for id, farm in pairs(self.farms) do
    if farm:IsValid() then refresh[id] = farm else removed = removed + 1 end;
  end;

  self.instanceSinceLastValidation = 0;
  self.farms = refresh;

  Log:Info(self, "Validation completed", "removed instances "..removed);
end;

---@private
---@param mapPalEgg UPalMapObjectPalEggModel
---@return BreedFarm | nil
function BreedFarmManager:GetByMapPalEgg(mapPalEgg)
  for _, farm in pairs(self.farms) do
    if farm:isMapPalEggInsideFarm(mapPalEgg) then return farm end;
  end;
  return nil;
end

---@param breedFarm UPalMapObjectBreedFarmModel
function BreedFarmManager:ProcessNewBreedFarm(breedFarm)
  if not breedFarm:IsValid() then
    Log:Error(self, "Failed to process new BreedFarmModel", "object is not valid");
    return;
  end;

  if not Helpers:IsValidGuid(breedFarm.InstanceId) then
    Log:Error(self, "Failed to process new BreedFarmModel", "id is not valid");
    return;
  end;

  -- Validate existing instances before adding a new one
  self:ValidateInstances();

  local farm = BreedFarm:New(self.session, breedFarm);
  self.instanceSinceLastValidation = self.instanceSinceLastValidation + 1;
  self.farms[farm:GetId()] = farm;

  if self.session:IsDebugSession() then
    farm:SetInstantBreedingTime();
  end;
end

---@param mapPalEgg UPalMapObjectPalEggModel
function BreedFarmManager:ProcessNewMapPalEggModel(mapPalEgg)
  if not mapPalEgg:IsValid() then
    Log:Error(self, "Failed to process new MapPalEggModel", "object is not valid");
    return;
  end;

  if not Helpers:IsValidGuid(mapPalEgg.ModelInstanceId) then
    Log:Error(self, "Failed to process new MapPalEggModel", "id is not valid");
    return;
  end;

  local farm = self:GetByMapPalEgg(mapPalEgg);
  if farm then
    Log:Info(self, "New egg spawned inside a breed farm");
    self.session:GetPurebredLogic():ProcessNewBreedFarmEgg(farm, mapPalEgg);
  end;
end


return BreedFarmManager;
