local Helpers = require("PalPurebredRework/Utils/Helpers");
local Log = require("PalPurebredRework/Utils/Log");

---@class PalIndividualCP
local PalIndividualCP = {};

---@param session GameSession
---@param model UPalIndividualCharacterParameter
function PalIndividualCP:New(session, model)
  ---@class PalIndividualCP
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.session = session;

  ---@private
  instance.model = model;

  ---@private
  instance.id = Helpers:ToStringGuid(model.IndividualId.InstanceId);

  return instance;
end

function PalIndividualCP:__tostring() return "PalIndividualCP: "..self.id end

function PalIndividualCP:GetId() return self.id end

function PalIndividualCP:IsValid() return self.model:IsValid() end

function PalIndividualCP:GetCharacterId() 
  if not self:IsValid() then 
    Log:Error(self, "Failed to retrieve character id", "invalid instance");
    return nil;
  end;
  return self.model.SaveParameter.CharacterID:ToString();
end

---@return PalIVs | nil
function PalIndividualCP:GetIVs()
  if not self:IsValid() then
    Log:Error(self, "Failed to retrieve ivs", "invalid instance");
    return nil;
  end;

  ---@type PalIVs
  local ivs = {
    hp = self.model.SaveParameter.Talent_HP,
    shot = self.model.SaveParameter.Talent_Shot,
    melee = self.model.SaveParameter.Talent_Melee,
    defense = self.model.SaveParameter.Talent_Defense,
  };

  return ivs;
end

---@return string[] | nil
function PalIndividualCP:GetPassives()
  if not self:IsValid() then
    Log:Error(self, "Failed to retrieve passives", "invalid instance");
    return nil;
  end;

  ---@type string[]
  local passives = {};
  local passivesData = self.model.SaveParameter.PassiveSkillList;

  for i = 1, #passivesData do passives[i] = passivesData[i]:ToString() end;

  return passives;
end

return PalIndividualCP;