local Helpers = require("PalPurebredRework/Utils/Helpers");
local Log = require("PalPurebredRework/Utils/Log");

---@class EggHatcher
local EggHatcher = {};

---@param session GameSession
---@param model UPalMapObjectHatchingEggModel
function EggHatcher:New(session, model)
  ---@class EggHatcher
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.session = session;

  ---@private
  instance.model = model;

  ---@private
  instance.id = Helpers:ToStringGuid(model.ModelInstanceId);

  return instance;
end

function EggHatcher:__tostring() return "EggHatcher "..self.id end

function EggHatcher:GetId() return self.id end

function EggHatcher:IsValid() return self.model:IsValid() end

---@return boolean | nil
function EggHatcher:IsElectric() 
  if not self:IsValid() then return nil end;
  return self.model:GetEnergyModule():CanConsumeEnergy();
end

---@private
---@return UPalItemSlot | nil
function EggHatcher:GetContent()
  if not self:IsValid() then
    Log:Error(self, "GetContent Failed", "instance not valid");
    return nil;
  end

  local container = self.model:GetItemContainerModule():GetContainer();
  if not container:IsValid() or container:IsEmpty() then
    Log:Error(self, "GetContent Failed", "container not valid or empty");
    return nil;
  end;

  local content = container:Get(0);
  if not content then
    Log:Error(self, "GetContent Failed", "no content find");
    return nil;
  end

  return content;
end

---@return BreedEgg | nil
function EggHatcher:UpdateEggStatsWithBreedEgg()
  if not self:IsValid() then
    Log:Error(self, "Failed to update egg stats", "invalid instance");
    return nil;
  end;

  local content = self:GetContent();
  if not content then
    Log:Error(self, "Failed to update egg stats", "no content find");
    return nil;
  end;

  local eggId = content.DynamicItemData:GetId().LocalIdInCreatedWorld;
  local egg = self.session:GetBreedEggManager():GetByInstanceId(eggId);
  if not egg then
    Log:Error(self, "Failed to update egg stats", "egg not found");
    return nil;
  end;

  local eggIVs = egg:GetIVs();
  local eggPassives = egg:GetPassives();
  if not eggIVs or not eggPassives then
    Log:Error(self, "Failed to update egg stats", "egg stats not found");
    return nil;
  end

  local stats = self.model.HatchedCharacterSaveParameter;

  -- Update IVs
  stats.Talent_HP = eggIVs.hp;
  stats.Talent_Shot = eggIVs.shot;
  stats.Talent_Melee = eggIVs.melee;
  stats.Talent_Defense = eggIVs.defense;

  -- Update Passives
  ---@type FName[]
  local updatedPassives = {};
  for i = 1, #eggPassives do updatedPassives[i] = FName(eggPassives[i]) end;

  Helpers:ReplaceTArrayWith(stats.PassiveSkillList, updatedPassives);

  Log:Info(self, "Egg stats updated");
  return egg;
end

return EggHatcher;
