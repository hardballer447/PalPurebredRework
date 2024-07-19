local Helpers = require("PalPurebredRework/Utils/Helpers");
local Log = require("PalPurebredRework/Utils/Log");

---@class BreedFarm
local BreedFarm = {};

---@param session GameSession
---@param model UPalMapObjectBreedFarmModel
function BreedFarm:New(session, model)
  ---@class BreedFarm
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.session = session;

  ---@private
  instance.model = model;

  ---@private
  instance.id = Helpers:ToStringGuid(model.InstanceId);

  return instance;
end

function BreedFarm:__tostring() return "BreedFarm "..self.id end

function BreedFarm:IsValid() return self.model:IsValid() end

function BreedFarm:GetId() return self.id end

function BreedFarm:GetParents()
  if not self:IsValid() then return nil end;

  if #self.model.LastProceedWorkerIndividualIds ~= 2 then
    Log:Error(self, "Failed to retrieve parents", "workers count was not 2");
    return nil;
  end;

  ---@type PalIndividualCP[]
  local parents = {};
  for i = 1, 2 do
    local palId = self.model.LastProceedWorkerIndividualIds[i].InstanceId;
    parents[i] = self.session:GetPalIndividualCPManager():GetByInstanceId(palId);
  end;

  if not parents[1] or not parents[2] then
    Log:Error(self, "Failed to retrieve parents", "no valid pair");
    return nil;
  end;

  return parents;
end

---@param mapPalEgg UPalMapObjectPalEggModel
---@return boolean
function BreedFarm:isMapPalEggInsideFarm(mapPalEgg) 
  if not self:IsValid() then return false end;

  local eggs = self.model.SpawnedEggInstanceIds;

  for i = 1, #eggs, 1 do
    if Helpers:IsEqualGuid(mapPalEgg.ModelInstanceId, eggs[i]) then
      return true;
    end;
  end;

  return false;
end

-- Make the breeding process complete immediately for testing purposes
-- Only need to be called once per game session
function BreedFarm:SetInstantBreedingTime()
  if self:IsValid() then
    Log:Info(self, "Setting instant breeding process");
    self.model.BreedRequiredRealTime = 0;
  end;
end


return BreedFarm;