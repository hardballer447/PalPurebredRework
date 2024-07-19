local EggHatcher = require("PalPurebredRework/Models/EggHatcher");
local Helpers = require("PalPurebredRework/Utils/Helpers");
local Log = require("PalPurebredRework/Utils/Log");

---@class EggHatcherManager
local EggHatcherManager = {};

---@param session GameSession
function EggHatcherManager:New(session)
  ---@class EggHatcherManager
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.session = session;

  ---@private
  ---@type EggHatcherRegistry
  instance.hatchers = {};

  ---@private
  ---@type number
  instance.instanceSinceLastValidation = 0;

  ---@private
  ---@type number
  instance.maxInstanceBeforeValidation = 20;

  return instance;
end

function EggHatcherManager:__tostring() return "EggHatcherManager" end

---@param id FGuid
---@return EggHatcher | nil
function EggHatcherManager:GetByInstanceId(id)
  if not Helpers:IsValidGuid(id) then
    Log:Error(self, "Failed to find by instance id", "invalid guid");
    return nil;
  end;

  local hatcher = self.hatchers[Helpers:ToStringGuid(id)];

  if not hatcher then
    Log:Error(self, "Failed to find by instance id", "no instance found");
    return nil;
  end;

  if not hatcher:IsValid() then
    Log:Error(self, "Failed to find by instance id", "invalid instance");
    return nil;
  end;

  return hatcher;
end

---@private
function EggHatcherManager:ValidateInstances()
  -- No validation needed
  if self.instanceSinceLastValidation < self.maxInstanceBeforeValidation then return end;

  ---@type EggHatcherRegistry
  local refresh = {};
  local removed = 0;

  for id, hatcher in pairs(self.hatchers) do
    if hatcher:IsValid() then refresh[id] = hatcher else removed = removed + 1 end;
  end;

  self.instanceSinceLastValidation = 0;
  self.hatchers = refresh;

  Log:Info(self, "Validation completed", "removed instances "..removed);
end

---@param hatchingEggModel UPalMapObjectHatchingEggModel
function EggHatcherManager:ProcessNewHatchingEggModel(hatchingEggModel)
  if not hatchingEggModel:IsValid() then
    Log:Error(self, "Failed to process new HatchingEggModel, object is not valid");
    return;
  end;

  if not Helpers:IsValidGuid(hatchingEggModel.ModelInstanceId) then
    Log:Error(self, "Failed to process new HatchingEggModel", "id is not valid");
    return;
  end;

  -- Validate existing instances before adding a new one
  self:ValidateInstances();

  local hatcher = EggHatcher:New(self.session, hatchingEggModel);
  self.instanceSinceLastValidation = self.instanceSinceLastValidation + 1;
  self.hatchers[hatcher:GetId()] = hatcher;
end


return EggHatcherManager;
