local Helpers = require("PalPurebredRework/Utils/Helpers");
local Log = require("PalPurebredRework/Utils/Log");

---@class PurebredLogic
local PurebredLogic = {};

---@param session GameSession
function PurebredLogic:New(session)
  ---@class PurebredLogic
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.session = session;

  ---@private
  instance.maxIV = 100;

  ---@private
  instance.maxPassives = 4;

  return instance;
end

function PurebredLogic:__tostring() return "PurebredLogic" end;

---@param parentA PalIVs
---@param parentB PalIVs
---@param egg PalIVs
function PurebredLogic:ComputeIVs(parentA, parentB, egg)
  -- Initial values keeping the higher from both parents
  ---@type PalIVs
  local ivs = {
    hp = math.max(parentA.hp, parentB.hp),
    shot = math.max(parentA.shot, parentB.shot),
    defense = math.max(parentA.defense, parentB.defense),
    melee = math.max(parentA.melee, parentB.melee),
  };

  for name, value in pairs(ivs) do
    -- Use the egg randomized value if better
    -- Limitting to a gain between +1 and +5 (half an iv fruit) to keep it fair
    if egg[name] > value then
      value = math.min(egg[name], value + 5);
    end;

    -- make sure we don't go over the limit
    ivs[name] = math.min(value, self.maxIV);

    Log:Info(self, "Computed IVS value for "..name, ivs[name]);
  end;

  return ivs;
end

---@param parentA string[]
---@param parentB string[]
---@return string[]
function PurebredLogic:ComputePassives(parentA, parentB)
  if #parentA == 0 and #parentB == 0 then
    Log:Info("No passives from parents to compute");
    return {};
  end;

  ---@type { [string]: boolean }
  local dedupe = {};
  for i = 1, #parentA do dedupe[parentA[i]] = true end;
  for i = 1, #parentB do dedupe[parentB[i]] = true end;

  ---@types string[]
  local passives = {};
  for value, _ in pairs(dedupe) do table.insert(passives, value) end;

  if #passives > 4 then
    Helpers:ShuffleArray(passives);

    ---@types string[]
    local sliced = {};
    for i = 1, self.maxPassives do sliced[i] = passives[i] end;

    passives = sliced;
  end

  if Log:IsInfoEnabled() then
    for i = 1, #passives do Log:Info(self, "Computed passive #"..i, passives[i]) end;
  end;

  return passives;
end

---@param farm BreedFarm
---@param mapPalEgg UPalMapObjectPalEggModel
function PurebredLogic:ProcessNewBreedFarmEgg(farm, mapPalEgg) 
  local parents = farm:GetParents();
  if not parents or not #parents == 2 then
    Log:Error(self, "Failed to process new BreedEgg", "no parents found");
    return;
  end;

  -- Check if same species
  local idA = parents[1]:GetCharacterId();
  local idB = parents[2]:GetCharacterId();

  if not (idA and idB and idA == idB) then
    Log:Info(self, "Aborting new BreedEgg process", "Parents are not the same species");
    return false;
  end;

  self.session:GetBreedEggManager():ProcessNewBreedFarmEgg(parents, mapPalEgg);
end

---@param work UPalWorkBase
function PurebredLogic:ProcessNewHatchingWorkDone(work)
  if not work:IsValid() then
    Log:Error(self, "Failed to process new HatchingWorkDone", "work object not valid");
    return;
  end

  if not Helpers:IsValidGuid(work.OwnerMapObjectModelId) then
    Log:Error(self, "Failed to process new HatchingWorkDone", "work id not valid");
    return;
  end;

  local hatcher = self.session:GetEggHatcherManager():GetByInstanceId(work.OwnerMapObjectModelId);
  if not hatcher then
    Log:Error(self, "Failed to process new HatchingWorkDone", "instance not found");
    return;
  end;

  local isElectric = hatcher:IsElectric();
  if isElectric == nil then
    Log:Error(self, "Failed to process new HatchingWorkDone", "isElectric nil");
    return;
  end;

  if not isElectric then
    Log:Info(self, "Aborting new HatchingWorkDone process", "Hatcher is not electric");
    return;
  end;

  local usedBreedEgg = hatcher:UpdateEggStatsWithBreedEgg();
  if usedBreedEgg then
    Log:Info(self, "Successful egg update on hatching");
    self.session:GetBreedEggManager():Delete(usedBreedEgg);
  else
    Log:Error(self, "Failed to update egg stats on HatchingWorkDone");
  end;
end


return PurebredLogic;
