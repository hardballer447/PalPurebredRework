local GameSession = require("PalPurebredRework/GameSession");

RegisterHook("/Script/Engine.PlayerController:ServerAcknowledgePossession", function()
  GameSession:OnServerAcknowledgePossession();
end);

RegisterHook("/Script/Pal.PalMapObjectHatchingEggModel:OnFinishWorkInServer", function(_, workParam)
  ---@diagnostic disable-next-line: undefined-field
  local work = workParam:get() --[[@as UPalWorkBase ]];

  -- Wait for the HatchedCharacterSaveParameter to properly load
  ExecuteAsync(function()
    GameSession:GetPurebredLogic():ProcessNewHatchingWorkDone(work);
  end);
end);

NotifyOnNewObject("/Script/Engine.PlayerController", function()
  GameSession:OnNewPlayerController();
end);

---@param palICP UPalIndividualCharacterParameter
---@diagnostic disable-next-line: redundant-parameter
NotifyOnNewObject("/Script/Pal.PalIndividualCharacterParameter", function(palICP)
  -- Wait for the InstanceId to properly load
  ExecuteAsync(function()
    GameSession:GetPalIndividualCPManager():ProcessNewPalIndividualCP(palICP);
  end);
end);

---@param breedFarm UPalMapObjectBreedFarmModel
---@diagnostic disable-next-line: redundant-parameter
NotifyOnNewObject("/Script/Pal.PalMapObjectBreedFarmModel", function(breedFarm)
  -- Wait for the InstanceId to properly load
  ExecuteAsync(function()
    GameSession:GetBreedFarmManager():ProcessNewBreedFarm(breedFarm);
  end);
end);

---@param hatcher UPalMapObjectHatchingEggModel
---@diagnostic disable-next-line: redundant-parameter
NotifyOnNewObject("/Script/Pal.PalMapObjectHatchingEggModel", function(hatcher)
  -- Wait for the InstanceId to properly load
  ExecuteAsync(function()
    GameSession:GetEggHatcherManager():ProcessNewHatchingEggModel(hatcher);
  end);
end);

---@param palEgg UPalMapObjectPalEggModel
---@diagnostic disable-next-line: redundant-parameter
NotifyOnNewObject("/Script/Pal.PalMapObjectPalEggModel", function(palEgg) 
  -- No need to process the eggs created on game start
  if not GameSession:IsLoadingDone() then return end;

  -- Wait for the breed farm to properly register the new egg
  ExecuteWithDelay(500, function()
    GameSession:GetBreedFarmManager():ProcessNewMapPalEggModel(palEgg);
  end);
end);