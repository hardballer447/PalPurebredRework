local Log = require("PalPurebredRework/Utils/Log");

local FILE_PATH = "./Mods/PalPurebredRework/Scripts/PalPurebredRework/UserData/";

--- Saving utility
---@class UserData
local UserData = {};

---@string
function UserData:New(fileName)
  ---@class UserData
  local instance = setmetatable({}, self);
  self.__index = self;

  ---@private
  instance.fileName = fileName;

  return instance;
end

function UserData:__tostring() return "UserData "..self.fileName end

---@param data string[]
function UserData:Save(data)
  local file = io.open(FILE_PATH..self.fileName, "w+");
  if not file then
    Log:Error(self, "Failed to save data", "can't open file");
    return;
  end;

  local dataStr = "";
  for i = 1, #data do dataStr = dataStr..data[i].."\n" end;

  file:write(dataStr);
  file:close();
end

---@private
function UserData:HasFile() 
  local f = io.open(FILE_PATH..self.fileName, "rb")
  if f then f:close() end
  return f ~= nil;
end

---@return string[]
function UserData:Load() 
  if not self:HasFile() then return {} end;

  local lines = {};
  for line in io.lines(FILE_PATH..self.fileName) do
    Log:Info(self, line);
    lines[#lines + 1] = line
  end
  return lines;
end

return UserData;