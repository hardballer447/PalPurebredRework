local Helpers = require("PalPurebredRework/Utils/Helpers");
local Log = require("PalPurebredRework/Utils/Log");

---@class BreedEgg
local BreedEgg = {};


---@param session GameSession
function BreedEgg:New(session)
  ---@class BreedEgg
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.session = session;

  ---@private
  ---@type string
  instance.id = nil;

  ---@private
  ---@type PalIVs
  instance.ivs = nil;

  ---@private
  ---@type string[]
  instance.passives = nil;

  return instance;
end

function BreedEgg:__tostring() return "BreedEgg "..self.id end

function BreedEgg:IsValid()
  return self.id ~= nil
    and self.ivs ~= nil
    and self.passives ~= nil;
end

function BreedEgg:GetId() return self.id end

function BreedEgg:GetIVs()
  if not self:IsValid() then
    Log:Error(self, "Failed to retrieve IVs", "invalid instance");
    return nil;
  end;
  return self.ivs;
end

function BreedEgg:GetPassives()
  if not self:IsValid() then
    Log:Error(self, "Failed to retrieve passives", "invalid instance");
    return nil;
  end;
  return self.passives;
end

---@return string | nil
function BreedEgg:GetSaveString()
  if not self:IsValid() then
    Log:Error(self, "Failed to retrieve save string", "invalid instance");
    return nil;
  end;

  ---@type string[]
  local values = {
    self.id,
    tostring(self.ivs.hp),
    tostring(self.ivs.shot),
    tostring(self.ivs.melee),
    tostring(self.ivs.defense),
  };

  for i = 1, #self.passives do table.insert(values, self.passives[i]) end;

  return table.concat(values, ";");
end

---@private
---@param mapPalEgg UPalMapObjectPalEggModel
---@return UPalDynamicPalEggItemDataBase | nil
function BreedEgg:GetMapPalEggData(mapPalEgg)
  if not mapPalEgg:IsValid() then
    Log:Error(self, "Failed to retrieve MapPalEgg data", "invalid mapPalEgg");
    return nil;
  end;

  local container = mapPalEgg:GetItemContainerModule():GetContainer();
  if not container:IsValid() or container:IsEmpty() then
    Log:Error(self, "Failed to retrieve MapPalEgg data", "invalid container");
    return nil;
  end

  local eggData = container:Get(0).DynamicItemData --[[@as UPalDynamicPalEggItemDataBase ]];
  if not eggData:IsValid() then
    Log:Error(self, "Failed to retrieve MapPalEgg data", "invalid egg data");
    return nil;
  end;

  return eggData;
end

---@param data string[]
function BreedEgg:InitFromUserData(data)
  self.id = data[1];

  self.ivs = {
    hp = tonumber(data[2]) or 0,
    shot = tonumber(data[3]) or 0,
    melee = tonumber(data[4]) or 0,
    defense = tonumber(data[5]) or 0,
  };

  self.passives = {};
  for i = 6, #data do table.insert(self.passives, data[i]) end;

  return self;
end

---@param parents PalIndividualCP[]
---@param mapPalEgg UPalMapObjectPalEggModel
---@return BreedEgg
function BreedEgg:InitFromGameData(parents, mapPalEgg)
  local eggData = self:GetMapPalEggData(mapPalEgg);
  if not eggData then
    Log:Error("Failed to init BreedEgg from game data", "invalid egg data");
    return self;
  end;

  local ivsA = parents[1]:GetIVs();
  local ivsB = parents[2]:GetIVs();
  if not ivsA or not ivsB then
    Log:Error("Failed to init BreedEgg from game data", "invalid parents IVs");
    return self;
  end

  local passivesA = parents[1]:GetPassives();
  local passivesB = parents[2]:GetPassives();
  if not passivesA or not passivesB then
    Log:Error("Failed to init BreedEgg from game data", "invalid parents passives");
    return self;
  end

  ---@type PalIVs
  local eggIVs = {
    hp = eggData.SaveParameter.Talent_HP,
    shot = eggData.SaveParameter.Talent_Shot,
    melee = eggData.SaveParameter.Talent_Melee,
    defense = eggData.SaveParameter.Talent_Defense,
  };

  local purebredLogic = self.session:GetPurebredLogic();

  self.ivs = purebredLogic:ComputeIVs(ivsA, ivsB, eggIVs);
  self.passives = purebredLogic:ComputePassives(passivesA, passivesB);
  self.id = Helpers:ToStringGuid(eggData:GetId().LocalIdInCreatedWorld);

  return self;
end

return BreedEgg;