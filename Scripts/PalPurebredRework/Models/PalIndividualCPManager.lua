local PalIndividualCP = require("PalPurebredRework/Models/PalIndividualCP");
local Helpers = require("PalPurebredRework/Utils/Helpers");
local Log = require("PalPurebredRework/Utils/Log");

---@class PalIndividualCPManager
local PalIndividualCPManager = {};

---@param session GameSession
function PalIndividualCPManager:New(session)
  ---@class PalIndividualCPManager
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.session = session;

  ---@private
  ---@type PalIndividualCPRegistry
  instance.pals = {};

  ---@private
  ---@type number
  instance.instanceSinceLastValidation = 0;

  ---@private
  ---@type number
  instance.maxInstanceBeforeValidation = 1200;

  return instance;
end

---@return string
function PalIndividualCPManager:__tostring() return "PalIndividualCPManager" end

---@private
function PalIndividualCPManager:ValidateInstances()
  -- No validation needed
  if self.instanceSinceLastValidation < self.maxInstanceBeforeValidation then return end;

  ---@type PalIndividualCPRegistry
  local refresh = {};
  local removed = 0;

  for id, pal in pairs(self.pals) do
    if pal:IsValid() then refresh[id] = pal else removed = removed + 1 end;
  end;

  self.instanceSinceLastValidation = 0;
  self.pals = refresh;

  Log:Info(self, "Validation completed", "removed instances "..removed);
end

---@param id FGuid
function PalIndividualCPManager:GetByInstanceId(id)
  if not Helpers:IsValidGuid(id) then
    Log:Error(self, "Failed to find by instance id", "invalid guid");
    return nil;
  end;

  local pal = self.pals[Helpers:ToStringGuid(id)];

  if not pal then
    Log:Error(self, "Failed to find by instance id", "no instance found");
    return nil;
  end;

  if not pal:IsValid() then
    Log:Error(self, "Failed to find by instance id", "invalid instance");
    return nil;
  end;

  return pal;
end

---@param palICP UPalIndividualCharacterParameter
function PalIndividualCPManager:ProcessNewPalIndividualCP(palICP)
  if not palICP:IsValid() then
    Log:Error(self, "Failed to process new PalIndividualCP", "object is not valid");
    return;
  end;

  if not Helpers:IsValidGuid(palICP.IndividualId.InstanceId) then
    Log:Error(self, "Failed to process new PalIndividualCP", "id is not valid");
    return;
  end;

  -- Validate existing instances before adding a new one
  self:ValidateInstances();

  local pal = PalIndividualCP:New(self.session, palICP);
  self.instanceSinceLastValidation = self.instanceSinceLastValidation + 1;
  self.pals[pal:GetId()] = pal;
end


return PalIndividualCPManager;