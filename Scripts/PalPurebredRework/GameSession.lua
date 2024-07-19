local config = require("config");
local PurebredLogic = require("PalPurebredRework/Logics/PurebredLogic");
local BreedEggManager = require("PalPurebredRework/Models/BreedEggManager");
local BreedFarmManager = require("PalPurebredRework/Models/BreedFarmManager");
local EggHatcherManager = require("PalPurebredRework/Models/EggHatcherManager");
local PalIndividualCPManager = require("PalPurebredRework/Models/PalIndividualCPManager");
local Log = require("PalPurebredRework/Utils/Log");


---@class GameSession
local GameSession = {};

---@private
function GameSession:New()
  ---@class GameSession
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.isInGame = false;

  ---@private
  instance.isGameLoadingDone = false;

  ---@private
  ---@type number
  instance.startedAt = nil;

  ---@private
  instance.isDebug = config.is_debug_session;

  ---@private
  ---@type PurebredLogic
  instance.purebredLogic = nil;

  ---@private
  ---@type BreedEggManager
  instance.breedEggManager = nil;

  ---@private
  ---@type BreedFarmManager
  instance.breedFarmManager = nil;

  ---@private
  ---@type EggHatcherManager
  instance.eggHatcherManager = nil;

  ---@private
  ---@type PalIndividualCPManager
  instance.palIndividualCPManager = nil;

  return instance;
end

function GameSession:__tostring() return "GameSession" end

function GameSession:IsDebugSession() return self.isDebug end

function GameSession:GetPurebredLogic() return self.purebredLogic end

function GameSession:GetBreedEggManager() return self.breedEggManager end

function GameSession:GetBreedFarmManager() return self.breedFarmManager end

function GameSession:GetEggHatcherManager() return self.eggHatcherManager end

function GameSession:GetPalIndividualCPManager() return self.palIndividualCPManager end

-- Is the game initial loading done ?
---@return boolean
function GameSession:IsLoadingDone()
  -- Consider the loading completed 10 seconds after the game started
  if not self.isGameLoadingDone then
    self.isGameLoadingDone = (os.time() - self.startedAt) > 10;
  end;
  return self.isGameLoadingDone;
end

---@private
function GameSession:Init()
  self.isInGame = true;
  self.startedAt = os.time();
  self.purebredLogic = PurebredLogic:New(self);
  self.breedEggManager = BreedEggManager:New(self);
  self.breedFarmManager = BreedFarmManager:New(self);
  self.eggHatcherManager = EggHatcherManager:New(self);
  self.palIndividualCPManager = PalIndividualCPManager:New(self);
end

---@private
function GameSession:Reset()
  self.isInGame = false;
  self.isGameLoadingDone = false;
  self.purebredLogic = nil;
  self.breedEggManager = nil;
  self.breedFarmManager = nil;
  self.eggHatcherManager = nil;
  self.palIndividualCPManager = nil;
end

function GameSession:OnNewPlayerController()
  -- A player controller is created each time the player lands to the title screen or launch a new game
  -- So a new controller while in game means the user has just left the game
  if self.isInGame then
    Log:Info(self, "Game exited");
    self:Reset();
  end;
end

function GameSession:OnServerAcknowledgePossession()
  -- Acknowledgement can only happens while in game but will triggers a lot of times 
  -- Like if the player mount a pal then go on foot thats 2 acknowledgements
  -- For our need we only consider the first one per game session
  if not self.isInGame then
    Log:Info(self, "New game started");
    self:Init();
  end;
end


return GameSession:New();